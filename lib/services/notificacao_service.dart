import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show PlatformException;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest_all.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

import '../models/modelos.dart';

/// Lembretes locais dos compromissos: 30 min antes e na hora do início.
///
/// Nada aqui vai ao servidor: a preferência "lembrete ligado/desligado" de
/// cada compromisso fica em SharedPreferences, neste aparelho. Toda falha é
/// capturada para nunca quebrar o fluxo de salvar/excluir.
class NotificacaoService {
  NotificacaoService._();

  static final _plugin = FlutterLocalNotificationsPlugin();
  static bool _pronto = false;

  static const antecedencia = Duration(minutes: 30);
  static const _canalId = 'lembretes_compromissos';
  static const _canalNome = 'Lembretes de compromissos';

  // O iOS aceita no máximo 64 notificações pendentes (2 por compromisso).
  static const _limite = 60;

  /// Chame uma vez no main(), depois do Supabase.initialize.
  static Future<void> iniciar() async {
    if (_pronto) return;
    try {
      // Só precisamos de instantes absolutos (agendamentos únicos), então o
      // fuso "local" do pacote timezone (UTC por padrão) não altera o horário.
      tzdata.initializeTimeZones();

      const android = AndroidInitializationSettings('@mipmap/launcher_icon');
      const ios = DarwinInitializationSettings(
        requestAlertPermission: false,
        requestBadgePermission: false,
        requestSoundPermission: false,
      );
      await _plugin.initialize(
        const InitializationSettings(android: android, iOS: ios),
      );
      _pronto = true;
    } catch (e) {
      debugPrint('Erro ao iniciar notificações: $e');
    }
  }

  /// Pede permissão (Android 13+ e iOS). Seguro chamar mais de uma vez.
  static Future<void> pedirPermissao() async {
    if (!_pronto) return;
    try {
      await _plugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.requestNotificationsPermission();
      await _plugin
          .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(alert: true, badge: true, sound: true);
    } catch (e) {
      debugPrint('Erro ao pedir permissão de notificação: $e');
    }
  }

  // ---------- preferência por compromisso ----------

  static String _chave(String id) => 'lembrete_$id';

  /// Lembrete ligado? O padrão é ligado.
  static Future<bool> ativo(String id) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool(_chave(id)) ?? true;
    } catch (_) {
      return true;
    }
  }

  // ---------- agendamento ----------

  /// FNV-1a de 32 bits: id estável entre execuções (String.hashCode não é
  /// garantido) e dentro do limite de int do Android.
  static int _idNotificacao(String compromissoId) {
    var h = 0x811C9DC5;
    for (final u in compromissoId.codeUnits) {
      h ^= u;
      h = (h * 0x01000193) & 0xFFFFFFFF;
    }
    return h & 0x7FFFFFFF;
  }

  static String _hm(DateTime d) =>
      '${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';

  static const _detalhes = NotificationDetails(
    android: AndroidNotificationDetails(
      _canalId,
      _canalNome,
      channelDescription: 'Aviso antes e na hora de cada compromisso',
      importance: Importance.high,
      priority: Priority.high,
    ),
    iOS: DarwinNotificationDetails(),
  );

  static Future<void> _programar(
    int id,
    String titulo,
    String corpo,
    DateTime quando,
  ) async {
    final data = tz.TZDateTime.from(quando, tz.local);
    try {
      // Alarme exato: dispara no minuto certo mesmo com o app fechado e o
      // aparelho em Doze. Exige USE_EXACT_ALARM no manifest.
      await _plugin.zonedSchedule(
        id,
        titulo,
        corpo,
        data,
        _detalhes,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      );
    } on PlatformException catch (e) {
      // Sem permissão de alarme exato: cai para o modo inexato (pode atrasar).
      debugPrint('Alarme exato indisponível, usando inexato: $e');
      await _plugin.zonedSchedule(
        id,
        titulo,
        corpo,
        data,
        _detalhes,
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      );
    }
  }

  /// Agenda o aviso de 30 min antes e o aviso na hora do início.
  /// Devolve quantas notificações foram agendadas (as que já passaram são
  /// ignoradas).
  static Future<int> _agendar(Compromisso c) async {
    if (!_pronto) return 0;
    final agora = DateTime.now();
    var n = 0;

    final antes = c.inicio.subtract(antecedencia);
    if (antes.isAfter(agora)) {
      await _programar(
        _idNotificacao(c.id),
        c.titulo,
        'Começa às ${_hm(c.inicio)} · daqui a ${antecedencia.inMinutes} minutos',
        antes,
      );
      n++;
    }

    if (c.inicio.isAfter(agora)) {
      await _programar(
        _idNotificacao('${c.id}#inicio'),
        c.titulo,
        'Começa agora · ${_hm(c.inicio)}',
        c.inicio,
      );
      n++;
    }
    return n;
  }

  static Future<void> _cancelar(String id) async {
    if (!_pronto) return;
    await _plugin.cancel(_idNotificacao(id));
    await _plugin.cancel(_idNotificacao('$id#inicio'));
  }

  /// Grava a preferência e agenda (ou cancela) o lembrete do compromisso.
  /// Chamar ao criar, editar ou alternar o toggle. Reagendar sobrescreve o
  /// lembrete antigo (mesmo id), então editar o horário já funciona.
  static Future<void> aplicar(Compromisso c, {required bool ativo}) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_chave(c.id), ativo);
      await _cancelar(c.id);
      if (ativo) await _agendar(c);
    } catch (e) {
      debugPrint('Erro ao aplicar lembrete: $e');
    }
  }

  /// Ao excluir o compromisso.
  static Future<void> remover(String id) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_chave(id));
      await _cancelar(id);
    } catch (e) {
      debugPrint('Erro ao remover lembrete: $e');
    }
  }

  /// Refaz todos os lembretes a partir dos próximos compromissos (cobre
  /// edições/exclusões feitas em outro aparelho e reinstalações).
  static Future<void> sincronizar(List<Compromisso> proximos) async {
    if (!_pronto) return;
    try {
      await _plugin.cancelAll();
      var n = 0;
      for (final c in proximos) {
        if (n >= _limite) break;
        if (!await ativo(c.id)) continue;
        n += await _agendar(c);
      }
    } catch (e) {
      debugPrint('Erro ao sincronizar lembretes: $e');
    }
  }

  /// Ao sair da conta: outra conta no mesmo aparelho não pode receber avisos.
  static Future<void> cancelarTodas() async {
    if (!_pronto) return;
    try {
      await _plugin.cancelAll();
    } catch (e) {
      debugPrint('Erro ao cancelar lembretes: $e');
    }
  }
}
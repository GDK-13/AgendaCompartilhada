import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show PlatformException;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest_all.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

import '../models/modelos.dart';

/// Lembretes locais dos compromissos, no estilo Google Agenda: cada compromisso
/// tem uma lista de avisos, cada um com sua antecedência em minutos (0 = na
/// hora do início). A lista vai de 0 a [maxPorCompromisso] avisos.
///
/// Nada aqui vai ao servidor: a lista de cada compromisso fica em
/// SharedPreferences, neste aparelho. Toda falha é capturada para nunca
/// quebrar o fluxo de salvar/excluir.
class NotificacaoService {
  NotificacaoService._();

  static final _plugin = FlutterLocalNotificationsPlugin();
  static bool _pronto = false;

  /// Lista usada em compromissos novos: 30 min antes e na hora do início.
  static const padrao = [30, 0];

  /// Máximo de avisos por compromisso (igual ao Google Agenda).
  static const maxPorCompromisso = 5;

  /// Maior antecedência aceita: 4 semanas, em minutos.
  static const maxMinutos = 4 * 7 * 24 * 60;

  static const _canalId = 'lembretes_compromissos';
  static const _canalNome = 'Lembretes de compromissos';

  // O iOS aceita no máximo 64 notificações pendentes; ao sincronizar ficam as
  // 60 mais próximas no tempo.
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

  static String _chave(String id) => 'lembretes_$id';

  // Formato antigo: bool "lembrete ligado" (30 min antes + na hora).
  static String _chaveLegada(String id) => 'lembrete_$id';

  /// Remove duplicatas e valores inválidos; ordena do mais distante ao mais
  /// próximo do início (como o Google Agenda) e respeita o máximo.
  static List<int> normalizar(Iterable<int> minutos) {
    final l = minutos.where((m) => m >= 0 && m <= maxMinutos).toSet().toList()
      ..sort((a, b) => b.compareTo(a));
    return l.take(maxPorCompromisso).toList();
  }

  /// Antecedências (em minutos) configuradas para o compromisso. Lista vazia
  /// = sem lembretes. Compromissos antigos são migrados do formato bool.
  static Future<List<int>> lembretes(String id) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final salvo = prefs.getStringList(_chave(id));
      if (salvo != null) {
        return normalizar(salvo.map(int.tryParse).whereType<int>());
      }
      if (prefs.getBool(_chaveLegada(id)) == false) return [];
      return List.of(padrao);
    } catch (_) {
      return List.of(padrao);
    }
  }

  /// "Na hora do início", "30 minutos antes", "1 hora antes", "2 dias antes"...
  static String rotulo(int minutos) =>
      minutos == 0 ? 'Na hora do início' : '${_quanto(minutos)} antes';

  static String _quanto(int m) {
    String un(int n, String s, String p) => '$n ${n == 1 ? s : p}';
    if (m % (7 * 24 * 60) == 0) return un(m ~/ (7 * 24 * 60), 'semana', 'semanas');
    if (m % (24 * 60) == 0) return un(m ~/ (24 * 60), 'dia', 'dias');
    if (m % 60 == 0) return un(m ~/ 60, 'hora', 'horas');
    return un(m, 'minuto', 'minutos');
  }

  // ---------- agendamento ----------

  /// FNV-1a de 32 bits: id estável entre execuções (String.hashCode não é
  /// garantido) e dentro do limite de int do Android.
  static int _idNotificacao(String chave) {
    var h = 0x811C9DC5;
    for (final u in chave.codeUnits) {
      h ^= u;
      h = (h * 0x01000193) & 0xFFFFFFFF;
    }
    return h & 0x7FFFFFFF;
  }

  static int _idAviso(String compromissoId, int minutos) =>
      _idNotificacao('$compromissoId#$minutos');

  static String _hm(DateTime d) =>
      '${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';

  static const _detalhes = NotificationDetails(
    android: AndroidNotificationDetails(
      _canalId,
      _canalNome,
      channelDescription: 'Avisos antes e na hora de cada compromisso',
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

  static Future<void> _programarAviso(Compromisso c, int minutos) {
    final corpo = minutos == 0
        ? 'Começa agora · ${_hm(c.inicio)}'
        : 'Começa às ${_hm(c.inicio)} · daqui a ${_quanto(minutos)}';
    return _programar(
      _idAviso(c.id, minutos),
      c.titulo,
      corpo,
      c.inicio.subtract(Duration(minutes: minutos)),
    );
  }

  /// Agenda os avisos de [minutos] do compromisso. Avisos que já passaram são
  /// ignorados. Devolve quantos foram agendados.
  static Future<int> _agendar(Compromisso c, List<int> minutos) async {
    if (!_pronto) return 0;
    final agora = DateTime.now();
    var n = 0;
    for (final m in minutos) {
      if (!c.inicio.subtract(Duration(minutes: m)).isAfter(agora)) continue;
      await _programarAviso(c, m);
      n++;
    }
    return n;
  }

  static Future<void> _cancelar(String id, Iterable<int> minutos) async {
    if (!_pronto) return;
    for (final m in minutos) {
      await _plugin.cancel(_idAviso(id, m));
    }
    // ids do formato antigo (30 min antes e "#inicio")
    await _plugin.cancel(_idNotificacao(id));
    await _plugin.cancel(_idNotificacao('$id#inicio'));
  }

  /// Grava a lista de avisos e reagenda o compromisso. Chamar ao criar,
  /// editar ou mudar os lembretes. Lista vazia = sem lembretes.
  static Future<void> aplicar(
    Compromisso c, {
    required List<int> minutos,
  }) async {
    try {
      final novos = normalizar(minutos);
      final antigos = await lembretes(c.id);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList(_chave(c.id), novos.map((m) => '$m').toList());
      await prefs.remove(_chaveLegada(c.id));
      await _cancelar(c.id, {...antigos, ...novos});
      await _agendar(c, novos);
    } catch (e) {
      debugPrint('Erro ao aplicar lembretes: $e');
    }
  }

  /// Ao excluir o compromisso.
  static Future<void> remover(String id) async {
    try {
      final antigos = await lembretes(id);
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_chave(id));
      await prefs.remove(_chaveLegada(id));
      await _cancelar(id, antigos);
    } catch (e) {
      debugPrint('Erro ao remover lembretes: $e');
    }
  }

  /// Refaz todos os lembretes a partir dos próximos compromissos (cobre
  /// edições/exclusões feitas em outro aparelho e reinstalações). Se passar do
  /// limite do sistema, ficam os avisos mais próximos no tempo.
  static Future<void> sincronizar(
    List<Compromisso> proximos, {
    List<Grupo> grupos = const [],
  }) async {
    if (!_pronto) return;
    try {
      await _plugin.cancelAll();
      final agora = DateTime.now();
      final avisos = <({DateTime quando, Compromisso c, int minutos})>[];
      for (final c in proximos) {
        for (final m in await lembretes(c.id)) {
          final quando = c.inicio.subtract(Duration(minutes: m));
          if (quando.isAfter(agora)) {
            avisos.add((quando: quando, c: c, minutos: m));
          }
        }
      }
      avisos.sort((a, b) => a.quando.compareTo(b.quando));
      for (final a in avisos.take(_limite)) {
        await _programarAviso(a.c, a.minutos);
      }
      for (final g in grupos) {
        await agendarExclusaoGrupo(g);
      }
    } catch (e) {
      debugPrint('Erro ao sincronizar lembretes: $e');
    }
  }

  // ---------- grupos ----------

  /// Mostra na hora uma notificação (aviso vindo do servidor, ex.: "Ana saiu
  /// do grupo"). [chave] é o id do aviso, para não duplicar.
  static Future<void> mostrarAgora(
    String chave,
    String titulo,
    String corpo,
  ) async {
    if (!_pronto) return;
    try {
      await _plugin.show(_idNotificacao('aviso#$chave'), titulo, corpo, _detalhes);
    } catch (e) {
      debugPrint('Erro ao mostrar aviso: $e');
    }
  }

  /// Avisa 24 h antes de um grupo com um só membro ser excluído. Se o grupo
  /// não tem mais prazo (alguém entrou), cancela o aviso.
  static Future<void> agendarExclusaoGrupo(Grupo g) async {
    if (!_pronto) return;
    try {
      final id = _idNotificacao('grupo#${g.id}');
      await _plugin.cancel(id);
      final fim = g.excluiEm;
      if (fim == null) return;
      final quando = fim.subtract(const Duration(days: 1));
      if (!quando.isAfter(DateTime.now())) return;
      await _programar(
        id,
        g.nome,
        'Você é o único membro: o grupo será excluído amanhã (${g.excluiEmTexto}) se ninguém entrar.',
        quando,
      );
    } catch (e) {
      debugPrint('Erro ao agendar aviso do grupo: $e');
    }
  }

  static Future<void> cancelarGrupo(String grupoId) async {
    if (!_pronto) return;
    try {
      await _plugin.cancel(_idNotificacao('grupo#$grupoId'));
    } catch (_) {}
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
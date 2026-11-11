import 'dart:async';

import 'package:app_links/app_links.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'controllers/theme_controller.dart';
import 'routes/app_routes.dart';
import 'services/auth_service.dart';
import 'services/convite_service.dart';
import 'services/erros.dart';
import 'services/grupo_service.dart';
import 'theme/agenda_theme.dart';

class AgendaApp extends StatefulWidget {
  const AgendaApp({
    super.key,
    required this.themeController,
  });

  final ThemeController themeController;

  @override
  State<AgendaApp> createState() => _AgendaAppState();
}

class _AgendaAppState extends State<AgendaApp> {
  final _navKey = GlobalKey<NavigatorState>();
  final _msgKey = GlobalKey<ScaffoldMessengerState>();
  final _links = AppLinks();

  StreamSubscription<Uri>? _linksSub;
  StreamSubscription<AuthState>? _authSub;
  String? _ultimoCodigo;
  DateTime? _ultimoEm;

  @override
  void initState() {
    super.initState();
    _iniciarLinks();
    // App aberto já com sessão salva: busca o tema da conta.
    widget.themeController.sincronizarComConta();
    _authSub = Supabase.instance.client.auth.onAuthStateChange.listen((data) {
      if (data.event == AuthChangeEvent.signedIn) {
        // Aplica o tema salvo na conta de quem acabou de entrar.
        widget.themeController.sincronizarComConta();
        final c = ConviteService.pendente;
        if (c != null) {
          ConviteService.pendente = null;
          _entrarNoGrupo(c);
        }
      } else if (data.event == AuthChangeEvent.signedOut) {
        _navKey.currentState
            ?.pushNamedAndRemoveUntil(AppRoutes.login, (_) => false);
      }
    });
  }

  Future<void> _iniciarLinks() async {
    try {
      final inicial = await _links.getInitialLink();
      if (inicial != null) _tratarLink(inicial);
    } catch (e) {
      debugPrint('Erro ao ler link inicial: $e');
    }
    _linksSub = _links.uriLinkStream.listen(_tratarLink);
  }

  void _tratarLink(Uri uri) {
    final codigo = ConviteService.extrairCodigo(uri.toString());
    if (codigo == null) return;

    if (!AuthService.logado) {
      ConviteService.pendente = codigo;
      _aviso('Entre na sua conta para aceitar o convite.');
      return;
    }
    _entrarNoGrupo(codigo);
  }

  Future<void> _entrarNoGrupo(String codigo) async {
    // Evita processar o mesmo link duas vezes (link inicial + stream).
    final agora = DateTime.now();
    if (_ultimoCodigo == codigo &&
        _ultimoEm != null &&
        agora.difference(_ultimoEm!) < const Duration(seconds: 5)) {
      return;
    }
    _ultimoCodigo = codigo;
    _ultimoEm = agora;

    try {
      await GrupoService.entrar(codigo);
      _navKey.currentState
          ?.pushNamedAndRemoveUntil(AppRoutes.home, (_) => false);
      _aviso('Você entrou no grupo!');
    } catch (e) {
      _aviso(traduzirErro(e));
    }
  }

  void _aviso(String texto) {
    _msgKey.currentState
      ?..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(texto)));
  }

  @override
  void dispose() {
    _linksSub?.cancel();
    _authSub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<AppThemeId>(
      valueListenable: widget.themeController,
      builder: (context, themeId, child) {
        return MaterialApp(
          navigatorKey: _navKey,
          scaffoldMessengerKey: _msgKey,
          debugShowCheckedModeBanner: false,
          title: 'Agenda Compartilhada',
          theme: AppThemes.build(AppThemes.byId(themeId)),
          initialRoute: Supabase.instance.client.auth.currentSession != null
              ? AppRoutes.home
              : AppRoutes.login,
          routes: AppRoutes.routes(themeController: widget.themeController),
        );
      },
    );
  }
}
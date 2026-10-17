import 'package:flutter/material.dart';

import '../routes/app_routes.dart';
import '../services/auth_service.dart';
import '../services/erros.dart';
import '../theme/agenda_theme.dart';
import '../widgets/agenda_widgets.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _email = TextEditingController();
  final _senha = TextEditingController();
  bool _carregando = false;
  String? _erro;

  @override
  void dispose() {
    _email.dispose();
    _senha.dispose();
    super.dispose();
  }

  Future<void> _entrar() async {
    if (_email.text.trim().isEmpty || _senha.text.isEmpty) {
      setState(() => _erro = 'Informe e-mail e senha.');
      return;
    }
    setState(() {
      _carregando = true;
      _erro = null;
    });
    try {
      await AuthService.entrar(_email.text, _senha.text);
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, AppRoutes.home);
    } catch (e) {
      if (mounted) setState(() => _erro = traduzirErro(e));
    } finally {
      if (mounted) setState(() => _carregando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;

    return ScreenScaffold(
      children: [
        const SizedBox(height: 52),
        const Center(child: AppMark(tamanho: 92)),
        const SizedBox(height: 24),
        Text('Agenda Compartilhada',
            textAlign: TextAlign.center, style: AgendaText.titulo(t)),
        const SizedBox(height: 8),
        Text('Entre para acessar sua agenda e seus grupos.',
            textAlign: TextAlign.center, style: AgendaText.subtitulo(t)),
        const SizedBox(height: 32),
        GlassCard(
          child: Column(
            children: [
              InsetField(
                label: 'E-mail',
                hint: 'voce@exemplo.com',
                keyboardType: TextInputType.emailAddress,
                controller: _email,
              ),
              const SizedBox(height: 16),
              InsetField(
                label: 'Senha',
                hint: 'Sua senha',
                obscure: true,
                controller: _senha,
              ),
            ],
          ),
        ),
        if (_erro != null) ...[
          const SizedBox(height: 16),
          StatusBanner(texto: _erro!, tipo: BannerTipo.erro),
        ],
        const SizedBox(height: 20),
        PrimaryButton(
          label: _carregando ? 'Entrando...' : 'Entrar',
          icone: Icons.login_rounded,
          onPressed: _carregando ? null : _entrar,
        ),
        const SizedBox(height: 12),
        GlassButton(
          label: 'Criar conta',
          onPressed: () => Navigator.pushNamed(context, AppRoutes.signup),
        ),
      ],
    );
  }
}
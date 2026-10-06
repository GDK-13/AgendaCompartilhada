import 'package:flutter/material.dart';

import '../routes/app_routes.dart';
import '../theme/agenda_theme.dart';
import '../widgets/agenda_widgets.dart';

class AuthScreen extends StatelessWidget {
  const AuthScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;

    return ScreenScaffold(
      children: [
        const SizedBox(height: 52),
        const Center(child: AppMark(tamanho: 92)),
        const SizedBox(height: 24),
        Text(
          'Agenda Compartilhada',
          textAlign: TextAlign.center,
          style: AgendaText.titulo(t),
        ),
        const SizedBox(height: 8),
        Text(
          'Entre para acessar sua agenda e seus grupos.',
          textAlign: TextAlign.center,
          style: AgendaText.subtitulo(t),
        ),
        const SizedBox(height: 32),
        const GlassCard(
          child: Column(
            children: [
              InsetField(
                label: 'E mail',
                hint: 'voce@exemplo.com',
                keyboardType: TextInputType.emailAddress,
              ),
              SizedBox(height: 16),
              InsetField(
                label: 'Senha',
                hint: 'Sua senha',
                obscure: true,
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        PrimaryButton(
          label: 'Entrar',
          icone: Icons.login_rounded,
          onPressed: () {
            Navigator.pushReplacementNamed(context, AppRoutes.home);
          },
        ),
        const SizedBox(height: 12),
        GlassButton(
          label: 'Criar conta',
          onPressed: () {},
        ),
        const SizedBox(height: 16),
        Text(
          'A autenticação é apenas visual nesta versão.',
          textAlign: TextAlign.center,
          style: AgendaText.corpoSuave(t),
        ),
      ],
    );
  }
}

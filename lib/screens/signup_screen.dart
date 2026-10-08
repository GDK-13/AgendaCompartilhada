import 'package:flutter/material.dart';

import '../routes/app_routes.dart';
import '../theme/agenda_theme.dart';
import '../widgets/agenda_widgets.dart';

class SignupScreen extends StatelessWidget {
  const SignupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;

    return ScreenScaffold(
      header: ScreenHeader(
        titulo: 'Criar conta',
        subtitulo: 'Leva menos de um minuto.',
        leading: RoundIconButton(
          icone: Icons.chevron_left_rounded,
          onTap: () => Navigator.pop(context),
        ),
      ),
      children: [
        const SizedBox(height: 22),
        GlassCard(
          child: Column(
            children: [
              InsetField(
                label: 'Nome',
                valor: 'Kevin Tiago',
                hint: 'Seu nome',
              ),
              SizedBox(height: 16),
              InsetField(
                label: 'E-mail',
                hint: 'voce@email.com',
                keyboardType: TextInputType.emailAddress,
              ),
              SizedBox(height: 16),
              InsetField(
                label: 'Senha',
                valor: '12345678',
                hint: 'Mínimo de 6 caracteres',
                obscure: true,
              ),
              SizedBox(height: 7),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Mínimo de 6 caracteres',
                  style: TextStyle(fontSize: 11),
                ),
              ),
              SizedBox(height: 18),
              PrimaryButton(
                label: 'Criar conta',
                onPressed: () => Navigator.pushReplacementNamed(
                  context,
                  AppRoutes.home,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 26),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Já tem conta? ', style: AgendaText.corpoSuave(t)),
            GestureDetector(
              onTap: () => Navigator.pushReplacementNamed(
                context,
                AppRoutes.login,
              ),
              child: Text('Entrar', style: AgendaText.link(t)),
            ),
          ],
        ),
      ],
    );
  }
}

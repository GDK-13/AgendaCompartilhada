import 'package:flutter/material.dart';

import '../routes/app_routes.dart';
import '../services/auth_service.dart';
import '../services/erros.dart';
import '../theme/agenda_theme.dart';
import '../widgets/agenda_widgets.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _nome = TextEditingController();
  final _email = TextEditingController();
  final _senha = TextEditingController();

  bool _carregando = false;
  String? _erro;

  @override
  void dispose() {
    _nome.dispose();
    _email.dispose();
    _senha.dispose();
    super.dispose();
  }

  Future<void> _criar() async {
    if (_carregando) return;

    if (_nome.text.trim().isEmpty || _email.text.trim().isEmpty) {
      setState(() => _erro = 'Preencha nome e e-mail.');
      return;
    }
    if (_senha.text.length < 6) {
      setState(() => _erro = 'A senha precisa ter pelo menos 6 caracteres.');
      return;
    }
    setState(() {
      _carregando = true;
      _erro = null;
    });
    try {
      final entrou = await AuthService.criarConta(
        nome: _nome.text.trim(),
        email: _email.text.trim(),
        senha: _senha.text,
      );
      if (!mounted) return;
      if (entrou) {
        Navigator.pushReplacementNamed(context, AppRoutes.home);
      } else {
        setState(() => _erro = 'Conta criada! Confirme o e-mail e depois entre.');
      }
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
                hint: 'Seu nome',
                controller: _nome,
              ),
              const SizedBox(height: 16),
              InsetField(
                label: 'E-mail',
                hint: 'voce@email.com',
                keyboardType: TextInputType.emailAddress,
                controller: _email,
              ),
              const SizedBox(height: 16),
              InsetField(
                label: 'Senha',
                hint: 'Mínimo de 6 caracteres',
                obscure: true,
                controller: _senha,
              ),
              const SizedBox(height: 7),
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Mínimo de 6 caracteres',
                  style: TextStyle(fontSize: 11),
                ),
              ),
              if (_erro != null) ...[
                const SizedBox(height: 12),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    _erro!,
                    style: const TextStyle(fontSize: 12, color: Colors.redAccent),
                  ),
                ),
              ],
              const SizedBox(height: 18),
              PrimaryButton(
                label: _carregando ? 'Criando...' : 'Criar conta',
                onPressed: _criar,
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
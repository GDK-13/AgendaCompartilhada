
# Mapeamento

| Mockup | Implementação |
| --- | --- |
| Criar conta | `lib/screens/signup_screen.dart` |
| Minha agenda | `lib/screens/home_shell.dart` |
| Novo compromisso | `lib/screens/event_form_screen.dart` |
| Detalhe do compromisso | `lib/screens/event_detail_screen.dart` |
| Excluir compromisso | modal em `event_detail_screen.dart` |

## Tema

O arquivo `lib/theme/app_theme.dart` é a fonte das paletas e tokens do Figma. `lib/theme/agenda_theme.dart` converte esses tokens para a API que o restante do projeto já utilizava.

A troca de tema continua sendo controlada por `ThemeController` e pela tela de aparência.

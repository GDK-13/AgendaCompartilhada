# Agenda Compartilhada

Interface Flutter do projeto de agenda compartilhada.

## Estado desta versão

Esta versão integra o sistema visual exportado do Figma e as novas telas presentes no pacote de mockups.

### Temas

As cinco paletas vêm diretamente de `lib/theme/app_theme.dart`:

1. Aconchegante
2. Azul claro
3. Azul escuro
4. Multicolor claro
5. Roxo e rosa escuro

`agenda_theme.dart` funciona como adaptador para manter compatibilidade com os widgets e telas já existentes.

### Telas incorporadas

- Login
- Criar conta
- Minha agenda com visão semanal e linha do tempo
- Novo compromisso
- Detalhe do compromisso
- Confirmação de exclusão do compromisso
- Grupos
- Horários livres
- Perfil
- Aparência e troca de tema
- Criar grupo

## Supabase

O projeto já possui `supabase_flutter` e inicialização via `dart-define`.

```bash
flutter pub get
flutter run --dart-define-from-file=config/dev.json
```

## O que ainda é visual

As telas novas estão conectadas pela navegação, mas os dados exibidos são exemplos. Ainda faltam conectar autenticação, CRUD de compromissos, grupos, disponibilidade e notificações locais à lógica real do aplicativo.

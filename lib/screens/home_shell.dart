import 'package:flutter/material.dart';

import '../controllers/theme_controller.dart';
import '../routes/app_routes.dart';
import '../theme/agenda_theme.dart';
import '../widgets/agenda_widgets.dart';

class HomeShell extends StatefulWidget {
  const HomeShell({
    super.key,
    required this.themeController,
  });

  final ThemeController themeController;

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _index = 0;

  void _changeTab(int index) {
    setState(() => _index = index);
  }

  @override
  Widget build(BuildContext context) {
    return IndexedStack(
      index: _index,
      children: [
        _AgendaScreen(
          onTab: _changeTab,
          onNovo: () => Navigator.pushNamed(context, AppRoutes.eventForm),
        ),
        _GroupsScreen(
          onTab: _changeTab,
          onNovo: () => Navigator.pushNamed(context, AppRoutes.groupForm),
        ),
        _FreeSlotsScreen(onTab: _changeTab),
        _ProfileScreen(
          onTab: _changeTab,
          onSettings: () => Navigator.pushNamed(context, AppRoutes.settings),
          onLogout: () => Navigator.pushNamedAndRemoveUntil(
            context,
            AppRoutes.login,
            (_) => false,
          ),
        ),
      ],
    );
  }
}

class _AgendaScreen extends StatelessWidget {
  const _AgendaScreen({required this.onTab, required this.onNovo});

  final ValueChanged<int> onTab;
  final VoidCallback onNovo;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;

    return ScreenScaffold(
      tabIndex: 0,
      onTab: onTab,
      header: ScreenHeader(
        titulo: 'Minha agenda',
        subtitulo: 'Outubro de 2026',
        trailing: MemberAvatar(nome: 'Kevin', cor: t.membroA, tamanho: 44),
      ),
      children: [
        const SizedBox(height: 20),
        GlassCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text('Outubro', style: AgendaText.corpo(t)),
                  const Spacer(),
                  Icon(Icons.chevron_left, color: t.textoSuave),
                  const SizedBox(width: 8),
                  Icon(Icons.chevron_right, color: t.textoSuave),
                ],
              ),
              const SizedBox(height: 16),
              const _StaticCalendar(),
            ],
          ),
        ),
        const SizedBox(height: 18),
        Row(
          children: [
            Expanded(child: Text('Compromissos', style: AgendaText.corpo(t))),
            GestureDetector(
              onTap: onNovo,
              child: Text('Novo', style: AgendaText.link(t)),
            ),
          ],
        ),
        const SizedBox(height: 10),
        _EventTile(
          title: 'Programação para dispositivos móveis',
          time: '14:00 até 15:40',
          color: t.membroA,
        ),
        const SizedBox(height: 10),
        _EventTile(
          title: 'Trabalho em dupla',
          time: '17:30 até 18:30',
          color: t.membroB,
        ),
        const SizedBox(height: 18),
        PrimaryButton(
          label: 'Novo compromisso',
          icone: Icons.add_rounded,
          onPressed: onNovo,
        ),
      ],
    );
  }
}

class _StaticCalendar extends StatelessWidget {
  const _StaticCalendar();

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    const labels = ['D', 'S', 'T', 'Q', 'Q', 'S', 'S'];

    return Column(
      children: [
        Row(
          children: [
            for (final label in labels)
              Expanded(
                child: Center(
                  child: Text(label, style: AgendaText.rotulo(t)),
                ),
              ),
          ],
        ),
        const SizedBox(height: 8),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: 35,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 7,
          ),
          itemBuilder: (context, index) {
            final day = index + 1;
            if (day > 31) return const SizedBox.shrink();
            final selected = day == 6;
            final hasEvent = day == 6 || day == 9 || day == 15 || day == 21;

            return Center(
              child: Container(
                width: 34,
                height: 34,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: selected ? t.acentoBase : Colors.transparent,
                  shape: BoxShape.circle,
                  border: hasEvent && !selected
                      ? Border.all(color: t.acentoBase.withValues(alpha: 0.55))
                      : null,
                ),
                child: Text(
                  '$day',
                  style: TextStyle(
                    color: selected ? t.acentoSobre : t.textoPrincipal,
                    fontSize: 13,
                    fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}

class _EventTile extends StatelessWidget {
  const _EventTile({
    required this.title,
    required this.time,
    required this.color,
  });

  final String title;
  final String time;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return GlassCard(
      padding: const EdgeInsets.all(16),
      radius: 20,
      child: Row(
        children: [
          Container(
            width: 5,
            height: 44,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AgendaText.corpo(t)),
                const SizedBox(height: 3),
                Text(time, style: AgendaText.corpoSuave(t)),
              ],
            ),
          ),
          Icon(Icons.chevron_right, color: t.textoFraco),
        ],
      ),
    );
  }
}

class _GroupsScreen extends StatelessWidget {
  const _GroupsScreen({required this.onTab, required this.onNovo});

  final ValueChanged<int> onTab;
  final VoidCallback onNovo;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;

    return ScreenScaffold(
      tabIndex: 1,
      onTab: onTab,
      header: const ScreenHeader(
        titulo: 'Grupos',
        subtitulo: 'Agendas compartilhadas com outras pessoas',
      ),
      children: [
        const SizedBox(height: 20),
        _GroupTile(
          title: 'Trabalho PPDM',
          subtitle: '2 membros',
          color: t.membroA,
        ),
        const SizedBox(height: 12),
        _GroupTile(
          title: 'Pessoal',
          subtitle: '3 membros',
          color: t.membroB,
        ),
        const SizedBox(height: 20),
        PrimaryButton(
          label: 'Criar grupo',
          icone: Icons.group_add_outlined,
          onPressed: onNovo,
        ),
        const SizedBox(height: 12),
        GlassButton(
          label: 'Entrar com código',
          onPressed: () {},
        ),
      ],
    );
  }
}

class _GroupTile extends StatelessWidget {
  const _GroupTile({
    required this.title,
    required this.subtitle,
    required this.color,
  });

  final String title;
  final String subtitle;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return GlassCard(
      padding: const EdgeInsets.all(16),
      radius: 22,
      child: Row(
        children: [
          MemberAvatar(nome: title, cor: color, tamanho: 46),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AgendaText.corpo(t)),
                const SizedBox(height: 3),
                Text(subtitle, style: AgendaText.corpoSuave(t)),
              ],
            ),
          ),
          Icon(Icons.chevron_right, color: t.textoFraco),
        ],
      ),
    );
  }
}

class _FreeSlotsScreen extends StatelessWidget {
  const _FreeSlotsScreen({required this.onTab});

  final ValueChanged<int> onTab;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;

    return ScreenScaffold(
      tabIndex: 2,
      onTab: onTab,
      header: const ScreenHeader(
        titulo: 'Horários livres',
        subtitulo: 'Visualização de exemplo para o grupo selecionado',
      ),
      children: [
        const SizedBox(height: 20),
        GlassCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Quinta, 8 de outubro', style: AgendaText.corpo(t)),
              const SizedBox(height: 14),
              FreeSlotCard(intervalo: '09:00 até 10:30', duracao: '1 h 30 min'),
              const SizedBox(height: 10),
              FreeSlotCard(intervalo: '13:00 até 14:00', duracao: '1 hora'),
              const SizedBox(height: 10),
              FreeSlotCard(intervalo: '18:30 até 20:00', duracao: '1 h 30 min'),
            ],
          ),
        ),
        const SizedBox(height: 16),
        InfoNote(
          icone: Icons.info_outline,
          texto:
              'Os horários acima são apenas dados visuais. O cálculo real fica para a implementação das features.',
        ),
      ],
    );
  }
}

class _ProfileScreen extends StatelessWidget {
  const _ProfileScreen({
    required this.onTab,
    required this.onSettings,
    required this.onLogout,
  });

  final ValueChanged<int> onTab;
  final VoidCallback onSettings;
  final VoidCallback onLogout;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;

    return ScreenScaffold(
      tabIndex: 3,
      onTab: onTab,
      header: const ScreenHeader(titulo: 'Perfil'),
      children: [
        const SizedBox(height: 20),
        GlassCard(
          child: Column(
            children: [
              MemberAvatar(nome: 'Kevin', cor: t.membroA, tamanho: 72),
              const SizedBox(height: 12),
              Text('Usuário', style: AgendaText.corpo(t)),
              const SizedBox(height: 3),
              Text('usuario@email.com', style: AgendaText.corpoSuave(t)),
            ],
          ),
        ),
        const SizedBox(height: 16),
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: onSettings,
          child: GlassCard(
            padding: const EdgeInsets.all(16),
            radius: 22,
            child: Row(
              children: [
                Icon(Icons.palette_outlined, color: t.acentoBase),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Aparência', style: AgendaText.corpo(t)),
                      const SizedBox(height: 3),
                      Text(t.nome, style: AgendaText.corpoSuave(t)),
                    ],
                  ),
                ),
                Icon(Icons.chevron_right, color: t.textoFraco),
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),
        GlassButton(
          label: 'Sair da conta',
          onPressed: onLogout,
          cor: t.estadoErro,
        ),
      ],
    );
  }
}

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
          onDetalhe: () => Navigator.pushNamed(context, AppRoutes.eventDetail),
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
  const _AgendaScreen({
    required this.onTab,
    required this.onNovo,
    required this.onDetalhe,
  });

  final ValueChanged<int> onTab;
  final VoidCallback onNovo;
  final VoidCallback onDetalhe;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;

    return ScreenScaffold(
      tabIndex: 0,
      onTab: onTab,
      floatingAction: _AgendaFab(onTap: onNovo),
      children: [
        Text(
          'Quinta, 1 de outubro',
          style: AgendaText.corpoSuave(t),
        ),
        const SizedBox(height: 2),
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Text('Minha agenda', style: AgendaText.titulo(t)),
            ),
            MemberAvatar(nome: 'Kevin Tiago', cor: t.membroA, tamanho: 48),
          ],
        ),
        const SizedBox(height: 18),
        const _WeekStrip(),
        const SizedBox(height: 16),
        _DayTimeline(onEventTap: onDetalhe),
      ],
    );
  }
}

class _AgendaFab extends StatelessWidget {
  const _AgendaFab({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          color: t.acentoBase,
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white.withValues(alpha: 0.28)),
          boxShadow: t.sombraBotao,
        ),
        child: Icon(Icons.add_rounded, size: 32, color: t.acentoSobre),
      ),
    );
  }
}

class _WeekStrip extends StatelessWidget {
  const _WeekStrip();

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    const labels = ['D', 'S', 'T', 'Q', 'Q', 'S', 'S'];
    const days = ['27', '28', '29', '30', '1', '2', '3'];

    return GlassCard(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      radius: 26,
      child: Row(
        children: [
          for (var i = 0; i < labels.length; i++)
            Expanded(
              child: SizedBox(
                height: 68,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    if (i == 4)
                      Container(
                        width: 42,
                        height: 68,
                        decoration: BoxDecoration(
                          color: t.acentoBase,
                          borderRadius: BorderRadius.circular(22),
                          boxShadow: t.sombraBotao,
                        ),
                      ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          labels[i],
                          style: TextStyle(
                            color: i == 4 ? t.acentoSobre : t.textoSuave,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          days[i],
                          style: TextStyle(
                            color: i == 4 ? t.acentoSobre : t.textoPrincipal,
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                    if (i == 0 || i == 5)
                      Positioned(
                        bottom: 1,
                        child: Container(
                          width: 5,
                          height: 5,
                          decoration: BoxDecoration(
                            color: t.acentoBase,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _DayTimeline extends StatelessWidget {
  const _DayTimeline({required this.onEventTap});

  final VoidCallback onEventTap;

  static const double hourHeight = 52;
  static const double leftGutter = 52;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    const hours = ['08:00', '09:00', '10:00', '11:00', '12:00', '13:00', '14:00', '15:00', '16:00'];

    return GlassCard(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 16),
      radius: 28,
      child: SizedBox(
        height: hourHeight * 8 + 18,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final eventWidth = constraints.maxWidth - leftGutter - 4;
            return Stack(
              clipBehavior: Clip.none,
              children: [
                for (var i = 0; i < hours.length; i++) ...[
                  Positioned(
                    left: 0,
                    top: i * hourHeight - 5,
                    width: 44,
                    child: Text(
                      hours[i],
                      style: TextStyle(
                        color: t.textoSuave,
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  Positioned(
                    left: leftGutter,
                    right: 0,
                    top: i * hourHeight,
                    child: Container(height: 1, color: t.linha),
                  ),
                ],
                _TimelineEvent(
                  top: hourHeight,
                  height: hourHeight * .9,
                  width: eventWidth,
                  title: 'Dentista',
                  subtitle: '09:00 – 10:00  ·  lembrete 30 min antes',
                  color: t.membroA,
                  softColor: t.eventoASuave,
                  onTap: onEventTap,
                ),
                _TimelineEvent(
                  top: hourHeight * 2.5,
                  height: hourHeight * 1.42,
                  width: eventWidth,
                  title: 'Aula de Mobile',
                  subtitle: '10:30 – 12:00  ·  lembrete 30 min antes',
                  color: t.membroB,
                  softColor: t.eventoBSuave,
                  onTap: onEventTap,
                ),
                _TimelineEvent(
                  top: hourHeight * 4.5,
                  height: hourHeight * .9,
                  width: eventWidth,
                  title: 'Almoço com a mãe',
                  subtitle: '12:30 – 13:30  ·  lembrete 30 min antes',
                  color: t.eventoC,
                  softColor: t.eventoCSuave,
                  onTap: onEventTap,
                ),
                _TimelineEvent(
                  top: hourHeight * 7,
                  height: hourHeight * .9,
                  width: eventWidth,
                  title: 'Academia',
                  subtitle: '15:00 – 16:00  ·  lembrete 30 min antes',
                  color: t.membroA,
                  softColor: t.eventoASuave,
                  onTap: onEventTap,
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _TimelineEvent extends StatelessWidget {
  const _TimelineEvent({
    required this.top,
    required this.height,
    required this.width,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.softColor,
    required this.onTap,
  });

  final double top;
  final double height;
  final double width;
  final String title;
  final String subtitle;
  final Color color;
  final Color softColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return Positioned(
      left: _DayTimeline.leftGutter + 4,
      top: top + 3,
      width: width,
      height: height,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            color: softColor,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: t.vidroBorda),
            boxShadow: [
              BoxShadow(
                color: t.relevoSombraCurta,
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 5,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: const BorderRadius.horizontal(
                    left: Radius.circular(14),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: t.textoPrincipal,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: t.textoSuave,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
            ],
          ),
        ),
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
              const FreeSlotCard(
                intervalo: '09:00 até 10:30',
                duracao: '1 h 30 min',
              ),
              const SizedBox(height: 10),
              const FreeSlotCard(
                intervalo: '13:00 até 14:00',
                duracao: '1 hora',
              ),
              const SizedBox(height: 10),
              const FreeSlotCard(
                intervalo: '18:30 até 20:00',
                duracao: '1 h 30 min',
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        const InfoNote(
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

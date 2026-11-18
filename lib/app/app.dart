import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'theme.dart';
import '../core/store.dart';
import '../core/catalog.dart';
import '../core/widgets.dart';
import '../features/daily.dart';
import '../features/access.dart';
import '../features/workouts.dart';
import '../features/nutrition.dart';
import '../features/progress.dart';
import '../features/profile.dart';

void openScreen(BuildContext context, int id, {String? subject}) =>
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        settings: RouteSettings(name: '/t${id.toString().padLeft(2, '0')}'),
        builder: (_) => PulseScreen(id: id, subject: subject),
      ),
    );

class LunaePulseApp extends StatefulWidget {
  const LunaePulseApp({super.key});
  @override
  State<LunaePulseApp> createState() => _LunaePulseAppState();
}

class _LunaePulseAppState extends State<LunaePulseApp> {
  final store = PulseStore();
  @override
  void dispose() {
    store.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => PulseScope(
    store: store,
    child: ListenableBuilder(
      listenable: store,
      builder: (context, _) => MaterialApp(
        title: 'Lunae Pulse',
        debugShowCheckedModeBanner: false,
        locale: const Locale('pt', 'BR'),
        supportedLocales: const [Locale('pt', 'BR')],
        localizationsDelegates: GlobalMaterialLocalizations.delegates,
        theme: pulseTheme(Brightness.light),
        darkTheme: pulseTheme(Brightness.dark),
        themeMode: store.themeMode,
        home: const PulseShell(),
      ),
    ),
  );
}

class PulseShell extends StatefulWidget {
  const PulseShell({super.key});
  @override
  State<PulseShell> createState() => _PulseShellState();
}

class _PulseShellState extends State<PulseShell> {
  int tab = 0;
  static const ids = [12, 16, 25, 33, 44];
  static const labels = [
    'Início',
    'Treinos',
    'Alimentação',
    'Evolução',
    'Perfil',
  ];
  static const icons = [
    Icons.space_dashboard_outlined,
    Icons.fitness_center_rounded,
    Icons.restaurant_outlined,
    Icons.insights_rounded,
    Icons.person_outline_rounded,
  ];
  @override
  Widget build(BuildContext context) {
    final wide = MediaQuery.sizeOf(context).width >= 960;
    final store = PulseScope.of(context);
    final content = Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 12, 0),
          child: Row(
            children: [
              if (!wide) const Expanded(child: Brand()),
              if (wide)
                Text(
                  labels[tab],
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              if (wide) const Spacer(),
              IconButton(
                tooltip: 'Catálogo das 53 telas',
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => const ScreenCatalog(),
                  ),
                ),
                icon: const Icon(Icons.grid_view_rounded),
              ),
              IconButton(
                tooltip: 'Notificações',
                onPressed: () => openScreen(context, 13),
                icon: const Icon(Icons.notifications_none_rounded),
              ),
              IconButton(
                tooltip: 'Alternar tema',
                onPressed: () => store.update(
                  () => store.themeMode =
                      Theme.of(context).brightness == Brightness.dark
                      ? ThemeMode.light
                      : ThemeMode.dark,
                ),
                icon: const Icon(Icons.contrast_rounded),
              ),
            ],
          ),
        ),
        Expanded(
          child: IndexedStack(
            index: tab,
            children: ids.map((id) => PageBody(id: id)).toList(),
          ),
        ),
      ],
    );
    return Scaffold(
      body: SafeArea(
        child: Row(
          children: [
            if (wide)
              Container(
                width: 230,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  border: Border(
                    right: BorderSide(
                      color: Theme.of(context).colorScheme.outlineVariant,
                    ),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(padding: EdgeInsets.all(24), child: Brand()),
                    const Padding(
                      padding: EdgeInsets.all(24),
                      child: Text(
                        'SUA ROTINA, EM EQUILÍBRIO',
                        style: TextStyle(fontSize: 11, letterSpacing: 1.4),
                      ),
                    ),
                    for (var i = 0; i < 5; i++)
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 4,
                        ),
                        child: ListTile(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          selected: tab == i,
                          selectedTileColor: Theme.of(context)
                              .colorScheme
                              .primary
                              .withValues(alpha: .1),
                          leading: Icon(icons[i]),
                          title: Text(labels[i]),
                          onTap: () => setState(() => tab = i),
                        ),
                      ),
                    const Spacer(),
                    const Padding(
                      padding: EdgeInsets.all(24),
                      child: InfoNote(
                        'Frontend de demonstração\nDados ilustrativos desta sessão.',
                      ),
                    ),
                  ],
                ),
              ),
            Expanded(child: content),
          ],
        ),
      ),
      bottomNavigationBar: wide
          ? null
          : NavigationBar(
              selectedIndex: tab,
              onDestinationSelected: (i) => setState(() => tab = i),
              destinations: List.generate(
                5,
                (i) => NavigationDestination(
                  icon: Icon(icons[i]),
                  label: labels[i],
                ),
              ),
            ),
      floatingActionButton: tab == 0
          ? FloatingActionButton(
              tooltip: 'Adicionar registro',
              onPressed: () => quickActions(context),
              child: const Icon(Icons.add_rounded),
            )
          : null,
    );
  }
}

class PulseScreen extends StatefulWidget {
  const PulseScreen({super.key, required this.id, this.subject});
  final int id;
  final String? subject;
  @override
  State<PulseScreen> createState() => _PulseScreenState();
}

class _PulseScreenState extends State<PulseScreen> {
  ViewStatus status = ViewStatus.content;
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: Text(screenTitles[widget.id - 1]),
      actions: [
        PopupMenuButton<ViewStatus>(
          tooltip: 'Pré-visualizar estados da tela',
          onSelected: (v) => setState(() => status = v),
          itemBuilder: (_) => [
            for (final item in ViewStatus.values)
              PopupMenuItem(
                value: item,
                child: Text(switch (item) {
                  ViewStatus.content => 'Conteúdo',
                  ViewStatus.loading => 'Carregando',
                  ViewStatus.empty => 'Vazio',
                  ViewStatus.error => 'Erro',
                  ViewStatus.offline => 'Offline',
                  ViewStatus.syncing => 'Sincronizando',
                }),
              ),
          ],
        ),
      ],
    ),
    body: StatePreview(
      status: status,
      retry: () => setState(() => status = ViewStatus.content),
      child: PageBody(id: widget.id, subject: widget.subject),
    ),
  );
}

class PageBody extends StatelessWidget {
  const PageBody({super.key, required this.id, this.subject});
  final int id;
  final String? subject;
  @override
  Widget build(BuildContext context) => SingleChildScrollView(
    key: PageStorageKey('screen-$id'),
    padding: const EdgeInsets.fromLTRB(20, 24, 20, 100),
    child: Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1040),
        child: switch (id) {
          <= 11 => AccessPage(id: id),
          <= 15 => DailyPage(id: id),
          <= 24 => WorkoutPage(id: id, subject: subject),
          <= 32 => NutritionPage(id: id, subject: subject),
          <= 38 => ProgressPage(id: id),
          _ => ProfilePage(id: id),
        },
      ),
    ),
  );
}

class ScreenCatalog extends StatefulWidget {
  const ScreenCatalog({super.key});
  @override
  State<ScreenCatalog> createState() => _ScreenCatalogState();
}

class _ScreenCatalogState extends State<ScreenCatalog> {
  String query = '';
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Explore o Lunae Pulse')),
    body: ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const Text(
          '53 telas · uma rotina mais sua',
          style: TextStyle(fontSize: 26, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 8),
        const InfoNote(
          'Prévia de frontend. Contas, integrações, exportações e IA não usam serviços externos.',
        ),
        const SizedBox(height: 20),
        PulseSearch(
          label: 'Buscar tela ou módulo',
          onChanged: (v) => setState(() => query = v),
        ),
        const SizedBox(height: 20),
        for (final screen in screens.where(
          (s) => '${s.title} ${s.group} T${s.id}'.toLowerCase().contains(
            query.toLowerCase(),
          ),
        ))
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: PulseTile(
              screen.title,
              'T${screen.id.toString().padLeft(2, '0')} · ${screen.group}',
              icon: Icons.layers_outlined,
              onTap: () => openScreen(context, screen.id),
            ),
          ),
      ],
    ),
  );
}

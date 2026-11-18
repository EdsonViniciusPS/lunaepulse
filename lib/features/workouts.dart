import 'dart:async';

import 'package:flutter/material.dart';

import '../app/app.dart';
import '../core/store.dart';
import '../core/widgets.dart';

class WorkoutPage extends StatefulWidget {
  const WorkoutPage({super.key, required this.id, this.subject});
  final int id;
  final String? subject;
  @override
  State<WorkoutPage> createState() => _WorkoutPageState();
}

class _WorkoutPageState extends State<WorkoutPage> {
  String query = '', muscle = 'Todos';
  final name = TextEditingController(),
      load = TextEditingController(text: '12'),
      reps = TextEditingController(text: '10');
  final form = GlobalKey<FormState>();
  final List<String> chosen = [];
  Timer? timer;
  int rest = 90;
  bool paused = false;
  DateTime? deadline;
  @override
  void initState() {
    super.initState();
    if (widget.id == 22) {
      deadline = DateTime.now().add(const Duration(seconds: 90));
    }
    if (widget.id == 21 || widget.id == 22) {
      timer = Timer.periodic(const Duration(seconds: 1), (_) {
        if (!mounted) return;
        setState(() {
          if (widget.id == 22 && !paused) {
            rest = (deadline!.difference(DateTime.now()).inMilliseconds / 1000)
                .ceil()
                .clamp(0, 3600);
          }
        });
      });
    }
  }

  @override
  void dispose() {
    timer?.cancel();
    name.dispose();
    load.dispose();
    reps.dispose();
    super.dispose();
  }

  void go(int id, {String? subject}) =>
      openScreen(context, id, subject: subject);
  @override
  Widget build(BuildContext context) {
    final store = PulseScope.of(context), id = widget.id;
    if (id == 16) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Movimento que\nvira rotina.',
            style: Theme.of(context).textTheme.headlineLarge,
          ),
          const SizedBox(height: 12),
          const Text('Planeje com intenção. Treine no seu ritmo.'),
          const SizedBox(height: 24),
          PulseCard(
            hero: true,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'SEU TREINO DE HOJE',
                  style: TextStyle(letterSpacing: 1.5, fontSize: 12),
                ),
                const SizedBox(height: 16),
                Text(
                  store.currentPlan,
                  style: Theme.of(context).textTheme.headlineMedium
                      ?.copyWith(color: Colors.white),
                ),
                const SizedBox(height: 8),
                const Text(
                  '5 exercícios · 45 min estimados',
                  style: TextStyle(color: Colors.white),
                ),
                const SizedBox(height: 20),
                PulseButton(
                  store.activeWorkout ? 'Retomar treino' : 'Ver meu treino',
                  onPressed: () => go(store.activeWorkout ? 21 : 20),
                  icon: Icons.play_arrow_rounded,
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Section('Minhas fichas', action: 'Criar treino', onTap: () => go(19)),
          for (final p in store.plans)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: PulseTile(
                p,
                'Força · ficha pessoal de demonstração',
                icon: Icons.fitness_center,
                onTap: () => go(20, subject: p),
              ),
            ),
          const SizedBox(height: 16),
          PulseTile(
            'Biblioteca de exercícios',
            'Encontre seu próximo movimento',
            icon: Icons.menu_book_outlined,
            onTap: () => go(17),
          ),
          const SizedBox(height: 12),
          PulseTile(
            'Histórico de treinos',
            'Relembre suas sessões',
            icon: Icons.history,
            onTap: () => go(24),
          ),
        ],
      );
    }
    if (id == 17) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          PulseSearch(
            label: 'Buscar exercício',
            onChanged: (v) => setState(() => query = v),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            children: ['Todos', 'Peito', 'Costas', 'Ombros']
                .map(
                  (v) => ChoiceChip(
                    label: Text(v),
                    selected: muscle == v,
                    onSelected: (_) => setState(() => muscle = v),
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 24),
          ...store.exercises
              .where(
                (e) =>
                    e.toLowerCase().contains(query.toLowerCase()) &&
                    (muscle == 'Todos' ||
                        muscle == 'Peito' && e.contains('Supino') ||
                        muscle == 'Costas' && e.contains('Remada') ||
                        muscle == 'Ombros' &&
                            (e.contains('Desenvolvimento') ||
                                e.contains('Elevação'))),
              )
              .map(
                (e) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: PulseTile(
                    e,
                    '${e.contains('Supino') ? 'Peito' : 'Força'} · equipamento livre',
                    icon: Icons.fitness_center,
                    onTap: () => go(18, subject: e),
                    trailing: IconButton(
                      tooltip: store.favorites.contains(e)
                          ? 'Remover favorito'
                          : 'Favoritar exercício',
                      onPressed: () => store.update(() {
                        if (!store.favorites.add(e)) store.favorites.remove(e);
                      }),
                      icon: Icon(
                        store.favorites.contains(e)
                            ? Icons.favorite
                            : Icons.favorite_border,
                      ),
                    ),
                  ),
                ),
              ),
          if (!store.exercises.any(
            (e) => e.toLowerCase().contains(query.toLowerCase()),
          ))
            const InfoNote(
              'Nenhum exercício encontrado. Tente outro nome ou limpe a busca.',
            ),
        ],
      );
    }
    if (id == 18) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          PulseCard(
            child: ConstrainedBox(
              constraints: const BoxConstraints(minHeight: 180),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.fitness_center_rounded,
                    size: 72,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(height: 16),
                  const Text('Demonstração de movimento'),
                  const Text(
                    'Vídeo não disponível nesta prévia',
                    style: TextStyle(fontSize: 12),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            widget.subject ?? 'Supino reto com halteres',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 8),
          const Text('Peitoral · halteres · banco reto'),
          const Section('Execução consciente'),
          const Text(
            '1. Ajuste o banco e apoie os pés.\n\n2. Mantenha o movimento controlado e respeite sua amplitude confortável.\n\n3. Peça orientação profissional para ajustar a execução.',
          ),
          const SizedBox(height: 20),
          const InfoNote(
            'Conteúdo ilustrativo de interface. Material técnico e fonte serão incluídos na versão final.',
          ),
          const SizedBox(height: 24),
          PulseButton(
            'Adicionar à ficha',
            icon: Icons.add,
            onPressed: () {
              store.update(
                () => store.exercises.add(
                  widget.subject ?? 'Supino reto com halteres',
                ),
              );
              feedback(context, 'Exercício adicionado à ficha de demonstração');
            },
          ),
          const SizedBox(height: 12),
          PulseButton(
            'Ver evolução de carga',
            secondary: true,
            onPressed: () => go(36),
          ),
        ],
      );
    }
    if (id == 19 || id == 52) {
      return Form(
        key: form,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Monte seu próximo passo.',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: name,
              decoration: const InputDecoration(labelText: 'Nome da ficha'),
              validator: (v) =>
                  (v ?? '').trim().isEmpty ? 'Dê um nome à ficha.' : null,
            ),
            const SizedBox(height: 20),
            const Section('Selecione os exercícios'),
            for (final exercise in store.exercises.toSet())
              CheckboxListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(exercise),
                subtitle: const Text(
                  '3 séries · 10 repetições · 90 s de descanso',
                ),
                value: chosen.contains(exercise),
                onChanged: (v) => setState(() {
                  if (v == true) {
                    chosen.add(exercise);
                  } else {
                    chosen.remove(exercise);
                  }
                }),
              ),
            const SizedBox(height: 24),
            PulseButton(
              'Salvar ficha',
              icon: Icons.check,
              onPressed: () {
                if (!form.currentState!.validate()) return;
                if (chosen.isEmpty) {
                  feedback(context, 'Selecione pelo menos um exercício.');
                  return;
                }
                store.update(() {
                  final title = name.text.trim();
                  if (!store.plans.contains(title)) store.plans.add(title);
                  store.planExercises[title] = List.of(chosen);
                });
                feedback(context, 'Ficha salva nesta sessão');
                Navigator.pop(context);
              },
            ),
            const SizedBox(height: 12),
            const InfoNote(
              'Ficha de demonstração. Não gera prescrição automática de exercícios.',
            ),
          ],
        ),
      );
    }
    if (id == 20) {
      final plan = widget.subject ?? 'Superior A';
      final exercises = store.exercisesFor(plan);
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.subject ?? 'Superior A',
            style: Theme.of(context).textTheme.headlineLarge,
          ),
          const SizedBox(height: 12),
          Text(
            '${exercises.length} exercícios · ${exercises.length * 3} séries planejadas\nDescanso: 90 s entre séries · ficha de demonstração',
          ),
          const SizedBox(height: 24),
          PulseButton(
            store.activeWorkout ? 'Retomar treino' : 'Iniciar treino',
            icon: Icons.play_arrow,
            onPressed: () {
              store.startWorkout(plan);
              go(21);
            },
          ),
          const Section('Seu roteiro'),
          for (var i = 0; i < exercises.length; i++)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: PulseTile(
                exercises[i],
                '3 séries × 10 repetições · descanso 90 s',
                icon: Icons.fitness_center,
                onTap: () => go(18, subject: exercises[i]),
              ),
            ),
          const SizedBox(height: 16),
          PulseButton(
            'Criar outra ficha',
            secondary: true,
            icon: Icons.edit_outlined,
            onPressed: () => go(19),
          ),
          const SizedBox(height: 16),
          const InfoNote(
            'Planejamento ilustrativo. Ajuste cargas e movimentos com orientação individual.',
          ),
        ],
      );
    }
    if (id == 21) {
      final elapsed = store.workoutStarted == null
          ? 0
          : DateTime.now().difference(store.workoutStarted!).inSeconds;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  store.currentPlan,
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
              ),
              Chip(
                avatar: const Icon(Icons.timer_outlined, size: 18),
                label: Text(
                  '${(elapsed ~/ 60).toString().padLeft(2, '0')}:${(elapsed % 60).toString().padLeft(2, '0')}',
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '${store.completedSets} de ${store.plannedSets} séries concluídas · dados desta sessão',
          ),
          const SizedBox(height: 16),
          LinearProgressIndicator(
            value: (store.completedSets / store.plannedSets).clamp(0, 1),
            minHeight: 6,
            borderRadius: BorderRadius.circular(6),
          ),
          const SizedBox(height: 24),
          PulseCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'EXERCÍCIO ATUAL',
                  style: TextStyle(fontSize: 12, letterSpacing: 1.5),
                ),
                const SizedBox(height: 12),
                Text(
                  store.currentExercises[(store.completedSets ~/ 3).clamp(
                    0,
                    store.currentExercises.length - 1,
                  )],
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                Text(
                  'Série ${store.completedSets % 3 + 1} de 3 · 10 repetições planejadas',
                ),
                const SizedBox(height: 24),
                Form(
                  key: form,
                  child: Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: load,
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          decoration: const InputDecoration(
                            labelText: 'Carga (kg)',
                          ),
                          validator: (v) =>
                              (double.tryParse(
                                        (v ?? '').replaceAll(',', '.'),
                                      ) ??
                                      -1) <
                                  0
                              ? 'Carga inválida'
                              : null,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextFormField(
                          controller: reps,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'Repetições',
                          ),
                          validator: (v) => (int.tryParse(v ?? '') ?? 0) <= 0
                              ? 'Informe repetições'
                              : null,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                PulseButton(
                  'Concluir série',
                  icon: Icons.check_rounded,
                  onPressed: store.completedSets >= store.plannedSets
                      ? null
                      : () {
                          if (!form.currentState!.validate()) return;
                          store.startWorkout();
                          store.update(() => store.completedSets++);
                          feedback(
                            context,
                            'Série ${store.completedSets} registrada nesta sessão',
                          );
                          if (store.completedSets < store.plannedSets) go(22);
                        },
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          PulseButton(
            'Encerrar treino',
            secondary: true,
            icon: Icons.stop_circle_outlined,
            onPressed: () async {
              final confirmed = await showDialog<bool>(
                context: context,
                builder: (c) => AlertDialog(
                  title: const Text('Encerrar este treino?'),
                  content: Text(
                    '${store.completedSets} séries foram registradas. Você poderá revisar o resumo.',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(c, false),
                      child: const Text('Continuar treino'),
                    ),
                    FilledButton(
                      onPressed: () => Navigator.pop(c, true),
                      child: const Text('Encerrar treino'),
                    ),
                  ],
                ),
              );
              if (confirmed == true && context.mounted) {
                store.finishWorkout();
                go(23);
              }
            },
          ),
          const SizedBox(height: 20),
          const InfoNote(
            'Os registros sobrevivem à navegação, mas são descartados ao fechar o aplicativo. Persistência não está conectada.',
          ),
        ],
      );
    }
    if (id == 22) {
      return Column(
        children: [
          const SizedBox(height: 24),
          Text(
            rest == 0 ? 'Pronto para continuar?' : 'Respire. Recupere.',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 32),
          PulseRing(
            progress: rest / 90,
            value: '${rest ~/ 60}:${(rest % 60).toString().padLeft(2, '0')}',
            label: 'descanso',
          ),
          const SizedBox(height: 32),
          Wrap(
            spacing: 12,
            children: [
              OutlinedButton(
                onPressed: () => setState(() {
                  rest = (rest - 15).clamp(0, 3600);
                  deadline = DateTime.now().add(Duration(seconds: rest));
                }),
                child: const Text('−15 s'),
              ),
              OutlinedButton(
                onPressed: () => setState(() {
                  rest += 15;
                  deadline = DateTime.now().add(Duration(seconds: rest));
                }),
                child: const Text('+15 s'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          PulseButton(
            paused ? 'Retomar contagem' : 'Pausar contagem',
            icon: paused ? Icons.play_arrow : Icons.pause,
            onPressed: () => setState(() {
              paused = !paused;
              deadline = DateTime.now().add(Duration(seconds: rest));
            }),
          ),
          const SizedBox(height: 12),
          PulseButton(
            'Voltar ao treino',
            secondary: true,
            onPressed: () => Navigator.pop(context),
          ),
        ],
      );
    }
    if (id == 23) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.check_circle_outline_rounded, size: 64),
          const SizedBox(height: 24),
          Text(
            'Mais um passo\nna sua jornada.',
            style: Theme.of(context).textTheme.headlineLarge,
          ),
          const SizedBox(height: 16),
          const Text(
            'Reconheça seu esforço e reserve um tempo para recuperar.',
          ),
          const SizedBox(height: 24),
          AdaptiveGrid(
            children: [
              Metric(
                '${store.completedSets}',
                'Séries registradas',
                icon: Icons.done_all,
              ),
              const Metric(
                'Superior A',
                'Treino de demonstração',
                icon: Icons.fitness_center,
              ),
            ],
          ),
          const SizedBox(height: 24),
          const TextField(
            maxLines: 3,
            decoration: InputDecoration(
              labelText: 'Como foi o treino? (opcional)',
            ),
          ),
          const SizedBox(height: 24),
          PulseButton('Ver histórico', onPressed: () => go(24)),
          const SizedBox(height: 12),
          PulseButton(
            'Voltar ao início',
            secondary: true,
            onPressed: () => Navigator.of(context).popUntil((r) => r.isFirst),
          ),
        ],
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Section('Cada sessão conta'),
        if (store.sessions.isEmpty) ...[
          const PulseCard(
            child: Column(
              children: [
                Icon(Icons.history_rounded, size: 48),
                SizedBox(height: 16),
                Text('Seu histórico começa no próximo treino.'),
                SizedBox(height: 12),
                Text('Conclua uma sessão para vê-la aqui.'),
              ],
            ),
          ),
          const SizedBox(height: 24),
          PulseButton('Explorar meu treino', onPressed: () => go(20)),
        ] else
          for (final session in store.sessions)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: PulseTile(
                session,
                'Registro de demonstração · nesta sessão',
                icon: Icons.check_circle_outline,
                onTap: () => go(23),
              ),
            ),
      ],
    );
  }
}

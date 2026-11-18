import 'package:flutter/material.dart';

import '../app/app.dart';
import '../app/theme.dart';
import '../core/store.dart';
import '../core/widgets.dart';

void quickActions(BuildContext context) => showModalBottomSheet<void>(
  context: context,
  showDragHandle: true,
  isScrollControlled: true,
  builder: (sheet) => SafeArea(
    child: SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'O que vamos registrar?',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            for (final item in [
              (21, 'Iniciar treino', Icons.fitness_center),
              (27, 'Adicionar alimento', Icons.restaurant),
              (32, 'Registrar água', Icons.water_drop_outlined),
              (34, 'Registrar peso', Icons.monitor_weight_outlined),
              (40, 'Registrar atividade', Icons.directions_walk),
            ])
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: PulseTile(
                  item.$2,
                  'Adicionar à sua rotina',
                  icon: item.$3,
                  onTap: () {
                    Navigator.pop(sheet);
                    openScreen(context, item.$1);
                  },
                ),
              ),
          ],
        ),
      ),
    ),
  ),
);

class DailyPage extends StatefulWidget {
  const DailyPage({super.key, required this.id});
  final int id;
  @override
  State<DailyPage> createState() => _DailyPageState();
}

class _DailyPageState extends State<DailyPage> {
  int selectedDay = 0;
  bool read = false;
  @override
  Widget build(BuildContext context) {
    final store = PulseScope.of(context);
    if (widget.id == 15) {
      return Column(
        children: [
          const InfoNote('Escolha um registro rápido para sua rotina.'),
          const SizedBox(height: 24),
          PulseButton(
            'Adicionar registro',
            onPressed: () => quickActions(context),
            icon: Icons.add,
          ),
        ],
      );
    }
    if (widget.id == 13) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Section('Sua rotina, no seu tempo'),
          TextButton.icon(
            onPressed: () => setState(() => read = true),
            icon: const Icon(Icons.done_all),
            label: Text(read ? 'Todas lidas' : 'Marcar todas como lidas'),
          ),
          const SizedBox(height: 16),
          PulseTile(
            'Hora de se movimentar',
            'Hoje · 17:30 · Lembrete demonstrativo',
            icon: read
                ? Icons.drafts_outlined
                : Icons.mark_email_unread_outlined,
            onTap: () {
              setState(() => read = true);
              openScreen(context, 20);
            },
          ),
          const SizedBox(height: 12),
          PulseTile(
            'Cada passo conta',
            '3 sessões nesta semana de exemplo. Veja sua consistência.',
            icon: Icons.auto_awesome_outlined,
            onTap: () => openScreen(context, 37),
          ),
          const SizedBox(height: 24),
          const InfoNote(
            'Notificações ilustrativas. Nenhum lembrete foi agendado.',
          ),
        ],
      );
    }
    if (widget.id == 14) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Section('Uma semana no seu ritmo'),
          const Text('16–22 de novembro · planejamento ilustrativo'),
          const SizedBox(height: 20),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: List.generate(
              7,
              (i) => ChoiceChip(
                label: Text(
                  '${['Seg', 'Ter', 'Qua', 'Qui', 'Sex', 'Sáb', 'Dom'][i]}\n${16 + i}',
                ),
                selected: selectedDay == i,
                onSelected: (_) => setState(() => selectedDay = i),
              ),
            ),
          ),
          const SizedBox(height: 24),
          PulseTile(
            selectedDay % 2 == 0 ? 'Superior A' : 'Descanso e recuperação',
            selectedDay % 2 == 0
                ? '17:30 · 45 min · planejado'
                : 'Respeite seu tempo de recuperação',
            icon: selectedDay % 2 == 0
                ? Icons.fitness_center
                : Icons.spa_outlined,
            onTap: () => openScreen(context, selectedDay % 2 == 0 ? 20 : 41),
          ),
          const SizedBox(height: 24),
          PulseButton(
            'Planejar uma sessão',
            onPressed: () => openScreen(context, 19),
            icon: Icons.add,
          ),
        ],
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'SEGUNDA, 16 DE NOVEMBRO',
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      letterSpacing: 1.4,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Seu ritmo, ${store.name}.',
                    style: Theme.of(context).textTheme.headlineLarge,
                  ),
                  const SizedBox(height: 4),
                  const Text('Um pouco a cada dia. Uma evolução que é sua.'),
                ],
              ),
            ),
            const SizedBox(width: 12),
            CircleAvatar(
              radius: 24,
              backgroundColor: Theme.of(context).colorScheme.primary
                  .withValues(alpha: .1),
              child: Text(
                store.name.isEmpty ? 'A' : store.name[0].toUpperCase(),
              ),
            ),
          ],
        ),
        const SizedBox(height: 28),
        PulseCard(
          hero: true,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(Icons.auto_awesome_outlined, size: 18),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'SEU MOVIMENTO DA SEMANA',
                      style: TextStyle(fontSize: 11, letterSpacing: 1.3),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Wrap(
                spacing: 32,
                runSpacing: 24,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  const PulseRing(
                    progress: .75,
                    value: '3 de 4',
                    label: 'treinos da semana',
                    light: true,
                  ),
                  SizedBox(
                    width: 230,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Constância faz\na diferença.',
                          style: Theme.of(context).textTheme.headlineMedium
                              ?.copyWith(color: Colors.white),
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'Seu próximo passo já está planejado.',
                          style: TextStyle(color: Colors.white),
                        ),
                        const SizedBox(height: 16),
                        FilledButton.icon(
                          style: FilledButton.styleFrom(
                            backgroundColor: PulseColors.aqua,
                            foregroundColor: PulseColors.navy,
                          ),
                          onPressed: () => openScreen(context, 14),
                          icon: const Icon(Icons.arrow_forward_rounded),
                          label: const Text('Ver minha semana'),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        const InfoNote(
          'Prévia · dados ilustrativos de 16/11/2026. Seus registros ficam somente nesta sessão.',
        ),
        const SizedBox(height: 24),
        Section(
          'Hoje é dia de evoluir',
          action: 'Meus treinos',
          onTap: () => openScreen(context, 16),
        ),
        PulseTile(
          store.activeWorkout ? 'Retomar treino' : 'Superior A',
          'Peito, ombros e tríceps · 45 min · 5 exercícios',
          icon: Icons.fitness_center_rounded,
          onTap: () => openScreen(context, store.activeWorkout ? 21 : 20),
        ),
        const SizedBox(height: 24),
        Section(
          'Seu equilíbrio diário',
          action: 'Alimentação',
          onTap: () => openScreen(context, 25),
        ),
        AdaptiveGrid(
          children: [
            Metric(
              '${store.calories} kcal',
              'Consumo registrado · estimativa',
              icon: Icons.restaurant_outlined,
            ),
            Metric(
              '${decimal(store.water / 1000, 2)} L',
              'Água · meta pessoal ${decimal(store.waterGoal / 1000)} L',
              icon: Icons.water_drop_outlined,
            ),
            Metric(
              '${decimal(store.weight)} kg',
              'Último peso · informado',
              icon: Icons.monitor_weight_outlined,
            ),
          ],
        ),
        const SizedBox(height: 24),
        PulseCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.water_drop_outlined),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Uma pausa para se hidratar',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              LinearProgressIndicator(
                value: (store.water / store.waterGoal).clamp(0, 1),
                minHeight: 7,
                borderRadius: BorderRadius.circular(8),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 12,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Text('${store.water} / ${store.waterGoal} mL'),
                  TextButton.icon(
                    onPressed: () {
                      store.addWater(250);
                      feedback(
                        context,
                        '250 mL adicionados',
                        undo: () => store.addWater(-250),
                      );
                    },
                    icon: const Icon(Icons.add),
                    label: const Text('250 mL'),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        PulseTile(
          'Saúde e atividade',
          'Conecte somente o que fizer sentido para você',
          icon: Icons.favorite_border_rounded,
          onTap: () => openScreen(context, 39),
        ),
      ],
    );
  }
}

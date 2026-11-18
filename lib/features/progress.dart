import 'package:flutter/material.dart';

import '../app/app.dart';
import '../core/store.dart';
import '../core/widgets.dart';

class ProgressPage extends StatefulWidget {
  const ProgressPage({super.key, required this.id});
  final int id;
  @override
  State<ProgressPage> createState() => _ProgressPageState();
}

class _ProgressPageState extends State<ProgressPage> {
  String period = '30d';
  final weight = TextEditingController(), notes = TextEditingController();
  final form = GlobalKey<FormState>();
  final Set<String> included = {'Peso', 'Treinos'};
  bool preview = false;
  @override
  void dispose() {
    weight.dispose();
    notes.dispose();
    super.dispose();
  }

  void go(int id) => openScreen(context, id);
  @override
  Widget build(BuildContext context) {
    final store = PulseScope.of(context), id = widget.id;
    Widget periods() => Wrap(
      spacing: 8,
      runSpacing: 8,
      children: ['7d', '30d', '90d', '1a']
          .map(
            (p) => ChoiceChip(
              label: Text(p),
              selected: period == p,
              onSelected: (_) => setState(() => period = p),
            ),
          )
          .toList(),
    );
    Widget chart() => PulseCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Tendência de peso',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              Text(
                '${decimal(store.weight)} kg',
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text('Período selecionado: $period · histórico demonstrativo'),
          const SizedBox(height: 20),
          PulseChart(
            values: List.of(store.weights),
            label: 'Peso em quilogramas, escala ajustada à variação',
          ),
          const SizedBox(height: 12),
          const Text(
            '10 nov                                                 16 nov',
            style: TextStyle(fontSize: 12),
          ),
          const SizedBox(height: 16),
          InfoNote(
            'Faixa do gráfico: ${decimal(store.weights.reduce((a, b) => a < b ? a : b) - .3)}–${decimal(store.weights.reduce((a, b) => a > b ? a : b) + .3)} kg. Dados informados; não representam avaliação de saúde.',
          ),
        ],
      ),
    );
    if (id == 33) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Sua evolução\nvai além dos números.',
            style: Theme.of(context).textTheme.headlineLarge,
          ),
          const SizedBox(height: 12),
          const Text('Observe tendências. Reconheça sua constância.'),
          const SizedBox(height: 24),
          periods(),
          const SizedBox(height: 20),
          chart(),
          const SizedBox(height: 20),
          AdaptiveGrid(
            children: [
              Metric(
                '${store.sessions.length}',
                'Treinos registrados nesta sessão',
                icon: Icons.fitness_center,
              ),
              const Metric(
                '3 / 4',
                'Meta semanal de exemplo',
                icon: Icons.calendar_today_outlined,
              ),
            ],
          ),
          const SizedBox(height: 24),
          PulseButton(
            'Registrar peso',
            icon: Icons.add,
            onPressed: () => go(34),
          ),
          const Section('Outras formas de evoluir'),
          for (final link in [
            (
              35,
              'Medidas corporais',
              'Acompanhe suas próprias referências',
              Icons.straighten,
            ),
            (
              36,
              'Evolução de força',
              'Cargas e repetições ao longo do tempo',
              Icons.fitness_center,
            ),
            (
              37,
              'Consistência',
              'Movimento e descanso fazem parte',
              Icons.calendar_month,
            ),
            (
              38,
              'Relatórios',
              'Escolha quais dados visualizar',
              Icons.description_outlined,
            ),
          ])
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: PulseTile(
                link.$2,
                link.$3,
                icon: link.$4,
                onTap: () => go(link.$1),
              ),
            ),
        ],
      );
    }
    if (id == 34) {
      return Form(
        key: form,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            chart(),
            const SizedBox(height: 24),
            TextFormField(
              controller: weight,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: const InputDecoration(
                labelText: 'Peso (kg)',
                hintText: 'Ex.: 72,4',
              ),
              validator: (v) {
                final n = double.tryParse((v ?? '').replaceAll(',', '.'));
                return n == null || n < 1 || n > 500
                    ? 'Informe um peso entre 1 e 500 kg.'
                    : null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: notes,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Observação (opcional)',
              ),
            ),
            const SizedBox(height: 20),
            PulseButton(
              'Salvar peso',
              icon: Icons.check,
              onPressed: () {
                if (!form.currentState!.validate()) return;
                final n = double.parse(weight.text.replaceAll(',', '.'));
                store.update(() {
                  store.weight = n;
                  store.weights.add(n);
                });
                feedback(context, 'Peso salvo nesta sessão');
                weight.clear();
              },
            ),
            const SizedBox(height: 24),
            const Section('Histórico · kg informados'),
            for (final n in store.weights.reversed.take(8))
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.monitor_weight_outlined),
                title: Text('${decimal(n)} kg'),
                subtitle: const Text('Registro demonstrativo'),
              ),
          ],
        ),
      );
    }
    if (id == 35) {
      return Form(
        key: form,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const InfoNote(
              'Registre com o mesmo método para comparar datas. Todas as medidas são opcionais.',
            ),
            const SizedBox(height: 24),
            for (final label in [
              'Cintura (cm)',
              'Quadril (cm)',
              'Tórax (cm)',
              'Braço direito (cm)',
              'Coxa direita (cm)',
              'Panturrilha direita (cm)',
            ])
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: TextFormField(
                  initialValue: store.drafts[35]?[label],
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: InputDecoration(labelText: label),
                  onChanged: (v) =>
                      store.drafts.putIfAbsent(35, () => {})[label] = v,
                  validator: (v) {
                    if ((v ?? '').isEmpty) return null;
                    final n = double.tryParse(v!.replaceAll(',', '.'));
                    return n == null || n <= 0 || n > 400
                        ? 'Informe uma medida válida em cm.'
                        : null;
                  },
                ),
              ),
            PulseButton(
              'Salvar medidas',
              icon: Icons.check,
              onPressed: () {
                if (form.currentState!.validate()) {
                  feedback(context, 'Medidas guardadas nesta sessão');
                }
              },
            ),
          ],
        ),
      );
    }
    if (id == 36) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Section('Cada repetição constrói'),
          DropdownButtonFormField<String>(
            initialValue: store.exercises.first,
            isExpanded: true,
            decoration: const InputDecoration(labelText: 'Exercício'),
            items: store.exercises
                .toSet()
                .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                .toList(),
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 20),
          periods(),
          const SizedBox(height: 24),
          const PulseCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Carga de trabalho · kg por halter'),
                SizedBox(height: 20),
                PulseChart(
                  values: [8, 8, 10, 10, 12, 12],
                  label: 'Exemplo de carga em kg',
                ),
                SizedBox(height: 16),
                InfoNote(
                  '6 sessões de exemplo · 8 a 12 kg por halter. Nenhum 1RM medido.',
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          PulseButton(
            'Consultar treinos',
            secondary: true,
            onPressed: () => go(24),
          ),
        ],
      );
    }
    if (id == 37) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'A rotina também\ninclui pausas.',
            style: Theme.of(context).textTheme.headlineLarge,
          ),
          const SizedBox(height: 16),
          const Text('Novembro de 2026 · calendário demonstrativo'),
          const SizedBox(height: 24),
          PulseCard(
            child: Column(
              children: [
                const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Text('D'),
                    Text('S'),
                    Text('T'),
                    Text('Q'),
                    Text('Q'),
                    Text('S'),
                    Text('S'),
                  ],
                ),
                const SizedBox(height: 12),
                LayoutBuilder(
                  builder: (c, b) => Wrap(
                    spacing: 4,
                    runSpacing: 4,
                    children: List.generate(
                      30,
                      (i) => SizedBox(
                        width: (b.maxWidth - 24) / 7,
                        height: 48,
                        child: TextButton(
                          style: TextButton.styleFrom(
                            backgroundColor: [2, 4, 6, 9, 11, 13].contains(i)
                                ? Theme.of(context).colorScheme.primary
                                      .withValues(alpha: .12)
                                : null,
                          ),
                          onPressed: () => feedback(
                            context,
                            [2, 4, 6, 9, 11, 13].contains(i)
                                ? '${i + 1}/11 · treino de demonstração'
                                : '${i + 1}/11 · sem registro ou descanso',
                          ),
                          child: Text('${i + 1}'),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          const InfoNote(
            'Dias destacados: atividade registrada. Dias sem destaque podem ser descanso; não indicam falha.',
          ),
        ],
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'O progresso que\nvocê quer compartilhar.',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        const SizedBox(height: 20),
        periods(),
        const SizedBox(height: 16),
        for (final item in ['Peso', 'Treinos', 'Alimentação', 'Medidas'])
          CheckboxListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(item),
            value: included.contains(item),
            onChanged: (v) => setState(() {
              if (v == true) {
                included.add(item);
              } else {
                included.remove(item);
              }
            }),
          ),
        const SizedBox(height: 24),
        PulseButton(
          'Pré-visualizar relatório',
          icon: Icons.visibility_outlined,
          onPressed: included.isEmpty
              ? null
              : () => setState(() => preview = true),
        ),
        if (preview) ...[
          const SizedBox(height: 24),
          PulseCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Brand(),
                const SizedBox(height: 16),
                Text(
                  'Relatório · $period',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                Text('Módulos: ${included.join(', ')}'),
                const SizedBox(height: 12),
                if (included.contains('Peso'))
                  Text('Último peso informado: ${decimal(store.weight)} kg'),
                if (included.contains('Treinos'))
                  Text('Treinos nesta sessão: ${store.sessions.length}'),
                const SizedBox(height: 16),
                const InfoNote(
                  'Prévia local. A geração de PDF/CSV será conectada posteriormente.',
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

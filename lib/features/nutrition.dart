import 'package:flutter/material.dart';

import '../app/app.dart';
import '../core/store.dart';
import '../core/widgets.dart';

const foodCatalog = [
  ('Banana-prata', 98, 'TACO · referência demonstrativa'),
  ('Aveia em flocos', 394, 'TACO · referência demonstrativa'),
  ('Arroz integral cozido', 124, 'TACO · referência demonstrativa'),
  ('Peito de frango grelhado', 159, 'TACO · referência demonstrativa'),
  ('Iogurte natural', 61, 'Catálogo de demonstração'),
  ('Feijão carioca cozido', 76, 'TACO · referência demonstrativa'),
];
const meals = ['Café da manhã', 'Almoço', 'Jantar', 'Lanches'];

class NutritionPage extends StatefulWidget {
  const NutritionPage({super.key, required this.id, this.subject});
  final int id;
  final String? subject;
  @override
  State<NutritionPage> createState() => _NutritionPageState();
}

class _NutritionPageState extends State<NutritionPage> {
  String query = '', filter = 'Brasileiros', meal = 'Lanches';
  final quantity = TextEditingController(text: '100'),
      name = TextEditingController(),
      kcal = TextEditingController(),
      water = TextEditingController(text: '250');
  final form = GlobalKey<FormState>();
  @override
  void dispose() {
    quantity.dispose();
    name.dispose();
    kcal.dispose();
    water.dispose();
    super.dispose();
  }

  void go(int id, {String? subject}) =>
      openScreen(context, id, subject: subject);
  Future<void> editFood(FoodEntry food) async {
    final store = PulseScope.of(context);
    final editForm = GlobalKey<FormState>();
    var grams = food.grams;
    var selectedMeal = food.meal;
    final saved = await showDialog<bool>(
      context: context,
      builder: (dialog) => AlertDialog(
        title: Text(food.name),
        content: SingleChildScrollView(
          child: Form(
            key: editForm,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  initialValue: decimal(food.grams),
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: const InputDecoration(labelText: 'Porção (g)'),
                  onChanged: (v) =>
                      grams = double.tryParse(v.replaceAll(',', '.')) ?? 0,
                  validator: (_) => grams <= 0 || grams > 10000
                      ? 'Informe de 1 a 10.000 g.'
                      : null,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  initialValue: selectedMeal,
                  isExpanded: true,
                  decoration: const InputDecoration(
                    labelText: 'Mover para refeição',
                  ),
                  items: meals
                      .map((m) => DropdownMenuItem(value: m, child: Text(m)))
                      .toList(),
                  onChanged: (v) => selectedMeal = v!,
                ),
                const SizedBox(height: 16),
                const InfoNote(
                  'A estimativa de energia acompanha a nova porção.',
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialog, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () {
              if (editForm.currentState!.validate()) {
                Navigator.pop(dialog, true);
              }
            },
            child: const Text('Salvar alterações'),
          ),
        ],
      ),
    );
    if (saved == true && mounted) {
      final index = store.foods.indexOf(food);
      if (index >= 0) {
        store.update(
          () => store.foods[index] = FoodEntry(
            food.name,
            grams,
            (food.kcal * grams / food.grams).round(),
            selectedMeal,
          ),
        );
      }
      if (mounted) feedback(context, 'Porção e refeição atualizadas');
    }
  }

  @override
  Widget build(BuildContext context) {
    final store = PulseScope.of(context), id = widget.id;
    if (id == 25) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Nutrir. Registrar.\nEncontrar equilíbrio.',
            style: Theme.of(context).textTheme.headlineLarge,
          ),
          const SizedBox(height: 12),
          const Text('Hoje · 16 de novembro · dados de demonstração'),
          const SizedBox(height: 24),
          PulseCard(
            child: Column(
              children: [
                PulseRing(
                  progress: store.calories / 2100,
                  value: '${store.calories}',
                  label: 'kcal registradas',
                ),
                const SizedBox(height: 20),
                const Text('Meta pessoal de exemplo: 2.100 kcal'),
                const SizedBox(height: 8),
                const InfoNote(
                  'Valores nutricionais estimados, sem recomendação de consumo.',
                ),
                const SizedBox(height: 20),
                PulseButton(
                  'Adicionar refeição',
                  icon: Icons.add,
                  onPressed: () => go(27),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          const AdaptiveGrid(
            children: [
              Metric(
                '58 g',
                'Proteínas · estimativa',
                icon: Icons.egg_outlined,
              ),
              Metric(
                '92 g',
                'Carboidratos · estimativa',
                icon: Icons.grain_rounded,
              ),
              Metric(
                '18 g',
                'Gorduras · estimativa',
                icon: Icons.opacity_rounded,
              ),
            ],
          ),
          const SizedBox(height: 24),
          Section('Suas refeições', action: 'Ver diário', onTap: () => go(26)),
          for (final m in meals)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: PulseTile(
                m,
                '${store.foods.where((f) => f.meal == m).fold(0, (s, f) => s + f.kcal)} kcal · estimadas',
                icon: Icons.restaurant_outlined,
                onTap: () => go(26),
              ),
            ),
          const SizedBox(height: 16),
          PulseTile(
            'Água também faz parte',
            '${store.water} de ${store.waterGoal} mL · meta pessoal',
            icon: Icons.water_drop_outlined,
            onTap: () => go(32),
          ),
          const SizedBox(height: 12),
          PulseTile(
            'Receitas e refeições salvas',
            'Facilite seus próximos registros',
            icon: Icons.bookmark_border,
            onTap: () => go(31),
          ),
          const SizedBox(height: 12),
          PulseButton(
            'Ler código de barras',
            secondary: true,
            icon: Icons.qr_code_scanner,
            onPressed: () => go(29),
          ),
        ],
      );
    }
    if (id == 26) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Hoje, 16/11/2026'),
          for (final m in meals) ...[
            Section(m, action: 'Adicionar', onTap: () => go(27)),
            if (!store.foods.any((f) => f.meal == m))
              const InfoNote(
                'Quando quiser, adicione seu primeiro alimento nesta refeição.',
              ),
            for (final food in store.foods.where((f) => f.meal == m).toList())
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: PulseTile(
                  food.name,
                  '${decimal(food.grams, 0)} g · ${food.kcal} kcal estimadas',
                  icon: Icons.restaurant_outlined,
                  onTap: () => editFood(food),
                  trailing: IconButton(
                    tooltip: 'Remover alimento',
                    onPressed: () {
                      store.update(() => store.foods.remove(food));
                      feedback(
                        context,
                        'Alimento removido',
                        undo: () => store.update(() => store.foods.add(food)),
                      );
                    },
                    icon: const Icon(Icons.delete_outline_rounded),
                  ),
                ),
              ),
          ],
          const SizedBox(height: 24),
          const InfoNote(
            'Origem: catálogo de demonstração e valores informados. Totais estimados.',
          ),
        ],
      );
    }
    if (id == 27) {
      final results = foodCatalog
          .where(
            (f) =>
                f.$1.toLowerCase().contains(query.toLowerCase()) &&
                (filter != 'Favoritos' || store.favorites.contains(f.$1)),
          )
          .toList();
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          PulseSearch(
            label: 'Qual alimento você procura?',
            onChanged: (v) => setState(() => query = v),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: ['Brasileiros', 'Produtos', 'Favoritos', 'Recentes']
                .map(
                  (f) => ChoiceChip(
                    label: Text(f),
                    selected: filter == f,
                    onSelected: (_) => setState(() => filter = f),
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 20),
          Text('${results.length} alimentos · valores por 100 g'),
          const SizedBox(height: 12),
          for (final f in results)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: PulseTile(
                f.$1,
                '${f.$2} kcal / 100 g\n${f.$3}',
                icon: Icons.restaurant_outlined,
                onTap: () => go(28, subject: f.$1),
                trailing: IconButton(
                  tooltip: store.favorites.contains(f.$1)
                      ? 'Remover favorito'
                      : 'Favoritar alimento',
                  onPressed: () => store.update(() {
                    if (!store.favorites.add(f.$1)) {
                      store.favorites.remove(f.$1);
                    }
                  }),
                  icon: Icon(
                    store.favorites.contains(f.$1)
                        ? Icons.bookmark
                        : Icons.bookmark_border,
                  ),
                ),
              ),
            ),
          if (results.isEmpty)
            const InfoNote(
              'Nenhum alimento encontrado. Limpe a busca ou crie um alimento personalizado.',
            ),
          const SizedBox(height: 16),
          PulseButton(
            'Criar alimento personalizado',
            secondary: true,
            icon: Icons.add,
            onPressed: () => go(30),
          ),
        ],
      );
    }
    if (id == 28) {
      final food = foodCatalog.firstWhere(
        (f) => f.$1 == widget.subject,
        orElse: () => foodCatalog.first,
      );
      final grams = double.tryParse(quantity.text.replaceAll(',', '.')) ?? 0;
      final total = (food.$2 * grams / 100).round();
      return Form(
        key: form,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            PulseCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.restaurant_outlined, size: 40),
                  const SizedBox(height: 16),
                  Text(
                    food.$1,
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 8),
                  Text('${food.$2} kcal por 100 g'),
                  const SizedBox(height: 12),
                  InfoNote('${food.$3}. Confira a fonte antes de uso real.'),
                ],
              ),
            ),
            const SizedBox(height: 24),
            TextFormField(
              controller: quantity,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              onChanged: (_) => setState(() {}),
              decoration: const InputDecoration(labelText: 'Quantidade (g)'),
              validator: (v) {
                final n = double.tryParse((v ?? '').replaceAll(',', '.'));
                return n == null || n <= 0 || n > 10000
                    ? 'Informe de 1 a 10.000 g.'
                    : null;
              },
            ),
            const SizedBox(height: 20),
            DropdownButtonFormField<String>(
              initialValue: meal,
              isExpanded: true,
              decoration: const InputDecoration(labelText: 'Refeição'),
              items: meals
                  .map((m) => DropdownMenuItem(value: m, child: Text(m)))
                  .toList(),
              onChanged: (v) => setState(() => meal = v!),
            ),
            const SizedBox(height: 24),
            Text(
              '$total kcal',
              style: Theme.of(context).textTheme.headlineLarge,
            ),
            const Text('Estimativa para a quantidade informada'),
            const SizedBox(height: 24),
            PulseButton(
              'Adicionar à refeição',
              icon: Icons.add,
              onPressed: () {
                if (!form.currentState!.validate()) return;
                store.update(
                  () => store.foods.add(FoodEntry(food.$1, grams, total, meal)),
                );
                feedback(context, 'Alimento adicionado a $meal');
                Navigator.pop(context);
              },
            ),
          ],
        ),
      );
    }
    if (id == 29) {
      return Column(
        children: [
          PulseCard(
            child: ConstrainedBox(
              constraints: const BoxConstraints(minHeight: 220),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.qr_code_scanner_rounded,
                    size: 100,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(height: 16),
                  const Text('Posicione o código dentro da área'),
                  const Text(
                    'Câmera não conectada nesta prévia',
                    style: TextStyle(fontSize: 12),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          const InfoNote(
            'A câmera só será solicitada após sua escolha na versão integrada.',
          ),
          const SizedBox(height: 24),
          const TextField(
            keyboardType: TextInputType.number,
            decoration: InputDecoration(labelText: 'Código de barras manual'),
          ),
          const SizedBox(height: 20),
          PulseButton(
            'Buscar produto de exemplo',
            icon: Icons.search,
            onPressed: () => go(28, subject: 'Iogurte natural'),
          ),
          const SizedBox(height: 12),
          PulseButton(
            'Usar busca por nome',
            secondary: true,
            onPressed: () => go(27),
          ),
        ],
      );
    }
    if (id == 30) {
      return Form(
        key: form,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const InfoNote('Fonte: informado por você · valores para 100 g'),
            const SizedBox(height: 24),
            TextFormField(
              controller: name,
              decoration: const InputDecoration(labelText: 'Nome do alimento'),
              validator: (v) =>
                  (v ?? '').trim().isEmpty ? 'Informe o nome.' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: kcal,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Energia (kcal / 100 g)',
              ),
              validator: (v) {
                final n = int.tryParse(v ?? '');
                return n == null || n < 0 || n > 1000
                    ? 'Informe de 0 a 1.000 kcal.'
                    : null;
              },
            ),
            const SizedBox(height: 16),
            for (final label in [
              'Proteínas (g)',
              'Carboidratos (g)',
              'Gorduras (g)',
            ])
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: TextFormField(
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: InputDecoration(labelText: label),
                  validator: (v) {
                    final n = double.tryParse((v ?? '').replaceAll(',', '.'));
                    return n == null || n < 0 || n > 100
                        ? 'Informe de 0 a 100 g.'
                        : null;
                  },
                ),
              ),
            const SizedBox(height: 16),
            PulseButton(
              'Salvar alimento e registrar',
              icon: Icons.check,
              onPressed: () {
                if (!form.currentState!.validate()) return;
                store.update(
                  () => store.foods.add(
                    FoodEntry(
                      name.text.trim(),
                      100,
                      int.parse(kcal.text),
                      'Lanches',
                    ),
                  ),
                );
                feedback(
                  context,
                  'Alimento personalizado registrado nesta sessão',
                );
                Navigator.pop(context);
              },
            ),
          ],
        ),
      );
    }
    if (id == 31) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Praticidade para\na sua rotina.',
            style: Theme.of(context).textTheme.headlineLarge,
          ),
          const SizedBox(height: 24),
          PulseTile(
            'Bowl de aveia e banana',
            '1 porção · 236 kcal estimadas · receita de exemplo',
            icon: Icons.rice_bowl_outlined,
            onTap: () => go(28, subject: 'Aveia em flocos'),
          ),
          const SizedBox(height: 20),
          const PulseCard(
            child: Text(
              'Ingredientes de exemplo\n\n40 g de aveia em flocos\n80 g de banana-prata\n\nRendimento: 1 porção. Peso e preparo podem alterar os valores.',
            ),
          ),
          const SizedBox(height: 24),
          PulseButton(
            'Adicionar receita ao diário',
            icon: Icons.add,
            onPressed: () {
              store.update(
                () => store.foods.add(
                  FoodEntry('Bowl de aveia e banana', 120, 236, 'Lanches'),
                ),
              );
              feedback(context, 'Receita adicionada ao diário');
            },
          ),
          const SizedBox(height: 12),
          PulseButton(
            'Criar refeição personalizada',
            secondary: true,
            onPressed: () => go(30),
          ),
        ],
      );
    }
    return Column(
      children: [
        Text(
          'Um gole de cada vez.',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        const SizedBox(height: 32),
        PulseRing(
          progress: store.water / store.waterGoal,
          value: decimal(store.water / 1000, 2),
          label: 'litros registrados',
        ),
        const SizedBox(height: 24),
        Text(
          '${store.water} / ${store.waterGoal} mL · meta pessoal demonstrativa',
        ),
        const SizedBox(height: 24),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            for (final ml in [150, 250, 500])
              OutlinedButton.icon(
                onPressed: () {
                  store.addWater(ml);
                  feedback(
                    context,
                    '$ml mL adicionados',
                    undo: () => store.addWater(-ml),
                  );
                },
                icon: const Icon(Icons.add),
                label: Text('$ml mL'),
              ),
          ],
        ),
        const SizedBox(height: 24),
        TextField(
          controller: water,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'Quantidade personalizada (mL)',
          ),
        ),
        const SizedBox(height: 16),
        PulseButton(
          'Registrar água',
          icon: Icons.water_drop_outlined,
          onPressed: () {
            final ml = int.tryParse(water.text);
            if (ml == null || ml <= 0 || ml > 3000) {
              feedback(context, 'Informe de 1 a 3.000 mL.');
              return;
            }
            store.addWater(ml);
            feedback(
              context,
              '$ml mL adicionados',
              undo: () => store.addWater(-ml),
            );
          },
        ),
        const SizedBox(height: 24),
        const InfoNote(
          'Sua necessidade de água é individual. Ajuste sua meta nas preferências.',
        ),
      ],
    );
  }
}

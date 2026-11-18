import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lunaepulse/app/app.dart';
import 'package:lunaepulse/app/theme.dart';
import 'package:lunaepulse/core/store.dart';

Widget host(
  PulseStore store,
  Widget child, {
  bool dark = false,
  double scale = 1,
}) => PulseScope(
  store: store,
  child: MaterialApp(
    locale: const Locale('pt', 'BR'),
    supportedLocales: const [Locale('pt', 'BR')],
    localizationsDelegates: GlobalMaterialLocalizations.delegates,
    theme: pulseTheme(dark ? Brightness.dark : Brightness.light),
    builder: (context, child) => MediaQuery(
      data: MediaQuery.of(context)
          .copyWith(textScaler: TextScaler.linear(scale)),
      child: child!,
    ),
    home: Scaffold(body: child),
  ),
);

void main() {
  for (final config in [
    (390.0, false, 1.0),
    (320.0, true, 1.3),
    (1280.0, false, 1.0),
  ]) {
    testWidgets(
      '53 screens at ${config.$1}px dark=${config.$2} scale=${config.$3}',
      (tester) async {
        tester.view.physicalSize = Size(config.$1, 900);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        final store = PulseStore();
        addTearDown(store.dispose);
        final errors = <String>[];
        for (var id = 1; id <= 53; id++) {
          await tester.pumpWidget(
            host(
              store,
              PageBody(key: ValueKey(id), id: id),
              dark: config.$2,
              scale: config.$3,
            ),
          );
          await tester.pump(const Duration(milliseconds: 80));
          final error = tester.takeException();
          if (error != null) errors.add('T$id : $error');
        }
        await tester.pumpWidget(const SizedBox());
        expect(errors, isEmpty);
      },
    );
  }

  testWidgets('water action changes shared state and undo restores it', (
    tester,
  ) async {
    final store = PulseStore();
    await tester.pumpWidget(host(store, const PageBody(id: 32)));
    final before = store.water;
    await tester.tap(find.text('250 mL'));
    await tester.pumpAndSettle();
    expect(store.water, before + 250);
    await tester.tap(find.text('Desfazer'));
    await tester.pumpAndSettle();
    expect(store.water, before);
  });

  testWidgets('portion recalculates, validates and adds food', (tester) async {
    final store = PulseStore();
    await tester.pumpWidget(
      host(store, const PageBody(id: 28, subject: 'Banana-prata')),
    );
    await tester.enterText(find.byType(TextFormField).first, '200');
    await tester.pump();
    expect(find.text('196 kcal'), findsOneWidget);
    await tester.ensureVisible(find.text('Adicionar à refeição'));
    await tester.tap(find.text('Adicionar à refeição'));
    await tester.pump();
    expect(store.foods.last.grams, 200);
    expect(store.foods.last.kcal, 196);
  });

  testWidgets('workout set survives leaving the workout page', (tester) async {
    final store = PulseStore();
    store.startWorkout();
    await tester.pumpWidget(host(store, const PageBody(id: 21)));
    await tester.ensureVisible(find.text('Concluir série'));
    await tester.tap(find.text('Concluir série'));
    await tester.pumpAndSettle();
    expect(store.completedSets, 1);
    await tester.pumpWidget(const SizedBox());
    await tester.pumpWidget(host(store, const PageBody(id: 16)));
    await tester.pump();
    expect(find.text('Retomar treino'), findsOneWidget);
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('weight rejects bad input and accepts decimal comma', (
    tester,
  ) async {
    final store = PulseStore();
    await tester.pumpWidget(host(store, const PageBody(id: 34)));
    await tester.enterText(find.byType(TextFormField).first, '-5');
    await tester.ensureVisible(find.text('Salvar peso'));
    await tester.tap(find.text('Salvar peso'));
    await tester.pump();
    expect(find.text('Informe um peso entre 1 e 500 kg.'), findsOneWidget);
    await tester.enterText(find.byType(TextFormField).first, '73,2');
    await tester.ensureVisible(find.text('Salvar peso'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Salvar peso'));
    await tester.pump();
    expect(store.weight, 73.2);
    expect(store.weights.last, 73.2);
  });

  testWidgets('search filters and clear restores food catalog', (tester) async {
    final store = PulseStore();
    await tester.pumpWidget(host(store, const PageBody(id: 27)));
    await tester.enterText(find.byType(TextField).first, 'inexistente');
    await tester.pump();
    expect(find.textContaining('Nenhum alimento encontrado'), findsOneWidget);
    await tester.tap(find.byTooltip('Limpar busca'));
    await tester.pump();
    expect(find.text('Banana-prata'), findsOneWidget);
  });

  testWidgets('main tabs and theme are reachable', (tester) async {
    await tester.pumpWidget(const LunaePulseApp());
    await tester.pumpAndSettle();
    expect(find.text('Seu ritmo, Alex.'), findsOneWidget);
    await tester.tap(find.text('Perfil').last);
    await tester.pumpAndSettle();
    expect(find.text('Sua jornada, suas escolhas'), findsOneWidget);
    await tester.tap(find.byTooltip('Alternar tema'));
    await tester.pumpAndSettle();
    expect(
      Theme.of(tester.element(find.byType(PulseShell))).brightness,
      Brightness.dark,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('narrow shell preserves all tabs with enlarged text', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final store = PulseStore();
    await tester.pumpWidget(host(store, const PulseShell(), scale: 1.3));
    for (final tab in [
      'Treinos',
      'Alimentação',
      'Evolução',
      'Perfil',
      'Início',
    ]) {
      await tester.tap(
        find.descendant(
          of: find.byType(NavigationBar),
          matching: find.text(tab),
        ),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull, reason: tab);
    }
  });

  test(
    'custom plan and new workout keep the correct exercises and reset sets',
    () {
      final store = PulseStore();
      store.planExercises['Minha ficha'] = ['Remada baixa'];
      store.startWorkout('Minha ficha');
      expect(store.currentExercises, ['Remada baixa']);
      expect(store.plannedSets, 3);
      store.completedSets = 3;
      store.finishWorkout();
      expect(store.sessions.single, contains('Minha ficha'));
      store.startWorkout();
      expect(store.completedSets, 0);
    },
  );

  testWidgets('diary editing updates portion without duplicating food', (
    tester,
  ) async {
    final store = PulseStore();
    await tester.pumpWidget(host(store, const PageBody(id: 26)));
    await tester.tap(find.text('Aveia em flocos'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField).first, '80');
    await tester.tap(find.text('Salvar alterações'));
    await tester.pumpAndSettle();
    expect(store.foods.length, 3);
    expect(store.foods.first.grams, 80);
    expect(store.foods.first.kcal, 316);
  });
}

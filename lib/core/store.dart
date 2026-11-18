import 'package:flutter/material.dart';

class FoodEntry {
  FoodEntry(this.name, this.grams, this.kcal, this.meal);
  final String name;
  final double grams;
  final int kcal;
  String meal;
}

class PulseStore extends ChangeNotifier {
  ThemeMode themeMode = ThemeMode.system;
  String name = 'Alex';
  int water = 1250;
  int waterGoal = 2000;
  double weight = 72.4;
  final List<double> weights = [73.2, 73.0, 72.8, 73.1, 72.6, 72.5, 72.4];
  final List<FoodEntry> foods = [
    FoodEntry('Aveia em flocos', 40, 158, 'Café da manhã'),
    FoodEntry('Banana-prata', 80, 78, 'Café da manhã'),
    FoodEntry('Arroz, feijão e frango', 350, 485, 'Almoço'),
  ];
  final List<String> plans = ['Superior A', 'Inferior B', 'Corpo inteiro C'];
  final Map<String, List<String>> planExercises = {};
  String currentPlan = 'Superior A';
  List<String> get currentExercises => exercisesFor(currentPlan);
  List<String> exercisesFor(String plan) => planExercises[plan] ?? exercises;
  int get plannedSets => currentExercises.length * 3;
  final List<String> exercises = [
    'Supino reto com halteres',
    'Remada baixa',
    'Desenvolvimento',
    'Elevação lateral',
    'Tríceps na polia',
  ];
  final Set<String> favorites = {};
  final Set<String> goals = {'Ganhar força', 'Criar rotina'};
  final List<String> sessions = [];
  final Map<int, Map<String, String>> drafts = {};
  final Map<String, bool> preferences = {};
  bool activeWorkout = false;
  int completedSets = 0;
  DateTime? workoutStarted;
  int get calories => foods.fold(0, (sum, food) => sum + food.kcal);
  void update(VoidCallback change) {
    change();
    notifyListeners();
  }

  void addWater(int ml) => update(() => water = (water + ml).clamp(0, 20000));
  void startWorkout([String? plan]) => update(() {
    if (!activeWorkout) {
      currentPlan = plan ?? currentPlan;
      completedSets = 0;
    }
    activeWorkout = true;
    workoutStarted ??= DateTime.now();
  });
  void finishWorkout() => update(() {
    sessions.insert(0, '$currentPlan · $completedSets séries · hoje');
    activeWorkout = false;
    workoutStarted = null;
  });
}

class PulseScope extends InheritedNotifier<PulseStore> {
  const PulseScope({super.key, required PulseStore store, required super.child})
    : super(notifier: store);
  static PulseStore of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<PulseScope>()!.notifier!;
}

String decimal(num value, [int places = 1]) =>
    value.toStringAsFixed(places).replaceAll('.', ',');

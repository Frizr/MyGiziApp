import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../../data/models/daily_log_model.dart';
import '../../data/repositories/nutrition_repository.dart';

final manualInputProvider = StateNotifierProvider<ManualInputNotifier, AsyncValue<void>>((ref) {
  final repo = ref.watch(nutritionRepositoryProvider);
  return ManualInputNotifier(repo);
});

class ManualInputNotifier extends StateNotifier<AsyncValue<void>> {
  final NutritionRepository _repository;

  ManualInputNotifier(this._repository) : super(const AsyncValue.data(null));

  Future<void> submitMeal({
    required String foodName,
    required int calories,
    double protein = 0,
    double carbs = 0,
    double fat = 0,
  }) async {
    state = const AsyncValue.loading();
    try {
      final meal = MealItem(
        time: DateTime.now(),
        foodName: foodName,
        calories: calories,
        protein: protein,
        carbs: carbs,
        fat: fat,
      );
      
      await _repository.addManualMeal(meal);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e.toString(), st);
    }
  }
}

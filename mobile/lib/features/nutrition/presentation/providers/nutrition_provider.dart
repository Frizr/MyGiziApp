import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gizi_ai/features/nutrition/data/datasources/nutrition_remote_datasource.dart';
import 'package:gizi_ai/features/nutrition/domain/entities/nutrition_result.dart';

// State class
sealed class NutritionState {
  const NutritionState();
}

class NutritionInitial extends NutritionState {
  const NutritionInitial();
}

class NutritionLoading extends NutritionState {
  const NutritionLoading();
}

class NutritionSuccess extends NutritionState {
  final NutritionResult result;
  final File image;
  const NutritionSuccess({required this.result, required this.image});
}

class NutritionError extends NutritionState {
  final String message;
  const NutritionError(this.message);
}

// Notifier
class NutritionNotifier extends StateNotifier<NutritionState> {
  final NutritionRemoteDatasource _datasource;

  NutritionNotifier(this._datasource) : super(const NutritionInitial());

  Future<void> analyzeFood(File imageFile) async {
    state = const NutritionLoading();
    try {
      final result = await _datasource.analyzeFood(imageFile);
      state = NutritionSuccess(result: result, image: imageFile);
    } catch (e) {
      state = NutritionError(e.toString().replaceFirst('Exception: ', ''));
    }
  }

  void reset() => state = const NutritionInitial();
}

// Providers
final nutritionDatasourceProvider = Provider<NutritionRemoteDatasource>(
  (ref) => NutritionRemoteDatasource(),
);

final nutritionProvider =
    StateNotifierProvider<NutritionNotifier, NutritionState>(
  (ref) => NutritionNotifier(ref.watch(nutritionDatasourceProvider)),
);

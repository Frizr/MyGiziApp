import 'package:gizi_ai/features/nutrition/domain/entities/nutrition_result.dart';

// Data Model — JSON parsing layer (dari Go API response)
class NutritionModel extends NutritionResult {
  const NutritionModel({
    required super.dishName,
    required super.calories,
    required super.proteinG,
    required super.carbsG,
    required super.fatG,
    required super.fiberG,
    required super.sugarG,
    required super.servingSize,
    required super.confidence,
    required super.notes,
  });

  factory NutritionModel.fromJson(Map<String, dynamic> json) {
    return NutritionModel(
      dishName: json['dish_name'] as String? ?? 'Tidak Diketahui',
      calories: (json['calories'] as num?)?.toDouble() ?? 0.0,
      proteinG: (json['protein_g'] as num?)?.toDouble() ?? 0.0,
      carbsG: (json['carbs_g'] as num?)?.toDouble() ?? 0.0,
      fatG: (json['fat_g'] as num?)?.toDouble() ?? 0.0,
      fiberG: (json['fiber_g'] as num?)?.toDouble() ?? 0.0,
      sugarG: (json['sugar_g'] as num?)?.toDouble() ?? 0.0,
      servingSize: json['serving_size'] as String? ?? '1 porsi',
      confidence: json['confidence'] as String? ?? 'medium',
      notes: json['notes'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'dish_name': dishName,
        'calories': calories,
        'protein_g': proteinG,
        'carbs_g': carbsG,
        'fat_g': fatG,
        'fiber_g': fiberG,
        'sugar_g': sugarG,
        'serving_size': servingSize,
        'confidence': confidence,
        'notes': notes,
      };
}

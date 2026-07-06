// Domain Entity — murni Dart, tanpa dependency framework
class NutritionResult {
  final String dishName;
  final double calories;
  final double proteinG;
  final double carbsG;
  final double fatG;
  final double fiberG;
  final double sugarG;
  final String servingSize;
  final String confidence; // "high", "medium", "low"
  final String notes;

  const NutritionResult({
    required this.dishName,
    required this.calories,
    required this.proteinG,
    required this.carbsG,
    required this.fatG,
    required this.fiberG,
    required this.sugarG,
    required this.servingSize,
    required this.confidence,
    required this.notes,
  });

  /// Total macro calories breakdown
  double get proteinCalories => proteinG * 4;
  double get carbsCalories => carbsG * 4;
  double get fatCalories => fatG * 9;

  /// Percentage of each macro relative to total calories
  double get proteinPercent =>
      calories > 0 ? (proteinCalories / calories * 100).clamp(0, 100) : 0;
  double get carbsPercent =>
      calories > 0 ? (carbsCalories / calories * 100).clamp(0, 100) : 0;
  double get fatPercent =>
      calories > 0 ? (fatCalories / calories * 100).clamp(0, 100) : 0;
}

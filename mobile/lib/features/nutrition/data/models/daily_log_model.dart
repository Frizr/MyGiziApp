import 'package:cloud_firestore/cloud_firestore.dart';

class MealItem {
  final DateTime time;
  final String foodName;
  final int calories;
  final double protein;
  final double carbs;
  final double fat;

  MealItem({
    required this.time,
    required this.foodName,
    required this.calories,
    this.protein = 0,
    this.carbs = 0,
    this.fat = 0,
  });

  factory MealItem.fromJson(Map<String, dynamic> json) {
    return MealItem(
      time: (json['time'] as Timestamp).toDate(),
      foodName: json['foodName'] as String,
      calories: json['calories'] as int,
      protein: (json['protein'] ?? 0).toDouble(),
      carbs: (json['carbs'] ?? 0).toDouble(),
      fat: (json['fat'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'time': Timestamp.fromDate(time),
      'foodName': foodName,
      'calories': calories,
      'protein': protein,
      'carbs': carbs,
      'fat': fat,
    };
  }
}

class DailyLogModel {
  final String uid;
  final String date;
  final int targetCalories;
  final int currentCalories;
  final double currentProtein;
  final double currentCarbs;
  final double currentFat;
  final List<MealItem> meals;

  DailyLogModel({
    required this.uid,
    required this.date,
    required this.targetCalories,
    this.currentCalories = 0,
    this.currentProtein = 0,
    this.currentCarbs = 0,
    this.currentFat = 0,
    this.meals = const [],
  });

  factory DailyLogModel.fromJson(Map<String, dynamic> json) {
    return DailyLogModel(
      uid: json['uid'] as String,
      date: json['date'] as String,
      targetCalories: json['targetCalories'] as int,
      currentCalories: json['currentCalories'] as int? ?? 0,
      currentProtein: (json['currentProtein'] ?? 0).toDouble(),
      currentCarbs: (json['currentCarbs'] ?? 0).toDouble(),
      currentFat: (json['currentFat'] ?? 0).toDouble(),
      meals: (json['meals'] as List<dynamic>?)
              ?.map((e) => MealItem.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'date': date,
      'targetCalories': targetCalories,
      'currentCalories': currentCalories,
      'currentProtein': currentProtein,
      'currentCarbs': currentCarbs,
      'currentFat': currentFat,
      'meals': meals.map((e) => e.toJson()).toList(),
    };
  }
  
  DailyLogModel copyWith({
    String? uid,
    String? date,
    int? targetCalories,
    int? currentCalories,
    double? currentProtein,
    double? currentCarbs,
    double? currentFat,
    List<MealItem>? meals,
  }) {
    return DailyLogModel(
      uid: uid ?? this.uid,
      date: date ?? this.date,
      targetCalories: targetCalories ?? this.targetCalories,
      currentCalories: currentCalories ?? this.currentCalories,
      currentProtein: currentProtein ?? this.currentProtein,
      currentCarbs: currentCarbs ?? this.currentCarbs,
      currentFat: currentFat ?? this.currentFat,
      meals: meals ?? this.meals,
    );
  }
}

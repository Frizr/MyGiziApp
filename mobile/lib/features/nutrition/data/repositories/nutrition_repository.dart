import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:gizi_ai/core/services/device_id_service.dart';
import '../models/daily_log_model.dart';
import 'package:intl/intl.dart';

final nutritionRepositoryProvider = Provider<NutritionRepository>((ref) {
  return NutritionRepository(FirebaseFirestore.instance);
});

class NutritionRepository {
  final FirebaseFirestore _firestore;

  NutritionRepository(this._firestore);

  String get _todayDateStr {
    final now = DateTime.now();
    return DateFormat('yyyy-MM-dd').format(now);
  }

  String get _currentUid {
    final id = DeviceIdService.cachedId;
    if (id == null) throw Exception('Device ID not initialized');
    return id;
  }

  Future<void> addManualMeal(MealItem meal) async {
    final uid = _currentUid;
    final date = _todayDateStr;
    final docId = '${uid}_$date';
    final docRef = _firestore.collection('daily_logs').doc(docId);

    return _firestore.runTransaction((transaction) async {
      final snapshot = await transaction.get(docRef);

      if (!snapshot.exists) {
        final newLog = DailyLogModel(
          uid: uid,
          date: date,
          targetCalories: 2000,
          currentCalories: meal.calories,
          currentProtein: meal.protein,
          currentCarbs: meal.carbs,
          currentFat: meal.fat,
          meals: [meal],
        );
        transaction.set(docRef, newLog.toJson());
      } else {
        final log = DailyLogModel.fromJson(snapshot.data()!);

        final updatedMeals = List<MealItem>.from(log.meals)..add(meal);
        final updatedLog = log.copyWith(
          currentCalories: log.currentCalories + meal.calories,
          currentProtein: log.currentProtein + meal.protein,
          currentCarbs: log.currentCarbs + meal.carbs,
          currentFat: log.currentFat + meal.fat,
          meals: updatedMeals,
        );

        transaction.update(docRef, updatedLog.toJson());
      }

      // Update user score (+10 per meal entry) — use device ID as user doc
      final userRef = _firestore.collection('users').doc(uid);
      final userSnap = await transaction.get(userRef);
      if (userSnap.exists) {
        transaction.update(userRef, {
          'score': FieldValue.increment(10),
        });
      } else {
        // Create user doc for anonymous device
        transaction.set(userRef, {
          'uid': uid,
          'name': 'Pengguna',
          'email': '',
          'score': 10,
          'level': 1,
          'createdAt': FieldValue.serverTimestamp(),
        });
      }
    });
  }
}

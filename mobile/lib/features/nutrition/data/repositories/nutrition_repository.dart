import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../models/daily_log_model.dart';
import 'package:intl/intl.dart';

final nutritionRepositoryProvider = Provider<NutritionRepository>((ref) {
  return NutritionRepository(
    FirebaseFirestore.instance,
    FirebaseAuth.instance,
  );
});

class NutritionRepository {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  NutritionRepository(this._firestore, this._auth);

  String get _todayDateStr {
    final now = DateTime.now();
    return DateFormat('yyyy-MM-dd').format(now);
  }

  String get _currentUid {
    final user = _auth.currentUser;
    if (user == null) throw Exception('User not logged in');
    return user.uid;
  }

  Future<void> addManualMeal(MealItem meal) async {
    final uid = _currentUid;
    final date = _todayDateStr;
    final docId = '${uid}_$date';
    final docRef = _firestore.collection('daily_logs').doc(docId);

    return _firestore.runTransaction((transaction) async {
      final snapshot = await transaction.get(docRef);

      if (!snapshot.exists) {
        // Create new log if doesn't exist (assuming target 2000 for now)
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
        // Update existing log
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
      
      // Update User Score (+10 per meal entry)
      final userRef = _firestore.collection('users').doc(uid);
      transaction.update(userRef, {
        'score': FieldValue.increment(10)
      });
    });
  }
}

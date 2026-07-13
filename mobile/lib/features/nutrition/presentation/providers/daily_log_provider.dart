import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import '../../data/models/daily_log_model.dart';

final todayLogStreamProvider = StreamProvider.autoDispose<DailyLogModel?>((ref) {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) {
    return Stream.value(null);
  }

  final uid = user.uid;
  final dateStr = DateFormat('yyyy-MM-dd').format(DateTime.now());
  final docId = '${uid}_$dateStr';

  return FirebaseFirestore.instance
      .collection('daily_logs')
      .doc(docId)
      .snapshots()
      .map((snapshot) {
    if (!snapshot.exists || snapshot.data() == null) {
      return null;
    }
    return DailyLogModel.fromJson(snapshot.data()!);
  });
});

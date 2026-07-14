import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:gizi_ai/core/services/device_id_service.dart';
import '../../data/models/daily_log_model.dart';

/// Provides device ID as a synchronous cached value.
/// DeviceIdService.getDeviceId() is called in main() before runApp,
/// so the cached value is always available.
final deviceIdProvider = Provider<String>((ref) {
  // This is safe because we pre-loaded it in main()
  return DeviceIdService.cachedId!;
});

/// Stream today's daily log from Firestore using device ID (no auth).
final todayLogStreamProvider = StreamProvider.autoDispose<DailyLogModel?>((ref) {
  final uid = ref.watch(deviceIdProvider);
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

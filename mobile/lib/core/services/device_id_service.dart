import 'package:shared_preferences/shared_preferences.dart';
import 'dart:math';

/// Generates and persists a unique device ID for anonymous usage.
/// No login required — data tied to this ID across sessions.
class DeviceIdService {
  static const _key = 'mygiziapp_device_id';
  static String? _cachedId;

  /// Synchronous access to cached ID (available after getDeviceId() called once)
  static String? get cachedId => _cachedId;

  /// Get or create device ID. Cached in memory after first call.
  static Future<String> getDeviceId() async {
    if (_cachedId != null) return _cachedId!;

    final prefs = await SharedPreferences.getInstance();
    var id = prefs.getString(_key);

    if (id == null) {
      id = _generateId();
      await prefs.setString(_key, id);
    }

    _cachedId = id;
    return id;
  }

  static String _generateId() {
    const chars = 'abcdefghijklmnopqrstuvwxyz0123456789';
    final rand = Random();
    final buffer = StringBuffer('anon_');
    for (var i = 0; i < 16; i++) {
      buffer.write(chars[rand.nextInt(chars.length)]);
    }
    return buffer.toString();
  }
}

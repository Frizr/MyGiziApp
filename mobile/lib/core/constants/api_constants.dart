class ApiConstants {
  ApiConstants._();

  // ⚠️ Ganti IP ini dengan IP komputer kamu saat development
  // Cek IP dengan: ipconfig (Windows) → IPv4 Address
  // Contoh: 'http://192.168.1.5:8080'
  // Untuk emulator Android: gunakan 'http://10.0.2.2:8080'
  // Untuk device fisik: gunakan IP lokal komputer kamu
  static const String baseUrl = 'http://10.0.2.2:8080';

  static const Duration connectTimeout = Duration(seconds: 10);
  static const Duration receiveTimeout = Duration(seconds: 45);
}

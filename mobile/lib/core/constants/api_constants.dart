class ApiConstants {
  ApiConstants._();

  // ⚠️ Ganti IP ini dengan IP komputer kamu saat development
  // Cek IP dengan: ipconfig (Windows) → IPv4 Address
  // Contoh: 'http://192.168.1.5:8080'
  // Untuk emulator Android: gunakan 'http://10.0.2.2:8080'
  // Untuk device fisik: gunakan IP lokal komputer kamu
  static const String baseUrl = 'http://10.0.2.2:8080'; // <-- Ganti ke 8080 sesuai backend Go yang ada, atau biarkan 8000 jika murni Laravel

  static const Duration connectTimeout = Duration(seconds: 15);
  static const Duration receiveTimeout = Duration(seconds: 45);

  // Endpoints Auth
  static const String login = '/api/login';
  static const String register = '/api/register';
  static const String logout = '/api/logout';

  // AI Endpoints
  // Jika pakai backend GO bawaan, endpoint-nya adalah POST /analyze
  static const String analyze = '/analyze';

  // Endpoint untuk request ke backend AI khusus (seperti request sebelumnya)
  static const String analyzeGroq = '/api/analyze/groq';
  static const String analyzeGemini = '/api/analyze/gemini';
}
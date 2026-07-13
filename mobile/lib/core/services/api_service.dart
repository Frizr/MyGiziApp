import 'package:dio/dio.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../constants/api_constants.dart';

final apiServiceProvider = Provider<ApiService>((ref) {
  return ApiService();
});

class ApiService {
  late final Dio _dio;

  ApiService() {
    _dio = Dio(
      BaseOptions(
        baseUrl: ApiConstants.baseUrl,
        connectTimeout: ApiConstants.connectTimeout,
        receiveTimeout: ApiConstants.receiveTimeout,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          // TODO: Inject Bearer Token here from SharedPreferences/SecureStorage
          // final token = await getToken();
          // if (token != null) {
          //   options.headers['Authorization'] = 'Bearer $token';
          // }
          return handler.next(options);
        },
        onError: (DioException e, handler) {
          // Log or handle global errors here
          return handler.next(e);
        },
      ),
    );
  }

  // --- Auth Endpoints ---

  Future<Response> login(String email, String password) async {
    try {
      final response = await _dio.post(
        ApiConstants.login,
        data: {
          'email': email,
          'password': password,
        },
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }

  // --- AI Integrations (Gemini / Groq) ---

  Future<Response> testGeminiAPI(String prompt) async {
    try {
      final response = await _dio.post(
        ApiConstants.analyzeGemini,
        data: {'prompt': prompt},
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future<Response> testGroqAPI(String prompt) async {
    try {
      final response = await _dio.post(
        ApiConstants.analyzeGroq,
        data: {'prompt': prompt},
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }
}
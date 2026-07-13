import 'package:dio/dio.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../../../../core/services/api_service.dart';
import '../../data/models/auth_model.dart';

final authControllerProvider = StateNotifierProvider<AuthController, AsyncValue<AuthModel?>>((ref) {
  final apiService = ref.watch(apiServiceProvider);
  return AuthController(apiService);
});

class AuthController extends StateNotifier<AsyncValue<AuthModel?>> {
  final ApiService _apiService;

  AuthController(this._apiService) : super(const AsyncValue.data(null));

  Future<void> login(String email, String password) async {
    state = const AsyncValue.loading();
    try {
      final response = await _apiService.login(email, password);

      if (response.statusCode == 200 || response.statusCode == 201) {
        final authData = AuthModel.fromJson(response.data);

        // TODO: Save token to local storage (SharedPreferences / Secure Storage)

        state = AsyncValue.data(authData);
      } else {
        state = AsyncValue.error('Login failed: ${response.statusMessage}', StackTrace.current);
      }
    } on DioException catch (e) {
      final data = e.response?.data;
      String errorMessage = 'An unexpected error occurred';
      if (data is Map && data['message'] != null) {
        errorMessage = data['message'].toString();
      } else if (e.message != null) {
        errorMessage = e.message!;
      }
      state = AsyncValue.error(errorMessage, e.stackTrace);
    } catch (e, st) {
      state = AsyncValue.error(e.toString(), st);
    }
  }

  void logout() {
    // TODO: Clear token from local storage
    state = const AsyncValue.data(null);
  }
}
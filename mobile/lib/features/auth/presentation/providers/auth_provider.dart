import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../../data/repositories/auth_repository.dart';
import 'package:firebase_auth/firebase_auth.dart';

// Provider untuk AuthRepository
final authRepositoryProvider = Provider<AuthRepository>((ref) => AuthRepository());

// Provider untuk memantau status stream (apakah user login/logout)
final authStateProvider = StreamProvider<User?>((ref) {
  return ref.watch(authRepositoryProvider).authStateChanges;
});

// Provider untuk aksi Login/Register (StateNotifier)
final authControllerProvider = StateNotifierProvider<AuthController, AsyncValue<void>>((ref) {
  return AuthController(ref.watch(authRepositoryProvider));
});

class AuthController extends StateNotifier<AsyncValue<void>> {
  final AuthRepository _repository;

  AuthController(this._repository) : super(const AsyncValue.data(null));

  Future<void> login(String email, String password) async {
    state = const AsyncValue.loading();
    try {
      await _repository.loginWithEmail(email, password);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(_handleFirebaseAuthError(e), st);
    }
  }

  Future<void> register(String name, String email, String password) async {
    state = const AsyncValue.loading();
    try {
      await _repository.registerWithEmail(name, email, password);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(_handleFirebaseAuthError(e), st);
    }
  }

  Future<void> logout() async {
    await _repository.logout();
  }

  // Helper untuk membaca pesan error Firebase agar ramah user
  String _handleFirebaseAuthError(dynamic error) {
    if (error is FirebaseAuthException) {
      switch (error.code) {
        case 'user-not-found':
          return 'Email tidak ditemukan, silakan daftar dulu.';
        case 'wrong-password':
          return 'Password salah.';
        case 'email-already-in-use':
          return 'Email ini sudah terdaftar.';
        case 'weak-password':
          return 'Password terlalu lemah (minimal 6 karakter).';
        case 'invalid-email':
          return 'Format email tidak valid.';
        default:
          return error.message ?? 'Terjadi kesalahan autentikasi.';
      }
    }
    return error.toString();
  }
}

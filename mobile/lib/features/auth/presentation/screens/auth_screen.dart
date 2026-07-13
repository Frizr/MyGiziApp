import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:gizi_ai/core/theme/app_theme.dart';
import '../providers/auth_provider.dart';

class AuthScreen extends HookConsumerWidget {
  const AuthScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // State local untuk toggle form
    final isLoginMode = useState(true);
    final isPasswordVisible = useState(false);

    // Controllers
    final nameController = useTextEditingController();
    final emailController = useTextEditingController();
    final passwordController = useTextEditingController();

    // Pantau status action auth dari Riverpod (loading/error)
    final authState = ref.watch(authControllerProvider);

    // Action Submit
    void submit() {
      if (emailController.text.trim().isEmpty || passwordController.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Isi semua field terlebih dahulu')),
        );
        return;
      }

      if (isLoginMode.value) {
        ref.read(authControllerProvider.notifier).login(
              emailController.text.trim(),
              passwordController.text,
            );
      } else {
        if (nameController.text.trim().isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Isi nama panggilan kamu')),
          );
          return;
        }
        ref.read(authControllerProvider.notifier).register(
              nameController.text.trim(),
              emailController.text.trim(),
              passwordController.text,
            );
      }
    }

    // Dengarkan perubahan state pada Action Auth untuk menembakkan popup error
    ref.listen<AsyncValue<void>>(authControllerProvider, (previous, next) {
      next.whenOrNull(
        error: (error, stackTrace) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(error.toString()),
              backgroundColor: Colors.redAccent,
            ),
          );
        },
      );
    });

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Icon(Icons.shield_moon_rounded, size: 80, color: AppTheme.primary),
              const SizedBox(height: 24),
              Text(
                isLoginMode.value ? 'Selamat Datang Kembali!' : 'Ayo Mulai Jurnal Gizi-mu!',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: AppTheme.onSurface,
                      fontWeight: FontWeight.bold,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),

              // Form Name (Hanya untuk register)
              if (!isLoginMode.value) ...[
                _buildTextField(
                  controller: nameController,
                  label: 'Nama Panggilan',
                  icon: Icons.person_outline,
                ),
                const SizedBox(height: 16),
              ],

              // Form Email
              _buildTextField(
                controller: emailController,
                label: 'Email',
                icon: Icons.email_outlined,
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 16),

              // Form Password
              _buildTextField(
                controller: passwordController,
                label: 'Password',
                icon: Icons.lock_outline,
                isPassword: true,
                isPasswordVisible: isPasswordVisible.value,
                onVisibilityToggle: () {
                  isPasswordVisible.value = !isPasswordVisible.value;
                },
              ),
              const SizedBox(height: 32),

              // Tombol Submit
              ElevatedButton(
                onPressed: authState.isLoading ? null : submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primary,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: authState.isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(color: Colors.black, strokeWidth: 2),
                      )
                    : Text(
                        isLoginMode.value ? 'Masuk' : 'Daftar Sekarang',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
              ),

              const SizedBox(height: 16),

              // Text Button Toggle Login/Register
              TextButton(
                onPressed: () {
                  isLoginMode.value = !isLoginMode.value;
                },
                child: Text(
                  isLoginMode.value
                      ? 'Belum punya akun? Daftar di sini.'
                      : 'Sudah punya akun? Masuk di sini.',
                  style: const TextStyle(color: AppTheme.primary),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool isPassword = false,
    bool isPasswordVisible = false,
    VoidCallback? onVisibilityToggle,
    TextInputType? keyboardType,
  }) {
    return TextField(
      controller: controller,
      obscureText: isPassword && !isPasswordVisible,
      keyboardType: keyboardType,
      style: const TextStyle(color: AppTheme.onSurface),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: AppTheme.onSurfaceMuted),
        prefixIcon: Icon(icon, color: AppTheme.onSurfaceMuted),
        suffixIcon: isPassword
            ? IconButton(
                icon: Icon(
                  isPasswordVisible ? Icons.visibility_off : Icons.visibility,
                  color: AppTheme.onSurfaceMuted,
                ),
                onPressed: onVisibilityToggle,
              )
            : null,
        filled: true,
        fillColor: AppTheme.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppTheme.primary, width: 2),
        ),
      ),
    );
  }
}
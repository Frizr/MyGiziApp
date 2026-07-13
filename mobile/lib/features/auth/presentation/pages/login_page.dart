import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../controllers/auth_controller.dart';
import '../../../../core/services/api_service.dart';

class LoginPage extends HookConsumerWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final emailController = useTextEditingController();
    final passwordController = useTextEditingController();
    final isPasswordVisible = useState(false);

    // Auth State
    final authState = ref.watch(authControllerProvider);

    // Testing state for AI
    final aiResponseState = useState<String?>(null);
    final isAiLoading = useState(false);

    // Watch API Service for AI testing
    final apiService = ref.watch(apiServiceProvider);

    void onLogin() {
      if (emailController.text.isEmpty || passwordController.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please fill all fields')),
        );
        return;
      }
      ref.read(authControllerProvider.notifier).login(
            emailController.text,
            passwordController.text,
          );
    }

    Future<void> onTestGemini() async {
      isAiLoading.value = true;
      aiResponseState.value = null;
      try {
        final res = await apiService.testGeminiAPI('Hai, berikan informasi gizi singkat dari apel.');
        aiResponseState.value = 'Gemini Response: \n${res.data}';
      } catch (e) {
        aiResponseState.value = 'Error Gemini: $e';
      } finally {
        isAiLoading.value = false;
      }
    }

    Future<void> onTestGroq() async {
      isAiLoading.value = true;
      aiResponseState.value = null;
      try {
        final res = await apiService.testGroqAPI('Hai, berikan informasi gizi singkat dari apel.');
        aiResponseState.value = 'Groq Response: \n${res.data}';
      } catch (e) {
        aiResponseState.value = 'Error Groq: $e';
      } finally {
        isAiLoading.value = false;
      }
    }

    // Listen for Auth changes (like success or error)
    ref.listen<AsyncValue>(authControllerProvider, (previous, next) {
      next.whenOrNull(
        error: (error, stackTrace) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(error.toString()), backgroundColor: Colors.red),
          );
        },
        data: (data) {
          if (data != null) {
             ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Login Success!'), backgroundColor: Colors.green),
            );
            // Navigate to next screen, e.g. Home
          }
        },
      );
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Gizi AI - Login & Test'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Icon(Icons.fastfood_rounded, size: 80, color: Colors.green),
            const SizedBox(height: 32),

            // --- LOGIN FORM ---
            TextField(
              controller: emailController,
              decoration: const InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.email),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: passwordController,
              obscureText: !isPasswordVisible.value,
              decoration: InputDecoration(
                labelText: 'Password',
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.lock),
                suffixIcon: IconButton(
                  icon: Icon(
                    isPasswordVisible.value ? Icons.visibility : Icons.visibility_off,
                  ),
                  onPressed: () {
                    isPasswordVisible.value = !isPasswordVisible.value;
                  },
                ),
              ),
            ),
            const SizedBox(height: 24),

            ElevatedButton(
              onPressed: authState.isLoading ? null : onLogin,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: authState.isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('LOGIN'),
            ),

            const Divider(height: 48),

            // --- AI API TESTING ---
            const Text(
              'Test AI API Endpoints (backend)',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: isAiLoading.value ? null : onTestGemini,
                    icon: const Icon(Icons.auto_awesome),
                    label: const Text('Test Gemini'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: isAiLoading.value ? null : onTestGroq,
                    icon: const Icon(Icons.bolt),
                    label: const Text('Test Groq'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            if (isAiLoading.value)
               const Center(child: CircularProgressIndicator()),

            if (aiResponseState.value != null && !isAiLoading.value)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(aiResponseState.value!),
              )
          ],
        ),
      ),
    );
  }
}
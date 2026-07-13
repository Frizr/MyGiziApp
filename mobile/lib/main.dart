import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gizi_ai/core/theme/app_theme.dart';
import 'package:gizi_ai/features/nutrition/presentation/screens/main_dashboard_screen.dart';
import 'package:gizi_ai/features/auth/presentation/screens/auth_screen.dart';
import 'package:gizi_ai/features/auth/presentation/providers/auth_provider.dart';

import "package:firebase_core/firebase_core.dart";

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(
    const ProviderScope(
      child: GiziAiApp(),
    ),
  );
}

class GiziAiApp extends ConsumerWidget {
  const GiziAiApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Pantau status login Firebase secara realtime
    final authState = ref.watch(authStateProvider);

    return MaterialApp(
      title: 'Gizi AI',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: authState.when(
        data: (user) {
          // Jika ada data user (sudah login), masuk ke Home
          if (user != null) {
            return const MainDashboardScreen();
          }
          // Jika belum login, masuk ke halaman Auth
          return const AuthScreen();
        },
        loading: () => const Scaffold(
          body: Center(
            child: CircularProgressIndicator(color: AppTheme.primary),
          ),
        ),
        error: (err, stack) => Scaffold(
          body: Center(
            child: Text('Error initializing auth: $err', style: const TextStyle(color: Colors.red)),
          ),
        ),
      ),
    );
  }
}
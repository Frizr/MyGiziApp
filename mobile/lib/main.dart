import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:gizi_ai/core/theme/app_theme.dart';
import 'package:gizi_ai/core/services/device_id_service.dart';
import 'package:gizi_ai/features/nutrition/presentation/screens/main_dashboard_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  // Pre-load device ID so it's cached before any provider reads it
  await DeviceIdService.getDeviceId();
  runApp(
    const ProviderScope(
      child: GiziAiApp(),
    ),
  );
}

class GiziAiApp extends StatelessWidget {
  const GiziAiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MyGiziApp',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: const MainDashboardScreen(),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gizi_ai/core/theme/app_theme.dart';
import 'package:gizi_ai/features/nutrition/presentation/screens/home_screen.dart';

void main() {
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
      title: 'Gizi AI',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: const HomeScreen(),
    );
  }
}

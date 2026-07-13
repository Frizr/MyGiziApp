import 'package:flutter/material.dart';
import 'package:gizi_ai/core/theme/app_theme.dart';

class LeaderboardPage extends StatelessWidget {
  const LeaderboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        'Leaderboard',
        style: TextStyle(color: AppTheme.onSurface),
      ),
    );
  }
}

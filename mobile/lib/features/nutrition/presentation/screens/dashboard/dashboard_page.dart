import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import 'package:gizi_ai/core/theme/app_theme.dart';
import '../../providers/daily_log_provider.dart';
import '../../widgets/macro_bar.dart';

class DashboardPage extends HookConsumerWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dailyLogAsync = ref.watch(todayLogStreamProvider);

    return dailyLogAsync.when(
      data: (log) {
        if (log == null) {
          return _buildEmptyState();
        }

        final targetProtein = log.targetCalories * 0.2 / 4;
        final targetCarbs = log.targetCalories * 0.5 / 4;
        final targetFat = log.targetCalories * 0.3 / 9;

        return RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(todayLogStreamProvider);
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildDateHeader().animate().fadeIn().slideY(begin: -0.2),
                const SizedBox(height: 32),

                // Health Bar
                _buildHealthBar(log.currentCalories, log.targetCalories)
                    .animate()
                    .fadeIn(delay: 100.ms)
                    .slideY(begin: 0.1),

                const SizedBox(height: 32),

                // Macros
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppTheme.surface,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppTheme.surfaceElevated),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Makronutrien',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 24),
                      MacroBar(
                        label: 'Protein',
                        value: log.currentProtein,
                        unit: 'g',
                        percent: targetProtein > 0 ? (log.currentProtein / targetProtein * 100) : 0,
                        color: AppTheme.proteinColor,
                      ),
                      const SizedBox(height: 16),
                      MacroBar(
                        label: 'Karbohidrat',
                        value: log.currentCarbs,
                        unit: 'g',
                        percent: targetCarbs > 0 ? (log.currentCarbs / targetCarbs * 100) : 0,
                        color: AppTheme.carbsColor,
                      ),
                      const SizedBox(height: 16),
                      MacroBar(
                        label: 'Lemak',
                        value: log.currentFat,
                        unit: 'g',
                        percent: targetFat > 0 ? (log.currentFat / targetFat * 100) : 0,
                        color: AppTheme.fatColor,
                      ),
                    ],
                  ),
                ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.1),

                const SizedBox(height: 32),

                // Meals List
                if (log.meals.isNotEmpty) ...[
                  const Text(
                    'Riwayat Makanan Hari Ini',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.onSurface,
                    ),
                  ).animate().fadeIn(delay: 300.ms),
                  const SizedBox(height: 16),
                  ...log.meals.asMap().entries.map((entry) {
                    final meal = entry.value;
                    final timeStr = DateFormat('HH:mm').format(meal.time);
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppTheme.surface,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppTheme.surfaceElevated),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: AppTheme.calorieColor.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.restaurant,
                              color: AppTheme.calorieColor,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  meal.foodName,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: AppTheme.onSurface,
                                    fontSize: 15,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  timeStr,
                                  style: const TextStyle(
                                    color: AppTheme.onSurfaceMuted,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            '${meal.calories} kcal',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: AppTheme.calorieColor,
                              fontSize: 15,
                            ),
                          ),
                        ],
                      ),
                    ).animate().fadeIn(delay: (400 + entry.key * 50).ms).slideX(begin: 0.1);
                  }),
                ]
              ],
            ),
          ),
        );
      },
      loading: () => const Center(
        child: CircularProgressIndicator(color: AppTheme.primary),
      ),
      error: (err, stack) => Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, color: AppTheme.error, size: 48),
              const SizedBox(height: 16),
              Text(
                'Gagal memuat data:\n$err',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.redAccent),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () => ref.invalidate(todayLogStreamProvider),
                icon: const Icon(Icons.refresh),
                label: const Text('Coba Lagi'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primary,
                  foregroundColor: Colors.black,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.restaurant_menu,
            size: 80,
            color: AppTheme.surfaceElevated,
          ).animate().scale(delay: 200.ms, duration: 400.ms),
          const SizedBox(height: 24),
          const Text(
            'Belum ada asupan hari ini',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppTheme.onSurface,
            ),
          ).animate().fadeIn(delay: 300.ms),
          const SizedBox(height: 8),
          const Text(
            'Catat makanan pertamamu di tab Input!',
            style: TextStyle(
              fontSize: 14,
              color: AppTheme.onSurfaceMuted,
            ),
          ).animate().fadeIn(delay: 400.ms),
        ],
      ),
    );
  }

  Widget _buildDateHeader() {
    final now = DateTime.now();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Health Bar',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: AppTheme.onSurface,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          DateFormat('EEEE, d MMM yyyy').format(now),
          style: const TextStyle(
            fontSize: 14,
            color: AppTheme.onSurfaceMuted,
          ),
        ),
      ],
    );
  }

  Widget _buildHealthBar(int current, int target) {
    final double percent = target > 0 ? (current / target).clamp(0.0, 1.0) : 0.0;

    Color barColor = AppTheme.primary;
    if (percent >= 1.0) {
      barColor = Colors.redAccent;
    } else if (percent > 0.8) {
      barColor = Colors.orangeAccent;
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: barColor.withValues(alpha: 0.3), width: 2),
        boxShadow: [
          BoxShadow(
            color: barColor.withValues(alpha: 0.1),
            blurRadius: 20,
            spreadRadius: -5,
          )
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Kalori Terkumpul',
                    style: TextStyle(
                      color: AppTheme.onSurfaceMuted,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        current.toString(),
                        style: TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                          color: barColor,
                        ),
                      ),
                      const Text(
                        ' kcal',
                        style: TextStyle(
                          fontSize: 16,
                          color: AppTheme.onSurfaceMuted,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text(
                    'Target',
                    style: TextStyle(
                      color: AppTheme.onSurfaceMuted,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$target kcal',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.onSurface,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),
          // Fixed health bar - no more nested AnimatedContainer/FractionallySizedBox bug
          LayoutBuilder(
            builder: (context, constraints) {
              final barWidth = constraints.maxWidth * percent;
              return ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Stack(
                  children: [
                    Container(
                      height: 20,
                      width: double.infinity,
                      color: AppTheme.surfaceElevated,
                    ),
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 1000),
                      curve: Curves.easeOutCubic,
                      height: 20,
                      width: barWidth,
                      decoration: BoxDecoration(
                        color: barColor,
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                            color: barColor.withValues(alpha: 0.5),
                            blurRadius: 8,
                          )
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          const SizedBox(height: 8),
          Text(
            '${(percent * 100).toStringAsFixed(0)}%',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: barColor,
            ),
          ),
        ],
      ),
    );
  }
}

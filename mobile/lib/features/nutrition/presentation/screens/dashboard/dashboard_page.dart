import 'dart:io';
import 'dart:math';
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
          return _buildEmptyState(context);
        }

        final targetProtein = log.targetCalories * 0.2 / 4;
        final targetCarbs = log.targetCalories * 0.5 / 4;
        final targetFat = log.targetCalories * 0.3 / 9;

        return RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(todayLogStreamProvider);
          },
          color: AppTheme.primary,
          backgroundColor: AppTheme.surface,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Gradient Header
                _buildGradientHeader(context, log.currentCalories, log.targetCalories)
                    .animate()
                    .fadeIn(duration: 500.ms)
                    .slideY(begin: -0.1),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 24),

                      // Quick Stats Row
                      _buildQuickStats(log.meals.length, log.currentCalories, log.targetCalories)
                          .animate()
                          .fadeIn(delay: 200.ms)
                          .slideY(begin: 0.1),

                      const SizedBox(height: 24),

                      // Macros Card
                      _buildMacrosCard(
                        log.currentProtein, targetProtein,
                        log.currentCarbs, targetCarbs,
                        log.currentFat, targetFat,
                      ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.1),

                      const SizedBox(height: 24),

                      // Meals List
                      if (log.meals.isNotEmpty) ...[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              '🍽️ Riwayat Hari Ini',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.onSurface,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppTheme.primary.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                '${log.meals.length} item',
                                style: const TextStyle(
                                  color: AppTheme.primary,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
                        ).animate().fadeIn(delay: 400.ms),
                        const SizedBox(height: 16),
                        ...log.meals.reversed.toList().asMap().entries.map((entry) {
                          final meal = entry.value;
                          final timeStr = DateFormat('HH:mm').format(meal.time);
                          final hasImage = meal.imagePath != null && meal.imagePath!.isNotEmpty;

                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  AppTheme.surface,
                                  AppTheme.surfaceElevated.withValues(alpha: 0.5),
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(18),
                              border: Border.all(
                                color: AppTheme.surfaceElevated.withValues(alpha: 0.7),
                              ),
                            ),
                            child: Row(
                              children: [
                                // Food image or placeholder
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(14),
                                  child: hasImage
                                      ? Image.file(
                                          File(meal.imagePath!),
                                          width: 56,
                                          height: 56,
                                          fit: BoxFit.cover,
                                          errorBuilder: (_, __, ___) => _buildMealIcon(),
                                        )
                                      : _buildMealIcon(),
                                ),
                                const SizedBox(width: 14),
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
                                      const SizedBox(height: 4),
                                      Row(
                                        children: [
                                          const Icon(Icons.access_time, size: 12, color: AppTheme.onSurfaceMuted),
                                          const SizedBox(width: 4),
                                          Text(
                                            timeStr,
                                            style: const TextStyle(
                                              color: AppTheme.onSurfaceMuted,
                                              fontSize: 12,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: AppTheme.calorieColor.withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    '${meal.calories}',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: AppTheme.calorieColor,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ).animate().fadeIn(delay: (450 + entry.key * 80).ms).slideX(begin: 0.05);
                        }),
                      ],

                      // Bottom padding for FAB
                      const SizedBox(height: 100),
                    ],
                  ),
                ),
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

  // ─── GRADIENT HEADER WITH HEALTH BAR ────────────────────────────────
  Widget _buildGradientHeader(BuildContext context, int current, int target) {
    final double percent = target > 0 ? (current / target).clamp(0.0, 1.0) : 0.0;
    final int percentInt = (percent * 100).round();

    Color barColor = AppTheme.primary;
    String statusEmoji = '💪';
    String statusText = 'Terus semangat!';

    if (percent >= 1.0) {
      barColor = Colors.redAccent;
      statusEmoji = '🎯';
      statusText = 'Target tercapai!';
    } else if (percent > 0.8) {
      barColor = Colors.orangeAccent;
      statusEmoji = '🔥';
      statusText = 'Hampir sampai!';
    } else if (percent > 0.5) {
      statusEmoji = '⚡';
      statusText = 'Setengah jalan!';
    } else if (percent > 0.0) {
      statusEmoji = '🌱';
      statusText = 'Awal yang baik!';
    }

    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 16,
        left: 24,
        right: 24,
        bottom: 28,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            barColor.withValues(alpha: 0.25),
            AppTheme.background,
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Date
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    DateFormat('EEEE').format(DateTime.now()),
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppTheme.onSurfaceMuted,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    DateFormat('d MMMM yyyy').format(DateTime.now()),
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.onSurface,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: barColor.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: barColor.withValues(alpha: 0.3)),
                ),
                child: Text(
                  '$statusEmoji $statusText',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: barColor,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 28),

          // Big calorie display
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                current.toString(),
                style: TextStyle(
                  fontSize: 52,
                  fontWeight: FontWeight.w900,
                  color: barColor,
                  height: 1,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 8, left: 4),
                child: Text(
                  '/ $target kcal',
                  style: const TextStyle(
                    fontSize: 16,
                    color: AppTheme.onSurfaceMuted,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Health bar with glow
          Stack(
            children: [
              // Background bar
              Container(
                height: 14,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: AppTheme.surfaceElevated,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              // Progress bar
              LayoutBuilder(
                builder: (context, constraints) {
                  final barWidth = constraints.maxWidth * percent;
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 1200),
                    curve: Curves.easeOutCubic,
                    height: 14,
                    width: barWidth,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [barColor, barColor.withValues(alpha: 0.7)],
                      ),
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: barColor.withValues(alpha: 0.5),
                          blurRadius: 12,
                          spreadRadius: -2,
                        ),
                      ],
                    ),
                  );
                },
              ),
              // Percentage label
              Positioned(
                right: 0,
                top: -2,
                child: Text(
                  '$percentInt%',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: barColor,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ─── QUICK STATS ROW ───────────────────────────────────────────────
  Widget _buildQuickStats(int mealCount, int calories, int target) {
    final remaining = max(0, target - calories);

    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            icon: Icons.restaurant_rounded,
            label: 'Porsi',
            value: '$mealCount',
            color: AppTheme.proteinColor,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            icon: Icons.local_fire_department_rounded,
            label: 'Kalori',
            value: '$calories',
            color: AppTheme.calorieColor,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            icon: Icons.flag_rounded,
            label: 'Sisa',
            value: '$remaining',
            color: AppTheme.carbsColor,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            color.withValues(alpha: 0.12),
            color.withValues(alpha: 0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w900,
              color: color,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              color: AppTheme.onSurfaceMuted,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  // ─── MACROS CARD ────────────────────────────────────────────────────
  Widget _buildMacrosCard(
    double protein, double targetProtein,
    double carbs, double targetCarbs,
    double fat, double targetFat,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppTheme.surfaceElevated),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Text('📊', style: TextStyle(fontSize: 18)),
              SizedBox(width: 8),
              Text(
                'Makronutrien',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          MacroBar(
            label: 'Protein',
            value: protein,
            unit: 'g',
            percent: targetProtein > 0 ? (protein / targetProtein * 100) : 0,
            color: AppTheme.proteinColor,
          ),
          const SizedBox(height: 14),
          MacroBar(
            label: 'Karbohidrat',
            value: carbs,
            unit: 'g',
            percent: targetCarbs > 0 ? (carbs / targetCarbs * 100) : 0,
            color: AppTheme.carbsColor,
          ),
          const SizedBox(height: 14),
          MacroBar(
            label: 'Lemak',
            value: fat,
            unit: 'g',
            percent: targetFat > 0 ? (fat / targetFat * 100) : 0,
            color: AppTheme.fatColor,
          ),
        ],
      ),
    );
  }

  // ─── EMPTY STATE ────────────────────────────────────────────────────
  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppTheme.primary.withValues(alpha: 0.2),
                    AppTheme.primary.withValues(alpha: 0.05),
                  ],
                ),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.restaurant_menu_rounded,
                size: 56,
                color: AppTheme.primary,
              ),
            ).animate().scale(delay: 200.ms, duration: 500.ms, curve: Curves.elasticOut),
            const SizedBox(height: 32),
            const Text(
              'Belum ada asupan hari ini',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppTheme.onSurface,
              ),
            ).animate().fadeIn(delay: 300.ms),
            const SizedBox(height: 8),
            const Text(
              'Ketuk tombol + di bawah untuk\nmencatat makanan pertamamu!',
              style: TextStyle(
                fontSize: 14,
                color: AppTheme.onSurfaceMuted,
              ),
              textAlign: TextAlign.center,
            ).animate().fadeIn(delay: 400.ms),
          ],
        ),
      ),
    );
  }

  // ─── MEAL PLACEHOLDER ICON ─────────────────────────────────────────
  Widget _buildMealIcon() {
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.calorieColor.withValues(alpha: 0.2),
            AppTheme.calorieColor.withValues(alpha: 0.08),
          ],
        ),
        borderRadius: BorderRadius.circular(14),
      ),
      child: const Icon(
        Icons.restaurant_rounded,
        color: AppTheme.calorieColor,
        size: 24,
      ),
    );
  }
}

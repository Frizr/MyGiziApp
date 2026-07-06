import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:gizi_ai/core/theme/app_theme.dart';
import 'package:gizi_ai/features/nutrition/domain/entities/nutrition_result.dart';
import 'package:gizi_ai/features/nutrition/presentation/providers/nutrition_provider.dart';
import 'package:gizi_ai/features/nutrition/presentation/widgets/macro_bar.dart';
import 'package:gizi_ai/features/nutrition/presentation/widgets/nutrient_card.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ResultScreen extends ConsumerWidget {
  final NutritionSuccess state;

  const ResultScreen({super.key, required this.state});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final result = state.result;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // App bar dengan foto
          _buildSliverAppBar(context, state),

          // Content
          SliverPadding(
            padding: const EdgeInsets.all(20),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // Nama makanan + confidence
                _buildDishHeader(context, result)
                    .animate()
                    .fadeIn(delay: 100.ms)
                    .slideY(begin: 0.2),
                const SizedBox(height: 20),

                // Kalori utama
                _buildCalorieCard(context, result)
                    .animate()
                    .fadeIn(delay: 200.ms)
                    .slideY(begin: 0.2),
                const SizedBox(height: 20),

                // Macro breakdown bars
                _buildMacroSection(context, result)
                    .animate()
                    .fadeIn(delay: 300.ms)
                    .slideY(begin: 0.2),
                const SizedBox(height: 20),

                // Nutrient detail cards
                _buildNutrientGrid(result)
                    .animate()
                    .fadeIn(delay: 400.ms)
                    .slideY(begin: 0.2),

                // Notes jika ada
                if (result.notes.isNotEmpty) ...[
                  const SizedBox(height: 20),
                  _buildNotes(context, result)
                      .animate()
                      .fadeIn(delay: 500.ms),
                ],

                const SizedBox(height: 32),

                // Scan lagi button
                ElevatedButton.icon(
                  onPressed: () {
                    ref.read(nutritionProvider.notifier).reset();
                    Navigator.pop(context);
                  },
                  icon: const Icon(Icons.camera_alt_outlined),
                  label: const Text('Scan Makanan Lagi'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primary,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ).animate().fadeIn(delay: 600.ms).slideY(begin: 0.2),

                const SizedBox(height: 16),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  SliverAppBar _buildSliverAppBar(BuildContext context, NutritionSuccess state) {
    return SliverAppBar(
      expandedHeight: 280,
      pinned: true,
      backgroundColor: AppTheme.background,
      leading: GestureDetector(
        onTap: () => Navigator.pop(context),
        child: Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.black54,
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(Icons.arrow_back, color: Colors.white),
        ),
      ),
      flexibleSpace: FlexibleSpaceBar(
        background: Image.file(
          state.image,
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  Widget _buildDishHeader(BuildContext context, NutritionResult result) {
    final confidenceColor = switch (result.confidence) {
      'high' => AppTheme.primary,
      'medium' => AppTheme.calorieColor,
      _ => AppTheme.onSurfaceMuted,
    };

    final confidenceLabel = switch (result.confidence) {
      'high' => '✓ Akurasi Tinggi',
      'medium' => '◐ Akurasi Sedang',
      _ => '? Akurasi Rendah',
    };

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                result.dishName,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppTheme.onSurface,
                    ),
              ),
              const SizedBox(height: 4),
              Text(
                result.servingSize,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppTheme.onSurfaceMuted,
                    ),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: confidenceColor.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: confidenceColor.withValues(alpha: 0.4)),
          ),
          child: Text(
            confidenceLabel,
            style: TextStyle(
              color: confidenceColor,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCalorieCard(BuildContext context, NutritionResult result) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1A2535), Color(0xFF243044)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.calorieColor.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: AppTheme.calorieColor.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.local_fire_department,
                color: AppTheme.calorieColor, size: 28),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${result.calories.toStringAsFixed(0)} kcal',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: AppTheme.calorieColor,
                    ),
              ),
              Text(
                'Total Kalori',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppTheme.onSurfaceMuted,
                    ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMacroSection(BuildContext context, NutritionResult result) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Komposisi Makro',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppTheme.onSurface,
                ),
          ),
          const SizedBox(height: 16),
          MacroBar(
            label: 'Protein',
            value: result.proteinG,
            unit: 'g',
            percent: result.proteinPercent,
            color: AppTheme.proteinColor,
          ),
          const SizedBox(height: 10),
          MacroBar(
            label: 'Karbohidrat',
            value: result.carbsG,
            unit: 'g',
            percent: result.carbsPercent,
            color: AppTheme.carbsColor,
          ),
          const SizedBox(height: 10),
          MacroBar(
            label: 'Lemak',
            value: result.fatG,
            unit: 'g',
            percent: result.fatPercent,
            color: AppTheme.fatColor,
          ),
        ],
      ),
    );
  }

  Widget _buildNutrientGrid(NutritionResult result) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.4,
      children: [
        NutrientCard(
          label: 'Serat',
          value: result.fiberG,
          unit: 'g',
          icon: Icons.grass_outlined,
          color: AppTheme.fiberColor,
        ),
        NutrientCard(
          label: 'Gula',
          value: result.sugarG,
          unit: 'g',
          icon: Icons.icecream_outlined,
          color: AppTheme.sugarColor,
        ),
        NutrientCard(
          label: 'Kalori Protein',
          value: result.proteinCalories,
          unit: 'kcal',
          icon: Icons.fitness_center_outlined,
          color: AppTheme.proteinColor,
        ),
        NutrientCard(
          label: 'Kalori Lemak',
          value: result.fatCalories,
          unit: 'kcal',
          icon: Icons.water_drop_outlined,
          color: AppTheme.fatColor,
        ),
      ],
    );
  }

  Widget _buildNotes(BuildContext context, NutritionResult result) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.secondary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.secondary.withValues(alpha: 0.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.info_outline, color: AppTheme.secondary, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              result.notes,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppTheme.onSurface,
                    height: 1.5,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}

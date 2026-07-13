import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:gizi_ai/core/theme/app_theme.dart';
import '../../providers/manual_input_provider.dart';

class ManualInputPage extends HookConsumerWidget {
  const ManualInputPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final foodNameController = useTextEditingController();
    final caloriesController = useTextEditingController();
    final proteinController = useTextEditingController();
    final carbsController = useTextEditingController();
    final fatController = useTextEditingController();

    final inputState = ref.watch(manualInputProvider);

    ref.listen(manualInputProvider, (previous, next) {
      next.whenOrNull(
        data: (_) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Berhasil mencatat ${foodNameController.text}'),
              backgroundColor: AppTheme.primary,
            ),
          );
          foodNameController.clear();
          caloriesController.clear();
          proteinController.clear();
          carbsController.clear();
          fatController.clear();
        },
        error: (error, stack) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Gagal: $error'), backgroundColor: Colors.red),
          );
        },
      );
    });

    void submitData() {
      if (foodNameController.text.trim().isEmpty ||
          caloriesController.text.trim().isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Nama makanan dan Kalori harus diisi')),
        );
        return;
      }

      final calories = int.tryParse(caloriesController.text.trim()) ?? 0;
      final protein = double.tryParse(proteinController.text.trim()) ?? 0;
      final carbs = double.tryParse(carbsController.text.trim()) ?? 0;
      final fat = double.tryParse(fatController.text.trim()) ?? 0;

      ref.read(manualInputProvider.notifier).submitMeal(
        foodName: foodNameController.text.trim(),
        calories: calories,
        protein: protein,
        carbs: carbs,
        fat: fat,
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Catat Makanan Baru',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: AppTheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Masukkan detail makanan untuk melihat progres pada health bar.',
            style: TextStyle(
              fontSize: 14,
              color: AppTheme.onSurfaceMuted,
            ),
          ),
          const SizedBox(height: 32),
          
          _buildTextField(
            controller: foodNameController,
            label: 'Nama Makanan',
            icon: Icons.fastfood_outlined,
          ),
          const SizedBox(height: 16),
          
          _buildTextField(
            controller: caloriesController,
            label: 'Kalori (kkal)',
            icon: Icons.local_fire_department_outlined,
            keyboardType: TextInputType.number,
            colorIcon: AppTheme.calorieColor,
          ),
          const SizedBox(height: 16),
          
          Row(
            children: [
              Expanded(
                child: _buildTextField(
                  controller: proteinController,
                  label: 'Protein (g)',
                  icon: Icons.fitness_center_outlined,
                  keyboardType: TextInputType.number,
                  colorIcon: AppTheme.proteinColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          Row(
            children: [
              Expanded(
                child: _buildTextField(
                  controller: carbsController,
                  label: 'Karbo (g)',
                  icon: Icons.grain_outlined,
                  keyboardType: TextInputType.number,
                  colorIcon: AppTheme.carbsColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          Row(
            children: [
              Expanded(
                child: _buildTextField(
                  controller: fatController,
                  label: 'Lemak (g)',
                  icon: Icons.water_drop_outlined,
                  keyboardType: TextInputType.number,
                  colorIcon: AppTheme.fatColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),
          
          ElevatedButton(
            onPressed: inputState.isLoading ? null : submitData,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primary,
              foregroundColor: Colors.black,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: inputState.isLoading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(color: Colors.black, strokeWidth: 2),
                  )
                : const Text(
                    'Simpan Catatan',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    Color colorIcon = AppTheme.onSurfaceMuted,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      style: const TextStyle(color: AppTheme.onSurface),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: AppTheme.onSurfaceMuted),
        prefixIcon: Icon(icon, color: colorIcon),
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

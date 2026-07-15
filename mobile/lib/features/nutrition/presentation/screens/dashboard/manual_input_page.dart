import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:image_picker/image_picker.dart';
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
    final selectedImage = useState<XFile?>(null);

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
          selectedImage.value = null;
        },
        error: (error, stack) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Gagal: $error'), backgroundColor: Colors.red),
          );
        },
      );
    });

    Future<void> pickImage(ImageSource source) async {
      final picker = ImagePicker();
      final image = await picker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );
      if (image != null) {
        selectedImage.value = image;
      }
    }

    void showImageSourceDialog() {
      showModalBottomSheet(
        context: context,
        backgroundColor: AppTheme.surface,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        builder: (context) => SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Pilih Sumber Foto',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.onSurface,
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildSourceOption(
                      icon: Icons.camera_alt_rounded,
                      label: 'Kamera',
                      onTap: () {
                        Navigator.pop(context);
                        pickImage(ImageSource.camera);
                      },
                    ),
                    _buildSourceOption(
                      icon: Icons.photo_library_rounded,
                      label: 'Galeri',
                      onTap: () {
                        Navigator.pop(context);
                        pickImage(ImageSource.gallery);
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
    }

    void submitData() async {
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
        imagePath: selectedImage.value?.path,
      );
    }

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Catat Makanan'),
        backgroundColor: AppTheme.surface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Photo Section
            GestureDetector(
              onTap: showImageSourceDialog,
              child: Container(
                height: 180,
                decoration: BoxDecoration(
                  color: AppTheme.surface,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: selectedImage.value != null
                        ? AppTheme.primary
                        : AppTheme.surfaceElevated,
                    width: 2,
                  ),
                ),
                child: selectedImage.value != null
                    ? Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(18),
                            child: Image.file(
                              File(selectedImage.value!.path),
                              width: double.infinity,
                              height: double.infinity,
                              fit: BoxFit.cover,
                            ),
                          ),
                          Positioned(
                            top: 8,
                            right: 8,
                            child: GestureDetector(
                              onTap: () => selectedImage.value = null,
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: Colors.black54,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: const Icon(
                                  Icons.close,
                                  color: Colors.white,
                                  size: 20,
                                ),
                              ),
                            ),
                          ),
                        ],
                      )
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.add_a_photo_rounded,
                            size: 48,
                            color: AppTheme.onSurfaceMuted,
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'Tambah Foto Makanan',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: AppTheme.onSurfaceMuted,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Ketuk untuk memilih dari kamera atau galeri',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppTheme.onSurfaceMuted.withValues(alpha: 0.7),
                            ),
                          ),
                        ],
                      ),
              ),
            ),
            const SizedBox(height: 32),

            const Text(
              'Detail Makanan',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppTheme.onSurface,
              ),
            ),
            const SizedBox(height: 16),

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
      ),
    );
  }

  Widget _buildSourceOption({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: AppTheme.primary.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(icon, color: AppTheme.primary, size: 32),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(
              color: AppTheme.onSurface,
              fontWeight: FontWeight.w500,
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

import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:gizi_ai/core/constants/api_constants.dart';
import 'package:gizi_ai/features/nutrition/data/models/nutrition_model.dart';

// Remote datasource — komunikasi dengan Go backend
class NutritionRemoteDatasource {
  NutritionRemoteDatasource();

  /// Kirim foto makanan ke Go backend, terima hasil analisis nutrisi.
  Future<NutritionModel> analyzeFood(File imageFile) async {
    final uri = Uri.parse('${ApiConstants.baseUrl}/analyze');

    // Buat multipart request (http.Client dibuat per-request, tidak perlu disimpan)
    final request = http.MultipartRequest('POST', uri)
      ..files.add(
        await http.MultipartFile.fromPath(
          'image',
          imageFile.path,
        ),
      );

    request.headers['Accept'] = 'application/json';

    final streamedResponse = await request.send().timeout(
          const Duration(seconds: 45),
          onTimeout: () => throw Exception(
              'Request timeout — pastikan server berjalan dan koneksi stabil'),
        );

    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body) as Map<String, dynamic>;
      if (json['success'] == true && json['data'] != null) {
        return NutritionModel.fromJson(json['data'] as Map<String, dynamic>);
      }
      throw Exception(json['error'] ?? 'Analisis gagal');
    } else {
      final errorBody = jsonDecode(response.body) as Map<String, dynamic>?;
      throw Exception(
          errorBody?['error'] ?? 'Server error: ${response.statusCode}');
    }
  }
}

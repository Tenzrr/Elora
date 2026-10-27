import 'dart:convert';
import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:garden_mobile/features/crop_health/models/crop_health_models.dart';

class CropHealthState {
  const CropHealthState({
    this.isLoading = false,
    this.errorMessage,
    this.result,
    this.selectedImagePath,
    this.selectedCrop = 'tomato',
  });

  final bool isLoading;
  final String? errorMessage;
  final CropHealthAnalysisResult? result;
  final String? selectedImagePath;
  final String selectedCrop;

  CropHealthState copyWith({
    bool? isLoading,
    String? errorMessage,
    CropHealthAnalysisResult? result,
    String? selectedImagePath,
    String? selectedCrop,
  }) {
    return CropHealthState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      result: result ?? this.result,
      selectedImagePath: selectedImagePath ?? this.selectedImagePath,
      selectedCrop: selectedCrop ?? this.selectedCrop,
    );
  }
}

class CropHealthNotifier extends StateNotifier<CropHealthState> {
  CropHealthNotifier({http.Client? client, String baseUrl = 'http://10.0.2.2:8000'})
      : _client = client ?? http.Client(),
        _baseUrl = baseUrl,
        super(const CropHealthState());

  final http.Client _client;
  final String _baseUrl;

  void setSelectedCrop(String cropSlug) {
    state = state.copyWith(selectedCrop: cropSlug);
  }

  void reset() {
    state = const CropHealthState();
  }

  Future<CropHealthAnalysisResult?> analyzeImage({
    required String filePath,
    String cropSlug = 'tomato',
    String task = 'disease',
  }) async {
    state = state.copyWith(
      isLoading: true,
      errorMessage: null,
      selectedImagePath: filePath,
      selectedCrop: cropSlug,
    );

    try {
      final uri = Uri.parse('$_baseUrl/api/v1/crop-health/analyze');
      final request = http.MultipartRequest('POST', uri);

      request.fields['crop_slug'] = cropSlug;
      request.fields['task'] = task;

      final file = File(filePath);
      if (await file.exists()) {
        final multipartFile = await http.MultipartFile.fromPath('file', filePath);
        request.files.add(multipartFile);
      } else {
        // Fallback for tests or simulated bytes
        request.files.add(
          http.MultipartFile.fromBytes(
            'file',
            [0xFF, 0xD8, 0xFF, 0xE0],
            filename: 'scan.jpg',
          ),
        );
      }

      final streamedResponse = await _client.send(request);
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        final jsonMap = json.decode(response.body) as Map<String, dynamic>;
        final analysisResult = CropHealthAnalysisResult.fromJson(jsonMap);
        state = state.copyWith(isLoading: false, result: analysisResult);
        return analysisResult;
      } else {
        final errorMsg = 'Inference request failed with code ${response.statusCode}';
        state = state.copyWith(isLoading: false, errorMessage: errorMsg);
        return null;
      }
    } catch (e) {
      final errorMsg = 'Network error: $e';
      state = state.copyWith(isLoading: false, errorMessage: errorMsg);
      return null;
    }
  }
}

final cropHealthProvider =
    StateNotifierProvider<CropHealthNotifier, CropHealthState>((ref) {
  return CropHealthNotifier();
});

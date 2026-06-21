import 'package:dio/dio.dart';
import 'package:edveo/core/api/api_client.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:edveo/features/auth/data/auth_repository.dart';
import 'package:edveo/features/teacher_standalone/home/data/models/ai_banner_model.dart';

class AiBannerRepository {
  final Dio _dio;
  AiBannerRepository(ApiClient client) : _dio = client.dio;

  Future<AiBannerModel> fetchBanner() async {
    final response = await _dio.get('/api/mobile/standalone-teacher/ai-banner');
    return AiBannerModel.fromJson(response.data as Map<String, dynamic>);
  }
}

final aiBannerRepositoryProvider = Provider<AiBannerRepository>((ref) {
  return AiBannerRepository(ref.read(apiClientProvider));
});


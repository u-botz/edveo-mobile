import 'package:edveo/core/api/api_client.dart';
import 'package:edveo/features/auth/data/auth_repository.dart';
import 'package:edveo/features/teacher_standalone/home/data/models/home_data_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';

class HomeRepository {
  final Dio _dio;

  HomeRepository(ApiClient client) : _dio = client.dio;

  Future<HomeDataModel> getHomeData() async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/api/mobile/standalone-teacher/home',
    );
    final body = response.data!;
    return HomeDataModel.fromJson(body['data'] as Map<String, dynamic>);
  }
}

final homeRepositoryProvider = Provider<HomeRepository>((ref) {
  return HomeRepository(ref.read(apiClientProvider));
});

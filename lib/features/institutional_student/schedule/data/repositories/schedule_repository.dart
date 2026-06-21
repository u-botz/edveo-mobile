import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../features/auth/data/auth_repository.dart';
import '../../../../../core/api/api_client.dart';
import '../models/schedule_model.dart';

class ScheduleRepository {
  final Dio _dio;

  ScheduleRepository(ApiClient client) : _dio = client.dio;

  Future<StudentScheduleModel?> getSchedule() async {
    final response = await _dio.get('/api/mobile/institutional-student/schedule');
    final data = response.data['data'];
    if (data == null) return null;
    return StudentScheduleModel.fromJson(data as Map<String, dynamic>);
  }
}

final scheduleRepositoryProvider = Provider<ScheduleRepository>((ref) {
  return ScheduleRepository(ref.read(apiClientProvider));
});

final scheduleProvider = FutureProvider<StudentScheduleModel?>((ref) async {
  return ref.read(scheduleRepositoryProvider).getSchedule();
});

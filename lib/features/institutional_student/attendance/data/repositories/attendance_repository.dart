import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../features/auth/data/auth_repository.dart';
import '../../../../../core/api/api_client.dart';
import '../models/attendance_model.dart';

class AttendanceRepository {
  final Dio _dio;

  AttendanceRepository(ApiClient client) : _dio = client.dio;

  Future<StudentAttendanceModel> getAttendance() async {
    final response =
        await _dio.get('/api/mobile/institutional-student/attendance');
    return StudentAttendanceModel.fromJson(
      response.data['data'] as Map<String, dynamic>,
    );
  }
}

final attendanceRepositoryProvider = Provider<AttendanceRepository>((ref) {
  return AttendanceRepository(ref.read(apiClientProvider));
});

final attendanceProvider = FutureProvider<StudentAttendanceModel>((ref) async {
  return ref.read(attendanceRepositoryProvider).getAttendance();
});

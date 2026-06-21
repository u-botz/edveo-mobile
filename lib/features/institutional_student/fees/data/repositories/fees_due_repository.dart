import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../core/api/api_client.dart';
import '../../../../../features/auth/data/auth_repository.dart';
import '../models/fees_due_model.dart';

class FeesDueRepository {
  final Dio _dio;

  FeesDueRepository(ApiClient client) : _dio = client.dio;

  Future<StudentFeesDueModel> getFeesDue() async {
    final response =
        await _dio.get('/api/mobile/institutional-student/fees/due');
    return StudentFeesDueModel.fromJson(
      response.data['data'] as Map<String, dynamic>,
    );
  }
}

final feesDueRepositoryProvider = Provider<FeesDueRepository>((ref) {
  return FeesDueRepository(ref.read(apiClientProvider));
});

final feesDueProvider = FutureProvider<StudentFeesDueModel>((ref) async {
  return ref.read(feesDueRepositoryProvider).getFeesDue();
});

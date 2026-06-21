import 'package:dio/dio.dart';
import 'package:edveo/core/api/api_client.dart';
import 'package:edveo/features/auth/data/auth_repository.dart';
import 'package:edveo/features/quizzes/data/models/quiz_analytics_model.dart';
import 'package:edveo/features/quizzes/data/models/quiz_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class QuizRepository {
  final Dio _dio;

  QuizRepository(ApiClient client) : _dio = client.dio;

  /// Fetches the teacher's quiz list (15 per page, newest first).
  /// [status] is one of: active | draft | inactive | closed. Null = all.
  Future<({List<QuizModel> items, int total, int currentPage, int lastPage})>
      fetchQuizList({
    String? search,
    String? status,
    int page = 1,
  }) async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/api/mobile/standalone-teacher/quizzes',
      queryParameters: {
        if (search != null && search.isNotEmpty) 'search': search,
        if (status != null) 'status': status,
        'page': page,
      },
    );

    final body = response.data!;
    final items = (body['data'] as List<dynamic>)
        .map((e) => QuizModel.fromJson(e as Map<String, dynamic>))
        .toList();
    final meta = body['meta'] as Map<String, dynamic>;

    return (
      items:       items,
      total:       meta['total'] as int,
      currentPage: meta['current_page'] as int,
      lastPage:    meta['last_page'] as int,
    );
  }

  /// Fetches analytics summary + student insights for a quiz.
  Future<QuizAnalyticsModel> fetchAnalytics(int quizId) async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/api/mobile/standalone-teacher/quizzes/$quizId/analytics',
    );
    final body = response.data!;
    return QuizAnalyticsModel.fromJson(body['data'] as Map<String, dynamic>);
  }

  /// Fetches paginated question breakdown for a quiz.
  Future<QuizQuestionsPage> fetchAnalyticsQuestions(
    int quizId, {
    int page = 1,
    int perPage = 20,
  }) async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/api/mobile/standalone-teacher/quizzes/$quizId/analytics/questions',
      queryParameters: {'page': page, 'per_page': perPage},
    );
    final body = response.data!;
    return QuizQuestionsPage.fromJson(body['data'] as Map<String, dynamic>);
  }
}

final quizRepositoryProvider = Provider<QuizRepository>((ref) {
  return QuizRepository(ref.read(apiClientProvider));
});

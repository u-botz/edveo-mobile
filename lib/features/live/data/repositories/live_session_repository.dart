import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:edveo/features/auth/data/auth_repository.dart';
import 'package:edveo/features/live/data/models/live_session_model.dart';

class LiveSessionRepository {
  LiveSessionRepository(this._dio);

  final Dio _dio;

  Future<LiveSessionTodayResponse> fetchToday() async {
    try {
      final response = await _dio.get(
        '/api/mobile/standalone/live-sessions/today',
      );

      final data = response.data as Map<String, dynamic>;
      if (data['success'] != true) {
        return const LiveSessionTodayResponse(recentSessions: []);
      }

      final payload = data['data'] as Map<String, dynamic>;

      final nextSession = payload['next_session'] != null
          ? NextLiveSession.fromJson(
              payload['next_session'] as Map<String, dynamic>)
          : null;

      final recentSessions = (payload['recent_sessions'] as List<dynamic>)
          .map((s) => RecentLiveSession.fromJson(s as Map<String, dynamic>))
          .toList();

      return LiveSessionTodayResponse(
        nextSession: nextSession,
        recentSessions: recentSessions,
      );
    } on DioException {
      return const LiveSessionTodayResponse(recentSessions: []);
    }
  }
}

final liveSessionRepositoryProvider = Provider<LiveSessionRepository>((ref) {
  return LiveSessionRepository(ref.read(apiClientProvider).dio);
});

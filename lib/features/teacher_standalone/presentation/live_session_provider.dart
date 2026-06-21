import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:edveo/features/live/data/models/live_session_model.dart';
import 'package:edveo/features/live/data/repositories/live_session_repository.dart';

// ─── State ────────────────────────────────────────────────────────────────────

class LiveSessionState {
  final LiveSessionTodayResponse? response;
  final bool isLoading;
  final bool hasError;

  const LiveSessionState({
    this.response,
    this.isLoading = false,
    this.hasError = false,
  });

  bool get hasSession => response?.hasSession ?? false;
  bool get hasRecentSessions => response?.hasRecentSessions ?? false;
  NextLiveSession? get nextSession => response?.nextSession;
  List<RecentLiveSession> get recentSessions =>
      response?.recentSessions ?? [];

  LiveSessionState copyWith({
    LiveSessionTodayResponse? response,
    bool? isLoading,
    bool? hasError,
  }) {
    return LiveSessionState(
      response: response ?? this.response,
      isLoading: isLoading ?? this.isLoading,
      hasError: hasError ?? this.hasError,
    );
  }
}

// ─── Notifier ─────────────────────────────────────────────────────────────────

class LiveSessionNotifier extends StateNotifier<LiveSessionState> {
  LiveSessionNotifier(this._repository) : super(const LiveSessionState()) {
    load();
  }

  final LiveSessionRepository _repository;

  Future<void> load() async {
    state = state.copyWith(isLoading: true, hasError: false);
    try {
      final response = await _repository.fetchToday();
      state = LiveSessionState(response: response, isLoading: false);
    } catch (_) {
      state = state.copyWith(isLoading: false, hasError: true);
    }
  }

  Future<void> refresh() => load();
}

// ─── Provider ─────────────────────────────────────────────────────────────────

final liveSessionNotifierProvider =
    StateNotifierProvider<LiveSessionNotifier, LiveSessionState>((ref) {
  return LiveSessionNotifier(ref.read(liveSessionRepositoryProvider));
});

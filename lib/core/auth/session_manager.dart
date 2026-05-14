import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../storage/token_storage.dart';
import '../../features/auth/data/auth_repository.dart';

class SessionManager {
  final AuthRepository _authRepository;

  Timer? _refreshTimer;

  SessionManager({
    required AuthRepository authRepository,
  })  : _authRepository = authRepository;

  /// Start the proactive refresh timer.
  /// Must be called after a successful login or session restore.
  /// Must NOT be called if there is no active session.
  void startTimer() {
    stopTimer(); // Cancel any existing timer before starting a new one
    _refreshTimer = Timer.periodic(const Duration(minutes: 12), (_) async {
      await _refresh();
    });
  }

  /// Stop and cancel the timer.
  /// Must be called on logout.
  void stopTimer() {
    _refreshTimer?.cancel();
    _refreshTimer = null;
  }

  Future<void> _refresh() async {
    final hasSession = await TokenStorage.hasSession();
    if (!hasSession) {
      stopTimer();
      return;
    }
    // AuthRepository.refreshToken() calls the refresh endpoint.
    // AuthInterceptor already handles 401 → clear session → redirect.
    // Nothing more to do here on failure — interceptor owns that path.
    await _authRepository.refreshToken();
  }
}

final sessionManagerProvider = Provider<SessionManager>((ref) {
  return SessionManager(
    authRepository: ref.read(authRepositoryProvider),
  );
});

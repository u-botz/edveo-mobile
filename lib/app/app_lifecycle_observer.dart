import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/storage/token_storage.dart';
import '../features/auth/data/auth_repository.dart';

class AppLifecycleObserver extends WidgetsBindingObserver {
  final WidgetRef _ref;

  AppLifecycleObserver(this._ref);

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _onResumed();
    }
  }

  Future<void> _onResumed() async {
    final hasSession = await TokenStorage.hasSession();
    if (!hasSession) return;

    final lastRefresh = await TokenStorage.getLastRefreshAt();
    if (lastRefresh == null) return;

    final elapsed = DateTime.now().millisecondsSinceEpoch - lastRefresh;
    const tenMinutesMs = 10 * 60 * 1000;

    if (elapsed > tenMinutesMs) {
      // Token is stale — refresh immediately before any API call is made.
      // AuthInterceptor handles 401 → clear session → redirect to login.
      await _ref.read(authRepositoryProvider).refreshToken();
    }
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../data/auth_repository.dart';
import '../../../core/auth/session_manager.dart';

class RoleRouterScreen extends ConsumerStatefulWidget {
  const RoleRouterScreen({super.key});

  @override
  ConsumerState<RoleRouterScreen> createState() => _RoleRouterScreenState();
}

class _RoleRouterScreenState extends ConsumerState<RoleRouterScreen> {

  @override
  void initState() {
    super.initState();
    _resolveRole();
  }

  Future<void> _resolveRole() async {
    try {
      final user = await ref.read(authRepositoryProvider).getCurrentUser();

      if (user == null) {
        _failAndLogout('Session invalid.');
        return;
      }

      // Start the proactive refresh timer now that we have a confirmed session
      ref.read(sessionManagerProvider).startTimer();

      if (!mounted) return;

      switch (user.role) {
        case 'student':
          context.go('/student/home');
        case 'teacher':
          context.go('/teacher/home');
        case 'owner':
        case 'standalone_teacher':
          context.go('/standalone/home');
        default:
          _failAndLogout('Unrecognised role: ${user.role}');
      }
    } catch (_) {
      _failAndLogout('Could not verify your account. Please log in again.');
    }
  }

  Future<void> _failAndLogout(String reason) async {
    await ref.read(authRepositoryProvider).logout();
    if (!mounted) return;
    context.go('/');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(reason)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}

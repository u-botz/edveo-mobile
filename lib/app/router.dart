import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/storage/token_storage.dart';
import '../features/onboarding/presentation/institution_search_screen.dart';
import '../features/auth/presentation/login_screen.dart';
import '../features/auth/presentation/role_router_screen.dart';
import '../features/student/presentation/student_shell.dart';
import '../features/teacher_institutional/presentation/institutional_shell.dart';
import '../features/teacher_standalone/presentation/standalone_shell.dart';

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    redirect: (BuildContext context, GoRouterState state) async {
      final hasSession = await TokenStorage.hasSession();
      final onAuthRoute = state.matchedLocation == '/' ||
          state.matchedLocation == '/login';

      // Has session but on a public route → send to role router
      if (hasSession && onAuthRoute) return '/role-router';

      // No session but trying to access a protected route → send to search
      if (!hasSession && !onAuthRoute) return '/';

      return null; // No redirect needed
    },
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const InstitutionSearchScreen(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) {
          // Slug passed as extra from institution search
          final slug = state.extra as String;
          return LoginScreen(tenantSlug: slug);
        },
      ),
      GoRoute(
        path: '/role-router',
        builder: (context, state) => const RoleRouterScreen(),
      ),
      GoRoute(
        path: '/student/home',
        builder: (context, state) => const StudentShell(),
      ),
      GoRoute(
        path: '/teacher/home',
        builder: (context, state) => const InstitutionalTeacherShell(),
      ),
      GoRoute(
        path: '/standalone/home',
        builder: (context, state) => const StandaloneTeacherShell(),
      ),
    ],
  );
});

/// Called by AuthInterceptor on 401 after failed refresh.
/// Router must be initialised before this is callable.
void redirectToLogin(GoRouter router) {
  router.go('/');
}

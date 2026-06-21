import 'package:edveo/features/auth/data/auth_repository.dart';
import 'package:edveo/features/courses/data/models/student_course_model.dart';
import 'package:edveo/features/courses/data/repositories/student_courses_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final studentCoursesRepositoryProvider = Provider<StudentCoursesRepository>((ref) {
  return StudentCoursesRepository(ref.read(apiClientProvider).dio);
});

/// Tracks the active filter chip selection. Persists across navigations
/// within the session — not autoDispose so the filter is remembered.
final studentCoursesFilterProvider = StateProvider<String>((ref) => 'all');

/// Fetches ALL courses once and caches. Switching filters does not re-fetch.
final studentAllCoursesProvider = FutureProvider<List<StudentCourseModel>>((ref) {
  return ref.read(studentCoursesRepositoryProvider).getCourses(filter: 'all');
});

/// Derives the filtered list client-side — no network call per filter switch.
final studentCoursesProvider =
    Provider<AsyncValue<List<StudentCourseModel>>>((ref) {
  final allAsync = ref.watch(studentAllCoursesProvider);
  final filter = ref.watch(studentCoursesFilterProvider);

  return allAsync.whenData((courses) => switch (filter) {
        'in_progress' => courses.where((c) => !c.isCompleted).toList(),
        'completed'   => courses.where((c) => c.isCompleted).toList(),
        _             => courses,
      });
});

import 'package:edveo/features/courses/data/models/student_course_model.dart';
import 'package:edveo/features/courses/data/providers/student_courses_providers.dart';
import 'package:edveo/features/student/courses/presentation/widgets/course_list_card.dart';
import 'package:edveo/features/student/courses/presentation/widgets/courses_top_bar.dart';
import 'package:edveo/features/student/courses/presentation/widgets/filter_chip_row.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class StudentCoursesScreen extends ConsumerWidget {
  const StudentCoursesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Counts always reflect ALL courses — not just the active filter subset.
    final allCoursesAsync = ref.watch(studentAllCoursesProvider);
    final coursesAsync    = ref.watch(studentCoursesProvider);
    final filter          = ref.watch(studentCoursesFilterProvider);

    final counts = _computeCounts(allCoursesAsync);

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      body: SafeArea(
        child: Column(
          children: [
            CoursesTopBar(coursesAsync: allCoursesAsync),
            FilterChipRow(
              selected: filter,
              onSelect: (f) =>
                  ref.read(studentCoursesFilterProvider.notifier).state = f,
              counts: counts,
            ),
            Expanded(
              child: coursesAsync.when(
                loading: () => const _CoursesSkeletonLoader(),
                error: (_, __) => _CoursesErrorState(
                  onRetry: () => ref.invalidate(studentAllCoursesProvider),
                ),
                data: (courses) => courses.isEmpty
                    ? _CoursesEmptyState(filter: filter)
                    : RefreshIndicator(
                        color: const Color(0xFF059669),
                        onRefresh: () =>
                            ref.refresh(studentAllCoursesProvider.future),
                        child: ListView.separated(
                          padding:
                              const EdgeInsets.fromLTRB(20, 12, 20, 24),
                          itemCount: courses.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 10),
                          itemBuilder: (_, i) =>
                              CourseListCard(course: courses[i]),
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Single pass — avoids two separate .where().length traversals.
  Map<String, int> _computeCounts(
      AsyncValue<List<StudentCourseModel>> allCoursesAsync) {
    final data = allCoursesAsync.valueOrNull;
    if (data == null) {
      return {'all': 0, 'in_progress': 0, 'completed': 0};
    }
    int inProgress = 0;
    int completed  = 0;
    for (final c in data) {
      if (c.isCompleted) {
        completed++;
      } else {
        inProgress++;
      }
    }
    return {
      'all':         data.length,
      'in_progress': inProgress,
      'completed':   completed,
    };
  }
}

// ── Skeleton ──────────────────────────────────────────────────────────────────

class _CoursesSkeletonLoader extends StatelessWidget {
  const _CoursesSkeletonLoader();

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
      itemCount: 4,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (_, __) => const _SkeletonCard(),
    );
  }
}

class _SkeletonCard extends StatelessWidget {
  const _SkeletonCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 86,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: const Color(0xFFE5E7EB),
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  height: 13,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE5E7EB),
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
                const SizedBox(height: 6),
                Container(
                  height: 10,
                  width: 140,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE5E7EB),
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  height: 5,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE5E7EB),
                    borderRadius: BorderRadius.circular(99),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Empty State ───────────────────────────────────────────────────────────────

class _CoursesEmptyState extends StatelessWidget {
  final String filter;

  const _CoursesEmptyState({required this.filter});

  @override
  Widget build(BuildContext context) {
    final subtitle = switch (filter) {
      'completed'   => 'Complete a course to see it here.',
      'in_progress' => 'All your courses are completed!',
      _             => 'Your enrolled courses will appear here.',
    };

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.collections_bookmark_outlined,
              size: 48,
              color: Color(0xFFD1D5DB),
            ),
            const SizedBox(height: 12),
            const Text(
              'No courses yet',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: Color(0xFF374151),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              subtitle,
              style: const TextStyle(
                fontSize: 13,
                color: Color(0xFF9CA3AF),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

// ── Error State ───────────────────────────────────────────────────────────────

class _CoursesErrorState extends StatelessWidget {
  final VoidCallback onRetry;

  const _CoursesErrorState({required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.wifi_off_rounded,
              size: 48,
              color: Color(0xFFD1D5DB),
            ),
            const SizedBox(height: 12),
            const Text(
              "Couldn't load courses",
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: Color(0xFF374151),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: onRetry,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF111827),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: const EdgeInsets.symmetric(
                    horizontal: 24, vertical: 12),
              ),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}

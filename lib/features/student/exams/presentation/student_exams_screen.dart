import 'package:edveo/features/quizzes/data/providers/student_exams_providers.dart';
import 'package:edveo/features/student/exams/presentation/widgets/exams_stat_strip.dart';
import 'package:edveo/features/student/exams/presentation/widgets/exams_top_bar.dart';
import 'package:edveo/features/student/exams/presentation/widgets/past_score_row.dart';
import 'package:edveo/features/student/exams/presentation/widgets/upcoming_quiz_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class StudentExamsScreen extends ConsumerWidget {
  const StudentExamsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final examsAsync = ref.watch(studentExamsProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      body: Column(
        children: [
          const ExamsTopBar(),
          Expanded(
            child: examsAsync.when(
              loading: () => const _ExamsSkeletonLoader(),
              error: (_, __) => _ExamsErrorState(
                onRetry: () => ref.refresh(studentExamsProvider),
              ),
              data: (exams) => RefreshIndicator(
                color: const Color(0xFF059669),
                onRefresh: () => ref.refresh(studentExamsProvider.future),
                child: CustomScrollView(
                  slivers: [
                    // 3-card stat strip
                    SliverToBoxAdapter(
                      child: ExamsStatStrip(
                        avgScore:      exams.avgScore,
                        testsTaken:    exams.testsTaken,
                        upcomingCount: exams.upcomingCount,
                      ),
                    ),

                    // Upcoming Quizzes
                    if (exams.upcomingQuizzes.isNotEmpty) ...[
                      SliverToBoxAdapter(
                        child: _SectionHeader(
                          title: 'Upcoming Quizzes',
                        ),
                      ),
                      SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (_, i) => UpcomingQuizCard(
                            quiz: exams.upcomingQuizzes[i],
                          ),
                          childCount: exams.upcomingQuizzes.length,
                        ),
                      ),
                    ],

                    // Past Scores
                    if (exams.pastScores.isNotEmpty) ...[
                      SliverToBoxAdapter(
                        child: _SectionHeader(
                          title: 'Past Scores',
                          actionLabel: 'View all',
                          onAction: () => ScaffoldMessenger.of(context)
                              .showSnackBar(
                            const SnackBar(
                              content: Text('View all coming soon'),
                              duration: Duration(seconds: 2),
                            ),
                          ),
                        ),
                      ),
                      SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (_, i) => Padding(
                            padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
                            child: PastScoreRow(
                              result: exams.pastScores[i],
                            ),
                          ),
                          childCount: exams.pastScores.length,
                        ),
                      ),
                    ],

                    if (exams.pastScores.isEmpty && exams.upcomingQuizzes.isEmpty)
                      const SliverFillRemaining(
                        hasScrollBody: false,
                        child: _ExamsEmptyState(),
                      ),

                    const SliverToBoxAdapter(child: SizedBox(height: 24)),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Section Header ────────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final String title;
  final String? actionLabel;
  final VoidCallback? onAction;

  const _SectionHeader({
    required this.title,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: Color(0xFF111827),
            ),
          ),
          if (actionLabel != null && onAction != null)
            GestureDetector(
              onTap: onAction,
              child: Text(
                actionLabel!,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF16A34A),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ── Skeleton Loader ───────────────────────────────────────────────────────────

class _ExamsSkeletonLoader extends StatelessWidget {
  const _ExamsSkeletonLoader();

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
      children: [
        // 3 stat card skeletons
        Row(
          children: List.generate(3, (i) => [
            Expanded(
              child: Container(
                height: 70,
                decoration: BoxDecoration(
                  color: const Color(0xFFE5E7EB),
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            if (i < 2) const SizedBox(width: 8),
          ]).expand((e) => e).toList(),
        ),
        const SizedBox(height: 20),
        Container(
          height: 14, width: 120,
          decoration: BoxDecoration(
            color: const Color(0xFFE5E7EB),
            borderRadius: BorderRadius.circular(6),
          ),
        ),
        const SizedBox(height: 12),
        ...List.generate(2, (_) => Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Container(
            height: 80,
            decoration: BoxDecoration(
              color: const Color(0xFFE5E7EB),
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        )),
        const SizedBox(height: 8),
        ...List.generate(3, (_) => Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Container(
            height: 64,
            decoration: BoxDecoration(
              color: const Color(0xFFE5E7EB),
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        )),
      ],
    );
  }
}

// ── Empty State ───────────────────────────────────────────────────────────────

class _ExamsEmptyState extends StatelessWidget {
  const _ExamsEmptyState();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.quiz_outlined, size: 48, color: Color(0xFFD1D5DB)),
            SizedBox(height: 12),
            Text(
              'No exams yet',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: Color(0xFF374151),
              ),
            ),
            SizedBox(height: 6),
            Text(
              'Upcoming and completed quizzes will appear here.',
              style: TextStyle(fontSize: 13, color: Color(0xFF9CA3AF)),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

// ── Error State ───────────────────────────────────────────────────────────────

class _ExamsErrorState extends StatelessWidget {
  final VoidCallback onRetry;

  const _ExamsErrorState({required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.wifi_off_rounded, size: 48, color: Color(0xFFD1D5DB)),
            const SizedBox(height: 12),
            const Text(
              "Couldn't load exams",
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
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              child: const Text('Try again'),
            ),
          ],
        ),
      ),
    );
  }
}

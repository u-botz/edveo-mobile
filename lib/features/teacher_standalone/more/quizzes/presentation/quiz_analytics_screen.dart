import 'package:edveo/features/quizzes/data/models/quiz_analytics_model.dart';
import 'package:edveo/features/teacher_standalone/more/quizzes/presentation/quiz_analytics_provider.dart';
import 'package:edveo/features/teacher_standalone/more/quizzes/presentation/widgets/quiz_status_badge.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class QuizAnalyticsScreen extends ConsumerStatefulWidget {
  final int quizId;
  final String quizTitle;

  const QuizAnalyticsScreen({
    super.key,
    required this.quizId,
    required this.quizTitle,
  });

  @override
  ConsumerState<QuizAnalyticsScreen> createState() =>
      _QuizAnalyticsScreenState();
}

class _QuizAnalyticsScreenState extends ConsumerState<QuizAnalyticsScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final analyticsAsync = ref.watch(quizAnalyticsProvider(widget.quizId));

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          widget.quizTitle,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: Color(0xFF111827),
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: const Color(0xFF1D4ED8),
          unselectedLabelColor: const Color(0xFF6B7280),
          indicatorColor: const Color(0xFF1D4ED8),
          labelStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
          tabs: const [
            Tab(text: 'Overview'),
            Tab(text: 'Questions'),
          ],
        ),
      ),
      body: analyticsAsync.when(
        loading: () =>
            const Center(child: CircularProgressIndicator()),
        error: (_, __) => _ErrorBody(
          onRetry: () => ref.invalidate(quizAnalyticsProvider(widget.quizId)),
        ),
        data: (analytics) => TabBarView(
          controller: _tabController,
          children: [
            _OverviewTab(analytics: analytics),
            _QuestionsTab(quizId: widget.quizId),
          ],
        ),
      ),
    );
  }
}

// ── Overview tab ──────────────────────────────────────────────────────────────

class _OverviewTab extends StatelessWidget {
  final QuizAnalyticsModel analytics;

  const _OverviewTab({required this.analytics});

  @override
  Widget build(BuildContext context) {
    final summary  = analytics.summary;
    final insights = analytics.studentInsights;
    final hasData  = summary.totalAttempts > 0;

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
      children: [
        // Quiz info header
        _QuizInfoCard(quiz: analytics.quiz),
        const SizedBox(height: 16),

        // KPI grid
        _SectionHeader('Summary'),
        const SizedBox(height: 8),
        _KpiGrid(summary: summary),
        const SizedBox(height: 20),

        if (!hasData)
          const _EmptyState(message: 'No attempts yet. Share this quiz to collect data.')
        else ...[
          // Student performers
          _SectionHeader('Top Performers'),
          const SizedBox(height: 8),
          if (insights.topPerformers.isEmpty)
            const _EmptyState(message: 'No data yet.')
          else
            ...insights.topPerformers.map((s) => _PerformerRow(student: s)),
          const SizedBox(height: 20),

          _SectionHeader('Needs Improvement'),
          const SizedBox(height: 8),
          if (insights.lowPerformers.isEmpty)
            const _EmptyState(message: 'No data yet.')
          else
            ...insights.lowPerformers.map((s) => _PerformerRow(student: s)),
          const SizedBox(height: 20),

          // Score distribution bar chart
          if (insights.scoreDistribution.isNotEmpty) ...[
            _SectionHeader('Score Distribution'),
            const SizedBox(height: 8),
            _ScoreDistributionChart(buckets: insights.scoreDistribution),
            const SizedBox(height: 20),
          ],

          // Re-attempt stats
          _SectionHeader('Repeat Attempts'),
          const SizedBox(height: 8),
          _StatRow(
            label: 'Students with multiple attempts',
            value: '${insights.studentsWithMultipleAttempts}',
          ),
          _StatRow(
            label: 'Max attempts by a single student',
            value: '${insights.maxAttemptsBySingleStudent}',
          ),
        ],
      ],
    );
  }
}

class _QuizInfoCard extends StatelessWidget {
  final QuizInfo quiz;

  const _QuizInfoCard({required this.quiz});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  quiz.title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF111827),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${quiz.typeLabel} · ${quiz.timeMinutes} min · Pass ${quiz.passMark}/${quiz.totalMark}',
                  style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          QuizStatusBadge(status: quiz.status, label: quiz.statusLabel),
        ],
      ),
    );
  }
}

class _KpiGrid extends StatelessWidget {
  final QuizSummaryAnalytics summary;

  const _KpiGrid({required this.summary});

  String _fmt(double? val, {String suffix = '%', int dp = 1}) {
    if (val == null) return '—';
    return '${val.toStringAsFixed(dp)}$suffix';
  }

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 10,
      crossAxisSpacing: 10,
      childAspectRatio: 2.2,
      children: [
        _KpiCard(
          label: 'Total Attempts',
          value: '${summary.totalAttempts}',
          icon: Icons.assignment_outlined,
        ),
        _KpiCard(
          label: 'Completed',
          value: summary.completedAttempts != null
              ? '${summary.completedAttempts}'
              : '—',
          icon: Icons.check_circle_outline_rounded,
        ),
        _KpiCard(
          label: 'Pass Rate',
          value: _fmt(summary.passRatePerAttempt),
          icon: Icons.emoji_events_outlined,
        ),
        _KpiCard(
          label: 'Avg Score',
          value: _fmt(summary.averageScore, suffix: '%'),
          icon: Icons.bar_chart_rounded,
        ),
        _KpiCard(
          label: 'Avg Duration',
          value: _fmt(summary.avgCompletionMinutes, suffix: ' min'),
          icon: Icons.timer_outlined,
        ),
      ],
    );
  }
}

class _KpiCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _KpiCard({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 20, color: const Color(0xFF1D4ED8)),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF111827),
                  ),
                ),
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 10.5,
                    color: Color(0xFF9CA3AF),
                    fontWeight: FontWeight.w500,
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

class _PerformerRow extends StatelessWidget {
  final QuizStudentPerformer student;

  const _PerformerRow({required this.student});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: const Color(0xFFE5E7EB)),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                student.name,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF111827),
                ),
              ),
            ),
            Text(
              '${student.score.toStringAsFixed(1)}%',
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1D4ED8),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              '${student.attempts} att.',
              style: const TextStyle(fontSize: 11, color: Color(0xFF9CA3AF)),
            ),
          ],
        ),
      ),
    );
  }
}

class _ScoreDistributionChart extends StatelessWidget {
  final List<QuizScoreBucket> buckets;

  const _ScoreDistributionChart({required this.buckets});

  @override
  Widget build(BuildContext context) {
    final maxCount = buckets.fold<int>(
      1,
      (max, b) => b.count > max ? b.count : max,
    );

    return Container(
      height: 160,
      padding: const EdgeInsets.fromLTRB(8, 12, 8, 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: BarChart(
        BarChartData(
          maxY: maxCount.toDouble(),
          barGroups: buckets.asMap().entries.map((entry) {
            return BarChartGroupData(
              x: entry.key,
              barRods: [
                BarChartRodData(
                  toY: entry.value.count.toDouble(),
                  color: const Color(0xFF1D4ED8),
                  width: 20,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(4),
                  ),
                ),
              ],
            );
          }).toList(),
          titlesData: FlTitlesData(
            leftTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, _) {
                  final idx = value.toInt();
                  if (idx < 0 || idx >= buckets.length) {
                    return const SizedBox.shrink();
                  }
                  return Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      buckets[idx].label,
                      style: const TextStyle(
                        fontSize: 9,
                        color: Color(0xFF9CA3AF),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          gridData: const FlGridData(show: false),
          borderData: FlBorderData(show: false),
        ),
      ),
    );
  }
}

class _StatRow extends StatelessWidget {
  final String label;
  final String value;

  const _StatRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(fontSize: 13, color: Color(0xFF374151)),
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: Color(0xFF111827),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Questions tab ─────────────────────────────────────────────────────────────

class _QuestionsTab extends ConsumerWidget {
  final int quizId;

  const _QuestionsTab({required this.quizId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(quizQuestionsProvider(quizId));

    if (state.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.hasError && state.questions.isEmpty) {
      return _ErrorBody(
        onRetry: () => ref.invalidate(quizQuestionsProvider(quizId)),
      );
    }

    if (state.questions.isEmpty) {
      return const _EmptyState(message: 'No question data available yet.');
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
      itemCount: state.questions.length + (state.hasMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index >= state.questions.length) {
          return Padding(
            padding: const EdgeInsets.all(16),
            child: state.isLoadingMore
                ? const Center(
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Center(
                    child: OutlinedButton(
                      onPressed: () =>
                          ref.read(quizQuestionsProvider(quizId).notifier).loadMore(),
                      child: const Text('Load more'),
                    ),
                  ),
          );
        }

        final q = state.questions[index];
        return _QuestionRow(question: q);
      },
    );
  }
}

class _QuestionRow extends StatelessWidget {
  final QuizQuestionBreakdown question;

  const _QuestionRow({required this.question});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF6FF),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  'Q${question.questionNumber}',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1D4ED8),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                question.typeLabel,
                style: const TextStyle(fontSize: 11, color: Color(0xFF9CA3AF)),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            question.questionTitle,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Color(0xFF111827),
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              _Metric(label: 'Correct', value: '${question.correctPct.toStringAsFixed(0)}%'),
              const SizedBox(width: 16),
              _Metric(label: 'Skip', value: '${question.skipRate.toStringAsFixed(0)}%'),
              const SizedBox(width: 16),
              _Metric(label: 'Attempts', value: '${question.attempts}'),
              const SizedBox(width: 16),
              _Metric(label: 'Avg marks', value: question.avgMarks.toStringAsFixed(1)),
            ],
          ),
        ],
      ),
    );
  }
}

class _Metric extends StatelessWidget {
  final String label;
  final String value;

  const _Metric({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: Color(0xFF111827),
          ),
        ),
        Text(
          label,
          style: const TextStyle(fontSize: 10, color: Color(0xFF9CA3AF)),
        ),
      ],
    );
  }
}

// ── Shared helpers ─────────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final String text;

  const _SectionHeader(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w700,
        color: Color(0xFF374151),
        letterSpacing: 0.1,
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final String message;

  const _EmptyState({required this.message});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Center(
        child: Text(
          message,
          style: const TextStyle(fontSize: 13, color: Color(0xFF9CA3AF)),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}

class _ErrorBody extends StatelessWidget {
  final VoidCallback onRetry;

  const _ErrorBody({required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Failed to load analytics.',
            style: TextStyle(color: Color(0xFF6B7280)),
          ),
          const SizedBox(height: 12),
          OutlinedButton(onPressed: onRetry, child: const Text('Retry')),
        ],
      ),
    );
  }
}

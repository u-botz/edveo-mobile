import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../data/models/tests_model.dart';
import '../data/repositories/tests_repository.dart';

const _kAccent = Color(0xFFF97316);
const _kBg = Color(0xFFF9FAFB);
const _kCard = Colors.white;

class InstTestsScreen extends ConsumerWidget {
  const InstTestsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final top = MediaQuery.of(context).padding.top;
    final async = ref.watch(testsProvider);

    return Scaffold(
      backgroundColor: _kBg,
      body: Column(
        children: [
          _TopBar(top: top),
          const Divider(height: 1, color: Color(0xFFE5E7EB)),
          Expanded(
            child: async.when(
              loading: () => const _TestsSkeleton(),
              error: (e, _) => _ErrorView(
                onRetry: () => ref.refresh(testsProvider),
              ),
              data: (data) => _TestsBody(data: data),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Top bar ────────────────────────────────────────────────────────────────

class _TopBar extends StatelessWidget {
  final double top;
  const _TopBar({required this.top});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: _kCard,
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: top + 12,
        bottom: 14,
      ),
      child: const Row(
        children: [
          Text(
            'Tests & Results',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: Color(0xFF111827),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Body ───────────────────────────────────────────────────────────────────

class _TestsBody extends StatelessWidget {
  final StudentTestsModel data;
  const _TestsBody({required this.data});

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      color: _kAccent,
      onRefresh: () async {
        // parent Consumer handles refresh
      },
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          const SliverToBoxAdapter(child: SizedBox(height: 16)),

          // Stats strip
          SliverToBoxAdapter(child: _StatsStrip(stats: data.stats)),

          const SliverToBoxAdapter(child: SizedBox(height: 20)),

          // Upcoming section
          SliverToBoxAdapter(
            child: _SectionHeader(title: 'Upcoming Tests'),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 10)),
          if (data.upcoming.isEmpty)
            const SliverToBoxAdapter(child: _EmptyUpcoming())
          else
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, i) => _UpcomingCard(test: data.upcoming[i]),
                childCount: data.upcoming.length,
              ),
            ),

          const SliverToBoxAdapter(child: SizedBox(height: 20)),

          // Recent results section
          SliverToBoxAdapter(
            child: _SectionHeader(
              title: 'Past Results',
              actionLabel: 'All',
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 10)),
          if (data.recentResults.isEmpty)
            const SliverToBoxAdapter(child: _EmptyResults())
          else
            SliverToBoxAdapter(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: _kCard,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFFE5E7EB)),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: Column(
                    children: List.generate(
                      data.recentResults.length,
                      (i) => _ResultCard(
                        result: data.recentResults[i],
                        isLast: i == data.recentResults.length - 1,
                      ),
                    ),
                  ),
                ),
              ),
            ),

          const SliverToBoxAdapter(child: SizedBox(height: 32)),
        ],
      ),
    );
  }
}

// ─── Stats strip ────────────────────────────────────────────────────────────

class _StatsStrip extends StatelessWidget {
  final TestsStatsModel stats;
  const _StatsStrip({required this.stats});

  @override
  Widget build(BuildContext context) {
    final avg = stats.avgScore;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: _StatBox(
              label: 'Tests Taken',
              value: '${stats.testsTaken}',
              icon: Icons.assignment_outlined,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _StatBox(
              label: 'Avg Score',
              value: avg != null ? '${avg.toStringAsFixed(1)}%' : '—',
              icon: Icons.trending_up_rounded,
              accent: avg != null && avg >= 60,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatBox extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final bool accent;

  const _StatBox({
    required this.label,
    required this.value,
    required this.icon,
    this.accent = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _kCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFFFFF7ED),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 20, color: _kAccent),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: accent ? const Color(0xFF16A34A) : const Color(0xFF111827),
                ),
              ),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  color: Color(0xFF6B7280),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─── Section header ──────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final String title;
  final String? actionLabel;
  const _SectionHeader({required this.title, this.actionLabel});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Color(0xFF111827),
            ),
          ),
          if (actionLabel != null)
            Text(
              actionLabel!,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: _kAccent,
              ),
            ),
        ],
      ),
    );
  }
}

// ─── Upcoming test card ───────────────────────────────────────────────────────

class _UpcomingCard extends StatelessWidget {
  final UpcomingTestModel test;
  const _UpcomingCard({required this.test});

  @override
  Widget build(BuildContext context) {
    final dateStr = DateFormat('d MMM yyyy, h:mm a').format(test.accessStartsAt.toLocal());
    return Container(
      margin: const EdgeInsets.only(left: 16, right: 16, bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _kCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // SCHEDULED badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFEF3C7),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Text(
                        'SCHEDULED',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF92400E),
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      test.title,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF111827),
                      ),
                    ),
                    if (test.courseTitle != null) ...[
                      const SizedBox(height: 3),
                      Text(
                        test.courseTitle!,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF6B7280),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              // Clock icon
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF7ED),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.timer_outlined,
                  size: 22,
                  color: _kAccent,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(height: 1, color: Color(0xFFF3F4F6)),
          const SizedBox(height: 10),
          // Bottom row: date + meta
          Row(
            children: [
              const Icon(
                Icons.calendar_today_outlined,
                size: 13,
                color: Color(0xFF9CA3AF),
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  dateStr,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF6B7280),
                  ),
                ),
              ),
              // Duration chip
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFFF3F4F6),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  '${test.timeMinutes} min',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF374151),
                  ),
                ),
              ),
              const SizedBox(width: 6),
              // Marks chip
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFFF3F4F6),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  '${test.totalMark.toStringAsFixed(0)} marks',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF374151),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          // Opens-in label
          Row(
            children: [
              const Icon(Icons.access_time, size: 13, color: _kAccent),
              const SizedBox(width: 4),
              Text(
                test.daysUntilLabel,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: _kAccent,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─── Result card ─────────────────────────────────────────────────────────────

class _ResultCard extends StatelessWidget {
  final TestResultModel result;
  final bool isLast;
  const _ResultCard({required this.result, this.isLast = false});

  Color get _scoreColor {
    if (result.percent >= 80) return const Color(0xFF16A34A);
    if (result.percent >= 60) return _kAccent;
    if (result.percent >= 50) return const Color(0xFFCA8A04);
    return const Color(0xFFDC2626);
  }

  Color get _scoreBg {
    if (result.percent >= 80) return const Color(0xFFDCFCE7);
    if (result.percent >= 60) return const Color(0xFFFFF7ED);
    if (result.percent >= 50) return const Color(0xFFFEF9C3);
    return const Color(0xFFFEE2E2);
  }

  @override
  Widget build(BuildContext context) {
    final dateStr = result.submittedAt != null
        ? DateFormat('d MMM').format(result.submittedAt!.toLocal())
        : '';
    final sub = [
      if (dateStr.isNotEmpty) dateStr,
      if (result.gradeLetter != null) 'Grade ${result.gradeLetter}',
    ].join(' · ');

    return Container(
      decoration: isLast
          ? null
          : const BoxDecoration(
              border: Border(
                bottom: BorderSide(color: Color(0xFFE5E7EB)),
              ),
            ),
      child: Row(
        children: [
          const SizedBox(width: 16),
          // Score box
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: _scoreBg,
              borderRadius: BorderRadius.circular(12),
            ),
            alignment: Alignment.center,
            child: Text(
              '${result.percent}',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: _scoreColor,
              ),
            ),
          ),
          const SizedBox(width: 14),
          // Title + subtitle
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    result.title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF111827),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (sub.isNotEmpty) ...[
                    const SizedBox(height: 3),
                    Text(
                      sub,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF9CA3AF),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          const Icon(
            Icons.chevron_right,
            size: 20,
            color: Color(0xFFD1D5DB),
          ),
          const SizedBox(width: 12),
        ],
      ),
    );
  }
}

// ─── Skeleton ────────────────────────────────────────────────────────────────

class _TestsSkeleton extends StatelessWidget {
  const _TestsSkeleton();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: _ShimmerBox(height: 80, radius: 14)),
              const SizedBox(width: 12),
              Expanded(child: _ShimmerBox(height: 80, radius: 14)),
            ],
          ),
          const SizedBox(height: 24),
          const _ShimmerBox(height: 16, width: 120),
          const SizedBox(height: 12),
          const _ShimmerBox(height: 110, radius: 14),
          const SizedBox(height: 10),
          const _ShimmerBox(height: 110, radius: 14),
          const SizedBox(height: 24),
          const _ShimmerBox(height: 16, width: 120),
          const SizedBox(height: 12),
          const _ShimmerBox(height: 80, radius: 14),
          const SizedBox(height: 10),
          const _ShimmerBox(height: 80, radius: 14),
          const SizedBox(height: 10),
          const _ShimmerBox(height: 80, radius: 14),
        ],
      ),
    );
  }
}

class _ShimmerBox extends StatelessWidget {
  final double height;
  final double? width;
  final double radius;
  const _ShimmerBox({required this.height, this.width, this.radius = 8});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: const Color(0xFFE5E7EB),
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }
}

// ─── Empty states ────────────────────────────────────────────────────────────

class _EmptyUpcoming extends StatelessWidget {
  const _EmptyUpcoming();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.symmetric(vertical: 24),
      decoration: BoxDecoration(
        color: _kCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: const Column(
        children: [
          Icon(Icons.event_available_outlined, size: 40, color: Color(0xFFD1D5DB)),
          SizedBox(height: 8),
          Text(
            'No upcoming tests',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFF6B7280),
            ),
          ),
          SizedBox(height: 4),
          Text(
            'Scheduled tests will appear here',
            style: TextStyle(fontSize: 12, color: Color(0xFF9CA3AF)),
          ),
        ],
      ),
    );
  }
}

class _EmptyResults extends StatelessWidget {
  const _EmptyResults();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.symmetric(vertical: 24),
      decoration: BoxDecoration(
        color: _kCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: const Column(
        children: [
          Icon(Icons.quiz_outlined, size: 40, color: Color(0xFFD1D5DB)),
          SizedBox(height: 8),
          Text(
            'No tests taken yet',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFF6B7280),
            ),
          ),
          SizedBox(height: 4),
          Text(
            'Your results will show up here',
            style: TextStyle(fontSize: 12, color: Color(0xFF9CA3AF)),
          ),
        ],
      ),
    );
  }
}

// ─── Error view ──────────────────────────────────────────────────────────────

class _ErrorView extends StatelessWidget {
  final VoidCallback onRetry;
  const _ErrorView({required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.wifi_off_rounded, size: 48, color: Color(0xFFD1D5DB)),
          const SizedBox(height: 12),
          const Text(
            'Could not load tests',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: Color(0xFF374151),
            ),
          ),
          const SizedBox(height: 16),
          TextButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh, size: 16),
            label: const Text('Retry'),
            style: TextButton.styleFrom(foregroundColor: _kAccent),
          ),
        ],
      ),
    );
  }
}

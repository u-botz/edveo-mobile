import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/models/attendance_model.dart';
import '../data/repositories/attendance_repository.dart';

const _kAccent = Color(0xFFF97316);
const _kBg = Color(0xFFF9FAFB);

// Status-driven colors
const _kSafe     = Color(0xFF16A34A);
const _kWarning  = Color(0xFFF97316);
const _kCritical = Color(0xFFDC2626);

class InstAttendanceScreen extends ConsumerWidget {
  const InstAttendanceScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final top   = MediaQuery.of(context).padding.top;
    final async = ref.watch(attendanceProvider);

    return Scaffold(
      backgroundColor: _kBg,
      body: Column(
        children: [
          _TopBar(top: top),
          const Divider(height: 1, color: Color(0xFFE5E7EB)),
          Expanded(
            child: async.when(
              loading: () => const _AttendanceSkeleton(),
              error:   (_, __) => _ErrorView(
                onRetry: () => ref.invalidate(attendanceProvider),
              ),
              data: (data) => _AttendanceBody(
                data: data,
                onRefresh: () async {
                  ref.invalidate(attendanceProvider);
                  await Future<void>.delayed(const Duration(milliseconds: 400));
                },
              ),
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
      color: Colors.white,
      padding: EdgeInsets.only(
        left: 16, right: 16, top: top + 12, bottom: 14,
      ),
      child: const Row(
        children: [
          Text(
            'Attendance',
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

class _AttendanceBody extends StatelessWidget {
  final StudentAttendanceModel data;
  final Future<void> Function() onRefresh;

  const _AttendanceBody({required this.data, required this.onRefresh});

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      color: _kAccent,
      onRefresh: onRefresh,
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          // ── Summary card ──────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: _SummaryCard(summary: data.summary),
          ),

          // ── Breakdown chips ───────────────────────────────────────────────
          SliverToBoxAdapter(
            child: _BreakdownRow(summary: data.summary),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 20)),

          // ── Session list header ───────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  const Expanded(
                    child: Text(
                      'This month\'s sessions',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF111827),
                      ),
                    ),
                  ),
                  Text(
                    '${data.sessions.length} sessions',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF9CA3AF),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 10)),

          // ── Session list ──────────────────────────────────────────────────
          if (data.sessions.isEmpty)
            const SliverToBoxAdapter(child: _EmptySessionsView())
          else
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, i) => _SessionRow(
                    session: data.sessions[i],
                    isLast: i == data.sessions.length - 1,
                  ),
                  childCount: data.sessions.length,
                ),
              ),
            ),

          const SliverToBoxAdapter(child: SizedBox(height: 32)),
        ],
      ),
    );
  }
}

// ─── Summary card (ring + status) ────────────────────────────────────────────

class _SummaryCard extends StatelessWidget {
  final AttendanceSummaryModel summary;
  const _SummaryCard({required this.summary});

  Color get _statusColor {
    if (summary.isSafe)     return _kSafe;
    if (summary.isWarning)  return _kWarning;
    return _kCritical;
  }

  Color get _statusBg {
    if (summary.isSafe)     return const Color(0xFFF0FDF4);
    if (summary.isWarning)  return const Color(0xFFFFF7ED);
    return const Color(0xFFFFF1F2);
  }

  IconData get _statusIcon {
    if (summary.isSafe) return Icons.check_circle;
    return Icons.warning_rounded;
  }

  String get _statusLabel {
    if (summary.isSafe)     return 'Exam eligible';
    if (summary.isWarning)  return 'At risk — improve attendance';
    return 'Below minimum — critical';
  }

  String get _aboveBelow {
    final diff = (summary.percentage - summary.threshold).abs().ceil();
    return summary.isSafe
        ? '$diff% above the ${summary.threshold}% minimum'
        : '$diff% below the ${summary.threshold}% minimum';
  }

  @override
  Widget build(BuildContext context) {
    final frac = summary.total > 0
        ? summary.attended / summary.total
        : 0.0;

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              // Donut ring
              _DonutRing(
                fraction: frac,
                color: _statusColor,
                percentage: summary.percentage,
                periodLabel: summary.periodLabel,
              ),
              const SizedBox(width: 18),
              // Right side
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Status badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: _statusBg,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(_statusIcon, size: 13, color: _statusColor),
                          const SizedBox(width: 5),
                          Flexible(
                            child: Text(
                              _statusLabel,
                              style: TextStyle(
                                fontSize: 11.5,
                                fontWeight: FontWeight.w600,
                                color: _statusColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      '${summary.attended} of ${summary.total} sessions attended',
                      style: const TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF374151),
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      _aboveBelow,
                      style: const TextStyle(
                        fontSize: 11.5,
                        color: Color(0xFF6B7280),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─── Donut ring ───────────────────────────────────────────────────────────────

class _DonutRing extends StatelessWidget {
  final double fraction;
  final Color color;
  final double percentage;
  final String periodLabel;

  const _DonutRing({
    required this.fraction,
    required this.color,
    required this.percentage,
    required this.periodLabel,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 100,
      height: 100,
      child: CustomPaint(
        painter: _RingPainter(fraction: fraction.clamp(0.0, 1.0), color: color),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '${percentage.toStringAsFixed(1)}%',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: color,
                  height: 1.1,
                ),
              ),
              Text(
                periodLabel.split(' ').first, // "June"
                style: const TextStyle(
                  fontSize: 9,
                  color: Color(0xFF9CA3AF),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  final double fraction;
  final Color color;
  const _RingPainter({required this.fraction, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width / 2) - 8;
    const sw = 9.0;

    canvas.drawCircle(
      center, radius,
      Paint()
        ..color = const Color(0xFFE5E7EB)
        ..strokeWidth = sw
        ..style = PaintingStyle.stroke,
    );
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      2 * math.pi * fraction,
      false,
      Paint()
        ..color = color
        ..strokeWidth = sw
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(_RingPainter old) =>
      old.fraction != fraction || old.color != color;
}

// ─── Breakdown row ────────────────────────────────────────────────────────────

class _BreakdownRow extends StatelessWidget {
  final AttendanceSummaryModel summary;
  const _BreakdownRow({required this.summary});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Row(
        children: [
          _Chip(
            label: 'Present',
            count: summary.present,
            color: _kSafe,
            bg: const Color(0xFFF0FDF4),
          ),
          const SizedBox(width: 8),
          _Chip(
            label: 'Absent',
            count: summary.absent,
            color: _kCritical,
            bg: const Color(0xFFFFF1F2),
          ),
          const SizedBox(width: 8),
          _Chip(
            label: 'Late',
            count: summary.late,
            color: _kWarning,
            bg: const Color(0xFFFFF7ED),
          ),
          const SizedBox(width: 8),
          _Chip(
            label: 'Excused',
            count: summary.excused,
            color: const Color(0xFF6366F1),
            bg: const Color(0xFFEEF2FF),
          ),
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final String label;
  final int count;
  final Color color;
  final Color bg;

  const _Chip({
    required this.label,
    required this.count,
    required this.color,
    required this.bg,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          children: [
            Text(
              '$count',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: color,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w500,
                color: color.withAlpha(180),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Session row ──────────────────────────────────────────────────────────────

class _SessionRow extends StatelessWidget {
  final AttendanceSessionModel session;
  final bool isLast;
  const _SessionRow({required this.session, required this.isLast});

  Color get _statusColor {
    return switch (session.status) {
      'present' => _kSafe,
      'absent'  => _kCritical,
      'late'    => _kWarning,
      'excused' => const Color(0xFF6366F1),
      _         => const Color(0xFF9CA3AF),
    };
  }

  Color get _statusBg {
    return switch (session.status) {
      'present' => const Color(0xFFF0FDF4),
      'absent'  => const Color(0xFFFFF1F2),
      'late'    => const Color(0xFFFFF7ED),
      'excused' => const Color(0xFFEEF2FF),
      _         => const Color(0xFFF3F4F6),
    };
  }

  String get _statusLabel {
    return switch (session.status) {
      'present' => 'Present',
      'absent'  => 'Absent',
      'late'    => 'Late',
      'excused' => 'Excused',
      _         => 'Not marked',
    };
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: isLast
              ? BorderSide.none
              : const BorderSide(color: Color(0xFFE5E7EB)),
        ),
        borderRadius: isLast
            ? const BorderRadius.only(
                bottomLeft: Radius.circular(14),
                bottomRight: Radius.circular(14),
              )
            : null,
      ),
      child: Row(
        children: [
          // Date block
          Container(
            width: 52,
            padding: const EdgeInsets.symmetric(vertical: 14),
            alignment: Alignment.center,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  session.dayLabel.split(', ').last.split(' ').first, // day number
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF111827),
                  ),
                ),
                Text(
                  session.dayLabel.split(', ').first, // "Mon"
                  style: const TextStyle(
                    fontSize: 10,
                    color: Color(0xFF9CA3AF),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 1,
            height: 40,
            color: const Color(0xFFE5E7EB),
          ),
          const SizedBox(width: 12),
          // Subject + time
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    session.sessionTitle,
                    style: const TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF111827),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${session.startTime} – ${session.endTime}',
                    style: const TextStyle(
                      fontSize: 11.5,
                      color: Color(0xFF9CA3AF),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Status chip
          Container(
            margin: const EdgeInsets.only(right: 14),
            padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
            decoration: BoxDecoration(
              color: _statusBg,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              _statusLabel,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: _statusColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Empty sessions ───────────────────────────────────────────────────────────

class _EmptySessionsView extends StatelessWidget {
  const _EmptySessionsView();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.symmetric(vertical: 32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: const Column(
        children: [
          Icon(Icons.fact_check_outlined, size: 40, color: Color(0xFFD1D5DB)),
          SizedBox(height: 10),
          Text(
            'No sessions this month',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFF6B7280),
            ),
          ),
          SizedBox(height: 4),
          Text(
            'Attendance records will appear here once\nyour teacher marks sessions',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12, color: Color(0xFF9CA3AF)),
          ),
        ],
      ),
    );
  }
}

// ─── Skeleton ─────────────────────────────────────────────────────────────────

class _AttendanceSkeleton extends StatelessWidget {
  const _AttendanceSkeleton();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Summary card skeleton
          Container(
            height: 130,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE5E7EB)),
            ),
            padding: const EdgeInsets.all(18),
            child: Row(
              children: [
                _Sh(width: 100, height: 100, radius: 50),
                const SizedBox(width: 18),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _Sh(width: 120, height: 26, radius: 8),
                      const SizedBox(height: 10),
                      _Sh(width: 160, height: 13, radius: 4),
                      const SizedBox(height: 6),
                      _Sh(width: 130, height: 11, radius: 4),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          // Breakdown chips skeleton
          Row(
            children: List.generate(
              4,
              (_) => Expanded(
                child: Container(
                  margin: const EdgeInsets.only(right: 8),
                  height: 54,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE5E7EB),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          _Sh(width: 140, height: 15, radius: 4),
          const SizedBox(height: 12),
          ...List.generate(
            5,
            (i) => Container(
              margin: const EdgeInsets.only(bottom: 1),
              height: 62,
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border(
                  bottom: BorderSide(color: const Color(0xFFE5E7EB)),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Sh extends StatelessWidget {
  final double width;
  final double height;
  final double radius;
  const _Sh({required this.width, required this.height, required this.radius});

  @override
  Widget build(BuildContext context) => Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: const Color(0xFFE5E7EB),
          borderRadius: BorderRadius.circular(radius),
        ),
      );
}

// ─── Error view ───────────────────────────────────────────────────────────────

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
            'Could not load attendance',
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

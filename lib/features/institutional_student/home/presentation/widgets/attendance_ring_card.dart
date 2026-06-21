import 'dart:math' as math;
import 'package:flutter/material.dart';

// status: 'safe' | 'warning' | 'critical' | null → falls back to orange
const _kSafe     = Color(0xFF16A34A);
const _kWarning  = Color(0xFFF97316);
const _kCritical = Color(0xFFDC2626);

Color _colorForStatus(String? status) {
  return switch (status) {
    'safe'     => _kSafe,
    'critical' => _kCritical,
    _          => _kWarning, // 'warning' + null both map to orange
  };
}

class AttendanceRingCard extends StatelessWidget {
  final int presentDays;
  final int totalDays;
  final double minimumPercent; // e.g. 0.75
  final String? status;        // 'safe' | 'warning' | 'critical' | null
  final bool isLoading;

  const AttendanceRingCard({
    super.key,
    this.presentDays = 0,
    this.totalDays = 0,
    this.minimumPercent = 0.75,
    this.status,
    this.isLoading = false,
  });

  Color get _accentColor => _colorForStatus(status);

  double get _percent =>
      totalDays > 0 ? presentDays / totalDays : 0.0;

  bool get _isSafe => status == 'safe' || (status == null && _percent >= minimumPercent);

  String get _percentLabel =>
      '${(_percent * 100).round()}%';

  String get _aboveBelow {
    final diff = ((_percent - minimumPercent) * 100).abs().round();
    return _isSafe
        ? '$diff% above the ${(minimumPercent * 100).round()}% minimum.'
        : '$diff% below the ${(minimumPercent * 100).round()}% minimum.';
  }

  Color get _badgeBg {
    return switch (status) {
      'safe'     => const Color(0xFFF0FDF4),
      'critical' => const Color(0xFFFFF1F2),
      _          => const Color(0xFFFFF7ED),
    };
  }

  String get _badgeLabel {
    return switch (status) {
      'safe'     => 'Exam eligible',
      'critical' => 'Below minimum',
      _          => 'At risk',
    };
  }

  IconData get _badgeIcon {
    return status == 'safe' ? Icons.check_circle : Icons.warning;
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) return _LoadingSkeleton();

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 14, 16, 0),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Row(
        children: [
          // Donut ring
          SizedBox(
            width: 88,
            height: 88,
            child: CustomPaint(
              painter: _RingPainter(
                percent: _percent,
                accentColor: _accentColor,
              ),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _percentLabel,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: _accentColor,
                        height: 1.1,
                      ),
                    ),
                    const Text(
                      'attendance',
                      style: TextStyle(
                        fontSize: 9,
                        color: Color(0xFF9CA3AF),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          // Stats
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Badge
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _badgeBg,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(_badgeIcon, size: 13, color: _accentColor),
                      const SizedBox(width: 4),
                      Text(
                        _badgeLabel,
                        style: TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w600,
                          color: _accentColor,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '$presentDays of $totalDays sessions attended.',
                  style: const TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF374151),
                  ),
                ),
                const SizedBox(height: 2),
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
    );
  }
}

class _LoadingSkeleton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 14, 16, 0),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Row(
        children: [
          Container(
            width: 88,
            height: 88,
            decoration: const BoxDecoration(
              color: Color(0xFFE5E7EB),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 100,
                  height: 24,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE5E7EB),
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                const SizedBox(height: 10),
                Container(
                  height: 12,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE5E7EB),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(height: 6),
                Container(
                  width: 120,
                  height: 10,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE5E7EB),
                    borderRadius: BorderRadius.circular(4),
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

class _RingPainter extends CustomPainter {
  final double percent;
  final Color accentColor;

  const _RingPainter({required this.percent, required this.accentColor});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width / 2) - 7;
    const strokeWidth = 8.0;

    canvas.drawCircle(
      center, radius,
      Paint()
        ..color = const Color(0xFFE5E7EB)
        ..strokeWidth = strokeWidth
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round,
    );

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      2 * math.pi * percent.clamp(0.0, 1.0),
      false,
      Paint()
        ..color = accentColor
        ..strokeWidth = strokeWidth
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(_RingPainter old) =>
      old.percent != percent || old.accentColor != accentColor;
}

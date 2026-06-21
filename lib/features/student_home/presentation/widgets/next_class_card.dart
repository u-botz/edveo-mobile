import 'dart:async';

import 'package:edveo/features/student_home/data/models/student_home_live_session_model.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class NextClassCard extends StatefulWidget {
  final StudentHomeLiveSessionModel session;

  const NextClassCard({super.key, required this.session});

  @override
  State<NextClassCard> createState() => _NextClassCardState();
}

class _NextClassCardState extends State<NextClassCard> {
  late Timer _timer;
  late String _countdownText;

  @override
  void initState() {
    super.initState();
    _countdownText = _countdown(widget.session.scheduledAt);
    _timer = Timer.periodic(const Duration(minutes: 1), (_) {
      if (mounted) setState(() => _countdownText = _countdown(widget.session.scheduledAt));
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  String _countdown(DateTime scheduledAt) {
    final diff = scheduledAt.toLocal().difference(DateTime.now());
    if (diff.isNegative) return 'Live now';
    if (diff.inMinutes < 60) return 'In ${diff.inMinutes} min';
    return 'In ${diff.inHours}h ${diff.inMinutes % 60}m';
  }

  // "4:00 – 5:30 PM"
  String _timeRange(DateTime start, int? durationMinutes) {
    String fmt(DateTime dt, {bool showPeriod = false}) {
      final h = dt.hour;
      final m = dt.minute;
      final period = h >= 12 ? 'PM' : 'AM';
      final hour = h > 12 ? h - 12 : (h == 0 ? 12 : h);
      final min = m.toString().padLeft(2, '0');
      return showPeriod ? '$hour:$min $period' : '$hour:$min';
    }

    final local = start.toLocal();
    if (durationMinutes == null || durationMinutes <= 0) return fmt(local, showPeriod: true);
    final end = local.add(Duration(minutes: durationMinutes));
    return '${fmt(local)} – ${fmt(end, showPeriod: true)}';
  }

  Future<void> _joinClass(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.session;
    final isLive = s.scheduledAt.toLocal().isBefore(DateTime.now());
    final canJoin = s.joinLink != null && s.joinLink!.isNotEmpty;
    final timeRange = _timeRange(s.scheduledAt, s.durationMinutes);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF16A34A), Color(0xFF22C55E)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          padding: const EdgeInsets.all(18),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              // Watermark icon — back layer
              Positioned(
                right: -12,
                top: -12,
                child: Icon(
                  Icons.school_rounded,
                  size: 90,
                  color: Colors.white.withValues(alpha: 0.08),
                ),
              ),

              // Content
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Label row
                  Row(
                    children: [
                      Container(
                        width: 7,
                        height: 7,
                        decoration: const BoxDecoration(
                          color: Color(0xFFFFD700),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'NEXT CLASS · $_countdownText'.toUpperCase(),
                        style: const TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.6,
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Course title
                  Text(
                    s.title,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      letterSpacing: -0.3,
                      height: 1.2,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),

                  // Instructor + time range
                  Text(
                    [
                      if (s.instructorName != null && s.instructorName!.isNotEmpty)
                        s.instructorName!,
                      timeRange,
                    ].join(' · '),
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: Colors.white70,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 16),

                  // Buttons
                  Row(
                    children: [
                      // Join class — functional
                      ElevatedButton.icon(
                        onPressed: canJoin ? () => _joinClass(s.joinLink!) : null,
                        icon: const Icon(Icons.play_arrow_rounded, size: 16),
                        label: Text(isLive ? 'Join now' : 'Join class'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          disabledBackgroundColor: Colors.white30,
                          foregroundColor: const Color(0xFF16A34A),
                          disabledForegroundColor: Colors.white60,
                          elevation: 0,
                          textStyle: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 13.5,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 11,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      // View material — stub
                      OutlinedButton(
                        onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Course materials coming soon'),
                            duration: Duration(seconds: 2),
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.white,
                          side: const BorderSide(color: Colors.white60),
                          textStyle: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 13.5,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 11,
                          ),
                        ),
                        child: const Text('View material'),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

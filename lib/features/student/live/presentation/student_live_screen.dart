import 'package:flutter/material.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Static demo models — replace with real providers once backend is ready.
// ─────────────────────────────────────────────────────────────────────────────

class _LiveNowSession {
  final String title;
  final String instructorName;
  final int startedMinutesAgo;
  final int watchingCount;

  const _LiveNowSession({
    required this.title,
    required this.instructorName,
    required this.startedMinutesAgo,
    required this.watchingCount,
  });
}

class _UpcomingSession {
  final String title;
  final String instructorName;
  final String when; // "Today · 6:30 PM"
  final Color iconColor;

  const _UpcomingSession({
    required this.title,
    required this.instructorName,
    required this.when,
    required this.iconColor,
  });
}

class _PastRecording {
  final String title;
  final String dateLabel;
  final String duration; // "1h 24m"
  final Color thumbColor;

  const _PastRecording({
    required this.title,
    required this.dateLabel,
    required this.duration,
    required this.thumbColor,
  });
}

// ─────────────────────────────────────────────────────────────────────────────
// Screen
// ─────────────────────────────────────────────────────────────────────────────

class StudentLiveScreen extends StatelessWidget {
  const StudentLiveScreen({super.key});

  // Demo data ─────────────────────────────────────────────────────────────────

  static const _liveNow = _LiveNowSession(
    title:               'JEE Strategy — Last 30 Days',
    instructorName:      'Mr. Suresh Babu',
    startedMinutesAgo:   12,
    watchingCount:       42,
  );

  static const _upcoming = [
    _UpcomingSession(
      title:          'Doubt Solving — Physics',
      instructorName: 'Dr. Ramesh Iyer',
      when:           'Today · 6:30 PM',
      iconColor:      Color(0xFF2563EB),
    ),
    _UpcomingSession(
      title:          'Organic Chem · Reactions',
      instructorName: 'Ms. Priya Nair',
      when:           'Tomorrow · 9:00 AM',
      iconColor:      Color(0xFF7C3AED),
    ),
  ];

  static const _recordings = [
    _PastRecording(
      title:      'Calculus · Limits & Continuity',
      dateLabel:  '12 May',
      duration:   '1h 24m',
      thumbColor: Color(0xFFF97316),
    ),
    _PastRecording(
      title:      'Mechanics · Friction',
      dateLabel:  '10 May',
      duration:   '58 min',
      thumbColor: Color(0xFF2563EB),
    ),
    _PastRecording(
      title:      'Genetics · Mendelian Laws',
      dateLabel:  '9 May',
      duration:   '1h 02m',
      thumbColor: Color(0xFF0891B2),
    ),
  ];

  // ─────────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final topPad = MediaQuery.of(context).padding.top;

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      body: Column(
        children: [
          _LiveTopBar(topPad: topPad),
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                // Live Now card
                _LiveNowCard(session: _liveNow),

                // Upcoming sessions
                const _SectionHeader(title: 'Upcoming Sessions'),
                ..._upcoming.map((s) => _UpcomingSessionRow(session: s)),

                // Past recordings
                const _SectionHeader(
                  title: 'Past Recordings',
                  actionLabel: 'See all',
                ),
                ..._recordings.map((r) => _PastRecordingRow(recording: r)),

                const SizedBox(height: 100),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Top bar
// ─────────────────────────────────────────────────────────────────────────────

class _LiveTopBar extends StatelessWidget {
  final double topPad;
  const _LiveTopBar({required this.topPad});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(20, topPad + 14, 20, 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'SESSIONS',
                        style: TextStyle(
                          fontSize: 11,
                          color: Color(0xFF9CA3AF),
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.8,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'Live',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF111827),
                          letterSpacing: -0.4,
                        ),
                      ),
                    ],
                  ),
                ),
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    GestureDetector(
                      onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Notifications coming soon'),
                          duration: Duration(seconds: 2),
                        ),
                      ),
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          border: Border.all(color: const Color(0xFFE5E7EB)),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.notifications_outlined,
                          size: 20,
                          color: Color(0xFF6B7280),
                        ),
                      ),
                    ),
                    Positioned(
                      top: 6,
                      right: 8,
                      child: Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: Color(0xFFDC2626),
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Container(height: 1, color: const Color(0xFFE5E7EB)),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Live Now card (red gradient)
// ─────────────────────────────────────────────────────────────────────────────

class _LiveNowCard extends StatelessWidget {
  final _LiveNowSession session;
  const _LiveNowCard({required this.session});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFFDC2626), Color(0xFFEF4444)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          padding: const EdgeInsets.all(18),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              // Watermark circle decoration
              Positioned(
                right: -24,
                bottom: -24,
                child: Container(
                  width: 110,
                  height: 110,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withValues(alpha: 0.07),
                  ),
                ),
              ),
              Positioned(
                right: 12,
                bottom: -4,
                child: Container(
                  width: 70,
                  height: 70,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withValues(alpha: 0.06),
                  ),
                ),
              ),

              // Content
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // "LIVE NOW" + watching count
                  Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      const Text(
                        'LIVE NOW',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                          letterSpacing: 0.8,
                        ),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '${session.watchingCount} watching',
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Title
                  Text(
                    session.title,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      letterSpacing: -0.3,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 6),

                  // Instructor + started
                  Text(
                    '${session.instructorName} · Started ${session.startedMinutesAgo} min ago',
                    style: TextStyle(
                      fontSize: 12.5,
                      color: Colors.white.withValues(alpha: 0.8),
                    ),
                  ),
                  const SizedBox(height: 18),

                  // Join button
                  GestureDetector(
                    onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Live join coming soon'),
                        duration: Duration(seconds: 2),
                      ),
                    ),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 18, vertical: 11),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.play_arrow_rounded,
                              size: 17, color: Color(0xFFDC2626)),
                          SizedBox(width: 6),
                          Text(
                            'Join live now',
                            style: TextStyle(
                              fontSize: 13.5,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFFDC2626),
                            ),
                          ),
                        ],
                      ),
                    ),
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

// ─────────────────────────────────────────────────────────────────────────────
// Section header
// ─────────────────────────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final String title;
  final String? actionLabel;

  const _SectionHeader({required this.title, this.actionLabel});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
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
          if (actionLabel != null)
            GestureDetector(
              onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Coming soon'),
                  duration: Duration(seconds: 2),
                ),
              ),
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

// ─────────────────────────────────────────────────────────────────────────────
// Upcoming session row
// ─────────────────────────────────────────────────────────────────────────────

class _UpcomingSessionRow extends StatelessWidget {
  final _UpcomingSession session;
  const _UpcomingSessionRow({required this.session});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
      child: Row(
        children: [
          // Camera icon square
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: session.iconColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.videocam_rounded,
              size: 22,
              color: session.iconColor,
            ),
          ),
          const SizedBox(width: 12),

          // Title + instructor + when
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  session.title,
                  style: const TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF111827),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 3),
                Text(
                  '${session.instructorName} · ${session.when}',
                  style: const TextStyle(
                    fontSize: 11.5,
                    color: Color(0xFF6B7280),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),

          // Remind button
          GestureDetector(
            onTap: () => ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Reminder set!'),
                duration: Duration(seconds: 2),
              ),
            ),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
              decoration: BoxDecoration(
                color: const Color(0xFFF0FDF4),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFBBF7D0)),
              ),
              child: const Text(
                'Remind',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF16A34A),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Past recording row
// ─────────────────────────────────────────────────────────────────────────────

class _PastRecordingRow extends StatelessWidget {
  final _PastRecording recording;
  const _PastRecordingRow({required this.recording});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Row(
        children: [
          // Thumbnail with duration badge
          Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  width: 68,
                  height: 48,
                  color: recording.thumbColor,
                  child: const Icon(
                    Icons.play_circle_fill_rounded,
                    size: 28,
                    color: Colors.white,
                  ),
                ),
              ),
              // Duration badge bottom-left
              Positioned(
                bottom: 3,
                left: 3,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 4, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.65),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    recording.duration,
                    style: const TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 12),

          // Title + date
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  recording.title,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF111827),
                    height: 1.3,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 3),
                Text(
                  recording.dateLabel,
                  style: const TextStyle(
                    fontSize: 11.5,
                    color: Color(0xFF9CA3AF),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),

          // Download icon
          GestureDetector(
            onTap: () => ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Download coming soon'),
                duration: Duration(seconds: 2),
              ),
            ),
            child: const Icon(
              Icons.download_outlined,
              size: 22,
              color: Color(0xFF9CA3AF),
            ),
          ),
        ],
      ),
    );
  }
}

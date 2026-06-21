import 'package:flutter/material.dart';

enum CheckInStatus { present, absent, notMarked }

class CheckInStatusCard extends StatelessWidget {
  final CheckInStatus status;
  // e.g. "9:02 AM" — null when status is notMarked/absent
  final String? checkInTime;
  // e.g. "Gate 2 biometric"
  final String? method;
  // e.g. "DAY 1/4" — current day of the week/cycle
  final String dayLabel;

  const CheckInStatusCard({
    super.key,
    required this.status,
    this.checkInTime,
    this.method,
    required this.dayLabel,
  });

  @override
  Widget build(BuildContext context) {
    final (bg, iconBg, icon, title, subtitle) = switch (status) {
      CheckInStatus.present => (
          const Color(0xFFF0FDF4),
          const Color(0xFF16A34A),
          Icons.check,
          'Marked present today',
          checkInTime != null && method != null
              ? 'Checked in $checkInTime · $method'
              : 'Attendance recorded',
        ),
      CheckInStatus.absent => (
          const Color(0xFFFFF1F2),
          const Color(0xFFDC2626),
          Icons.close,
          'Marked absent today',
          'Contact your teacher if this is incorrect',
        ),
      CheckInStatus.notMarked => (
          const Color(0xFFFFF7ED),
          const Color(0xFFF97316),
          Icons.schedule,
          'Not yet checked in',
          'Attendance will be marked at class start',
        ),
    };

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          // Status icon circle
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: iconBg,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 12),
          // Title + subtitle
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF111827),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 11.5,
                    color: Color(0xFF6B7280),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          // Day badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: iconBg.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              dayLabel,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: iconBg,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

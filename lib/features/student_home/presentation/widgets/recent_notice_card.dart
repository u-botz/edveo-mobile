import 'package:edveo/features/student_home/data/models/notice_model.dart';
import 'package:flutter/material.dart';

class RecentNoticeCard extends StatelessWidget {
  final NoticeModel notice;

  const RecentNoticeCard({super.key, required this.notice});

  /// Parses `#RRGGBB` or falls back to amber.
  Color _noticeColor() {
    final raw = notice.color;
    if (raw != null && raw.startsWith('#') && raw.length == 7) {
      try {
        return Color(int.parse('0xFF${raw.substring(1)}'));
      } catch (_) {}
    }
    return const Color(0xFFF59E0B);
  }

  /// BR-STU-HOME-017: relative time computed client-side.
  String _relativeTime(DateTime createdAt) {
    final diff = DateTime.now().difference(createdAt);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }

  @override
  Widget build(BuildContext context) {
    final accent = _noticeColor();
    final timeStr = notice.createdAt != null
        ? _relativeTime(notice.createdAt!)
        : '';

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFE5E7EB)),
        ),
        padding: const EdgeInsets.all(14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 4,
              height: 48,
              decoration: BoxDecoration(
                color: accent,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.campaign_rounded,
                        size: 14,
                        color: Color(0xFF6B7280),
                      ),
                      const SizedBox(width: 4),
                      const Text(
                        'Notice',
                        style: TextStyle(
                          fontSize: 11,
                          color: Color(0xFF6B7280),
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.4,
                        ),
                      ),
                      const Spacer(),
                      if (timeStr.isNotEmpty)
                        Text(
                          timeStr,
                          style: const TextStyle(
                            fontSize: 11,
                            color: Color(0xFF9CA3AF),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    notice.title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF111827),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (notice.message != null && notice.message!.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      notice.message!,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF6B7280),
                        height: 1.4,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

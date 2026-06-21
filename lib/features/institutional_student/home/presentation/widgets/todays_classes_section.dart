import 'package:flutter/material.dart';

enum ClassStatus { completed, ongoing, upcoming }

class TodayClassItem {
  final String time;
  final String subject;
  final String teacher;
  final String room;
  final ClassStatus status;

  const TodayClassItem({
    required this.time,
    required this.subject,
    required this.teacher,
    required this.room,
    required this.status,
  });
}

class TodaysClassesSection extends StatelessWidget {
  final String dateLabel;
  final List<TodayClassItem> classes;
  final VoidCallback? onScheduleTap;
  final Color accentColor;
  final bool isLoading;
  final String? emptyMessage;

  const TodaysClassesSection({
    super.key,
    required this.dateLabel,
    required this.classes,
    this.onScheduleTap,
    this.accentColor = const Color(0xFFF97316),
    this.isLoading = false,
    this.emptyMessage,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section header
          Row(
            children: [
              const Expanded(
                child: Text(
                  "Today's classes",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF111827),
                  ),
                ),
              ),
              GestureDetector(
                onTap: onScheduleTap,
                child: Text(
                  'Schedule →',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: accentColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 3),
          Text(
            dateLabel,
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFF9CA3AF),
              fontWeight: FontWeight.w400,
            ),
          ),
          const SizedBox(height: 12),

          // Body: loading | empty | list
          if (isLoading)
            _LoadingSkeleton()
          else if (classes.isEmpty)
            _EmptyState(message: emptyMessage ?? 'No classes today')
          else
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFE5E7EB)),
              ),
              child: ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: classes.length,
                separatorBuilder: (_, __) => const Divider(
                  height: 1,
                  indent: 60,
                  endIndent: 0,
                  color: Color(0xFFE5E7EB),
                ),
                itemBuilder: (_, i) => _ClassRow(
                  item: classes[i],
                  accentColor: accentColor,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ─── Loading skeleton ────────────────────────────────────────────────────────

class _LoadingSkeleton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: 3,
        separatorBuilder: (_, __) => const Divider(
          height: 1,
          indent: 60,
          color: Color(0xFFE5E7EB),
        ),
        itemBuilder: (_, __) => Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          child: Row(
            children: [
              _Shimmer(width: 36, height: 14, radius: 4),
              const SizedBox(width: 14),
              _Shimmer(width: 3, height: 38, radius: 2),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _Shimmer(width: 120, height: 13, radius: 4),
                    const SizedBox(height: 6),
                    _Shimmer(width: 160, height: 11, radius: 4),
                  ],
                ),
              ),
              _Shimmer(width: 44, height: 24, radius: 12),
            ],
          ),
        ),
      ),
    );
  }
}

class _Shimmer extends StatelessWidget {
  final double width;
  final double height;
  final double radius;
  const _Shimmer({required this.width, required this.height, required this.radius});

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

// ─── Empty state ─────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  final String message;
  const _EmptyState({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 28),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.wb_sunny_outlined,
            size: 36,
            color: Color(0xFFD1D5DB),
          ),
          const SizedBox(height: 8),
          Text(
            message,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: Color(0xFF9CA3AF),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Class row ────────────────────────────────────────────────────────────────

class _ClassRow extends StatelessWidget {
  final TodayClassItem item;
  final Color accentColor;

  const _ClassRow({required this.item, required this.accentColor});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        children: [
          // Time
          SizedBox(
            width: 44,
            child: Text(
              item.time,
              style: const TextStyle(
                fontSize: 12,
                color: Color(0xFF9CA3AF),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          // Left accent bar
          Container(
            width: 3,
            height: 38,
            margin: const EdgeInsets.only(right: 10),
            decoration: BoxDecoration(
              color: item.status == ClassStatus.ongoing
                  ? accentColor
                  : const Color(0xFFE5E7EB),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          // Subject + teacher · room
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.subject,
                  style: const TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF111827),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  [if (item.teacher.isNotEmpty) item.teacher,
                   if (item.room.isNotEmpty) item.room]
                      .join(' · '),
                  style: const TextStyle(
                    fontSize: 11.5,
                    color: Color(0xFF9CA3AF),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          _StatusBadge(status: item.status, accentColor: accentColor),
        ],
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final ClassStatus status;
  final Color accentColor;

  const _StatusBadge({required this.status, required this.accentColor});

  @override
  Widget build(BuildContext context) {
    return switch (status) {
      ClassStatus.completed => const Icon(
          Icons.check_circle_outline,
          size: 18,
          color: Color(0xFF16A34A),
        ),
      ClassStatus.ongoing => Container(
          padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
          decoration: BoxDecoration(
            color: accentColor,
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Text(
            'NOW',
            style: TextStyle(
              fontSize: 10.5,
              fontWeight: FontWeight.w800,
              color: Colors.white,
              letterSpacing: 0.3,
            ),
          ),
        ),
      ClassStatus.upcoming => const Text(
          'upcoming',
          style: TextStyle(
            fontSize: 11.5,
            color: Color(0xFF9CA3AF),
            fontWeight: FontWeight.w400,
          ),
        ),
    };
  }
}

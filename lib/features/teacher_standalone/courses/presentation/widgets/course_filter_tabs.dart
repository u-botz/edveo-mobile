import 'package:flutter/material.dart';
import 'package:edveo/features/courses/data/models/course_model.dart';

class CourseFilterTabs extends StatelessWidget {
  final CourseStatus? activeFilter;
  final Map<CourseStatus?, int> counts;
  final ValueChanged<CourseStatus?> onFilterChanged;

  const CourseFilterTabs({
    super.key,
    required this.activeFilter,
    required this.counts,
    required this.onFilterChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 44,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          _tab(label: 'All',       count: counts[null]                  ?? 0, status: null),
          _tab(label: 'Published', count: counts[CourseStatus.published] ?? 0, status: CourseStatus.published),
          _tab(label: 'Draft',     count: counts[CourseStatus.draft]     ?? 0, status: CourseStatus.draft),
          _tab(label: 'Archived',  count: counts[CourseStatus.archived]  ?? 0, status: CourseStatus.archived),
        ],
      ),
    );
  }

  Widget _tab({required String label, required int count, required CourseStatus? status}) {
    final isActive = activeFilter == status;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () => onFilterChanged(status),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: isActive ? const Color(0xFF111827) : Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: isActive ? const Color(0xFF111827) : Colors.grey.shade300),
          ),
          child: Row(
            children: [
              Text(
                label,
                style: TextStyle(
                  color: isActive ? Colors.white : Colors.black87,
                  fontWeight: FontWeight.w500,
                  fontSize: 13,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                '$count',
                style: TextStyle(
                  color: isActive ? Colors.white70 : Colors.grey.shade500,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

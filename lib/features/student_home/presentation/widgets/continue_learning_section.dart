import 'package:edveo/features/student_home/data/models/continue_learning_item_model.dart';
import 'package:edveo/features/student_home/presentation/widgets/continue_learning_card.dart';
import 'package:flutter/material.dart';

/// BR-STU-HOME-014: when [items] is empty the entire section is hidden —
/// no header, no empty row, no placeholder text.
class ContinueLearningSection extends StatelessWidget {
  final List<ContinueLearningItemModel> items;

  const ContinueLearningSection({super.key, required this.items});

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 12),
          child: Row(
            children: [
              const Expanded(
                child: Text(
                  'Continue Learning',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF111827),
                  ),
                ),
              ),
              // "See all" stub (§9.5 — no navigation this milestone)
              GestureDetector(
                onTap: () {},
                child: const Text(
                  'See all',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF16A34A),
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 202,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: items.length > 4 ? 4 : items.length, // BR-STU-HOME-014: max 4
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (context, index) =>
                ContinueLearningCard(item: items[index]),
          ),
        ),
      ],
    );
  }
}

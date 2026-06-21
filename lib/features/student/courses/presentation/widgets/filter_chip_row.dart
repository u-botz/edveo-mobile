import 'package:flutter/material.dart';

class FilterChipRow extends StatelessWidget {
  final String selected;
  final ValueChanged<String> onSelect;
  final Map<String, int> counts;

  const FilterChipRow({
    super.key,
    required this.selected,
    required this.onSelect,
    required this.counts,
  });

  static const _filters = <({String value, String label})>[
    (value: 'all',         label: 'All'),
    (value: 'in_progress', label: 'In Progress'),
    (value: 'completed',   label: 'Completed'),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 10),
        child: Row(
          children: _filters.map((f) {
            final isActive = selected == f.value;
            final count = counts[f.value] ?? 0;

            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: GestureDetector(
                onTap: () => onSelect(f.value),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 7),
                  decoration: BoxDecoration(
                    color: isActive
                        ? const Color(0xFF111827)
                        : Colors.white,
                    borderRadius: BorderRadius.circular(99),
                    border: Border.all(
                      color: isActive
                          ? const Color(0xFF111827)
                          : const Color(0xFFE5E7EB),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        f.label,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: isActive
                              ? Colors.white
                              : const Color(0xFF6B7280),
                        ),
                      ),
                      if (count > 0) ...[
                        const SizedBox(width: 6),
                        Text(
                          '$count',
                          style: TextStyle(
                            fontSize: 10,
                            fontFamily: 'monospace',
                            fontWeight: FontWeight.w600,
                            color: (isActive ? Colors.white : const Color(0xFF6B7280))
                                .withValues(alpha: 0.75),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';

class ExamsStatStrip extends StatelessWidget {
  final double? avgScore;
  final int testsTaken;
  final int upcomingCount;

  const ExamsStatStrip({
    super.key,
    required this.avgScore,
    required this.testsTaken,
    required this.upcomingCount,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 14),
      child: Row(
        children: [
          Expanded(
            child: _StatCard(
              value: avgScore != null ? avgScore!.toStringAsFixed(1) : '—',
              label: 'Avg score',
              valueColor: const Color(0xFF00875A),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _StatCard(
              value: testsTaken.toString(),
              label: 'Tests taken',
              valueColor: const Color(0xFF111827),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _StatCard(
              value: upcomingCount.toString(),
              label: 'Upcoming',
              valueColor: const Color(0xFFEA580C),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String value;
  final String label;
  final Color valueColor;

  const _StatCard({
    required this.value,
    required this.label,
    required this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w700,
              color: valueColor,
              height: 1.1,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: Color(0xFF9CA3AF),
            ),
          ),
        ],
      ),
    );
  }
}

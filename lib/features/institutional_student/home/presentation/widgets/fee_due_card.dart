import 'package:flutter/material.dart';

class FeeDueCard extends StatelessWidget {
  final String termLabel;      // e.g. "Term 3 fee due"
  final String amount;         // e.g. "₹12,000"
  final String dueDateLabel;   // e.g. "Pay before 15 Jun to avoid late fee"
  final VoidCallback? onPay;
  final Color accentColor;

  const FeeDueCard({
    super.key,
    required this.termLabel,
    required this.amount,
    required this.dueDateLabel,
    this.onPay,
    this.accentColor = const Color(0xFFF97316),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 14, 16, 0),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF7ED),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFFED7AA)),
      ),
      child: Row(
        children: [
          // Credit card icon
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: accentColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              Icons.credit_card_outlined,
              color: accentColor,
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          // Label + amount + due date
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$termLabel · $amount',
                  style: const TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF111827),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  dueDateLabel,
                  style: const TextStyle(
                    fontSize: 11.5,
                    color: Color(0xFF6B7280),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          // Pay button
          GestureDetector(
            onTap: onPay,
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: accentColor,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Text(
                'Pay',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../theme/edveo_colors.dart';
import '../theme/edveo_typography.dart';

class EdveoBrandHeader extends StatelessWidget {
  const EdveoBrandHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 16, left: 24, right: 24, bottom: 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: EdveoColors.brandPrimary,
              borderRadius: BorderRadius.circular(6),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'edveo',
            style: EdveoTypography.logoWordmark,
          ),
          Text(
            'Your learning, simplified',
            style: EdveoTypography.logoTagline,
          ),
        ],
      ),
    );
  }
}

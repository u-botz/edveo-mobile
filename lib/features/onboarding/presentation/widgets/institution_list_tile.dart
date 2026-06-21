import 'package:flutter/material.dart';
import '../../data/models/institution.dart';
import '../../../../core/theme/edveo_colors.dart';
import '../../../../core/theme/edveo_typography.dart';
import '../../../auth/presentation/widgets/institution_avatar.dart';

class InstitutionListTile extends StatelessWidget {
  final Institution institution;
  final VoidCallback onTap;

  const InstitutionListTile({
    super.key,
    required this.institution,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final hasCity = institution.city != null && institution.city!.isNotEmpty;

    return Semantics(
      button: true,
      label: 'Open ${institution.name}${hasCity ? " in ${institution.city}" : ""}',
      child: Material(
        color: EdveoColors.surface,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          splashColor: EdveoColors.accentGreen.withValues(alpha: 0.05),
          highlightColor: EdveoColors.accentGreen.withValues(alpha: 0.05),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              border: Border.all(color: EdveoColors.divider),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                InstitutionAvatar(
                  institutionName: institution.name,
                  accentColor: EdveoColors.tintForSlug(institution.slug),
                  logoUrl: institution.logoUrl,
                  size: 44,
                  borderRadius: 12,
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        institution.name,
                        style: EdveoTypography.cardTitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (hasCity) ...[
                        const SizedBox(height: 2),
                        Text(
                          institution.city!,
                          style: EdveoTypography.cardMeta,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                      const SizedBox(height: 2),
                      Text(
                        institution.slug,
                        style: EdveoTypography.cardMeta.copyWith(
                          color: EdveoColors.textFaint,
                          fontFamily: 'monospace',
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 14),
                const Icon(
                  Icons.chevron_right_rounded,
                  size: 18,
                  color: EdveoColors.textFaint,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

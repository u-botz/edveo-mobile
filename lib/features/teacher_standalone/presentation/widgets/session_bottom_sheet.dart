import 'package:edveo/features/teacher_standalone/home/data/models/home_data_model.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

void showSessionBottomSheet(
  BuildContext context,
  ScheduleSessionModel session,
) {
  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _SessionSheet(session: session),
  );
}

class _SessionSheet extends StatelessWidget {
  final ScheduleSessionModel session;
  const _SessionSheet({required this.session});

  String _formatTime(DateTime dt) {
    final local = dt.toLocal();
    final h = local.hour;
    final m = local.minute;
    final period = h >= 12 ? 'PM' : 'AM';
    final hour = h > 12 ? h - 12 : (h == 0 ? 12 : h);
    return '$hour:${m.toString().padLeft(2, '0')} $period';
  }

  Future<void> _joinClass(BuildContext context) async {
    final uri = Uri.tryParse(session.hostUrl);
    if (uri == null) return;
    final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!ok && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not open the class link.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final textPrimary = const Color(0xFF111827);
    final primary = const Color(0xFF1D4ED8);
    final border = const Color(0xFFE5E7EB);
    final primaryShadow = const Color(0x331D4ED8);

    TextStyle pjs({
      double size = 13,
      FontWeight weight = FontWeight.w400,
      Color? color,
    }) =>
        GoogleFonts.plusJakartaSans(
          fontSize: size,
          fontWeight: weight,
          color: color ?? textPrimary,
        );

    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFFFFFFFF),
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: EdgeInsets.fromLTRB(
        20,
        20,
        20,
        20 + MediaQuery.of(context).viewInsets.bottom + MediaQuery.of(context).padding.bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: border,
                borderRadius: BorderRadius.circular(99),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(session.title,
              style: pjs(size: 18, weight: FontWeight.w800)),
          const SizedBox(height: 12),
          _InfoRow(
            icon: Icons.schedule_rounded,
            label: '${_formatTime(session.startsAt)} – ${_formatTime(session.endsAt)}',
            sub: '${session.durationMinutes} min',
            color: primary,
          ),
          const SizedBox(height: 8),
          _InfoRow(
            icon: Icons.videocam_rounded,
            label: session.provider,
            color: primary,
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: primary,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: primaryShadow,
                    blurRadius: 14,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () => _joinClass(context),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Join Class',
                          style: pjs(
                              size: 15,
                              weight: FontWeight.w700,
                              color: Colors.white)),
                      const SizedBox(width: 6),
                      const Icon(Icons.arrow_forward_rounded,
                          size: 16, color: Colors.white),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String? sub;
  final Color color;

  const _InfoRow({
    required this.icon,
    required this.label,
    this.sub,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 16, color: color),
        ),
        const SizedBox(width: 10),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF111827),
                )),
            if (sub != null)
              Text(sub!,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11,
                    color: const Color(0xFF6B7280),
                  )),
          ],
        ),
      ],
    );
  }
}

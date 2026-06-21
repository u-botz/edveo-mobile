import 'dart:async';

import 'package:edveo/core/utils/currency_formatter.dart';
import 'package:edveo/features/auth/presentation/me_providers.dart';
import 'package:edveo/features/teacher_standalone/home/data/models/home_data_model.dart';
import 'package:edveo/features/teacher_standalone/home/presentation/providers/home_providers.dart';
import 'package:edveo/features/teacher_standalone/home/presentation/widgets/enrollment_chart_widget.dart';
import 'package:edveo/features/teacher_standalone/home/presentation/widgets/revenue_chart_widget.dart';
import 'package:edveo/features/teacher_standalone/presentation/widgets/session_bottom_sheet.dart';
import 'package:edveo/features/teacher_standalone/presentation/widgets/ai_banner_widget.dart';
import 'package:edveo/features/teacher_standalone/presentation/widgets/ai_banner_skeleton.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

// ── Design tokens ─────────────────────────────────────────────────────────────

class _C {
  static const primary       = Color(0xFF1D4ED8);
  static const green         = Color(0xFF059669);
  static const red           = Color(0xFFDC2626);
  static const text          = Color(0xFF111827);
  static const muted         = Color(0xFF6B7280);
  static const faint         = Color(0xFF9CA3AF);
  static const bg            = Color(0xFFF9FAFB);
  static const surf          = Color(0xFFFFFFFF);
  static const border        = Color(0xFFE5E7EB);
  static const borderS       = Color(0xFFF3F4F6);
}

// ── Cached base TextStyles — avoids GoogleFonts() construction on every build ─

final _pjsBase = GoogleFonts.plusJakartaSans();
final _fmBase  = GoogleFonts.jetBrainsMono();

// Cached font-family string for inline RichText spans.
final _monoFamily = GoogleFonts.jetBrainsMono().fontFamily;

TextStyle _pjs({
  double size = 13,
  FontWeight weight = FontWeight.w400,
  Color color = _C.text,
  double ls = 0,
  double? height,
}) =>
    _pjsBase.copyWith(
      fontSize: size,
      fontWeight: weight,
      color: color,
      letterSpacing: ls,
      height: height,
    );

TextStyle _fm({
  double size = 13,
  FontWeight weight = FontWeight.w400,
  Color color = _C.text,
  double ls = 0,
  double? height,
}) =>
    _fmBase.copyWith(
      fontSize: size,
      fontWeight: weight,
      color: color,
      letterSpacing: ls,
      height: height,
    );

// ── Helpers ───────────────────────────────────────────────────────────────────

String _dayName(int weekday) => const [
      'Monday', 'Tuesday', 'Wednesday', 'Thursday',
      'Friday', 'Saturday', 'Sunday'
    ][weekday - 1];

String _monthName(int month) => const [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ][month - 1];

String _fmtDate(DateTime d) =>
    '${_dayName(d.weekday)}, ${d.day} ${_monthName(d.month)}';

String _fmtTime(DateTime dt) {
  final local = dt.toLocal();
  final h = local.hour;
  final m = local.minute;
  final period = h >= 12 ? 'PM' : 'AM';
  final hour = h > 12 ? h - 12 : (h == 0 ? 12 : h);
  return '$hour:${m.toString().padLeft(2, '0')} $period';
}

String _relativeTime(DateTime dt) {
  final diff = DateTime.now().difference(dt.toLocal());
  if (diff.inMinutes < 1) return 'Just now';
  if (diff.inMinutes < 60) return '${diff.inMinutes} min ago';
  if (diff.inHours < 24) return '${diff.inHours} hr ago';
  return '${diff.inDays}d ago';
}

String _countdown(DateTime startsAt) {
  final diff = startsAt.toLocal().difference(DateTime.now());
  if (diff.isNegative) return 'Live now';
  if (diff.inMinutes < 60) return 'Starting in ${diff.inMinutes} min';
  return 'In ${diff.inHours}h ${diff.inMinutes % 60}m';
}

// ── Screen ────────────────────────────────────────────────────────────────────

class StandaloneHomeScreen extends ConsumerStatefulWidget {
  const StandaloneHomeScreen({super.key});

  @override
  ConsumerState<StandaloneHomeScreen> createState() =>
      _StandaloneHomeScreenState();
}

class _StandaloneHomeScreenState extends ConsumerState<StandaloneHomeScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulseCtrl;
  // Fires every minute so countdown/relative-time labels stay accurate.
  Timer? _clockTimer;

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..repeat(reverse: true);

    _clockTimer = Timer.periodic(const Duration(minutes: 1), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    _clockTimer?.cancel();
    super.dispose();
  }

  String get _greeting {
    final h = DateTime.now().hour;
    if (h < 12) return 'Good morning 👋';
    if (h < 17) return 'Good afternoon 👋';
    if (h < 21) return 'Good evening 👋';
    return 'Working late 🌙';
  }

  Future<void> _onRefresh() async {
    ref.invalidate(aiBannerProvider);
    await ref.read(homeProvider.notifier).refresh();
  }

  @override
  Widget build(BuildContext context) {
    final homeAsync = ref.watch(homeProvider);
    final me = ref.watch(currentMeProvider);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: _C.bg,
        body: SafeArea(
          bottom: false,
          child: homeAsync.when(
            loading: () => _buildSkeleton(),
            error: (e, _) => _buildError(),
            data: (home) => RefreshIndicator(
              onRefresh: _onRefresh,
              child: CustomScrollView(
                physics: const BouncingScrollPhysics(),
                slivers: [
                  SliverToBoxAdapter(
                      child: _TopBar(
                    greeting: _greeting,
                    initials: me?.initials ?? '?',
                  )),
                  const SliverToBoxAdapter(child: SizedBox(height: 12)),
                  SliverToBoxAdapter(
                      child: _SummaryStrip(stats: home.stats)),
                  const SliverToBoxAdapter(child: SizedBox(height: 14)),

                  // AI Banner
                  SliverToBoxAdapter(
                    child: ref.watch(aiBannerProvider).when(
                          data: (banner) => AiBannerWidget(
                            banner: banner,
                            onCtaTap: banner.ctaRoute == null
                                ? null
                                : () => context.push(banner.ctaRoute!),
                          ),
                          loading: () => const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 16),
                            child: AiBannerSkeleton(),
                          ),
                          error: (_, __) => const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 16),
                            child: AiBannerSkeleton(),
                          ),
                        ),
                  ),
                  const SliverToBoxAdapter(child: SizedBox(height: 16)),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 18),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Today · ${_fmtDate(DateTime.now())}',
                              style: _pjs(size: 14, weight: FontWeight.w800, ls: -0.2)),
                          Row(
                            children: [
                              Text('Calendar', style: _pjs(size: 11.5, weight: FontWeight.w700, color: _C.primary)),
                              const SizedBox(width: 2),
                              const Icon(Icons.arrow_forward_rounded, size: 12, color: _C.primary),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SliverToBoxAdapter(child: SizedBox(height: 6)),
                  SliverToBoxAdapter(
                    child: _AgendaSection(
                      sessions: home.schedule,
                      pulseCtrl: _pulseCtrl,
                    ),
                  ),
                  const SliverToBoxAdapter(child: SizedBox(height: 18)),
                  SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 18),
                        child: Text('Quick actions', style: _pjs(size: 14, weight: FontWeight.w800, ls: -0.2)),
                      )),
                  const SliverToBoxAdapter(child: SizedBox(height: 6)),
                  const SliverToBoxAdapter(child: _QuickActions()),
                  if (home.activity.isNotEmpty) ...[
                    const SliverToBoxAdapter(child: SizedBox(height: 18)),
                    SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 18),
                          child: Text('Recent activity', style: _pjs(size: 14, weight: FontWeight.w800, ls: -0.2)),
                        )),
                    const SliverToBoxAdapter(child: SizedBox(height: 6)),
                    SliverToBoxAdapter(
                        child: _ActivityList(events: home.activity)),
                  ],
                  const SliverToBoxAdapter(child: SizedBox(height: 18)),
                  SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 18),
                        child: Text('Analytics', style: _pjs(size: 14, weight: FontWeight.w800, ls: -0.2)),
                      )),
                  const SliverToBoxAdapter(child: SizedBox(height: 6)),
                  SliverToBoxAdapter(
                      child: RevenueChartWidget(data: home.charts.revenue)),
                  SliverToBoxAdapter(
                      child: EnrollmentChartWidget(
                          data: home.charts.enrollments)),
                  const SliverToBoxAdapter(child: SizedBox(height: 90)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSkeleton() {
    return AnimatedBuilder(
      animation: _pulseCtrl,
      builder: (context, _) {
        final opacity = 0.4 + _pulseCtrl.value * 0.4;
        return Opacity(
          opacity: opacity,
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 14),
                _SkeletonBox(width: 220, height: 22, radius: 8),
                const SizedBox(height: 18),
                Row(children: [
                  Expanded(child: _SkeletonBox(height: 80, radius: 12)),
                  const SizedBox(width: 8),
                  Expanded(child: _SkeletonBox(height: 80, radius: 12)),
                  const SizedBox(width: 8),
                  Expanded(child: _SkeletonBox(height: 80, radius: 12)),
                ]),
                const SizedBox(height: 20),
                _SkeletonBox(width: 150, height: 16, radius: 6),
                const SizedBox(height: 10),
                _SkeletonBox(height: 120, radius: 14),
                const SizedBox(height: 8),
                _SkeletonBox(height: 60, radius: 12),
                const SizedBox(height: 20),
                _SkeletonBox(width: 100, height: 16, radius: 6),
                const SizedBox(height: 10),
                _SkeletonBox(height: 130, radius: 14),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildError() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.wifi_off_rounded, size: 48, color: _C.faint),
          const SizedBox(height: 12),
          Text('Could not load dashboard',
              style: _pjs(size: 15, weight: FontWeight.w700)),
          const SizedBox(height: 4),
          Text('Pull down to retry',
              style: _pjs(size: 12, color: _C.muted)),
          const SizedBox(height: 16),
          GestureDetector(
            onTap: () => ref.refresh(homeProvider),
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                color: _C.primary,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text('Retry',
                  style: _pjs(
                      size: 13,
                      weight: FontWeight.w700,
                      color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }
}

class _SkeletonBox extends StatelessWidget {
  final double? width;
  final double height;
  final double radius;

  const _SkeletonBox({this.width, required this.height, required this.radius});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: _C.border,
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }
}

// ── Top bar ───────────────────────────────────────────────────────────────────

class _TopBar extends StatelessWidget {
  final String greeting;
  final String initials;
  const _TopBar({required this.greeting, required this.initials});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 14, 18, 0),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: const BoxDecoration(
              color: _C.primary,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(initials,
                  style: _pjs(
                      size: 16,
                      weight: FontWeight.w800,
                      color: Colors.white)),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(greeting,
                    style: _pjs(size: 16, weight: FontWeight.w800, ls: -0.3)),
                Text('Ready for today\'s classes?',
                    style: _pjs(size: 11.5, weight: FontWeight.w500, color: _C.muted)),
              ],
            ),
          ),
          SizedBox(
            width: 40,
            height: 40,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: _C.surf,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: _C.border),
                  ),
                  child: const Icon(Icons.notifications_none_rounded, size: 20, color: _C.text),
                ),
                Positioned(
                  top: -2, right: -2,
                  child: Container(
                    width: 12, height: 12,
                    decoration: BoxDecoration(
                      color: _C.red,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Summary strip ─────────────────────────────────────────────────────────────

class _SummaryStrip extends StatelessWidget {
  final HomeStatsModel stats;
  const _SummaryStrip({required this.stats});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18),
      child: Row(
        children: [
          Expanded(
            child: _MetricCard(
              value: formatCurrency(stats.monthEarningsCents),
              label: 'REVENUE',
              sub: 'This month',
              valueColor: _C.green,
              sparklineColor: _C.green,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _MetricCard(
              value: '${stats.activeStudentsCount}',
              label: 'STUDENTS',
              sub: 'Active',
              sparklineColor: _C.primary,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _MetricCard(
              value: formatCurrency(stats.todayEarningsCents),
              label: 'TODAY',
              sub: 'Earnings',
              valueColor: _C.green,
              sparklineColor: _C.green,
            ),
          ),
        ],
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  final String value;
  final String label;
  final String sub;
  final Color valueColor;
  final Color sparklineColor;

  const _MetricCard({
    required this.value,
    required this.label,
    required this.sub,
    this.valueColor = _C.text,
    required this.sparklineColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: _C.surf,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _C.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(label, style: _pjs(size: 10, weight: FontWeight.w700, ls: 0.6)),
              ),
              CustomPaint(
                size: const Size(36, 14),
                painter: _SparklinePainter(color: sparklineColor),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(value,
              style: _pjs(size: 18, weight: FontWeight.w800, ls: -0.5, color: valueColor)),
          Text(sub, style: _pjs(size: 10.5, weight: FontWeight.w400, color: _C.muted)),
        ],
      ),
    );
  }
}

class _SparklinePainter extends CustomPainter {
  final Color color;
  const _SparklinePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.8
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final path = Path();
    path.moveTo(0, size.height * 0.8);
    path.lineTo(size.width * 0.3, size.height * 0.6);
    path.lineTo(size.width * 0.6, size.height * 0.7);
    path.lineTo(size.width, size.height * 0.2);

    canvas.drawPath(path, paint);

    final dotPaint = Paint()..color = color..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(size.width, size.height * 0.2), 2, dotPaint);
  }

  @override
  bool shouldRepaint(covariant _SparklinePainter old) => old.color != color;
}

// ── Agenda ────────────────────────────────────────────────────────────────────

class _AgendaSection extends StatelessWidget {
  final List<ScheduleSessionModel> sessions;
  final AnimationController pulseCtrl;
  const _AgendaSection({required this.sessions, required this.pulseCtrl});

  @override
  Widget build(BuildContext context) {
    if (sessions.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 24),
          decoration: BoxDecoration(
            color: _C.surf,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: _C.border),
          ),
          child: Column(
            children: [
              const Icon(Icons.event_available_rounded,
                  size: 28, color: _C.faint),
              const SizedBox(height: 8),
              Text('No sessions today',
                  style: _pjs(size: 13, color: _C.muted)),
            ],
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18),
      child: Column(
        children: [
          for (int i = 0; i < sessions.length; i++) ...[
            if (i > 0) const SizedBox(height: 8),
            if (i == 0)
              _NextSessionCard(
                  session: sessions[i], pulseCtrl: pulseCtrl)
            else
              _SessionRow(session: sessions[i]),
          ],
        ],
      ),
    );
  }
}

class _NextSessionCard extends StatelessWidget {
  final ScheduleSessionModel session;
  final AnimationController pulseCtrl;
  const _NextSessionCard(
      {required this.session, required this.pulseCtrl});

  @override
  Widget build(BuildContext context) {
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    final countdown = _countdown(session.startsAt);

    // Static badge widget — extracted so AnimatedBuilder only wraps the
    // opacity layer, not the entire card layout.
    final badge = Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFFEF3C7),
        borderRadius: BorderRadius.circular(99),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6, height: 6,
            decoration: const BoxDecoration(
                color: Color(0xFFD97706), shape: BoxShape.circle),
          ),
          const SizedBox(width: 4),
          Text(countdown,
              style: _pjs(
                  size: 10.5,
                  weight: FontWeight.w800,
                  color: const Color(0xFF92400E))),
        ],
      ),
    );

    return GestureDetector(
      onTap: () => showSessionBottomSheet(context, session),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: _C.surf,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: _C.border),
          boxShadow: const [
            BoxShadow(
                color: Color(0x0D111827),
                blurRadius: 6,
                offset: Offset(0, 2)),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                    width: 6,
                    height: 6,
                    decoration: const BoxDecoration(
                        color: _C.primary, shape: BoxShape.circle)),
                const SizedBox(width: 6),
                Text(
                    'NEXT SESSION · ${_fmtTime(session.startsAt)}'.toUpperCase(),
                    style: _pjs(
                        size: 10.5,
                        weight: FontWeight.w800,
                        ls: 0.6,
                        color: _C.primary)),
                const Spacer(),
                // Opacity animation is GPU-accelerated; no rasterisation cost.
                AnimatedBuilder(
                  animation: pulseCtrl,
                  builder: (_, child) => Opacity(
                    opacity: reduceMotion
                        ? 1.0
                        : (0.65 + pulseCtrl.value * 0.35).clamp(0.0, 1.0),
                    child: child,
                  ),
                  child: badge,
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(session.title,
                style: _pjs(size: 18, weight: FontWeight.w800, ls: -0.3)),
            const SizedBox(height: 4),
            Row(
              children: [
                Text('Batch ${session.batchId}', style: _pjs(size: 12, color: _C.muted)),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  child: Text('·', style: _pjs(color: _C.faint)),
                ),
                Text('${session.durationMinutes} min', style: _pjs(size: 12, color: _C.muted)),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  child: Text('·', style: _pjs(color: _C.faint)),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: _C.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(session.provider,
                      style: _pjs(
                          size: 10.5,
                          weight: FontWeight.w700,
                          color: _C.primary)),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Container(
              width: double.infinity,
              height: 46,
              decoration: BoxDecoration(
                color: _C.primary,
                borderRadius: BorderRadius.circular(12),
                boxShadow: const [
                  BoxShadow(
                      color: Color(0x331D4ED8),
                      blurRadius: 14,
                      offset: Offset(0, 6)),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('View Details',
                      style: _pjs(
                          size: 14,
                          weight: FontWeight.w700,
                          color: Colors.white)),
                  const SizedBox(width: 6),
                  const Icon(Icons.arrow_forward_rounded,
                      size: 16, color: Colors.white),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SessionRow extends StatelessWidget {
  final ScheduleSessionModel session;
  const _SessionRow({required this.session});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => showSessionBottomSheet(context, session),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
        decoration: BoxDecoration(
          color: _C.surf,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: _C.border),
        ),
        child: Row(
          children: [
            SizedBox(
              width: 44,
              child: Center(
                child: Text(_fmtTime(session.startsAt),
                    style: _fm(size: 11, weight: FontWeight.w700, ls: -0.2)),
              ),
            ),
            Container(
              width: 1,
              height: 28,
              color: _C.borderS,
              margin: const EdgeInsets.symmetric(horizontal: 10),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(session.title,
                      style: _pjs(
                          size: 13,
                          weight: FontWeight.w700,
                          ls: -0.1)),
                  Text('Batch ${session.batchId}',
                      style: _pjs(size: 11.5, weight: FontWeight.w500, color: _C.muted)),
                ],
              ),
            ),
            Container(
              height: 28,
              padding:
                  const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                border: Border.all(color: _C.border),
                borderRadius: BorderRadius.circular(8),
              ),
              alignment: Alignment.center,
              child: Text('Start',
                  style: _pjs(size: 11.5, weight: FontWeight.w700)),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Quick actions ─────────────────────────────────────────────────────────────

class _QuickActions extends StatelessWidget {
  const _QuickActions();

  @override
  Widget build(BuildContext context) {
    const actions = [
      ('New Class',    Icons.video_call_rounded,  Color(0xFFDBEAFE), Color(0xFF1D4ED8)),
      ('Add Student',  Icons.person_add_rounded,  Color(0xFFD1FAE5), Color(0xFF059669)),
      ('Create Quiz',  Icons.quiz_rounded,        Color(0xFFEDE9FE), Color(0xFF7C3AED)),
      ('Collect Fee',  Icons.payments_rounded,    Color(0xFFFEF3C7), Color(0xFFD97706)),
      ('View Reports', Icons.bar_chart_rounded,   Color(0xFFCFFAFE), Color(0xFF0891B2)),
    ];

    return SizedBox(
      height: 80,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 18),
        itemCount: actions.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, i) {
          final (label, icon, bgC, fgC) = actions[i];
          return _QuickChip(label: label, icon: icon, bgC: bgC, fgC: fgC);
        },
      ),
    );
  }
}

class _QuickChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color bgC;
  final Color fgC;

  const _QuickChip(
      {required this.label, required this.icon, required this.bgC, required this.fgC});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 76,
      height: 80,
      decoration: BoxDecoration(
        color: _C.surf,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _C.border),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: bgC,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 18, color: fgC),
          ),
          const SizedBox(height: 4),
          Text(label,
              style: _pjs(size: 10.5, weight: FontWeight.w700, height: 1.15),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis),
        ],
      ),
    );
  }
}

// ── Activity list ─────────────────────────────────────────────────────────────

class _ActivityList extends StatelessWidget {
  final List<ActivityEventModel> events;
  const _ActivityList({required this.events});

  static const _avatarColors = [
    Colors.purple,
    Colors.teal,
    Color(0xFF059669),
    Colors.indigo,
    Colors.deepOrange,
  ];

  (String verb, String target) _describe(ActivityEventModel e) {
    return switch (e.type) {
      ActivityEventType.courseEnrolled =>
        ('enrolled in', e.courseName ?? 'a course'),
      ActivityEventType.paymentReceived =>
        ('paid', formatCurrency(e.amountCents ?? 0)),
      ActivityEventType.newStudentRegistered => ('joined', 'as a student'),
    };
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 18),
      decoration: BoxDecoration(
        color: _C.surf,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _C.border),
      ),
      // ListView.builder renders only visible rows — better for long lists.
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 14),
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: events.length,
        separatorBuilder: (_, __) => const Divider(
            height: 1,
            color: _C.borderS,
            indent: 40,
            endIndent: 0),
        itemBuilder: (_, i) {
          final e = events[i];
          final (verb, target) = _describe(e);
          final avatarColor = _avatarColors[i % _avatarColors.length];
          final initials = e.studentName
              .split(' ')
              .map((w) => w.isEmpty ? '' : w[0])
              .take(2)
              .join();
          final isPayment = e.type == ActivityEventType.paymentReceived;

          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Row(
              children: [
                Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    color: avatarColor.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(isPayment ? '₹' : initials,
                        style: isPayment
                            ? _fm(size: 11, weight: FontWeight.w700, color: avatarColor)
                            : _fm(size: 10, weight: FontWeight.w700, color: avatarColor)),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: RichText(
                    text: TextSpan(
                      style: _pjs(size: 12.5, height: 1.35),
                      children: [
                        TextSpan(
                            text: e.studentName,
                            style: const TextStyle(
                                fontWeight: FontWeight.w700)),
                        TextSpan(text: ' $verb '),
                        TextSpan(
                          text: target,
                          style: isPayment
                              ? TextStyle(
                                  fontWeight: FontWeight.w700,
                                  color: _C.green,
                                  fontFamily: _monoFamily,
                                )
                              : const TextStyle(
                                  fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(_relativeTime(e.occurredAt),
                    style: _pjs(
                        size: 10.5,
                        weight: FontWeight.w600,
                        color: _C.faint)),
              ],
            ),
          );
        },
      ),
    );
  }
}

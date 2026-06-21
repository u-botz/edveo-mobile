import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:edveo/features/live/data/models/live_session_model.dart';
import 'live_session_provider.dart';

// ── Tokens ────────────────────────────────────────────────────────────────────
class _C {
  static const primary       = Color(0xFF1D4ED8);
  static const primary2      = Color(0xFF2563EB);
  static const primaryShadow = Color(0x401D4ED8);
  static const heroFillGlass = Color(0x1EFFFFFF);
  static const heroOrbitStr  = Color(0x1EFFFFFF);
  static const heroOrbitSoft = Color(0x11FFFFFF);
  static const startingDot   = Color(0xFFFBBF24);
  static const liveNowDot    = Color(0xFF22C55E);
  static const checkGreen    = Color(0xFF059669);
  static const surface       = Color(0xFFFFFFFF);
  static const bg            = Color(0xFFF9FAFB);
  static const border        = Color(0xFFE5E7EB);
  static const borderSubtle  = Color(0xFFF3F4F6);
  static const textPrimary   = Color(0xFF111827);
  static const textSecondary = Color(0xFF6B7280);
  static const textFaint     = Color(0xFF9CA3AF);

  static const tints = [
    Color(0xFF1D4ED8), Color(0xFF7C3AED),
    Color(0xFF059669), Color(0xFFF97316),
  ];
  static Color tintFor(int index) => tints[index % tints.length];
}

TextStyle _pjs({
  double size = 14,
  FontWeight weight = FontWeight.w400,
  Color color = _C.textPrimary,
  double ls = 0,
  double? lh,
  TextDecoration? dec,
}) => GoogleFonts.plusJakartaSans(
      fontSize: size,
      fontWeight: weight,
      color: color,
      letterSpacing: ls,
      height: lh,
      decoration: dec,
    );

// ── Provider view helpers ─────────────────────────────────────────────────────
extension LiveSessionProviderView on LiveSessionProvider {
  String get abbreviation => switch (this) {
        LiveSessionProvider.zoom          => 'ZM',
        LiveSessionProvider.agora         => 'AG',
        LiveSessionProvider.jitsi         => 'JT',
        LiveSessionProvider.googleMeet    => 'GM',
        LiveSessionProvider.bigBlueButton => 'BB',
        LiveSessionProvider.youtube       => 'YT',
        LiveSessionProvider.local         => 'LC',
        LiveSessionProvider.unknown       => 'LS',
      };

  Color get badgeColor => switch (this) {
        LiveSessionProvider.zoom          => const Color(0xFF2D8CFF),
        LiveSessionProvider.agora         => const Color(0xFFF97316),
        LiveSessionProvider.jitsi         => const Color(0xFF4A90E2),
        LiveSessionProvider.googleMeet    => const Color(0xFF00897B),
        LiveSessionProvider.bigBlueButton => const Color(0xFF1B72BE),
        LiveSessionProvider.youtube       => const Color(0xFFFF0000),
        LiveSessionProvider.local         => _C.textPrimary,
        LiveSessionProvider.unknown       => _C.textSecondary,
      };
}

// ── Time helpers ──────────────────────────────────────────────────────────────
String _formatTimeRange(DateTime utcStart, int durationMinutes) {
  final start = utcStart.toLocal();
  final end   = start.add(Duration(minutes: durationMinutes));

  String fmt(DateTime dt) {
    final h  = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
    final m  = dt.minute.toString().padLeft(2, '0');
    final ap = dt.hour >= 12 ? 'PM' : 'AM';
    return dt.minute == 0 ? '$h $ap' : '$h:$m $ap';
  }

  return 'TODAY · ${fmt(start)} – ${fmt(end)}';
}

String _formatCountdown(int minutes) {
  if (minutes <= 0) return 'Starting now';
  if (minutes < 60) return 'Starting in $minutes min';
  final h = minutes ~/ 60;
  final m = minutes % 60;
  return m == 0 ? 'Starting in ${h}h' : 'Starting in ${h}h ${m}m';
}

String _formatSessionDate(DateTime utc) {
  final dt = utc.toLocal();
  const days   = ['MON','TUE','WED','THU','FRI','SAT','SUN'];
  const months = ['JAN','FEB','MAR','APR','MAY','JUN',
                  'JUL','AUG','SEP','OCT','NOV','DEC'];
  return '${days[dt.weekday - 1]}, ${dt.day} ${months[dt.month - 1]}';
}

Future<void> _launch(String url) async {
  final uri = Uri.parse(url);
  if (await canLaunchUrl(uri)) {
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }
}

// ── Screen ────────────────────────────────────────────────────────────────────
class StandaloneLiveSessionScreen extends ConsumerStatefulWidget {
  const StandaloneLiveSessionScreen({super.key});

  @override
  ConsumerState<StandaloneLiveSessionScreen> createState() =>
      _StandaloneLiveSessionScreenState();
}

class _StandaloneLiveSessionScreenState
    extends ConsumerState<StandaloneLiveSessionScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulseCtrl;

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat();
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    super.dispose();
  }

  Future<void> _onRefresh() =>
      ref.read(liveSessionNotifierProvider.notifier).refresh();

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(liveSessionNotifierProvider);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: _C.bg,
        body: SafeArea(
          bottom: false,
          child: RefreshIndicator(
            onRefresh: _onRefresh,
            color: _C.primary,
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(
                parent: AlwaysScrollableScrollPhysics(),
              ),
              slivers: [
                const SliverToBoxAdapter(child: _TopBar()),

                // ── Loading ───────────────────────────────────────────────
                if (state.isLoading) ...[
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(18, 8, 18, 14),
                      child: _SkeletonHero(),
                    ),
                  ),
                  SliverToBoxAdapter(child: _SkeletonSection()),
                ]

                // ── Error ─────────────────────────────────────────────────
                else if (state.hasError)
                  SliverFillRemaining(
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.wifi_off_rounded,
                              size: 40, color: _C.textFaint),
                          const SizedBox(height: 12),
                          Text('Could not load session',
                              style: _pjs(
                                  size: 14,
                                  weight: FontWeight.w600,
                                  color: _C.textSecondary)),
                          const SizedBox(height: 8),
                          GestureDetector(
                            onTap: () => ref
                                .read(liveSessionNotifierProvider.notifier)
                                .refresh(),
                            child: Text('Try again',
                                style: _pjs(
                                    size: 13,
                                    weight: FontWeight.w700,
                                    color: _C.primary)),
                          ),
                        ],
                      ),
                    ),
                  )

                // ── Loaded ────────────────────────────────────────────────
                else ...[
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(18, 8, 18, 14),
                      child: state.hasSession
                          ? _HeroCard(
                              session: state.nextSession!,
                              pulseAnim: _pulseCtrl,
                            )
                          : const _EmptyHero(),
                    ),
                  ),

                  if (state.hasSession) ...[
                    SliverToBoxAdapter(
                      child: _TopicSection(
                          description: state.nextSession!.description),
                    ),
                    const SliverToBoxAdapter(child: SizedBox(height: 12)),
                    SliverToBoxAdapter(
                      child: _StudentsPreview(
                        count: state.nextSession!.enrolledStudentsCount,
                        courseTitle: state.nextSession!.courseTitle,
                      ),
                    ),
                    const SliverToBoxAdapter(child: SizedBox(height: 12)),
                    const SliverToBoxAdapter(child: _ChecklistSection()),
                    const SliverToBoxAdapter(child: SizedBox(height: 12)),
                  ],

                  if (state.hasRecentSessions) ...[
                    SliverToBoxAdapter(
                      child: _PreviousSessions(
                          sessions: state.recentSessions),
                    ),
                    const SliverToBoxAdapter(child: SizedBox(height: 100)),
                  ],
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── Top Bar ───────────────────────────────────────────────────────────────────
class _TopBar extends StatelessWidget {
  const _TopBar();

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.fromLTRB(14, 12, 18, 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            GestureDetector(
              onTap: () => Navigator.of(context).maybePop(),
              child: Container(
                width: 38, height: 38,
                decoration: BoxDecoration(
                  color: _C.surface,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: _C.border),
                ),
                child: const Icon(Icons.chevron_left_rounded,
                    size: 20, color: _C.textPrimary),
              ),
            ),
            Text('Live Session',
                style: _pjs(size: 14, weight: FontWeight.w700, ls: -0.2)),
            // Share — Phase 2
            Container(
              width: 38, height: 38,
              decoration: BoxDecoration(
                color: _C.surface,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: _C.border),
              ),
              child: const Icon(Icons.ios_share_rounded,
                  size: 20, color: _C.textPrimary),
            ),
          ],
        ),
      );
}

// ── Hero Card — real data ─────────────────────────────────────────────────────
class _HeroCard extends StatelessWidget {
  final NextLiveSession session;
  final Animation<double> pulseAnim;

  const _HeroCard({required this.session, required this.pulseAnim});

  @override
  Widget build(BuildContext context) {
    final isLive = session.operationalStatus ==
        LiveSessionOperationalStatus.liveNow;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [_C.primary, _C.primary2],
        ),
        boxShadow: const [
          BoxShadow(
              color: _C.primaryShadow,
              blurRadius: 28,
              offset: Offset(0, 12)),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          // Orbit rings
          Positioned(
            top: -60, right: -40,
            child: Container(
              width: 220, height: 220,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border:
                    Border.all(color: _C.heroOrbitSoft, width: 1.5),
              ),
            ),
          ),
          Positioned(
            top: -40, right: -20,
            child: Container(
              width: 180, height: 180,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border:
                    Border.all(color: _C.heroOrbitStr, width: 1.5),
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Provider badge
                Row(children: [
                  Container(
                    width: 24, height: 24,
                    decoration: BoxDecoration(
                      color: session.provider.badgeColor,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Center(
                      child: Text(session.provider.abbreviation,
                          style: _pjs(
                              size: 9,
                              weight: FontWeight.w800,
                              color: Colors.white)),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(session.provider.displayLabel,
                      style: _pjs(
                          size: 10.5,
                          weight: FontWeight.w700,
                          ls: 0.8,
                          color: Colors.white
                              .withValues(alpha: 0.9))),
                ]),

                const SizedBox(height: 10),
                Text(session.title,
                    style: _pjs(
                        size: 22,
                        weight: FontWeight.w800,
                        ls: -0.5,
                        color: Colors.white)),
                const SizedBox(height: 2),
                Text(
                  session.courseTitle ?? 'Live Session',
                  style: _pjs(
                      size: 12.5,
                      color: Colors.white.withValues(alpha: 0.85)),
                ),
                const SizedBox(height: 12),

                // Time strip
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    color: _C.heroFillGlass,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _formatTimeRange(
                                session.date, session.durationMinutes),
                            style: _pjs(
                                size: 11,
                                weight: FontWeight.w600,
                                ls: 0.3,
                                color: Colors.white
                                    .withValues(alpha: 0.8)),
                          ),
                          const SizedBox(height: 2),
                          Row(children: [
                            _PulseDot(
                              animation: pulseAnim,
                              color: isLive
                                  ? _C.liveNowDot
                                  : _C.startingDot,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              isLive
                                  ? 'Live Now'
                                  : _formatCountdown(
                                      session.minutesUntilStart),
                              style: _pjs(
                                  size: 13,
                                  weight: FontWeight.w700,
                                  color: Colors.white),
                            ),
                          ]),
                        ],
                      ),
                    ),
                  ]),
                ),

                const SizedBox(height: 14),

                // CTA
                GestureDetector(
                  onTap: session.canStart && session.startLink != null
                      ? () => _launch(session.startLink!)
                      : null,
                  child: Container(
                    height: 48,
                    decoration: BoxDecoration(
                      color: session.canStart
                          ? Colors.white
                          : Colors.white
                              .withValues(alpha: 0.4),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            isLive ? 'Join Now' : 'Start Class',
                            style: _pjs(
                                size: 15,
                                weight: FontWeight.w800,
                                color: _C.primary),
                          ),
                          const SizedBox(width: 6),
                          const Icon(Icons.arrow_forward_rounded,
                              size: 18, color: _C.primary),
                        ],
                      ),
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

// ── Hero — no session today ───────────────────────────────────────────────────
class _EmptyHero extends StatelessWidget {
  const _EmptyHero();

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 28),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF374151), Color(0xFF1F2937)],
          ),
        ),
        child: Column(children: [
          Icon(Icons.videocam_off_rounded,
              size: 36, color: Colors.white.withValues(alpha: 0.5)),
          const SizedBox(height: 12),
          Text('No session today',
              style: _pjs(
                  size: 18,
                  weight: FontWeight.w800,
                  ls: -0.3,
                  color: Colors.white)),
          const SizedBox(height: 4),
          Text('Pull down to refresh',
              style: _pjs(
                  size: 12,
                  color: Colors.white.withValues(alpha: 0.6))),
        ]),
      );
}

// ── Pulse Dot ─────────────────────────────────────────────────────────────────
class _PulseDot extends StatelessWidget {
  final Animation<double> animation;
  final Color color;

  const _PulseDot({required this.animation, required this.color});

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
        animation: animation,
        builder: (_, __) {
          final spread = animation.value * 6.0;
          final alpha  = (1.0 - animation.value).clamp(0.0, 1.0);
          return Container(
            width: 8, height: 8,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: color.withValues(alpha: alpha),
                  blurRadius: 2,
                  spreadRadius: spread,
                ),
              ],
            ),
          );
        },
      );
}

// ── Topic Section ─────────────────────────────────────────────────────────────
class _TopicSection extends StatelessWidget {
  final String? description;
  const _TopicSection({this.description});

  @override
  Widget build(BuildContext context) {
    if (description == null || description!.trim().isEmpty) {
      return const SizedBox.shrink();
    }
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text("TODAY'S TOPIC",
            style: _pjs(
                size: 10.5,
                weight: FontWeight.w700,
                ls: 0.5,
                color: _C.textSecondary)),
        const SizedBox(height: 4),
        Text(description!,
            style: _pjs(size: 13.5, weight: FontWeight.w600, ls: -0.1),
            maxLines: 1,
            overflow: TextOverflow.ellipsis),
      ]),
    );
  }
}

// ── Students Preview ──────────────────────────────────────────────────────────
class _StudentsPreview extends StatelessWidget {
  final int count;
  final String? courseTitle;

  const _StudentsPreview({required this.count, this.courseTitle});

  @override
  Widget build(BuildContext context) {
    final avatarCount = count.clamp(0, 4);
    final overflow    = count > 4 ? count - 4 : 0;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: _C.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: _C.border),
        ),
        child: Row(children: [
          // Avatar stack
          SizedBox(
            width: 28.0 +
                (avatarCount + (overflow > 0 ? 1 : 0) - 1) * 18.0,
            height: 28,
            child: Stack(
              children: [
                for (int i = 0; i < avatarCount; i++)
                  Positioned(
                    left: i * 18.0,
                    child: Container(
                      width: 28, height: 28,
                      decoration: BoxDecoration(
                        color: _C.tintFor(i),
                        shape: BoxShape.circle,
                        border:
                            Border.all(color: Colors.white, width: 2),
                      ),
                    ),
                  ),
                if (overflow > 0)
                  Positioned(
                    left: avatarCount * 18.0,
                    child: Container(
                      width: 28, height: 28,
                      decoration: BoxDecoration(
                        color: _C.borderSubtle,
                        shape: BoxShape.circle,
                        border:
                            Border.all(color: Colors.white, width: 2),
                      ),
                      child: Center(
                        child: Text('+$overflow',
                            style: _pjs(
                                size: 10,
                                weight: FontWeight.w800,
                                color: _C.textPrimary)),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  count == 0
                      ? 'No students enrolled'
                      : '$count student${count == 1 ? '' : 's'} enrolled',
                  style: _pjs(size: 12.5, weight: FontWeight.w700),
                ),
                if (courseTitle != null)
                  Text(courseTitle!,
                      style: _pjs(size: 11, color: _C.textSecondary),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
          // Phase 2: "View all →" navigates to student list filtered by session
          Text('View all →',
              style: _pjs(
                  size: 11.5,
                  weight: FontWeight.w700,
                  color: _C.primary)),
        ]),
      ),
    );
  }
}

// ── Checklist — UI only, local state ──────────────────────────────────────────
class _ChecklistSection extends StatefulWidget {
  const _ChecklistSection();
  @override State<_ChecklistSection> createState() => _ChecklistSectionState();
}

class _ChecklistSectionState extends State<_ChecklistSection> {
  bool _quizChecked = false;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('PRE-SESSION CHECKLIST',
                style: _pjs(
                    size: 11,
                    weight: FontWeight.w700,
                    ls: 0.4,
                    color: _C.textSecondary)),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.fromLTRB(12, 4, 12, 4),
              decoration: BoxDecoration(
                color: _C.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: _C.border),
              ),
              child: Column(children: [
                const _CheckRow(
                    label: 'Upload topic notes', isDone: true),
                const Divider(
                    height: 1, thickness: 1, color: _C.borderSubtle),
                _CheckRow(
                  label: 'Attach quiz for after class',
                  isDone: _quizChecked,
                  trailingAffordance: _quizChecked ? null : 'Add',
                  trailingIcon:
                      _quizChecked ? null : Icons.upload_rounded,
                  onTap: () =>
                      setState(() => _quizChecked = !_quizChecked),
                ),
              ]),
            ),
          ],
        ),
      );
}

class _CheckRow extends StatelessWidget {
  final String label;
  final bool isDone;
  final String? trailingAffordance;
  final IconData? trailingIcon;
  final VoidCallback? onTap;

  const _CheckRow({
    required this.label,
    required this.isDone,
    this.trailingAffordance,
    this.trailingIcon,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: SizedBox(
          height: 36,
          child: Row(children: [
            Container(
              width: 20, height: 20,
              decoration: BoxDecoration(
                color:
                    isDone ? _C.checkGreen : Colors.transparent,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: isDone ? _C.checkGreen : _C.border,
                  width: 1.5,
                ),
              ),
              child: isDone
                  ? const Center(
                      child: Icon(Icons.check_rounded,
                          size: 14, color: Colors.white))
                  : null,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(label,
                  style: _pjs(
                    size: 12.5,
                    weight: isDone
                        ? FontWeight.w500
                        : FontWeight.w600,
                    color: isDone
                        ? _C.textSecondary
                        : _C.textPrimary,
                    dec: isDone
                        ? TextDecoration.lineThrough
                        : null,
                  )),
            ),
            if (trailingAffordance != null) ...[
              const SizedBox(width: 8),
              Row(mainAxisSize: MainAxisSize.min, children: [
                if (trailingIcon != null) ...[
                  Icon(trailingIcon, size: 14, color: _C.primary),
                  const SizedBox(width: 4),
                ],
                Text(trailingAffordance!,
                    style: _pjs(
                        size: 11.5,
                        weight: FontWeight.w700,
                        color: _C.primary)),
              ]),
            ],
          ]),
        ),
      );
}

// ── Previous Sessions ─────────────────────────────────────────────────────────
class _PreviousSessions extends StatelessWidget {
  final List<RecentLiveSession> sessions;
  const _PreviousSessions({required this.sessions});

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('PREVIOUS SESSIONS',
                    style: _pjs(
                        size: 11,
                        weight: FontWeight.w700,
                        ls: 0.4,
                        color: _C.textSecondary)),
                // Phase 2: "See all" navigates to full history
                Text('See all',
                    style: _pjs(
                        size: 11.5,
                        weight: FontWeight.w600,
                        color: _C.primary)),
              ],
            ),
            const SizedBox(height: 4),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
              decoration: BoxDecoration(
                color: _C.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: _C.border),
              ),
              child: Column(
                children: sessions
                    .take(5)
                    .toList()
                    .asMap()
                    .entries
                    .map((entry) {
                  final i = entry.key;
                  final s = entry.value;
                  return Column(children: [
                    if (i > 0)
                      const Divider(
                          height: 1,
                          thickness: 1,
                          color: _C.borderSubtle),
                    _SessionRow(session: s),
                  ]);
                }).toList(),
              ),
            ),
          ],
        ),
      );
}

class _SessionRow extends StatelessWidget {
  final RecentLiveSession session;
  const _SessionRow({required this.session});

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(_formatSessionDate(session.date),
                      style: _pjs(
                          size: 10.5,
                          weight: FontWeight.w700,
                          ls: 0.3,
                          color: _C.textSecondary)),
                  const SizedBox(height: 2),
                  Text(session.title,
                      style: _pjs(
                          size: 13,
                          weight: FontWeight.w700,
                          ls: -0.1),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
            // Phase 2: attendance chip (attended/total)
            // Attendance is unlinked from live_sessions — deferred
            Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: _C.borderSubtle,
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                session.provider.abbreviation,
                style: _pjs(
                    size: 10.5,
                    weight: FontWeight.w700,
                    ls: 0.2,
                    color: _C.textSecondary),
              ),
            ),
          ],
        ),
      );
}

// ── Skeletons ─────────────────────────────────────────────────────────────────
class _SkeletonHero extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Container(
        height: 220,
        decoration: BoxDecoration(
          color: _C.borderSubtle,
          borderRadius: BorderRadius.circular(18),
        ),
      );
}

class _SkeletonSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.fromLTRB(18, 0, 18, 0),
        child: Column(children: [
          const SizedBox(height: 12),
          Container(
              height: 12, width: 120,
              decoration: BoxDecoration(
                  color: _C.borderSubtle,
                  borderRadius: BorderRadius.circular(6))),
          const SizedBox(height: 8),
          Container(
              height: 60,
              decoration: BoxDecoration(
                  color: _C.borderSubtle,
                  borderRadius: BorderRadius.circular(12))),
        ]),
      );
}
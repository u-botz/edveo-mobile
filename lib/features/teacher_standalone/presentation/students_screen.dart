import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:edveo/features/students/data/models/student_model.dart';
import 'create_student_bottom_sheet.dart';
import 'students_provider.dart';

// ── Tokens ────────────────────────────────────────────────────────────────────
class _C {
  static const primary      = Color(0xFF1D4ED8);
  static const primarySoft  = Color(0x141D4ED8);
  static const green        = Color(0xFF059669);
  static const greenSoft    = Color(0xFFD1FAE5);
  static const amber        = Color(0xFFD97706);
  static const amberSoft    = Color(0xFFFEF3C7);
  static const surface      = Color(0xFFFFFFFF);
  static const bg           = Color(0xFFF9FAFB);
  static const border       = Color(0xFFE5E7EB);
  static const borderSubtle = Color(0xFFF3F4F6);
  static const textPrimary  = Color(0xFF111827);
  static const textSecondary= Color(0xFF6B7280);
  static const textFaint    = Color(0xFF9CA3AF);

  static const tints = [
    Color(0xFF1D4ED8), Color(0xFF7C3AED),
    Color(0xFF059669), Color(0xFFF97316), Color(0xFFD97706),
  ];

  static Color tintFor(int id) => tints[id.abs() % tints.length];

  static Color ringColor(int pct) {
    if (pct >= 70) return green;
    if (pct >= 50) return primary;
    return amber;
  }
}

// Cached base styles — avoids GoogleFonts() construction per build call.
final _pjsBase = GoogleFonts.plusJakartaSans();

TextStyle _pjs({double size=13, FontWeight weight=FontWeight.w400,
  Color color=_C.textPrimary, double ls=0, double? lh}) =>
  _pjsBase.copyWith(fontSize: size, fontWeight: weight,
    color: color, letterSpacing: ls, height: lh);

// ── Helpers ───────────────────────────────────────────────────────────────────

String _formatDate(DateTime? dt) {
  if (dt == null) return '—';
  final now = DateTime.now();
  final diff = now.difference(dt);
  if (diff.inDays < 1) return 'Today';
  if (diff.inDays < 2) return 'Yesterday';
  if (diff.inDays < 7) return '${diff.inDays}d ago';
  const months = ['Jan','Feb','Mar','Apr','May','Jun',
                  'Jul','Aug','Sep','Oct','Nov','Dec'];
  return '${dt.day} ${months[dt.month - 1]}';
}

String _courseLine(List<StudentCourse> courses) {
  if (courses.isEmpty) return '—';
  if (courses.length == 1) return courses[0].title;
  final names = courses
      .take(2)
      .map((c) => c.title.contains('—')
          ? c.title.split('—').last.trim()
          : c.title)
      .join(', ');
  final overflow = courses.length > 2 ? ' +${courses.length - 2}' : '';
  return '${courses.length} courses · $names$overflow';
}

// ── Screen ────────────────────────────────────────────────────────────────────
class StandaloneStudentsScreen extends ConsumerStatefulWidget {
  const StandaloneStudentsScreen({super.key});
  @override ConsumerState<StandaloneStudentsScreen> createState() =>
      _StandaloneStudentsScreenState();
}

class _StandaloneStudentsScreenState
    extends ConsumerState<StandaloneStudentsScreen> {
  int _filter = 0;
  final _scrollController = ScrollController();

  // Cached subtitle — recomputed only when the students list changes.
  List<Student>? _lastStudents;
  String _cachedSubtitle = '';
  int _cachedNewCount = 0;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final pos = _scrollController.position;
    if (pos.pixels >= pos.maxScrollExtent - 300) {
      // canLoadMore guard prevents redundant calls while a page is in-flight.
      final state = ref.read(studentsNotifierProvider);
      if (state.canLoadMore) {
        ref.read(studentsNotifierProvider.notifier).loadMore();
      }
    }
  }

  Future<void> _onRefresh() =>
      ref.read(studentsNotifierProvider.notifier).refresh();

  List<Student> _filtered(List<Student> all) {
    return switch (_filter) {
      1 => all,
      2 => [],
      3 => [],
      _ => all,
    };
  }

  // Single-pass computation over students — only runs when the list reference
  // changes (i.e. after load/refresh/loadMore), not on every build.
  void _updateCachedStats(List<Student> students, int? total) {
    if (identical(_lastStudents, students)) return;
    _lastStudents = students;

    // Build unique course-id set in one traversal.
    final ids = <int>{};
    int newCount = 0;
    final cutoff = DateTime.now().subtract(const Duration(days: 7));
    for (final s in students) {
      for (final c in s.enrolledCourses) {
        ids.add(c.id);
      }
      if (s.earliestEnrolledAt != null &&
          s.earliestEnrolledAt!.isAfter(cutoff)) {
        newCount++;
      }
    }

    _cachedNewCount = newCount;
    if (ids.isEmpty) {
      _cachedSubtitle = total != null && total > 0
          ? '$total enrolled students'
          : 'No students yet';
    } else {
      _cachedSubtitle =
          'Across ${ids.length} active course${ids.length == 1 ? '' : 's'}';
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(studentsNotifierProvider);
    final filtered = _filtered(state.students);

    _updateCachedStats(state.students, state.meta?.total);

    const attentionCount = 0;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: _C.bg,
        floatingActionButton: FloatingActionButton(
          backgroundColor: _C.primary,
          foregroundColor: Colors.white,
          onPressed: () {
            showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
              ),
              builder: (_) => const CreateStudentBottomSheet(),
            );
          },
          child: const Icon(Icons.person_add_rounded),
        ),
        body: SafeArea(
          bottom: false,
          child: RefreshIndicator(
            onRefresh: _onRefresh,
            color: _C.primary,
            child: CustomScrollView(
              controller: _scrollController,
              physics: const BouncingScrollPhysics(
                parent: AlwaysScrollableScrollPhysics(),
              ),
              slivers: [
                SliverToBoxAdapter(
                  child: _TopBar(
                    total: state.meta?.total ?? state.students.length,
                    subtitle: _cachedSubtitle,
                  ),
                ),
                SliverToBoxAdapter(child: const SizedBox(height: 2)),
                SliverToBoxAdapter(
                  child: _FilterRow(
                    selected: _filter,
                    onChanged: (i) => setState(() => _filter = i),
                  ),
                ),
                SliverToBoxAdapter(child: const SizedBox(height: 4)),

                if (!state.isLoading && !state.hasError)
                  SliverToBoxAdapter(
                    child: _SummaryStrip(
                      newCount: _cachedNewCount,
                      attentionCount: attentionCount,
                    ),
                  ),

                SliverToBoxAdapter(child: const SizedBox(height: 4)),

                if (state.isLoading)
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(18, 0, 18, 220),
                    sliver: SliverList.separated(
                      itemCount: 6,
                      separatorBuilder: (_, __) => const SizedBox(height: 8),
                      itemBuilder: (_, __) => const _SkeletonCard(),
                    ),
                  )

                else if (state.hasError)
                  SliverFillRemaining(
                    child: Center(
                      child: Column(mainAxisSize: MainAxisSize.min, children: [
                        Icon(Icons.wifi_off_rounded,
                            size: 40, color: _C.textFaint),
                        const SizedBox(height: 12),
                        Text('Could not load students',
                            style: _pjs(
                                size: 14,
                                weight: FontWeight.w600,
                                color: _C.textSecondary)),
                        const SizedBox(height: 8),
                        GestureDetector(
                          onTap: () => ref
                              .read(studentsNotifierProvider.notifier)
                              .refresh(),
                          child: Text('Try again',
                              style: _pjs(
                                  size: 13,
                                  weight: FontWeight.w700,
                                  color: _C.primary)),
                        ),
                      ]),
                    ),
                  )

                else if (state.isEmpty)
                  SliverFillRemaining(
                    child: Center(
                      child: Column(mainAxisSize: MainAxisSize.min, children: [
                        Icon(Icons.people_outline,
                            size: 40, color: _C.textFaint),
                        const SizedBox(height: 12),
                        Text('No students yet',
                            style: _pjs(
                                size: 14,
                                weight: FontWeight.w600,
                                color: _C.textSecondary)),
                        const SizedBox(height: 4),
                        Text('Share your course link to get started',
                            style: _pjs(size: 12, color: _C.textFaint)),
                      ]),
                    ),
                  )

                else
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(18, 0, 18, 220),
                    sliver: SliverList.separated(
                      itemCount:
                          filtered.length + (state.isLoadingMore ? 1 : 0),
                      separatorBuilder: (_, __) =>
                          const SizedBox(height: 8),
                      itemBuilder: (context, i) {
                        if (i == filtered.length) {
                          return const Padding(
                            padding: EdgeInsets.symmetric(vertical: 16),
                            child: Center(
                              child: CircularProgressIndicator(
                                  color: _C.primary, strokeWidth: 2),
                            ),
                          );
                        }
                        final student = filtered[i];
                        return _StudentCard(
                          student: student,
                          highlighted: false,
                          onTap: () {},
                          // Cap delay at 10 cards to avoid burst of 50+ timers
                          // when a full page loads at once.
                          delay: Duration(
                              milliseconds: i.clamp(0, 9) * 30),
                        );
                      },
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── Top bar ───────────────────────────────────────────────────────────────────
class _TopBar extends StatelessWidget {
  final int total;
  final String subtitle;
  const _TopBar({required this.total, required this.subtitle});

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(18, 14, 18, 12),
    child: Row(children: [
      Expanded(child: Column(
        crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Text('Students',
              style: _pjs(size:20, weight:FontWeight.w800, ls:-0.4)),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal:8, vertical:3),
            decoration: BoxDecoration(color:_C.primarySoft,
              borderRadius: BorderRadius.circular(999)),
            child: Text('$total',
              style: _pjs(size:11, weight:FontWeight.w700, color:_C.primary)),
          ),
        ]),
        Text(subtitle, style: _pjs(size:11.5, color:_C.textSecondary)),
      ])),
      _IconBtn(icon: Icons.search_rounded),
      const SizedBox(width: 8),
      _IconBtn(icon: Icons.tune_rounded),
    ]),
  );
}

class _IconBtn extends StatelessWidget {
  final IconData icon;
  const _IconBtn({required this.icon});
  @override
  Widget build(BuildContext context) => Container(
    width:38, height:38,
    decoration: BoxDecoration(color:_C.surface,
      borderRadius: BorderRadius.circular(10),
      border: Border.all(color:_C.border)),
    child: Icon(icon, size:18, color:_C.textSecondary),
  );
}

// ── Filter row ────────────────────────────────────────────────────────────────
class _FilterRow extends StatelessWidget {
  final int selected;
  final ValueChanged<int> onChanged;
  const _FilterRow({required this.selected, required this.onChanged});

  static const _labels = ['All', 'Active', 'Inactive', 'Needs Attention'];

  @override
  Widget build(BuildContext context) => SizedBox(
    height: 42,
    child: ListView.separated(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal:18),
      itemCount: _labels.length,
      separatorBuilder: (_, __) => const SizedBox(width:6),
      itemBuilder: (_, i) {
        final active = selected == i;
        final isAttention = i == 3;
        return GestureDetector(
          onTap: () => onChanged(i),
          child: Container(
            height:30,
            padding: const EdgeInsets.symmetric(horizontal:11),
            decoration: BoxDecoration(
              color: active ? _C.textPrimary : _C.surface,
              borderRadius: BorderRadius.circular(999),
              border: Border.all(
                  color: active ? _C.textPrimary : _C.border),
            ),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              if (isAttention) ...[
                Container(width:6, height:6,
                  decoration: const BoxDecoration(
                      color:_C.amber, shape:BoxShape.circle)),
                const SizedBox(width:5),
              ],
              Text(_labels[i],
                  style: _pjs(size:11.5, weight:FontWeight.w600,
                    color: active ? Colors.white : _C.textPrimary)),
            ]),
          ),
        );
      },
    ),
  );
}

// ── Summary strip ─────────────────────────────────────────────────────────────
class _SummaryStrip extends StatelessWidget {
  final int newCount;
  final int attentionCount;
  const _SummaryStrip(
      {required this.newCount, required this.attentionCount});

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(horizontal:18),
    child: Row(children: [
      Expanded(child: _SummaryCard(
        iconBg: _C.greenSoft, icon: Icons.trending_up_rounded,
        iconColor: _C.green,
        value: '$newCount new', valueColor: _C.green,
        sub: 'this week', borderColor: _C.border,
      )),
      const SizedBox(width:8),
      Expanded(child: _SummaryCard(
        iconBg: _C.amberSoft, icon: Icons.priority_high_rounded,
        iconColor: _C.amber,
        value: '$attentionCount need', valueColor: _C.amber,
        sub: 'attention',
        borderColor: _C.amber.withValues(alpha: 0x44 / 255),
      )),
    ]),
  );
}

class _SummaryCard extends StatelessWidget {
  final Color iconBg, iconColor, valueColor, borderColor;
  final IconData icon;
  final String value, sub;
  const _SummaryCard({required this.iconBg, required this.icon,
    required this.iconColor, required this.value,
    required this.valueColor, required this.sub,
    required this.borderColor});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal:12, vertical:10),
    decoration: BoxDecoration(color:_C.surface,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color:borderColor)),
    child: Row(children: [
      Container(width:32, height:32,
        decoration: BoxDecoration(color:iconBg,
            borderRadius: BorderRadius.circular(8)),
        child: Icon(icon, size:16, color:iconColor)),
      const SizedBox(width:10),
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(value, style: _pjs(size:16, weight:FontWeight.w800,
            ls:-0.3, color:valueColor)),
        Text(sub, style: _pjs(size:10.5, weight:FontWeight.w500,
            color:_C.textSecondary)),
      ]),
    ]),
  );
}

// ── Skeleton card ─────────────────────────────────────────────────────────────
class _SkeletonCard extends StatelessWidget {
  const _SkeletonCard();
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal:12, vertical:10),
    decoration: BoxDecoration(color:_C.surface,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color:_C.border)),
    child: Row(children: [
      Container(width:40, height:40,
        decoration: BoxDecoration(
            color:_C.borderSubtle, shape:BoxShape.circle)),
      const SizedBox(width:12),
      Expanded(child: Column(
        crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(height:12, width:120,
          decoration: BoxDecoration(color:_C.borderSubtle,
              borderRadius: BorderRadius.circular(6))),
        const SizedBox(height:6),
        Container(height:10, width:80,
          decoration: BoxDecoration(color:_C.borderSubtle,
              borderRadius: BorderRadius.circular(6))),
      ])),
      Container(width:28, height:28,
        decoration: BoxDecoration(
            color:_C.borderSubtle, shape:BoxShape.circle)),
    ]),
  );
}

// ── Student card ──────────────────────────────────────────────────────────────
class _StudentCard extends StatefulWidget {
  final Student student;
  final bool highlighted;
  final VoidCallback onTap;
  final Duration delay;
  const _StudentCard({
    required this.student,
    required this.highlighted,
    required this.onTap,
    required this.delay,
  });
  @override State<_StudentCard> createState() => _StudentCardState();
}

class _StudentCardState extends State<_StudentCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _opacity;
  late final Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync:this,
        duration:const Duration(milliseconds:120));
    _opacity = CurvedAnimation(parent:_ctrl, curve:Curves.easeOut);
    _slide = Tween<Offset>(begin:const Offset(0, .04), end:Offset.zero)
        .animate(CurvedAnimation(parent:_ctrl, curve:Curves.easeOut));
    Future.delayed(widget.delay, () { if (mounted) _ctrl.forward(); });
  }

  @override void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final s = widget.student;
    final tint = _C.tintFor(s.id);
    final initials = (s.firstName.isNotEmpty ? s.firstName[0] : '') +
                     (s.lastName.isNotEmpty ? s.lastName[0] : '');

    return FadeTransition(
      opacity: _opacity,
      child: SlideTransition(
        position: _slide,
        child: GestureDetector(
          onTap: widget.onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds:120),
            padding: const EdgeInsets.symmetric(horizontal:12, vertical:10),
            decoration: BoxDecoration(
              color: _C.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: widget.highlighted ? _C.primary : _C.border,
                width: widget.highlighted ? 1.5 : 1,
              ),
              boxShadow: widget.highlighted ? [
                BoxShadow(color:_C.primarySoft, blurRadius:0, spreadRadius:3),
              ] : null,
            ),
            child: Row(children: [
              Container(width:40, height:40,
                decoration: BoxDecoration(color:tint, shape:BoxShape.circle),
                child: Center(child: Text(
                  initials.isEmpty ? '?' : initials.toUpperCase(),
                  style: _pjs(size:14, weight:FontWeight.w700,
                      color:Colors.white)))),
              const SizedBox(width:12),
              Expanded(child: Column(
                crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(s.fullName,
                  style: _pjs(size:13.5, weight:FontWeight.w700, ls:-0.1),
                  maxLines:1, overflow:TextOverflow.ellipsis),
                Text(_courseLine(s.enrolledCourses),
                  style: _pjs(size:11.5, color:_C.textSecondary),
                  maxLines:1, overflow:TextOverflow.ellipsis),
              ])),
              const SizedBox(width:8),
              Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                if (s.earliestEnrolledAt != null)
                  Text(_formatDate(s.earliestEnrolledAt),
                    style: _pjs(size:10.5, weight:FontWeight.w600,
                        color:_C.textFaint)),
                const SizedBox(height:4),
                const _Ring(pct: null),
              ]),
            ]),
          ),
        ),
      ),
    );
  }
}

// ── Progress ring ─────────────────────────────────────────────────────────────
class _Ring extends StatelessWidget {
  final int? pct;
  final double size = 28;
  const _Ring({required this.pct});

  @override
  Widget build(BuildContext context) => SizedBox(
    width:size, height:size,
    child: CustomPaint(
      painter: _RingPainter(pct:pct),
      child: Center(child: Text(
        pct != null ? '$pct' : '—',
        style: _pjs(
          size:9*size/28,
          weight:FontWeight.w700,
          lh:1,
          color: pct != null ? _C.textPrimary : _C.textFaint,
        ),
      )),
    ),
  );
}

class _RingPainter extends CustomPainter {
  final int? pct;
  const _RingPainter({required this.pct});

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width/2, cy = size.height/2;
    const stroke = 3.0;
    final r = size.width/2 - stroke/2;
    final rect = Rect.fromCircle(center:Offset(cx,cy), radius:r);

    canvas.drawArc(rect, 0, 6.283, false,
      Paint()
        ..color=_C.borderSubtle
        ..strokeWidth=stroke
        ..style=PaintingStyle.stroke);

    if (pct != null && pct! > 0) {
      final sweep = (pct!/100)*6.283;
      canvas.drawArc(rect, -1.5708, sweep, false,
        Paint()
          ..color=_C.ringColor(pct!)
          ..strokeWidth=stroke
          ..style=PaintingStyle.stroke
          ..strokeCap=StrokeCap.round);
    }
  }

  @override bool shouldRepaint(_RingPainter old) => old.pct != pct;
}

/*
// Phase 2 student-detail sheet preserved below — enable by wiring onTap above.
class _StudentSheet extends StatelessWidget { ... }
*/

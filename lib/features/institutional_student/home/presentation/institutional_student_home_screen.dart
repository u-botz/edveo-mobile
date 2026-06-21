import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../auth/presentation/me_providers.dart';
import '../../../../core/theme/edveo_colors.dart';
import '../../attendance/data/repositories/attendance_repository.dart';
import '../../fees/data/repositories/fees_due_repository.dart';
import '../../presentation/institutional_student_shell.dart';
import '../../tests/data/repositories/tests_repository.dart';
import '../../schedule/data/models/schedule_model.dart';
import '../../schedule/data/repositories/schedule_repository.dart';
import 'widgets/inst_student_top_bar.dart';
import 'widgets/checkin_status_card.dart';
import 'widgets/attendance_ring_card.dart';
import 'widgets/next_test_card.dart';
import 'widgets/todays_classes_section.dart';
import 'widgets/fee_due_card.dart';

const _kAccent = Color(0xFFF97316);

class InstitutionalStudentHomeScreen extends ConsumerWidget {
  const InstitutionalStudentHomeScreen({super.key});

  // day_of_week convention: 0 = Sunday … 6 = Saturday (matches backend + schedule screen)
  int get _todayDow => DateTime.now().weekday % 7;

  String _dateLabel(int count) {
    final now = DateTime.now();
    final day = DateFormat('EEE, d MMM').format(now);
    if (count == 0) return day;
    return '$day · $count ${count == 1 ? "period" : "periods"}';
  }

  ClassStatus _classStatus(String startTime, String endTime) {
    final now = DateTime.now();
    final nowMins = now.hour * 60 + now.minute;

    int parseMins(String hhmm) {
      final p = hhmm.split(':');
      if (p.length < 2) return 0;
      return (int.tryParse(p[0]) ?? 0) * 60 + (int.tryParse(p[1]) ?? 0);
    }

    final startMins = parseMins(startTime);
    final endMins   = parseMins(endTime);

    if (nowMins >= endMins) return ClassStatus.completed;
    if (nowMins >= startMins) return ClassStatus.ongoing;
    return ClassStatus.upcoming;
  }

  List<TodayClassItem> _buildClasses(List<ScheduleSlotModel> slots) {
    return slots.map((s) => TodayClassItem(
      time:    s.startTime,
      subject: s.displayName,
      teacher: s.teacher ?? '',
      room:    s.venue ?? '',
      status:  _classStatus(s.startTime, s.endTime),
    )).toList();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final me              = ref.watch(currentMeProvider);
    final scheduleAsync   = ref.watch(scheduleProvider);
    final attendanceAsync = ref.watch(attendanceProvider);
    final feesDueAsync    = ref.watch(feesDueProvider);
    final testsAsync      = ref.watch(testsProvider);
    final avatarColor     = me != null ? EdveoColors.tintForSlug(me.id) : _kAccent;

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      body: Column(
        children: [
          InstStudentTopBar(
            firstName: me?.firstName.isNotEmpty == true ? me!.firstName : 'Student',
            initials: me?.initials ?? 'S',
            avatarColor: avatarColor,
            classLabel: 'Class 12 · JEE-A1', // TODO: wire from student profile API
            onNotificationTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Notifications coming soon'),
                  duration: Duration(seconds: 2),
                ),
              );
            },
          ),
          const Divider(height: 1, color: Color(0xFFE5E7EB)),

          Expanded(
            child: RefreshIndicator(
              color: _kAccent,
              onRefresh: () async {
                ref.invalidate(scheduleProvider);
                ref.invalidate(attendanceProvider);
                ref.invalidate(feesDueProvider);
                ref.invalidate(testsProvider);
                await Future<void>.delayed(const Duration(milliseconds: 400));
              },
              child: CustomScrollView(
                slivers: [
                  // ── Check-in status ────────────────────────────────────────
                  // TODO: wire to attendance API
                  const SliverToBoxAdapter(
                    child: CheckInStatusCard(
                      status: CheckInStatus.present,
                      checkInTime: '9:02 AM',
                      method: 'Gate 2 biometric',
                      dayLabel: 'DAY 1/4',
                    ),
                  ),

                  // ── Attendance ring ────────────────────────────────────────
                  SliverToBoxAdapter(
                    child: attendanceAsync.when(
                      loading: () => const AttendanceRingCard(isLoading: true),
                      error: (_, __) => const AttendanceRingCard(
                        presentDays: 0,
                        totalDays: 0,
                      ),
                      data: (att) => AttendanceRingCard(
                        presentDays:    att.summary.attended,
                        totalDays:      att.summary.total,
                        minimumPercent: att.summary.threshold / 100.0,
                        status:         att.summary.status,
                      ),
                    ),
                  ),

                  // ── Today's classes ────────────────────────────────────────
                  SliverToBoxAdapter(
                    child: scheduleAsync.when(
                      loading: () => TodaysClassesSection(
                        isLoading: true,
                        dateLabel: _dateLabel(0),
                        classes: const [],
                        accentColor: _kAccent,
                      ),
                      error: (_, __) => TodaysClassesSection(
                        dateLabel: _dateLabel(0),
                        classes: const [],
                        accentColor: _kAccent,
                        emptyMessage: 'Could not load schedule',
                      ),
                      data: (schedule) {
                        if (schedule == null) {
                          return TodaysClassesSection(
                            dateLabel: _dateLabel(0),
                            classes: const [],
                            accentColor: _kAccent,
                            emptyMessage: 'No timetable set up yet',
                          );
                        }

                        final todaySlots = schedule.slotsForDay(_todayDow);
                        final classes    = _buildClasses(todaySlots);

                        return TodaysClassesSection(
                          dateLabel: _dateLabel(todaySlots.length),
                          classes: classes,
                          accentColor: _kAccent,
                          emptyMessage: 'No classes today',
                          onScheduleTap: () {
                            // Switch shell to Schedule tab (index 2)
                            ref.read(shellTabIndexProvider.notifier).state = 2;
                          },
                        );
                      },
                    ),
                  ),

                  // ── Next scheduled test ───────────────────────────────────
                  // Disappears when no upcoming quizzes.
                  SliverToBoxAdapter(
                    child: testsAsync.when(
                      loading: () => const SizedBox.shrink(),
                      error:   (_, __) => const SizedBox.shrink(),
                      data: (tests) {
                        if (tests.upcoming.isEmpty) return const SizedBox.shrink();
                        return NextTestCard(test: tests.upcoming.first);
                      },
                    ),
                  ),

                  // ── Fee due ──────────────────────────────────────────────
                  // Card is hidden entirely when no dues (has_dues=false).
                  // Errors are swallowed silently — don't break home for a fee.
                  SliverToBoxAdapter(
                    child: feesDueAsync.when(
                      loading: () => const SizedBox.shrink(),
                      error:   (_, __) => const SizedBox.shrink(),
                      data: (fees) {
                        if (!fees.hasDues || fees.nextDue == null) {
                          return const SizedBox.shrink();
                        }
                        final due = fees.nextDue!;
                        return FeeDueCard(
                          termLabel:    due.termLabel,
                          amount:       due.amountFormatted,
                          dueDateLabel: due.dueDateDisplay,
                          accentColor:  due.isOverdue
                              ? const Color(0xFFDC2626)
                              : _kAccent,
                          onPay: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Fee payment coming soon'),
                                duration: Duration(seconds: 2),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),

                  const SliverToBoxAdapter(child: SizedBox(height: 100)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

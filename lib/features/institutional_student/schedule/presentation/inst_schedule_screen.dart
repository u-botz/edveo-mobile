import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/models/schedule_model.dart';
import '../data/repositories/schedule_repository.dart';

const _kAccent = Color(0xFFF97316);

// 0 = Sunday … 6 = Saturday (matches backend day_of_week)
const _kDayLabels = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];

// Gap (minutes) between back-to-back slots to be labeled "Short break"
const _kBreakMinGap = 10;
const _kBreakMaxGap = 60;

class InstScheduleScreen extends ConsumerStatefulWidget {
  const InstScheduleScreen({super.key});

  @override
  ConsumerState<InstScheduleScreen> createState() =>
      _InstScheduleScreenState();
}

class _InstScheduleScreenState extends ConsumerState<InstScheduleScreen> {
  late int _selectedDay;

  @override
  void initState() {
    super.initState();
    // Default to today; will snap to a working day once data loads
    _selectedDay = DateTime.now().weekday % 7; // weekday: Mon=1..Sun=7 → %7 gives Sun=0..Sat=6
  }

  void _snapToNearestWorkingDay(List<int> workingDays) {
    if (workingDays.isEmpty) return;
    if (workingDays.contains(_selectedDay)) return;
    // Pick whichever working day is nearest to today
    _selectedDay = workingDays.reduce((a, b) {
      return (a - _selectedDay).abs() <= (b - _selectedDay).abs() ? a : b;
    });
  }

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.of(context).padding.top;
    final scheduleAsync = ref.watch(scheduleProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      body: Column(
        children: [
          // ── Header ──────────────────────────────────────────────────────────
          Container(
            color: Colors.white,
            padding: EdgeInsets.only(
              left: 16,
              right: 16,
              top: top + 12,
              bottom: 12,
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Schedule',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF111827),
                        ),
                      ),
                      scheduleAsync.whenData((s) => s).valueOrNull != null
                          ? Text(
                              '${scheduleAsync.valueOrNull?.batch.name ?? ''} · weekly',
                              style: const TextStyle(
                                fontSize: 12,
                                color: Color(0xFF9CA3AF),
                              ),
                            )
                          : const SizedBox.shrink(),
                    ],
                  ),
                ),
                // Bell icon
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    border: Border.all(color: const Color(0xFFE5E7EB)),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.notifications_outlined,
                    size: 18,
                    color: Color(0xFF6B7280),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: Color(0xFFE5E7EB)),

          // ── Body ─────────────────────────────────────────────────────────────
          Expanded(
            child: scheduleAsync.when(
              loading: () => const _ScheduleSkeleton(),
              error: (_, __) => _ErrorView(
                onRetry: () => ref.refresh(scheduleProvider),
              ),
              data: (schedule) {
                if (schedule == null) {
                  return const _EmptyView();
                }

                // Snap selected day to a working day once
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (!mounted) return;
                  final before = _selectedDay;
                  _snapToNearestWorkingDay(schedule.workingDays);
                  if (_selectedDay != before) setState(() {});
                });

                final slots = schedule.slotsForDay(_selectedDay);

                return RefreshIndicator(
                  color: _kAccent,
                  onRefresh: () => ref.refresh(scheduleProvider.future),
                  child: CustomScrollView(
                    slivers: [
                      // Day selector
                      SliverToBoxAdapter(
                        child: _DaySelector(
                          workingDays: schedule.workingDays,
                          selectedDay: _selectedDay,
                          onDaySelected: (d) =>
                              setState(() => _selectedDay = d),
                        ),
                      ),

                      // Slot list with break dividers
                      if (slots.isEmpty)
                        const SliverFillRemaining(
                          child: Center(
                            child: Text(
                              'No classes scheduled',
                              style: TextStyle(
                                fontSize: 14,
                                color: Color(0xFF9CA3AF),
                              ),
                            ),
                          ),
                        )
                      else
                        SliverPadding(
                          padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
                          sliver: SliverList(
                            delegate: SliverChildBuilderDelegate(
                              (context, i) => _buildSlotOrBreak(slots, i),
                              childCount: _itemCount(slots),
                            ),
                          ),
                        ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // Inserts break items between slots with qualifying gaps
  int _itemCount(List<ScheduleSlotModel> slots) {
    int count = slots.length;
    for (int i = 0; i < slots.length - 1; i++) {
      final gap = _gapMinutes(slots[i].endTime, slots[i + 1].startTime);
      if (gap >= _kBreakMinGap && gap <= _kBreakMaxGap) count++;
    }
    return count;
  }

  Widget _buildSlotOrBreak(List<ScheduleSlotModel> slots, int itemIndex) {
    // Map virtual item index to slot index + optional preceding break
    int slotIndex = 0;
    int cursor = 0;
    while (cursor < itemIndex) {
      cursor++;
      final gap = slotIndex < slots.length - 1
          ? _gapMinutes(slots[slotIndex].endTime, slots[slotIndex + 1].startTime)
          : 0;
      if (cursor <= itemIndex && gap >= _kBreakMinGap && gap <= _kBreakMaxGap) {
        if (cursor == itemIndex) {
          return _BreakDivider(time: slots[slotIndex].endTime, gap: gap);
        }
        cursor++;
      }
      if (cursor == itemIndex) break;
      slotIndex++;
    }

    if (itemIndex == 0) {
      return _SlotCard(slot: slots[0]);
    }

    // Walk through to find which slot corresponds to this item index
    int realSlotIdx = 0;
    int idx = 0;
    while (idx < itemIndex) {
      idx++;
      if (realSlotIdx < slots.length - 1) {
        final gap = _gapMinutes(
            slots[realSlotIdx].endTime, slots[realSlotIdx + 1].startTime);
        if (gap >= _kBreakMinGap && gap <= _kBreakMaxGap) {
          if (idx == itemIndex) {
            return _BreakDivider(time: slots[realSlotIdx].endTime, gap: gap);
          }
          idx++;
        }
      }
      realSlotIdx++;
      if (idx == itemIndex) break;
    }
    if (realSlotIdx >= slots.length) realSlotIdx = slots.length - 1;
    return _SlotCard(slot: slots[realSlotIdx]);
  }

  static int _gapMinutes(String endTime, String startTime) {
    int toMin(String t) {
      final parts = t.split(':');
      return int.tryParse(parts[0]) ?? 0 * 60 + (int.tryParse(parts[1]) ?? 0);
    }

    return math.max(0, toMin(startTime) - toMin(endTime));
  }
}

// ── Day selector ─────────────────────────────────────────────────────────────

class _DaySelector extends StatelessWidget {
  final List<int> workingDays;
  final int selectedDay;
  final ValueChanged<int> onDaySelected;

  const _DaySelector({
    required this.workingDays,
    required this.selectedDay,
    required this.onDaySelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      child: Row(
        children: workingDays.map((day) {
          final isSelected = day == selectedDay;
          return Expanded(
            child: GestureDetector(
              onTap: () => onDaySelected(day),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                margin: const EdgeInsets.symmetric(horizontal: 3),
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected ? _kAccent : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                  border: isSelected
                      ? null
                      : Border.all(color: const Color(0xFFE5E7EB)),
                ),
                child: Text(
                  _kDayLabels[day],
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                    color: isSelected ? Colors.white : const Color(0xFF6B7280),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

// ── Slot card ────────────────────────────────────────────────────────────────

// Assign a consistent color per subject name for the left accent bar
Color _subjectColor(String? subject) {
  if (subject == null) return _kAccent;
  final colors = [
    const Color(0xFFF97316), // orange
    const Color(0xFF8B5CF6), // purple
    const Color(0xFF16A34A), // green
    const Color(0xFF0891B2), // cyan
    const Color(0xFFDC2626), // red
    const Color(0xFF2563EB), // blue
    const Color(0xFFF59E0B), // amber
  ];
  int hash = subject.codeUnits.fold(0, (a, b) => a + b);
  return colors[hash % colors.length];
}

class _SlotCard extends StatelessWidget {
  final ScheduleSlotModel slot;

  const _SlotCard({required this.slot});

  @override
  Widget build(BuildContext context) {
    final barColor = _subjectColor(slot.subject);

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Time column
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    slot.startTime,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF374151),
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    slot.endTime,
                    style: const TextStyle(
                      fontSize: 11,
                      color: Color(0xFF9CA3AF),
                    ),
                  ),
                ],
              ),
            ),
            // Left accent bar
            Container(
              width: 3,
              margin: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: barColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 12),
            // Subject + details
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            slot.displayName,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF111827),
                            ),
                          ),
                        ),
                        if (slot.isOptional)
                          Container(
                            margin: const EdgeInsets.only(right: 12),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF3F4F6),
                              borderRadius: BorderRadius.circular(5),
                            ),
                            child: const Text(
                              'OPTIONAL',
                              style: TextStyle(
                                fontSize: 9.5,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF6B7280),
                                letterSpacing: 0.3,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(
                          Icons.location_on_outlined,
                          size: 12,
                          color: Color(0xFF9CA3AF),
                        ),
                        const SizedBox(width: 3),
                        if (slot.venue != null)
                          Text(
                            slot.venue!,
                            style: const TextStyle(
                              fontSize: 11.5,
                              color: Color(0xFF9CA3AF),
                            ),
                          ),
                        if (slot.teacher != null) ...[
                          const Text(
                            ' · ',
                            style: TextStyle(
                              fontSize: 11.5,
                              color: Color(0xFF9CA3AF),
                            ),
                          ),
                          Expanded(
                            child: Text(
                              slot.teacher!,
                              style: const TextStyle(
                                fontSize: 11.5,
                                color: Color(0xFF9CA3AF),
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Break divider ────────────────────────────────────────────────────────────

class _BreakDivider extends StatelessWidget {
  final String time;
  final int gap;

  const _BreakDivider({required this.time, required this.gap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          const Expanded(child: Divider(color: Color(0xFFE5E7EB))),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Text(
              '$time  ·  ${_label(gap)}',
              style: const TextStyle(
                fontSize: 11.5,
                color: Color(0xFF9CA3AF),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const Expanded(child: Divider(color: Color(0xFFE5E7EB))),
        ],
      ),
    );
  }

  static String _label(int minutes) {
    if (minutes <= 20) return 'Short break';
    if (minutes <= 45) return '$minutes min break';
    return 'Lunch break';
  }
}

// ── Skeleton ─────────────────────────────────────────────────────────────────

class _ScheduleSkeleton extends StatefulWidget {
  const _ScheduleSkeleton();

  @override
  State<_ScheduleSkeleton> createState() => _ScheduleSkeletonState();
}

class _ScheduleSkeletonState extends State<_ScheduleSkeleton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, __) {
        final opacity = 0.4 + _ctrl.value * 0.4;
        return Opacity(
          opacity: opacity,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Day row skeleton
                Container(
                  height: 40,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE5E7EB),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                const SizedBox(height: 16),
                for (int i = 0; i < 4; i++) ...[
                  Container(
                    height: 68,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE5E7EB),
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}

// ── Empty & error states ─────────────────────────────────────────────────────

class _EmptyView extends StatelessWidget {
  const _EmptyView();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.calendar_today_outlined, size: 52, color: Color(0xFFD1D5DB)),
          SizedBox(height: 14),
          Text(
            'No timetable yet',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: Color(0xFF374151),
            ),
          ),
          SizedBox(height: 6),
          Text(
            'Your teacher will publish your schedule soon.',
            style: TextStyle(fontSize: 13, color: Color(0xFF9CA3AF)),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final VoidCallback onRetry;

  const _ErrorView({required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.wifi_off_outlined, size: 48, color: Color(0xFFD1D5DB)),
          const SizedBox(height: 14),
          const Text(
            'Could not load schedule',
            style: TextStyle(fontSize: 14, color: Color(0xFF6B7280)),
          ),
          const SizedBox(height: 10),
          TextButton(onPressed: onRetry, child: const Text('Try again')),
        ],
      ),
    );
  }
}

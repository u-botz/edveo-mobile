import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../home/presentation/institutional_student_home_screen.dart';
import '../attendance/presentation/inst_attendance_screen.dart';
import '../schedule/presentation/inst_schedule_screen.dart';
import '../tests/presentation/inst_tests_screen.dart';
import '../profile/presentation/inst_profile_screen.dart';

// Orange accent used throughout the institutional-student shell.
const _kAccent = Color(0xFFF97316);

// Shared tab-index provider so child screens can switch tabs (e.g. Home → Schedule).
final shellTabIndexProvider = StateProvider<int>((ref) => 0);

class InstitutionalStudentShell extends ConsumerWidget {
  const InstitutionalStudentShell({super.key});

  // Tab order: 0 Home · 1 Attendance · 2 Schedule · 3 Tests · 4 Profile
  static const List<Widget> _screens = [
    InstitutionalStudentHomeScreen(),
    InstAttendanceScreen(),
    InstScheduleScreen(),
    InstTestsScreen(),
    InstProfileScreen(),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentIndex = ref.watch(shellTabIndexProvider);

    return Scaffold(
      body: IndexedStack(
        index: currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: currentIndex,
        onDestinationSelected: (i) =>
            ref.read(shellTabIndexProvider.notifier).state = i,
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        shadowColor: const Color(0x14000000),
        elevation: 0,
        indicatorColor: const Color(0xFFFFF7ED),
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home, color: _kAccent),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.fact_check_outlined),
            selectedIcon: Icon(Icons.fact_check, color: _kAccent),
            label: 'Attendance',
          ),
          NavigationDestination(
            icon: Icon(Icons.calendar_today_outlined),
            selectedIcon: Icon(Icons.calendar_today, color: _kAccent),
            label: 'Schedule',
          ),
          NavigationDestination(
            icon: Icon(Icons.quiz_outlined),
            selectedIcon: Icon(Icons.quiz, color: _kAccent),
            label: 'Tests',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person, color: _kAccent),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

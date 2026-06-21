import 'package:edveo/features/student/courses/presentation/student_courses_screen.dart';
import 'package:edveo/features/student/exams/presentation/student_exams_screen.dart';
import 'package:edveo/features/student/live/presentation/student_live_screen.dart';
import 'package:edveo/features/student_home/presentation/student_home_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Shared tab-index provider so child screens can programmatically switch tabs.
final studentShellTabProvider = StateProvider<int>((ref) => 0);

class StudentShell extends ConsumerWidget {
  const StudentShell({super.key});

  // Tab order: 0 Home · 1 Courses · 2 Exams · 3 Live · 4 Profile
  static const List<Widget> _screens = [
    StudentHomeScreen(),
    StudentCoursesScreen(),
    StudentExamsScreen(),
    StudentLiveScreen(),
    _ProfilePlaceholder(),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentIndex = ref.watch(studentShellTabProvider);

    return Scaffold(
      body: IndexedStack(
        index: currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: currentIndex,
        onDestinationSelected: (i) =>
            ref.read(studentShellTabProvider.notifier).state = i,
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        shadowColor: const Color(0x14000000),
        elevation: 0,
        indicatorColor: const Color(0xFFDCFCE7), // green-100
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        destinations: [
          const NavigationDestination(
            icon: Icon(Icons.home_outlined, color: Color(0xFF6B7280)),
            selectedIcon: Icon(Icons.home_rounded, color: Color(0xFF16A34A)),
            label: 'Home',
          ),
          const NavigationDestination(
            icon: Icon(Icons.menu_book_outlined, color: Color(0xFF6B7280)),
            selectedIcon: Icon(Icons.menu_book_rounded, color: Color(0xFF16A34A)),
            label: 'Courses',
          ),
          const NavigationDestination(
            icon: Icon(Icons.quiz_outlined, color: Color(0xFF6B7280)),
            selectedIcon: Icon(Icons.quiz_rounded, color: Color(0xFF16A34A)),
            label: 'Exams',
          ),
          NavigationDestination(
            icon: _BadgeIcon(
              child: const Icon(Icons.videocam_outlined, color: Color(0xFF6B7280)),
            ),
            selectedIcon: const Icon(Icons.videocam_rounded, color: Color(0xFF16A34A)),
            label: 'Live',
          ),
          const NavigationDestination(
            icon: Icon(Icons.person_outline, color: Color(0xFF6B7280)),
            selectedIcon: Icon(Icons.person_rounded, color: Color(0xFF16A34A)),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

// Red dot badge for the Live tab icon.
class _BadgeIcon extends StatelessWidget {
  final Widget child;
  const _BadgeIcon({required this.child});

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        child,
        Positioned(
          top: -2,
          right: -4,
          child: Container(
            width: 8,
            height: 8,
            decoration: const BoxDecoration(
              color: Color(0xFFDC2626),
              shape: BoxShape.circle,
            ),
          ),
        ),
      ],
    );
  }
}

class _ProfilePlaceholder extends StatelessWidget {
  const _ProfilePlaceholder();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color(0xFFF9FAFB),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.person_outline_rounded, size: 48, color: Color(0xFF9CA3AF)),
            SizedBox(height: 12),
            Text(
              'Profile',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Color(0xFF374151),
              ),
            ),
            SizedBox(height: 4),
            Text(
              'Coming soon',
              style: TextStyle(fontSize: 13, color: Color(0xFF9CA3AF)),
            ),
          ],
        ),
      ),
    );
  }
}

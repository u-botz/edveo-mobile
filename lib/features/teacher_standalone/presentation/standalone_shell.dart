import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'home_screen.dart';
import '../courses/presentation/courses_screen.dart';
import 'students_screen.dart';
import '../more/presentation/more_screen.dart';
import 'live_session_screen.dart';

class StandaloneTeacherShell extends ConsumerStatefulWidget {
  const StandaloneTeacherShell({super.key});

  @override
  ConsumerState<StandaloneTeacherShell> createState() =>
      _StandaloneTeacherShellState();
}

class _StandaloneTeacherShellState
    extends ConsumerState<StandaloneTeacherShell> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const StandaloneHomeScreen(),
    const StandaloneTeacherCoursesScreen(),
    const StandaloneStudentsScreen(),
    const StandaloneLiveSessionScreen(),
    const StandaloneMoreScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: _BottomTabBar(
        currentIndex: _currentIndex,
        onTap: (i) => setState(() => _currentIndex = i),
      ),
    );
  }
}



// ── Design-spec bottom tab bar ────────────────────────────────────────────────

const _tabItems = [
  (Icons.home_rounded, Icons.home_outlined, 'Home'),
  (Icons.play_circle_rounded, Icons.play_circle_outline, 'Courses'),
  (Icons.people_rounded, Icons.people_outline, 'Students'),
  (Icons.videocam_rounded, Icons.videocam_outlined, 'Live'),
  (Icons.grid_view_rounded, Icons.grid_view_outlined, 'More'),
];

class _BottomTabBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const _BottomTabBar({
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 74 + MediaQuery.of(context).padding.bottom,
      decoration: const BoxDecoration(
        color: Color(0xFFFFFFFF),
        border: Border(top: BorderSide(color: Color(0xFFE5E7EB))),
      ),
      child: Row(
        children: List.generate(_tabItems.length, (i) {
          final (activeIcon, idleIcon, label) = _tabItems[i];
          final isActive = i == currentIndex;
          return Expanded(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => onTap(i),
              child: Semantics(
                label: label,
                selected: isActive,
                button: true,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(height: 10),
                    // Active pill
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      width: isActive ? 20 : 0,
                      height: 3,
                      margin: const EdgeInsets.only(bottom: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1D4ED8),
                        borderRadius: BorderRadius.circular(99),
                      ),
                    ),
                    Icon(
                      isActive ? activeIcon : idleIcon,
                      size: 22,
                      color: isActive
                          ? const Color(0xFF1D4ED8)
                          : const Color(0xFF9CA3AF),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      label,
                      style: TextStyle(
                        fontSize: 10.5,
                        fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                        color: isActive
                            ? const Color(0xFF1D4ED8)
                            : const Color(0xFF9CA3AF),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}

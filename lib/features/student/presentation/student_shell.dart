import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class StudentShell extends ConsumerStatefulWidget {
  const StudentShell({super.key});

  @override
  ConsumerState<StudentShell> createState() => _StudentShellState();
}

class _StudentShellState extends ConsumerState<StudentShell> {
  int _currentIndex = 0;

  final List<Widget> _pages = const [
    _PlaceholderPage(label: 'Home'),
    _PlaceholderPage(label: 'Courses'),
    _PlaceholderPage(label: 'Timetable'),
    _PlaceholderPage(label: 'Results'),
    _PlaceholderPage(label: 'Profile'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_outlined),     label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.play_circle_outline), label: 'Courses'),
          BottomNavigationBarItem(icon: Icon(Icons.calendar_today_outlined), label: 'Timetable'),
          BottomNavigationBarItem(icon: Icon(Icons.bar_chart_outlined), label: 'Results'),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline),    label: 'Profile'),
        ],
      ),
    );
  }
}

class _PlaceholderPage extends StatelessWidget {
  final String label;
  const _PlaceholderPage({required this.label});

  @override
  Widget build(BuildContext context) {
    return Center(child: Text('$label — M2'));
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class InstitutionalTeacherShell extends ConsumerStatefulWidget {
  const InstitutionalTeacherShell({super.key});

  @override
  ConsumerState<InstitutionalTeacherShell> createState() =>
      _InstitutionalTeacherShellState();
}

class _InstitutionalTeacherShellState
    extends ConsumerState<InstitutionalTeacherShell> {
  int _currentIndex = 0;

  final List<Widget> _pages = const [
    _PlaceholderPage(label: 'Home'),
    _PlaceholderPage(label: 'Schedule'),
    _PlaceholderPage(label: 'Students'),
    _PlaceholderPage(label: 'Assignments'),
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
          BottomNavigationBarItem(icon: Icon(Icons.home_outlined),        label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.calendar_today_outlined), label: 'Schedule'),
          BottomNavigationBarItem(icon: Icon(Icons.people_outline),       label: 'Students'),
          BottomNavigationBarItem(icon: Icon(Icons.assignment_outlined),  label: 'Assignments'),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline),       label: 'Profile'),
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

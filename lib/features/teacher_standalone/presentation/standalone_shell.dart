import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class StandaloneTeacherShell extends ConsumerStatefulWidget {
  const StandaloneTeacherShell({super.key});

  @override
  ConsumerState<StandaloneTeacherShell> createState() =>
      _StandaloneTeacherShellState();
}

class _StandaloneTeacherShellState
    extends ConsumerState<StandaloneTeacherShell> {
  int _currentIndex = 0;

  final List<Widget> _pages = const [
    _PlaceholderPage(label: 'Home'),
    _PlaceholderPage(label: 'My Courses'),
    _PlaceholderPage(label: 'Students'),
    _PlaceholderPage(label: 'Live Session'),
    _PlaceholderPage(label: 'More'),
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
          BottomNavigationBarItem(icon: Icon(Icons.home_outlined),         label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.play_circle_outline),   label: 'My Courses'),
          BottomNavigationBarItem(icon: Icon(Icons.people_outline),        label: 'Students'),
          BottomNavigationBarItem(icon: Icon(Icons.videocam_outlined),     label: 'Live Session'),
          BottomNavigationBarItem(icon: Icon(Icons.grid_view_outlined),    label: 'More'),
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

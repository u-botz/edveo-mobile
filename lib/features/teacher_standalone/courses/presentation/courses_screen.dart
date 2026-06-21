import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/storage/token_storage.dart';
import 'package:edveo/features/courses/data/models/course_model.dart';
import 'package:edveo/features/courses/data/repositories/courses_repository.dart';
import 'widgets/course_card.dart';
import 'widgets/course_filter_tabs.dart';

class StandaloneTeacherCoursesScreen extends ConsumerStatefulWidget {
  const StandaloneTeacherCoursesScreen({super.key});

  @override
  ConsumerState<StandaloneTeacherCoursesScreen> createState() =>
      _StandaloneTeacherCoursesScreenState();
}

class _StandaloneTeacherCoursesScreenState
    extends ConsumerState<StandaloneTeacherCoursesScreen> {
  CoursesScreenModel? _data;
  bool _loading = true;
  String? _error;
  CourseStatus? _activeFilter;
  String _searchQuery = '';
  bool _searchOpen = false;
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    try {
      setState(() { _loading = true; _error = null; });
      final data = await ref.read(coursesRepositoryProvider).fetchCourses();
      if (mounted) setState(() { _data = data; _loading = false; });
    } catch (e) {
      if (mounted) setState(() { _loading = false; _error = e.toString(); });
    }
  }

  List<CourseModel> get _filteredCourses {
    if (_data == null) return [];
    return _data!.courses.where((c) {
      final matchesFilter = _activeFilter == null || c.status == _activeFilter;
      final matchesSearch = _searchQuery.isEmpty ||
          c.title.toLowerCase().contains(_searchQuery.toLowerCase());
      return matchesFilter && matchesSearch;
    }).toList();
  }

  int _count(CourseStatus? status) {
    if (_data == null) return 0;
    if (status == null) return _data!.courses.length;
    return _data!.courses.where((c) => c.status == status).length;
  }

  Future<void> _openNewCourse() async {
    final slug = await TokenStorage.getTenantSlug();
    if (slug == null) return;
    await launchUrl(
      Uri.parse('https://$slug.edveo.co/courses/new'),
      mode: LaunchMode.externalApplication,
    );
  }

  Future<void> _openEditCourse(String courseSlug) async {
    final slug = await TokenStorage.getTenantSlug();
    if (slug == null) return;
    await launchUrl(
      Uri.parse('https://$slug.edveo.co/courses/$courseSlug/edit'),
      mode: LaunchMode.externalApplication,
    );
  }

  void _showStub(String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$feature — coming soon')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: 8),
            if (_data != null)
              CourseFilterTabs(
                activeFilter: _activeFilter,
                counts: {
                  null: _count(null),
                  CourseStatus.published: _count(CourseStatus.published),
                  CourseStatus.draft:     _count(CourseStatus.draft),
                  CourseStatus.archived:  _count(CourseStatus.archived),
                },
                onFilterChanged: (f) => setState(() => _activeFilter = f),
              ),
            const SizedBox(height: 8),
            Expanded(child: _buildBody()),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Row(
        children: [
          if (_searchOpen)
            Expanded(
              child: TextField(
                controller: _searchController,
                autofocus: true,
                decoration: InputDecoration(
                  hintText: 'Search courses…',
                  border: InputBorder.none,
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () {
                      setState(() {
                        _searchOpen = false;
                        _searchController.clear();
                        _searchQuery = '';
                      });
                    },
                  ),
                ),
                onChanged: (v) => setState(() => _searchQuery = v),
              ),
            )
          else ...[
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('My Courses', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                  if (_data != null)
                    Text(
                      '${_data!.totalCourses} courses · ${_data!.totalStudents} students',
                      style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                    ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.search),
              onPressed: () => setState(() => _searchOpen = true),
            ),
            const SizedBox(width: 4),
            ElevatedButton.icon(
              onPressed: _openNewCourse,
              icon: const Icon(Icons.add, size: 18),
              label: const Text('New'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1A56DB),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (_loading) return const Center(child: CircularProgressIndicator());
    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.grey),
            const SizedBox(height: 12),
            const Text('Could not load courses'),
            const SizedBox(height: 12),
            ElevatedButton(onPressed: _load, child: const Text('Retry')),
          ],
        ),
      );
    }

    final courses = _filteredCourses;
    if (courses.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.book_outlined, size: 48, color: Colors.grey.shade400),
            const SizedBox(height: 12),
            Text(
              _searchQuery.isNotEmpty
                  ? 'No courses match your search'
                  : _activeFilter == null
                      ? 'You have not created any courses yet'
                      : 'No ${_activeFilter!.name} courses',
              style: TextStyle(color: Colors.grey.shade600),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _load,
      child: ListView.builder(
        padding: const EdgeInsets.only(bottom: 24, top: 4),
        itemCount: courses.length,
        itemBuilder: (_, i) => CourseCard(
          course: courses[i],
          onManage:           () => context.push(
                '/standalone/courses/${courses[i].id}/manage',
                extra: {'title': courses[i].title},
              ),
          onAnalytics:        () => _showStub('Course analytics'),
          onContinueEditing:  () => _openEditCourse(courses[i].slug),
        ),
      ),
    );
  }
}

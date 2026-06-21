import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:edveo/features/courses/data/models/course_structure_model.dart';
import 'course_manage_provider.dart';
import 'add_subject_bottom_sheet.dart';
import 'add_chapter_bottom_sheet.dart';
import 'add_video_lesson_bottom_sheet.dart';

class CourseManageScreen extends ConsumerWidget {
  final int courseId;
  final String courseTitle;

  const CourseManageScreen({
    super.key,
    required this.courseId,
    required this.courseTitle,
  });

  void _addSubject(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => AddSubjectBottomSheet(courseId: courseId),
    );
  }

  void _addChapter(BuildContext context, {int? subjectId}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => AddChapterBottomSheet(courseId: courseId, subjectId: subjectId),
    );
  }

  void _addVideoLesson(BuildContext context, int chapterId, {int? subjectId}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => AddVideoLessonBottomSheet(
        courseId: courseId,
        chapterId: chapterId,
        subjectId: subjectId,
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(courseManageProvider(courseId));

    return Scaffold(
      appBar: AppBar(
        title: Text(courseTitle, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
        centerTitle: false,
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF111827),
        surfaceTintColor: Colors.white,
      ),
      backgroundColor: const Color(0xFFF9FAFB),
      body: switch (state) {
        CourseStructureLoading() => const Center(child: CircularProgressIndicator()),
        CourseStructureError(:final message) => _ErrorView(
            message: message,
            onRetry: () => ref.read(courseManageProvider(courseId).notifier).refresh(),
          ),
        CourseStructureLoaded(:final structure) => _StructureView(
            structure: structure,
            onAddSubject: () => _addSubject(context),
            onAddChapter: ({int? subjectId}) => _addChapter(context, subjectId: subjectId),
            onAddVideoLesson: (chapterId, {int? subjectId}) =>
                _addVideoLesson(context, chapterId, subjectId: subjectId),
          ),
      },
    );
  }
}

// ─── Structure view ───────────────────────────────────────────────────────────

class _StructureView extends StatelessWidget {
  final CourseStructureModel structure;
  final VoidCallback onAddSubject;
  final void Function({int? subjectId}) onAddChapter;
  final void Function(int chapterId, {int? subjectId}) onAddVideoLesson;

  const _StructureView({
    required this.structure,
    required this.onAddSubject,
    required this.onAddChapter,
    required this.onAddVideoLesson,
  });

  @override
  Widget build(BuildContext context) {
    if (structure.isSubjectMode) {
      return _SubjectModeView(
        structure: structure,
        onAddSubject: onAddSubject,
        onAddChapter: onAddChapter,
        onAddVideoLesson: onAddVideoLesson,
      );
    }
    return _ChapterModeView(
      structure: structure,
      onAddChapter: onAddChapter,
      onAddVideoLesson: onAddVideoLesson,
    );
  }
}

// ─── subject_chapter_lesson mode ─────────────────────────────────────────────

class _SubjectModeView extends StatelessWidget {
  final CourseStructureModel structure;
  final VoidCallback onAddSubject;
  final void Function({int? subjectId}) onAddChapter;
  final void Function(int chapterId, {int? subjectId}) onAddVideoLesson;

  const _SubjectModeView({
    required this.structure,
    required this.onAddSubject,
    required this.onAddChapter,
    required this.onAddVideoLesson,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      children: [
        ...structure.subjects.indexed.map((entry) {
              final (i, s) = entry;
              return _SubjectTile(
                subject: s,
                initiallyExpanded: i == 0,
                onAddChapter: () => onAddChapter(subjectId: s.id),
                onAddVideoLesson: (chapterId) =>
                    onAddVideoLesson(chapterId, subjectId: s.id),
              );
            }),
        const SizedBox(height: 12),
        OutlinedButton.icon(
          onPressed: onAddSubject,
          icon: const Icon(Icons.add),
          label: const Text('Add Subject'),
          style: OutlinedButton.styleFrom(
            minimumSize: const Size.fromHeight(44),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }
}

class _SubjectTile extends StatelessWidget {
  final SubjectStructure subject;
  final bool initiallyExpanded;
  final VoidCallback onAddChapter;
  final void Function(int chapterId) onAddVideoLesson;

  const _SubjectTile({
    required this.subject,
    this.initiallyExpanded = false,
    required this.onAddChapter,
    required this.onAddVideoLesson,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        initiallyExpanded: initiallyExpanded,
        title: Text(subject.title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
        children: [
          ...subject.chapters.indexed.map((entry) {
                final (i, c) = entry;
                return _ChapterTile(
                  chapter: c,
                  initiallyExpanded: i == 0,
                  onAddLesson: () => onAddVideoLesson(c.id),
                );
              }),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
            child: OutlinedButton.icon(
              onPressed: onAddChapter,
              icon: const Icon(Icons.add, size: 18),
              label: const Text('Add Chapter'),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size.fromHeight(38),
                textStyle: const TextStyle(fontSize: 13),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── chapter_lesson mode ──────────────────────────────────────────────────────

class _ChapterModeView extends StatelessWidget {
  final CourseStructureModel structure;
  final void Function({int? subjectId}) onAddChapter;
  final void Function(int chapterId, {int? subjectId}) onAddVideoLesson;

  const _ChapterModeView({
    required this.structure,
    required this.onAddChapter,
    required this.onAddVideoLesson,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      children: [
        ...structure.chapters.indexed.map((entry) {
              final (i, c) = entry;
              return _ChapterTile(
                chapter: c,
                initiallyExpanded: i == 0,
                onAddLesson: () => onAddVideoLesson(c.id),
              );
            }),
        const SizedBox(height: 12),
        OutlinedButton.icon(
          onPressed: () => onAddChapter(),
          icon: const Icon(Icons.add),
          label: const Text('Add Chapter'),
          style: OutlinedButton.styleFrom(
            minimumSize: const Size.fromHeight(44),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }
}

// ─── Shared chapter tile ──────────────────────────────────────────────────────

class _ChapterTile extends StatelessWidget {
  final ChapterStructure chapter;
  final bool initiallyExpanded;
  final VoidCallback onAddLesson;

  const _ChapterTile({
    required this.chapter,
    this.initiallyExpanded = false,
    required this.onAddLesson,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
        initiallyExpanded: initiallyExpanded,
        title: Text(chapter.title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
        children: [
          ...chapter.lessons.map((l) => ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 24),
                leading: Icon(
                  l.sourceType == 'youtube'
                      ? Icons.smart_display_outlined
                      : Icons.play_circle_outline,
                  color: const Color(0xFF1D4ED8),
                  size: 20,
                ),
                title: Text(l.title, style: const TextStyle(fontSize: 13)),
                dense: true,
              )),
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 2, 24, 8),
            child: OutlinedButton.icon(
              onPressed: onAddLesson,
              icon: const Icon(Icons.add, size: 16),
              label: const Text('Add Lesson'),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size.fromHeight(34),
                textStyle: const TextStyle(fontSize: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Error view ───────────────────────────────────────────────────────────────

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 12),
            Text(message, textAlign: TextAlign.center, style: const TextStyle(color: Colors.black54)),
            const SizedBox(height: 20),
            ElevatedButton(onPressed: onRetry, child: const Text('Retry')),
          ],
        ),
      ),
    );
  }
}

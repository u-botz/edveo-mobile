import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:edveo/features/courses/data/models/course_structure_model.dart';
import 'package:edveo/features/courses/data/repositories/courses_repository.dart';

// ─── State ───────────────────────────────────────────────────────────────────

sealed class CourseStructureState {
  const CourseStructureState();
}

class CourseStructureLoading extends CourseStructureState {
  const CourseStructureLoading();
}

class CourseStructureLoaded extends CourseStructureState {
  final CourseStructureModel structure;
  const CourseStructureLoaded(this.structure);
}

class CourseStructureError extends CourseStructureState {
  final String message;
  const CourseStructureError(this.message);
}

// ─── Notifier ─────────────────────────────────────────────────────────────────

class CourseManageNotifier extends StateNotifier<CourseStructureState> {
  CourseManageNotifier(this._repository, this._courseId)
      : super(const CourseStructureLoading()) {
    _load();
  }

  final CoursesRepository _repository;
  final int _courseId;

  Future<void> _load() async {
    state = const CourseStructureLoading();
    try {
      final structure = await _repository.fetchCourseStructure(_courseId);
      state = CourseStructureLoaded(structure);
    } on DioException catch (e) {
      state = CourseStructureError(_extractError(e));
    } catch (_) {
      state = const CourseStructureError('Failed to load course structure.');
    }
  }

  Future<void> refresh() => _load();

  Future<String?> addSubject(String name) async {
    final current = state;
    if (current is! CourseStructureLoaded) return 'Not ready';
    try {
      final subject = await _repository.addSubject(_courseId, name);
      final updated = CourseStructureModel(
        id: current.structure.id,
        title: current.structure.title,
        mode: current.structure.mode,
        subjects: [...current.structure.subjects, subject],
        chapters: current.structure.chapters,
      );
      state = CourseStructureLoaded(updated);
      return null;
    } on DioException catch (e) {
      return _extractError(e);
    } catch (_) {
      return 'Something went wrong. Please try again.';
    }
  }

  Future<String?> addChapter(String title, {int? subjectId}) async {
    final current = state;
    if (current is! CourseStructureLoaded) return 'Not ready';
    try {
      final chapter = await _repository.addChapter(_courseId, title, subjectId: subjectId);

      late CourseStructureModel updated;
      if (subjectId != null) {
        // subject_chapter_lesson mode: append to the matching subject
        updated = CourseStructureModel(
          id: current.structure.id,
          title: current.structure.title,
          mode: current.structure.mode,
          subjects: current.structure.subjects.map((s) {
            return s.id == subjectId ? s.copyWithChapter(chapter) : s;
          }).toList(),
          chapters: current.structure.chapters,
        );
      } else {
        // chapter_lesson mode: append to top-level chapters
        updated = CourseStructureModel(
          id: current.structure.id,
          title: current.structure.title,
          mode: current.structure.mode,
          subjects: current.structure.subjects,
          chapters: [...current.structure.chapters, chapter],
        );
      }
      state = CourseStructureLoaded(updated);
      return null;
    } on DioException catch (e) {
      return _extractError(e);
    } catch (_) {
      return 'Something went wrong. Please try again.';
    }
  }

  Future<String?> addVideoLesson(int chapterId, String title, String videoUrl, {int? subjectId}) async {
    final current = state;
    if (current is! CourseStructureLoaded) return 'Not ready';
    try {
      final lesson = await _repository.addVideoLesson(_courseId, chapterId, title, videoUrl);

      late CourseStructureModel updated;
      if (subjectId != null) {
        // subject_chapter_lesson mode
        updated = CourseStructureModel(
          id: current.structure.id,
          title: current.structure.title,
          mode: current.structure.mode,
          subjects: current.structure.subjects.map((s) {
            if (s.id != subjectId) return s;
            return SubjectStructure(
              id: s.id,
              title: s.title,
              sortOrder: s.sortOrder,
              chapters: s.chapters.map((c) {
                return c.id == chapterId ? c.copyWithLesson(lesson) : c;
              }).toList(),
            );
          }).toList(),
          chapters: current.structure.chapters,
        );
      } else {
        // chapter_lesson mode
        updated = CourseStructureModel(
          id: current.structure.id,
          title: current.structure.title,
          mode: current.structure.mode,
          subjects: current.structure.subjects,
          chapters: current.structure.chapters.map((c) {
            return c.id == chapterId ? c.copyWithLesson(lesson) : c;
          }).toList(),
        );
      }
      state = CourseStructureLoaded(updated);
      return null;
    } on DioException catch (e) {
      return _extractError(e);
    } catch (_) {
      return 'Something went wrong. Please try again.';
    }
  }

  String _extractError(DioException e) {
    final body = e.response?.data as Map<String, dynamic>?;
    final error = body?['error'] as Map<String, dynamic>?;
    return error?['message'] as String? ?? 'Something went wrong. Please try again.';
  }
}

// ─── Provider ─────────────────────────────────────────────────────────────────

final courseManageProvider = StateNotifierProvider.autoDispose
    .family<CourseManageNotifier, CourseStructureState, int>(
  (ref, courseId) => CourseManageNotifier(
    ref.read(coursesRepositoryProvider),
    courseId,
  ),
);

import 'package:dio/dio.dart';
import 'package:edveo/features/auth/data/auth_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:edveo/features/courses/data/models/course_model.dart';
import 'package:edveo/features/courses/data/models/course_structure_model.dart';

class CoursesRepository {
  final Dio _dio;
  CoursesRepository(this._dio);

  Future<CoursesScreenModel> fetchCourses() async {
    final response = await _dio.get('/api/mobile/standalone-teacher/courses');
    return CoursesScreenModel.fromJson(response.data as Map<String, dynamic>);
  }

  Future<CourseStructureModel> fetchCourseStructure(int courseId) async {
    final response = await _dio.get('/api/mobile/standalone/courses/$courseId/structure');
    return CourseStructureModel.fromJson(response.data as Map<String, dynamic>);
  }

  Future<SubjectStructure> addSubject(int courseId, String name) async {
    final response = await _dio.post(
      '/api/mobile/standalone/courses/$courseId/subjects',
      data: {'name': name},
    );
    final data = (response.data as Map<String, dynamic>)['data'] as Map<String, dynamic>;
    return SubjectStructure.fromJson(data);
  }

  Future<ChapterStructure> addChapter(int courseId, String title, {int? subjectId}) async {
    final response = await _dio.post(
      '/api/mobile/standalone/courses/$courseId/chapters',
      data: {
        'title': title,
        if (subjectId != null) 'subject_id': subjectId,
      },
    );
    final data = (response.data as Map<String, dynamic>)['data'] as Map<String, dynamic>;
    return ChapterStructure.fromJson(data);
  }

  Future<LessonStructure> addVideoLesson(int courseId, int chapterId, String title, String videoUrl) async {
    final response = await _dio.post(
      '/api/mobile/standalone/courses/$courseId/lessons/video',
      data: {'title': title, 'chapter_id': chapterId, 'video_url': videoUrl},
    );
    final data = (response.data as Map<String, dynamic>)['data'] as Map<String, dynamic>;
    return LessonStructure.fromJson(data);
  }
}

final coursesRepositoryProvider = Provider<CoursesRepository>((ref) {
  return CoursesRepository(ref.read(apiClientProvider).dio);
});

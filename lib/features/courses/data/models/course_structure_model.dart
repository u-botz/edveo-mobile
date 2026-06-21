class LessonStructure {
  final int id;
  final String title;
  final String? sourceType;
  final String? sourceIdentifier;
  final int sortOrder;

  const LessonStructure({
    required this.id,
    required this.title,
    this.sourceType,
    this.sourceIdentifier,
    required this.sortOrder,
  });

  factory LessonStructure.fromJson(Map<String, dynamic> json) => LessonStructure(
        id:               json['id'] as int,
        title:            json['title'] as String,
        sourceType:       json['source_type'] as String?,
        sourceIdentifier: json['source_identifier'] as String?,
        sortOrder:        json['sort_order'] as int,
      );
}

class ChapterStructure {
  final int id;
  final String title;
  final int sortOrder;
  final int? subjectId;
  final List<LessonStructure> lessons;

  const ChapterStructure({
    required this.id,
    required this.title,
    required this.sortOrder,
    this.subjectId,
    required this.lessons,
  });

  factory ChapterStructure.fromJson(Map<String, dynamic> json) => ChapterStructure(
        id:        json['id'] as int,
        title:     json['title'] as String,
        sortOrder: json['sort_order'] as int,
        subjectId: json['subject_id'] as int?,
        lessons: (json['lessons'] as List<dynamic>)
            .map((l) => LessonStructure.fromJson(l as Map<String, dynamic>))
            .toList(),
      );

  ChapterStructure copyWithLesson(LessonStructure lesson) => ChapterStructure(
        id: id,
        title: title,
        sortOrder: sortOrder,
        subjectId: subjectId,
        lessons: [...lessons, lesson],
      );
}

class SubjectStructure {
  final int id;
  final String title;
  final int sortOrder;
  final List<ChapterStructure> chapters;

  const SubjectStructure({
    required this.id,
    required this.title,
    required this.sortOrder,
    required this.chapters,
  });

  factory SubjectStructure.fromJson(Map<String, dynamic> json) => SubjectStructure(
        id:        json['id'] as int,
        title:     json['title'] as String,
        sortOrder: json['sort_order'] as int,
        chapters: (json['chapters'] as List<dynamic>)
            .map((c) => ChapterStructure.fromJson(c as Map<String, dynamic>))
            .toList(),
      );

  SubjectStructure copyWithChapter(ChapterStructure chapter) => SubjectStructure(
        id: id,
        title: title,
        sortOrder: sortOrder,
        chapters: [...chapters, chapter],
      );
}

class CourseStructureModel {
  final int id;
  final String title;
  final String mode; // 'subject_chapter_lesson' or 'chapter_lesson'
  final List<SubjectStructure> subjects;
  final List<ChapterStructure> chapters; // used in chapter_lesson mode

  const CourseStructureModel({
    required this.id,
    required this.title,
    required this.mode,
    required this.subjects,
    required this.chapters,
  });

  bool get isSubjectMode => mode == 'subject_chapter_lesson';

  factory CourseStructureModel.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>;
    return CourseStructureModel(
      id:    data['id'] as int,
      title: data['title'] as String,
      mode:  data['mode'] as String,
      subjects: (data['subjects'] as List<dynamic>)
          .map((s) => SubjectStructure.fromJson(s as Map<String, dynamic>))
          .toList(),
      chapters: (data['chapters'] as List<dynamic>)
          .map((c) => ChapterStructure.fromJson(c as Map<String, dynamic>))
          .toList(),
    );
  }
}

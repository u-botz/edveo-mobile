import 'package:edveo/features/auth/data/auth_repository.dart';
import 'package:edveo/features/quizzes/data/models/student_exams_model.dart';
import 'package:edveo/features/quizzes/data/repositories/student_exams_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final studentExamsRepositoryProvider = Provider<StudentExamsRepository>((ref) {
  return StudentExamsRepository(ref.read(apiClientProvider).dio);
});

final studentExamsProvider = FutureProvider<StudentExamsModel>((ref) {
  return ref.watch(studentExamsRepositoryProvider).getExams();
});

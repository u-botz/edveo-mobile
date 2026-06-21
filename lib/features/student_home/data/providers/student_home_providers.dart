import 'package:edveo/features/student_home/data/models/student_home_model.dart';
import 'package:edveo/features/student_home/data/repositories/student_home_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final studentHomeProvider = FutureProvider.autoDispose<StudentHomeModel>((ref) {
  return ref.read(studentHomeRepositoryProvider).getHomeData();
});

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:edveo/features/students/data/models/create_student_request.dart';
import 'package:edveo/features/students/data/repositories/students_repository.dart';

// ─── State ───────────────────────────────────────────────────────────────────

sealed class CreateStudentState {
  const CreateStudentState();
}

class CreateStudentIdle extends CreateStudentState {
  const CreateStudentIdle();
}

class CreateStudentLoading extends CreateStudentState {
  const CreateStudentLoading();
}

class CreateStudentSuccess extends CreateStudentState {
  const CreateStudentSuccess();
}

class CreateStudentError extends CreateStudentState {
  final String message;
  final String? field; // non-null when error is field-specific (e.g. duplicate email)

  const CreateStudentError({required this.message, this.field});
}

// ─── Notifier ─────────────────────────────────────────────────────────────────

class CreateStudentNotifier extends StateNotifier<CreateStudentState> {
  CreateStudentNotifier(this._repository) : super(const CreateStudentIdle());

  final StudentsRepository _repository;

  Future<void> submit(CreateStudentRequest request) async {
    state = const CreateStudentLoading();
    try {
      await _repository.createStudent(request);
      state = const CreateStudentSuccess();
    } on DioException catch (e) {
      final body = e.response?.data as Map<String, dynamic>?;
      final error = body?['error'] as Map<String, dynamic>?;
      state = CreateStudentError(
        message: error?['message'] as String? ?? 'Something went wrong. Please try again.',
        field: error?['field'] as String?,
      );
    } catch (_) {
      state = const CreateStudentError(
        message: 'Something went wrong. Please try again.',
      );
    }
  }

  void reset() => state = const CreateStudentIdle();
}

// ─── Provider ─────────────────────────────────────────────────────────────────

// autoDispose: state is torn down when the bottom sheet closes so the form
// is clean on the next open rather than showing the previous submission result.
final createStudentProvider =
    StateNotifierProvider.autoDispose<CreateStudentNotifier, CreateStudentState>(
  (ref) => CreateStudentNotifier(ref.read(studentsRepositoryProvider)),
);

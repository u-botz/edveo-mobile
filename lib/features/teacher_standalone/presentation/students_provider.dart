import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:edveo/features/students/data/models/student_model.dart';
import 'package:edveo/features/students/data/repositories/students_repository.dart';

// ─── State ───────────────────────────────────────────────────────────────────

class StudentsState {
  final List<Student> students;
  final StudentsMeta? meta;
  final bool isLoading;      // true only on the very first load
  final bool isLoadingMore;  // true when fetching the next page
  final bool hasError;

  const StudentsState({
    this.students = const [],
    this.meta,
    this.isLoading = false,
    this.isLoadingMore = false,
    this.hasError = false,
  });

  bool get canLoadMore =>
      meta != null && meta!.hasNextPage && !isLoadingMore && !isLoading;

  bool get isEmpty => !isLoading && !hasError && students.isEmpty;

  StudentsState copyWith({
    List<Student>? students,
    StudentsMeta? meta,
    bool? isLoading,
    bool? isLoadingMore,
    bool? hasError,
  }) {
    return StudentsState(
      students: students ?? this.students,
      meta: meta ?? this.meta,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasError: hasError ?? this.hasError,
    );
  }
}

// ─── Notifier ─────────────────────────────────────────────────────────────────

class StudentsNotifier extends StateNotifier<StudentsState> {
  StudentsNotifier(this._repository) : super(const StudentsState()) {
    loadStudents();
  }

  final StudentsRepository _repository;

  // Initial load — clears everything and fetches page 1
  Future<void> loadStudents() async {
    state = state.copyWith(isLoading: true, hasError: false);
    try {
      final response = await _repository.fetchStudents(page: 1);
      state = StudentsState(
        students: response.students,
        meta: response.meta,
        isLoading: false,
      );
    } catch (_) {
      state = state.copyWith(isLoading: false, hasError: true);
    }
  }

  // Pull-to-refresh — same as initial load, replaces the list
  Future<void> refresh() => loadStudents();

  // Pagination — appends next page to the existing list
  Future<void> loadMore() async {
    if (!state.canLoadMore) return;
    final nextPage = (state.meta?.currentPage ?? 1) + 1;
    state = state.copyWith(isLoadingMore: true);
    try {
      final response = await _repository.fetchStudents(page: nextPage);
      state = state.copyWith(
        students: [...state.students, ...response.students],
        meta: response.meta,
        isLoadingMore: false,
      );
    } catch (_) {
      // On pagination failure: keep existing list, just stop the spinner
      state = state.copyWith(isLoadingMore: false);
    }
  }
}

// ─── Provider ─────────────────────────────────────────────────────────────────

final studentsNotifierProvider =
    StateNotifierProvider<StudentsNotifier, StudentsState>((ref) {
  return StudentsNotifier(ref.read(studentsRepositoryProvider));
});

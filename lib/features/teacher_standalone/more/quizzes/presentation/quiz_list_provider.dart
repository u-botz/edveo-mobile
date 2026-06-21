import 'package:edveo/features/quizzes/data/models/quiz_model.dart';
import 'package:edveo/features/quizzes/data/repositories/quiz_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// ── State ─────────────────────────────────────────────────────────────────────

sealed class QuizListState {}

class QuizListLoading extends QuizListState {}

class QuizListFeatureUnavailable extends QuizListState {}

class QuizListError extends QuizListState {
  final String message;
  QuizListError(this.message);
}

class QuizListLoaded extends QuizListState {
  final List<QuizModel> items;
  final int total;
  final int currentPage;
  final int lastPage;
  final bool loadingMore;

  QuizListLoaded({
    required this.items,
    required this.total,
    required this.currentPage,
    required this.lastPage,
    this.loadingMore = false,
  });

  bool get hasMore => currentPage < lastPage;

  QuizListLoaded copyWith({
    List<QuizModel>? items,
    int? total,
    int? currentPage,
    int? lastPage,
    bool? loadingMore,
  }) {
    return QuizListLoaded(
      items:       items ?? this.items,
      total:       total ?? this.total,
      currentPage: currentPage ?? this.currentPage,
      lastPage:    lastPage ?? this.lastPage,
      loadingMore: loadingMore ?? this.loadingMore,
    );
  }
}

// ── Notifier ──────────────────────────────────────────────────────────────────

class QuizListNotifier extends AutoDisposeNotifier<QuizListState> {
  String? _search;
  String? _status;

  @override
  QuizListState build() {
    _load();
    return QuizListLoading();
  }

  Future<void> _load({int page = 1}) async {
    if (page == 1) state = QuizListLoading();

    try {
      final result = await ref.read(quizRepositoryProvider).fetchQuizList(
            search: _search,
            status: _status,
            page: page,
          );

      if (page == 1) {
        state = QuizListLoaded(
          items:       result.items,
          total:       result.total,
          currentPage: result.currentPage,
          lastPage:    result.lastPage,
        );
      } else {
        final current = state as QuizListLoaded;
        state = current.copyWith(
          items:       [...current.items, ...result.items],
          currentPage: result.currentPage,
          lastPage:    result.lastPage,
          loadingMore: false,
        );
      }
    } catch (_) {
      if (page == 1) {
        state = QuizListError('Failed to load quizzes. Pull to refresh.');
      } else {
        // Revert the loading-more spinner on error
        if (state is QuizListLoaded) {
          state = (state as QuizListLoaded).copyWith(loadingMore: false);
        }
      }
    }
  }

  Future<void> refresh() => _load();

  Future<void> loadMore() async {
    final current = state;
    if (current is! QuizListLoaded) return;
    if (!current.hasMore || current.loadingMore) return;

    state = current.copyWith(loadingMore: true);
    await _load(page: current.currentPage + 1);
  }

  void applySearch(String? search) {
    _search = search?.isEmpty == true ? null : search;
    _load();
  }

  void applyStatusFilter(String? status) {
    _status = status;
    _load();
  }
}

final quizListProvider =
    NotifierProvider.autoDispose<QuizListNotifier, QuizListState>(
  QuizListNotifier.new,
);

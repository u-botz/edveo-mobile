import 'package:edveo/features/quizzes/data/models/quiz_analytics_model.dart';
import 'package:edveo/features/quizzes/data/repositories/quiz_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// ── Analytics Summary Provider ─────────────────────────────────────────────────

final quizAnalyticsProvider = AutoDisposeFutureProviderFamily<QuizAnalyticsModel, int>(
  (ref, quizId) {
    return ref.read(quizRepositoryProvider).fetchAnalytics(quizId);
  },
);

// ── Question Breakdown Notifier ───────────────────────────────────────────────

class QuizQuestionsNotifier
    extends AutoDisposeFamilyNotifier<QuizQuestionsState, int> {
  @override
  QuizQuestionsState build(int arg) {
    _load();
    return const QuizQuestionsState(
      questions: [],
      mostMissed: [],
      currentPage: 0,
      lastPage: 1,
      total: 0,
      isLoading: true,
      isLoadingMore: false,
    );
  }

  Future<void> _load({int page = 1}) async {
    if (page == 1) {
      state = const QuizQuestionsState(
        questions: [],
        mostMissed: [],
        currentPage: 0,
        lastPage: 1,
        total: 0,
        isLoading: true,
        isLoadingMore: false,
      );
    }

    try {
      final result = await ref
          .read(quizRepositoryProvider)
          .fetchAnalyticsQuestions(arg, page: page);

      if (page == 1) {
        state = QuizQuestionsState(
          questions:   result.questions,
          mostMissed:  result.mostMissed,
          currentPage: result.currentPage,
          lastPage:    result.lastPage,
          total:       result.total,
          isLoading:   false,
          isLoadingMore: false,
        );
      } else {
        state = state.copyWith(
          questions:     [...state.questions, ...result.questions],
          currentPage:   result.currentPage,
          lastPage:      result.lastPage,
          isLoadingMore: false,
        );
      }
    } catch (_) {
      state = state.copyWith(isLoading: false, isLoadingMore: false, hasError: true);
    }
  }

  Future<void> loadMore() async {
    if (state.isLoadingMore || !state.hasMore) return;
    state = state.copyWith(isLoadingMore: true);
    await _load(page: state.currentPage + 1);
  }
}

class QuizQuestionsState {
  final List<QuizQuestionBreakdown> questions;
  final List<QuizQuestionBreakdown> mostMissed;
  final int currentPage;
  final int lastPage;
  final int total;
  final bool isLoading;
  final bool isLoadingMore;
  final bool hasError;

  const QuizQuestionsState({
    required this.questions,
    required this.mostMissed,
    required this.currentPage,
    required this.lastPage,
    required this.total,
    required this.isLoading,
    required this.isLoadingMore,
    this.hasError = false,
  });

  bool get hasMore => currentPage < lastPage;

  QuizQuestionsState copyWith({
    List<QuizQuestionBreakdown>? questions,
    List<QuizQuestionBreakdown>? mostMissed,
    int? currentPage,
    int? lastPage,
    int? total,
    bool? isLoading,
    bool? isLoadingMore,
    bool? hasError,
  }) {
    return QuizQuestionsState(
      questions:     questions ?? this.questions,
      mostMissed:    mostMissed ?? this.mostMissed,
      currentPage:   currentPage ?? this.currentPage,
      lastPage:      lastPage ?? this.lastPage,
      total:         total ?? this.total,
      isLoading:     isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasError:      hasError ?? this.hasError,
    );
  }
}

final quizQuestionsProvider = NotifierProvider.autoDispose
    .family<QuizQuestionsNotifier, QuizQuestionsState, int>(
  QuizQuestionsNotifier.new,
);

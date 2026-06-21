import 'package:edveo/features/teacher_standalone/more/data/models/more_summary_model.dart';
import 'package:edveo/features/teacher_standalone/more/data/repositories/more_summary_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MoreSummaryNotifier extends AsyncNotifier<MoreSummaryModel?> {
  @override
  Future<MoreSummaryModel?> build() async {
    return ref.read(moreSummaryRepositoryProvider).fetchMoreSummary();
  }

  Future<void> reload() async {
    final cached = state.valueOrNull;
    state = const AsyncValue.loading();
    try {
      final data =
          await ref.read(moreSummaryRepositoryProvider).fetchMoreSummary();
      state = AsyncValue.data(data);
    } catch (_) {
      if (cached != null) {
        state = AsyncValue.data(cached);
      } else {
        state = const AsyncValue.data(null);
      }
    }
  }
}

final moreSummaryProvider =
    AsyncNotifierProvider<MoreSummaryNotifier, MoreSummaryModel?>(
  MoreSummaryNotifier.new,
);

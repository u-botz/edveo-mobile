import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/institution_repository.dart';
import '../../data/models/institution.dart';

/// Holds the current search query string.
final institutionQueryProvider = StateProvider<String>((ref) => '');

/// Performs a debounced search request when the query changes.
/// autoDispose ensures disposal on every query change, which cancels the delay.
final institutionSearchProvider =
    FutureProvider.autoDispose<List<Institution>?>((ref) async {
  final query = ref.watch(institutionQueryProvider).trim();
  if (query.length < 2) return null;

  // Track disposal so we can abort after the delay without hanging.
  var cancelled = false;
  ref.onDispose(() => cancelled = true);

  // 350ms debounce — Future.delayed always resolves (no hang risk).
  await Future.delayed(const Duration(milliseconds: 350));
  if (cancelled) return null;

  return ref.read(institutionRepositoryProvider).search(query);
});

import 'package:dio/dio.dart';
import 'package:edveo/features/blog/data/models/blog_post_model.dart';
import 'package:edveo/features/blog/data/repositories/blog_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// ── State ─────────────────────────────────────────────────────────────────────

sealed class BlogListState {}

class BlogListLoading extends BlogListState {}

class BlogListFeatureUnavailable extends BlogListState {}

class BlogListError extends BlogListState {
  final String message;
  BlogListError(this.message);
}

class BlogListLoaded extends BlogListState {
  final List<BlogPostModel> posts;
  final bool hasMore;
  final int? nextPage;
  final int total;
  final bool isLoadingMore;
  final String? search;
  final String? statusFilter;

  BlogListLoaded({
    required this.posts,
    required this.hasMore,
    this.nextPage,
    required this.total,
    this.isLoadingMore = false,
    this.search,
    this.statusFilter,
  });

  BlogListLoaded copyWith({
    List<BlogPostModel>? posts,
    bool? hasMore,
    int? nextPage,
    int? total,
    bool? isLoadingMore,
    String? search,
    String? statusFilter,
    bool clearNextPage = false,
  }) {
    return BlogListLoaded(
      posts:         posts ?? this.posts,
      hasMore:       hasMore ?? this.hasMore,
      nextPage:      clearNextPage ? null : (nextPage ?? this.nextPage),
      total:         total ?? this.total,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      search:        search ?? this.search,
      statusFilter:  statusFilter ?? this.statusFilter,
    );
  }
}

// ── Notifier ──────────────────────────────────────────────────────────────────

class BlogListNotifier extends AutoDisposeNotifier<BlogListState> {
  @override
  BlogListState build() {
    _load();
    return BlogListLoading();
  }

  Future<void> _load({
    String? search,
    String? statusFilter,
    int page = 1,
  }) async {
    if (page == 1) state = BlogListLoading();

    try {
      final result = await ref.read(blogRepositoryProvider).getBlogList(
            search: search,
            status: statusFilter,
            page: page,
          );

      if (page == 1) {
        state = BlogListLoaded(
          posts:       result.posts,
          hasMore:     result.hasMore,
          nextPage:    result.nextPage,
          total:       result.total,
          search:      search,
          statusFilter: statusFilter,
        );
      } else {
        final current = state;
        if (current is BlogListLoaded) {
          state = current.copyWith(
            posts:         [...current.posts, ...result.posts],
            hasMore:       result.hasMore,
            nextPage:      result.nextPage,
            isLoadingMore: false,
          );
        }
      }
    } on DioException catch (e) {
      if (page > 1) {
        // Revert loading-more spinner on error
        final current = state;
        if (current is BlogListLoaded) {
          state = current.copyWith(isLoadingMore: false);
        }
        return;
      }
      if (e.response?.statusCode == 403) {
        state = BlogListFeatureUnavailable();
        return;
      }
      final message = (e.response?.data as Map<String, dynamic>?)?['error']
              ?['message'] as String? ??
          'Failed to load blog posts.';
      state = BlogListError(message);
    } catch (_) {
      if (page == 1) state = BlogListError('Failed to load blog posts.');
    }
  }

  Future<void> applySearch(String? search) async {
    final current = state;
    final currentFilter = current is BlogListLoaded ? current.statusFilter : null;
    await _load(search: search?.isEmpty == true ? null : search, statusFilter: currentFilter);
  }

  Future<void> applyStatusFilter(String? status) async {
    final current = state;
    final currentSearch = current is BlogListLoaded ? current.search : null;
    await _load(search: currentSearch, statusFilter: status);
  }

  Future<void> loadMore() async {
    final current = state;
    if (current is! BlogListLoaded) return;
    if (!current.hasMore || current.isLoadingMore) return;

    state = current.copyWith(isLoadingMore: true);
    await _load(
      search:       current.search,
      statusFilter: current.statusFilter,
      page:         current.nextPage ?? 2,
    );
  }

  Future<void> refresh() async {
    final current = state;
    final search  = current is BlogListLoaded ? current.search : null;
    final filter  = current is BlogListLoaded ? current.statusFilter : null;
    await _load(search: search, statusFilter: filter);
  }
}

final blogListProvider =
    NotifierProvider.autoDispose<BlogListNotifier, BlogListState>(
  BlogListNotifier.new,
);

import 'package:dio/dio.dart';
import 'package:edveo/features/auth/data/auth_repository.dart';
import 'package:edveo/features/blog/data/models/blog_post_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class BlogRepository {
  final Dio _dio;

  BlogRepository(this._dio);

  /// Fetches a paginated list of the teacher's blog posts (15 per page).
  Future<({List<BlogPostModel> posts, bool hasMore, int? nextPage, int total})>
      getBlogList({
    String? search,
    String? status,
    int page = 1,
  }) async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/api/mobile/standalone-teacher/blog',
      queryParameters: {
        if (search != null && search.isNotEmpty) 'search': search,
        if (status != null) 'status': status,
        'page': page,
      },
    );

    final data = response.data!['data'] as Map<String, dynamic>;
    return (
      posts: (data['posts'] as List<dynamic>)
          .map((e) => BlogPostModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      hasMore:  data['has_more'] as bool,
      nextPage: data['next_page'] as int?,
      total:    data['total'] as int,
    );
  }
}

final blogRepositoryProvider = Provider<BlogRepository>((ref) {
  return BlogRepository(ref.read(apiClientProvider).dio);
});

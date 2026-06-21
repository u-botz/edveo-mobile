/// Shared blog post model — consumed by standalone teacher shell and eventually
/// by student and institutional teacher shells.
///
/// Must NOT be moved inside teacher_standalone/ — Shared Data Law compliance.
class BlogPostModel {
  final int id;
  final String title;
  final String slug;
  final String status;
  final String statusLabel;
  final String? categoryName;
  final DateTime displayDate;
  final int commentsCount;
  final String? thumbnailUrl;

  const BlogPostModel({
    required this.id,
    required this.title,
    required this.slug,
    required this.status,
    required this.statusLabel,
    this.categoryName,
    required this.displayDate,
    required this.commentsCount,
    this.thumbnailUrl,
  });

  /// True when the post is publicly viewable on the tenant website.
  bool get isPublished => status == 'published';

  /// True when the post can be opened in the admin editor.
  bool get isEditable => status == 'draft' || status == 'scheduled';

  factory BlogPostModel.fromJson(Map<String, dynamic> json) {
    return BlogPostModel(
      id:            json['id'] as int,
      title:         json['title'] as String,
      slug:          json['slug'] as String,
      status:        json['status'] as String,
      statusLabel:   json['status_label'] as String,
      categoryName:  json['category_name'] as String?,
      displayDate:   DateTime.parse(json['display_date'] as String),
      commentsCount: json['comments_count'] as int,
      thumbnailUrl:  json['thumbnail_url'] as String?,
    );
  }
}

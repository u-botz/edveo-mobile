import 'package:edveo/features/blog/data/models/blog_post_model.dart';
import 'package:edveo/features/teacher_standalone/more/blog/presentation/widgets/blog_status_badge.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

/// Blog post card displayed in BlogListScreen.
///
/// Thumbnail: 72×72 rounded image via Image.network when thumbnailUrl != null;
/// colour placeholder based on post.id hash when null (BR-BL-010).
///
/// Action buttons (BR-BL-005/006/007):
///   isPublished + hasBlogManage  → "View Live ↗"
///   isEditable  + hasBlogManage  → "Edit ↗"
class BlogPostCard extends StatelessWidget {
  final BlogPostModel post;
  final bool hasBlogManage;
  final String tenantSlug;

  const BlogPostCard({
    super.key,
    required this.post,
    required this.hasBlogManage,
    required this.tenantSlug,
  });

  static const _placeholderColors = [
    Color(0xFF3B82F6),
    Color(0xFF8B5CF6),
    Color(0xFFF59E0B),
    Color(0xFF10B981),
    Color(0xFFEF4444),
    Color(0xFF06B6D4),
    Color(0xFFF97316),
    Color(0xFF6366F1),
  ];

  Color get _placeholderColor =>
      _placeholderColors[post.id % _placeholderColors.length];

  Future<void> _viewLive() async {
    final uri = Uri.parse(
      'https://$tenantSlug.edveo.co/blog/${post.slug}',
    );
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> _edit() async {
    final uri = Uri.parse(
      'https://app.edveo.co/admin/blog/edit/${post.id}',
    );
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final formattedDate =
        DateFormat('dd MMM yyyy').format(post.displayDate.toLocal());

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x06000000),
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Thumbnail
          _Thumbnail(
            thumbnailUrl: post.thumbnailUrl,
            placeholderColor: _placeholderColor,
            initial: post.title.isNotEmpty ? post.title[0].toUpperCase() : '?',
          ),
          const SizedBox(width: 12),

          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Status + category row
                Row(
                  children: [
                    BlogStatusBadge(
                      status: post.status,
                      label: post.statusLabel,
                    ),
                    if (post.categoryName != null) ...[
                      const SizedBox(width: 8),
                      Flexible(
                        child: Text(
                          post.categoryName!,
                          style: const TextStyle(
                            fontSize: 11,
                            color: Color(0xFF9CA3AF),
                            fontWeight: FontWeight.w500,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 6),

                // Title
                Text(
                  post.title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF111827),
                    height: 1.35,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),

                // Date + comments
                Row(
                  children: [
                    Text(
                      formattedDate,
                      style: const TextStyle(
                        fontSize: 11.5,
                        color: Color(0xFF9CA3AF),
                      ),
                    ),
                    const SizedBox(width: 10),
                    const Icon(
                      Icons.chat_bubble_outline_rounded,
                      size: 12,
                      color: Color(0xFF9CA3AF),
                    ),
                    const SizedBox(width: 3),
                    Text(
                      '${post.commentsCount}',
                      style: const TextStyle(
                        fontSize: 11.5,
                        color: Color(0xFF9CA3AF),
                      ),
                    ),
                  ],
                ),

                // Action buttons
                if (hasBlogManage) ...[
                  const SizedBox(height: 10),
                  if (post.isPublished)
                    _ActionButton(
                      label: 'View Live ↗',
                      color: const Color(0xFF059669),
                      onTap: _viewLive,
                    )
                  else if (post.isEditable)
                    _ActionButton(
                      label: 'Edit ↗',
                      color: const Color(0xFF1D4ED8),
                      onTap: _edit,
                    ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Thumbnail extends StatelessWidget {
  final String? thumbnailUrl;
  final Color placeholderColor;
  final String initial;

  const _Thumbnail({
    required this.thumbnailUrl,
    required this.placeholderColor,
    required this.initial,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: thumbnailUrl != null && thumbnailUrl!.isNotEmpty
          ? Image.network(
              thumbnailUrl!,
              width: 72,
              height: 72,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => _placeholder(),
              loadingBuilder: (_, child, progress) =>
                  progress == null ? child : _placeholder(),
            )
          : _placeholder(),
    );
  }

  Widget _placeholder() {
    return Container(
      width: 72,
      height: 72,
      color: placeholderColor,
      alignment: Alignment.center,
      child: Text(
        initial,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 26,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ActionButton({
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
      ),
    );
  }
}

import 'dart:async';

import 'package:edveo/features/auth/presentation/me_providers.dart';
import 'package:edveo/features/teacher_standalone/more/blog/presentation/blog_list_provider.dart';
import 'package:edveo/features/teacher_standalone/more/blog/presentation/widgets/blog_post_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

class BlogListScreen extends ConsumerStatefulWidget {
  const BlogListScreen({super.key});

  @override
  ConsumerState<BlogListScreen> createState() => _BlogListScreenState();
}

class _BlogListScreenState extends ConsumerState<BlogListScreen> {
  final _searchController = TextEditingController();
  final _scrollController = ScrollController();
  Timer? _debounce;
  String? _selectedStatus;

  static const _statusFilters = <({String? value, String label})>[
    (value: null,          label: 'All'),
    (value: 'published',   label: 'Published'),
    (value: 'scheduled',   label: 'Scheduled'),
    (value: 'draft',       label: 'Draft'),
  ];

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final state = ref.read(blogListProvider);
    if (state is! BlogListLoaded) return;
    if (!state.hasMore || state.isLoadingMore) return;

    // Trigger load-more when within 200 px of the bottom (≈ 3 items)
    final nearEnd = _scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200;
    if (nearEnd) {
      ref.read(blogListProvider.notifier).loadMore();
    }
  }

  void _onSearchChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () {
      ref.read(blogListProvider.notifier).applySearch(value);
    });
  }

  void _setStatus(String? status) {
    setState(() => _selectedStatus = status);
    ref.read(blogListProvider.notifier).applyStatusFilter(status);
  }

  Future<void> _openCreateBlog() async {
    final uri = Uri.parse('https://app.edveo.co/admin/blog/new');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final me           = ref.watch(currentMeProvider);
    final hasBlogManage = me?.hasCapability('blog.manage') ?? false;
    final tenantSlug   = me?.tenant.slug ?? '';
    final state        = ref.watch(blogListProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Blog',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w800,
            color: Color(0xFF111827),
          ),
        ),
        actions: [
          if (hasBlogManage)
            IconButton(
              icon: const Icon(Icons.add_rounded, color: Color(0xFF1D4ED8)),
              tooltip: 'Create Blog',
              onPressed: _openCreateBlog,
            ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: const Color(0xFFE5E7EB)),
        ),
      ),
      body: Column(
        children: [
          // Search field
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: TextField(
              controller: _searchController,
              onChanged: _onSearchChanged,
              style: const TextStyle(fontSize: 14),
              decoration: InputDecoration(
                hintText: 'Search posts…',
                hintStyle: const TextStyle(color: Color(0xFF9CA3AF)),
                prefixIcon: const Icon(
                  Icons.search_rounded,
                  size: 20,
                  color: Color(0xFF9CA3AF),
                ),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(vertical: 10),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(
                    color: Color(0xFF1D4ED8),
                    width: 1.5,
                  ),
                ),
              ),
            ),
          ),

          // Status filter chips
          SizedBox(
            height: 44,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              children: _statusFilters.map((f) {
                final isSelected = _selectedStatus == f.value;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(f.label),
                    selected: isSelected,
                    onSelected: (_) => _setStatus(f.value),
                    selectedColor: const Color(0xFF1D4ED8),
                    labelStyle: TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
                      color: isSelected
                          ? Colors.white
                          : const Color(0xFF374151),
                    ),
                    backgroundColor: Colors.white,
                    side: BorderSide(
                      color: isSelected
                          ? const Color(0xFF1D4ED8)
                          : const Color(0xFFE5E7EB),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                  ),
                );
              }).toList(),
            ),
          ),

          // Content
          Expanded(
            child: switch (state) {
              BlogListLoading() =>
                const Center(child: CircularProgressIndicator()),
              BlogListFeatureUnavailable() => const Center(
                  child: Padding(
                    padding: EdgeInsets.all(24),
                    child: Text(
                      'Blog is not available on your current plan.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Color(0xFF6B7280), fontSize: 15),
                    ),
                  ),
                ),
              BlogListError(:final message) => Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        message,
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Color(0xFF6B7280)),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () =>
                            ref.read(blogListProvider.notifier).refresh(),
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                ),
              BlogListLoaded() => _buildList(
                  state,
                  hasBlogManage: hasBlogManage,
                  tenantSlug: tenantSlug,
                ),
            },
          ),
        ],
      ),
    );
  }

  Widget _buildList(
    BlogListLoaded state, {
    required bool hasBlogManage,
    required String tenantSlug,
  }) {
    if (state.posts.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.article_outlined,
                size: 48,
                color: Color(0xFFD1D5DB),
              ),
              const SizedBox(height: 12),
              const Text(
                'No blog posts yet.',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF374151),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                _searchController.text.isNotEmpty ||
                        _selectedStatus != null
                    ? 'No posts match your search.'
                    : hasBlogManage
                        ? "Tap '+' to write your first post."
                        : '',
                style: const TextStyle(
                  fontSize: 13,
                  color: Color(0xFF9CA3AF),
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => ref.read(blogListProvider.notifier).refresh(),
      child: ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.only(top: 4, bottom: 100),
        // +1 for count label header, +1 for possible bottom loading indicator
        itemCount: state.posts.length + 1 + (state.isLoadingMore ? 1 : 0),
        itemBuilder: (context, index) {
          // Count header
          if (index == 0) {
            return Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
              child: Text(
                '${state.total} posts',
                style: const TextStyle(
                  fontSize: 12,
                  color: Color(0xFF9CA3AF),
                  fontWeight: FontWeight.w500,
                ),
              ),
            );
          }

          final postIndex = index - 1;

          // Bottom spinner
          if (postIndex >= state.posts.length) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            );
          }

          return BlogPostCard(
            post: state.posts[postIndex],
            hasBlogManage: hasBlogManage,
            tenantSlug: tenantSlug,
          );
        },
      ),
    );
  }
}

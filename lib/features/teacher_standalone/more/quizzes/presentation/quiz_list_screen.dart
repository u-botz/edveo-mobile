import 'dart:async';

import 'package:edveo/features/teacher_standalone/more/quizzes/presentation/quiz_analytics_screen.dart';
import 'package:edveo/features/teacher_standalone/more/quizzes/presentation/quiz_list_provider.dart';
import 'package:edveo/features/teacher_standalone/more/quizzes/presentation/widgets/quiz_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

class QuizListScreen extends ConsumerStatefulWidget {
  const QuizListScreen({super.key});

  @override
  ConsumerState<QuizListScreen> createState() => _QuizListScreenState();
}

class _QuizListScreenState extends ConsumerState<QuizListScreen> {
  final _searchController = TextEditingController();
  Timer? _debounce;
  String? _selectedStatus;
  final _scrollController = ScrollController();

  static const _statusFilters = <({String? value, String label})>[
    (value: null,       label: 'All'),
    (value: 'active',   label: 'Live'),
    (value: 'draft',    label: 'Draft'),
    (value: 'inactive', label: 'Paused'),
    (value: 'closed',   label: 'Closed'),
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
    final nearEnd = _scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200;
    if (nearEnd) {
      ref.read(quizListProvider.notifier).loadMore();
    }
  }

  void _onSearchChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () {
      ref.read(quizListProvider.notifier).applySearch(value);
    });
  }

  void _setStatus(String? status) {
    setState(() => _selectedStatus = status);
    ref.read(quizListProvider.notifier).applyStatusFilter(status);
  }

  Future<void> _openCreateQuiz() async {
    const url = 'https://app.edveo.co/quiz/create';
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  void _openAnalytics(int quizId, String title) {
    Navigator.of(context).push(MaterialPageRoute<void>(
      builder: (_) => QuizAnalyticsScreen(quizId: quizId, quizTitle: title),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(quizListProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        titleSpacing: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Quizzes',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w800,
            color: Color(0xFF111827),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_rounded, color: Color(0xFF1D4ED8)),
            tooltip: 'Create Quiz',
            onPressed: _openCreateQuiz,
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
                hintText: 'Search quizzes…',
                hintStyle: const TextStyle(color: Color(0xFF9CA3AF)),
                prefixIcon: const Icon(Icons.search_rounded, size: 20, color: Color(0xFF9CA3AF)),
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
                  borderSide: const BorderSide(color: Color(0xFF1D4ED8), width: 1.5),
                ),
              ),
            ),
          ),

          // Status filter chips
          SizedBox(
            height: 44,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              children: _statusFilters.map((filter) {
                final isSelected = _selectedStatus == filter.value;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(filter.label),
                    selected: isSelected,
                    onSelected: (_) => _setStatus(filter.value),
                    selectedColor: const Color(0xFF1D4ED8),
                    labelStyle: TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
                      color: isSelected ? Colors.white : const Color(0xFF374151),
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
              QuizListLoading() => const Center(child: CircularProgressIndicator()),
              QuizListFeatureUnavailable() => const Center(
                  child: Text('Quiz feature is not available.'),
                ),
              QuizListError(:final message) => Center(
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
                            ref.read(quizListProvider.notifier).refresh(),
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                ),
              QuizListLoaded() => _buildList(state),
            },
          ),
        ],
      ),
    );
  }

  Widget _buildList(QuizListLoaded state) {
    if (state.items.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.quiz_outlined, size: 48, color: Color(0xFFD1D5DB)),
            const SizedBox(height: 12),
            const Text(
              'No quizzes found',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFF374151),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              _searchController.text.isNotEmpty || _selectedStatus != null
                  ? 'Try adjusting your filters.'
                  : 'Create your first quiz on the web dashboard.',
              style: const TextStyle(fontSize: 13, color: Color(0xFF9CA3AF)),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => ref.read(quizListProvider.notifier).refresh(),
      child: ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.only(top: 8, bottom: 100),
        itemCount: state.items.length + (state.loadingMore ? 1 : 0) + 1, // +1 for header
        itemBuilder: (context, index) {
          if (index == 0) {
            return Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
              child: Text(
                '${state.total} quizzes',
                style: const TextStyle(
                  fontSize: 12,
                  color: Color(0xFF9CA3AF),
                  fontWeight: FontWeight.w500,
                ),
              ),
            );
          }

          final itemIndex = index - 1;
          if (itemIndex >= state.items.length) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            );
          }

          final quiz = state.items[itemIndex];
          return QuizCard(
            quiz: quiz,
            onTap: () => _openAnalytics(quiz.id, quiz.title),
          );
        },
      ),
    );
  }
}

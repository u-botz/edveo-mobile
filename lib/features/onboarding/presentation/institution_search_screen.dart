import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/edveo_colors.dart';
import '../../../core/theme/edveo_typography.dart';
import '../../../core/storage/token_storage.dart';
import '../../../core/widgets/edveo_brand_header.dart';
import '../../../core/widgets/edveo_search_field.dart';
import '../data/models/institution.dart';
import 'providers/institution_search_providers.dart';
import 'widgets/institution_list_tile.dart';

class InstitutionSearchScreen extends ConsumerStatefulWidget {
  const InstitutionSearchScreen({super.key});

  @override
  ConsumerState<InstitutionSearchScreen> createState() =>
      _InstitutionSearchScreenState();
}

class _InstitutionSearchScreenState
    extends ConsumerState<InstitutionSearchScreen> {
  void _onQueryChanged(String value) {
    ref.read(institutionQueryProvider.notifier).state = value;
  }

  void _onInstitutionTapped(Institution institution) async {
    await TokenStorage.saveTenantSlug(institution.slug);
    if (mounted) {
      context.go('/login', extra: institution.slug);
    }
  }

  Widget _buildResultsSection(AsyncValue<List<Institution>?> searchAsync, bool isIdle) {
    if (isIdle) {
      return const SizedBox.shrink();
    }

    return searchAsync.when(
      data: (results) {
        if (results == null) return const SizedBox.shrink();
        
        if (results.isEmpty) {
          return Center(
            child: Semantics(
              label: 'No institutions found, try a different search',
              child: Column(
                children: [
                  const SizedBox(height: 32),
                  const Icon(
                    Icons.search_off_rounded,
                    size: 48,
                    color: EdveoColors.textFaint,
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'No institutions found',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: EdveoColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Try a different name',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      color: EdveoColors.textFaint,
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'RESULTS · ${results.length}',
              style: EdveoTypography.sectionEyebrow.copyWith(
                letterSpacing: 1.0,
              ),
            ),
            const SizedBox(height: 12),
            ...results.map((inst) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0.0, end: 1.0),
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeOut,
                  builder: (context, value, child) {
                    return Opacity(
                      opacity: value,
                      child: child,
                    );
                  },
                  child: InstitutionListTile(
                    institution: inst,
                    onTap: () => _onInstitutionTapped(inst),
                  ),
                ),
              );
            }),
          ],
        );
      },
      loading: () => const Center(
        child: Padding(
          padding: EdgeInsets.only(top: 32),
          child: SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: EdveoColors.accentGreen,
            ),
          ),
        ),
      ),
      error: (_, __) => const Center(
        child: Padding(
          padding: EdgeInsets.only(top: 32),
          child: Text(
            'Search unavailable. Please check your connection and try again.',
            style: TextStyle(color: EdveoColors.textSecondary),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final query = ref.watch(institutionQueryProvider);
    final searchAsync = ref.watch(institutionSearchProvider);
    final isIdle = query.trim().length < 2;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: EdveoColors.surface,
        body: SafeArea(
          child: Column(
            children: [
              // 1. Brand header
              const EdveoBrandHeader(),

              // 2. Page content (scrollable)
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 8),

                      // Headline
                      Text(
                        'Find your institution',
                        style: EdveoTypography.screenH1,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Search by name to get started',
                        style: EdveoTypography.screenSub,
                      ),
                      const SizedBox(height: 20),

                      // Search field
                      EdveoSearchField(
                        onChanged: _onQueryChanged,
                      ),
                      const SizedBox(height: 24),

                      // Results section
                      _buildResultsSection(searchAsync, isIdle),
                      const SizedBox(height: 32), // Bottom padding
                    ],
                  ),
                ),
              ),

              // 3. Footer
              const _Footer(),
            ],
          ),
        ),
      ),
    );
  }
}

class _Footer extends StatelessWidget {
  const _Footer();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24, left: 24, right: 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'New institute? ',
            style: EdveoTypography.footerText,
          ),
          GestureDetector(
            onTap: () {
              // TODO: Route to M2 registration flow
            },
            behavior: HitTestBehavior.opaque,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Get started',
                  style: EdveoTypography.footerLink,
                ),
                const SizedBox(width: 4),
                const Icon(
                  Icons.arrow_forward_rounded,
                  size: 14,
                  color: EdveoColors.textLink,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
import 'package:edveo/core/theme/edveo_colors.dart';
import 'package:flutter/foundation.dart';
import 'package:edveo/features/auth/presentation/me_providers.dart';
import 'package:edveo/features/student_home/data/providers/student_home_providers.dart';
import 'package:edveo/features/student_home/presentation/widgets/continue_learning_section.dart';
import 'package:edveo/features/student_home/presentation/widgets/home_top_bar.dart';
import 'package:edveo/features/student_home/presentation/widgets/next_class_card.dart';
import 'package:edveo/features/student_home/presentation/widgets/recent_notice_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class StudentHomeScreen extends ConsumerStatefulWidget {
  const StudentHomeScreen({super.key});

  @override
  ConsumerState<StudentHomeScreen> createState() => _StudentHomeScreenState();
}

class _StudentHomeScreenState extends ConsumerState<StudentHomeScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulseCtrl;

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final me = ref.watch(currentMeProvider);
    final homeAsync = ref.watch(studentHomeProvider);

    // BR-STU-HOME-013: deterministic avatar colour from me.id
    final avatarColor =
        me != null ? EdveoColors.tintForSlug(me.id) : const Color(0xFF1D4ED8);

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      body: Column(
        children: [
          HomeTopBar(
            displayName: me?.displayName ?? 'Student',
            initials: me?.initials ?? 'S',
            avatarColor: avatarColor,
          ),
          Container(height: 1, color: const Color(0xFFE5E7EB)),
          Expanded(
            child: homeAsync.when(
              loading: () => _buildSkeleton(),
              error: (err, stack) {
                debugPrint('[STUDENT_HOME] error: $err\n$stack');
                return _buildError();
              },
              data: (home) {
                final isEmpty = home.nextLiveSession == null &&
                    home.continueLearning.isEmpty &&
                    home.recentNotice == null;

                if (isEmpty) return _buildEmpty();

                return RefreshIndicator(
                  color: const Color(0xFF16A34A),
                  onRefresh: () => ref.refresh(studentHomeProvider.future),
                  child: CustomScrollView(
                    slivers: [
                      if (home.nextLiveSession != null)
                        SliverToBoxAdapter(
                          child: Padding(
                            padding: const EdgeInsets.only(top: 20),
                            child: NextClassCard(session: home.nextLiveSession!),
                          ),
                        ),

                      if (home.continueLearning.isNotEmpty)
                        SliverToBoxAdapter(
                          child: ContinueLearningSection(items: home.continueLearning),
                        ),

                      if (home.recentNotice != null) ...[
                        SliverToBoxAdapter(
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(16, 20, 16, 12),
                            child: Row(
                              children: [
                                const Expanded(
                                  child: Text(
                                    'Recent Notice',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w800,
                                      color: Color(0xFF111827),
                                    ),
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () {},
                                  child: const Text(
                                    'All notices',
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF16A34A),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        SliverToBoxAdapter(
                          child: RecentNoticeCard(notice: home.recentNotice!),
                        ),
                      ],

                      const SliverToBoxAdapter(child: SizedBox(height: 100)),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSkeleton() {
    return AnimatedBuilder(
      animation: _pulseCtrl,
      builder: (context, _) {
        final opacity = 0.4 + _pulseCtrl.value * 0.4;
        return Opacity(
          opacity: opacity,
          child: ListView(
            padding: const EdgeInsets.only(top: 20, bottom: 100),
            physics: const NeverScrollableScrollPhysics(),
            children: [
              // Next class skeleton
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
                child: Container(
                  height: 140,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE5E7EB),
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              // Continue learning label
              const Padding(
                padding: EdgeInsets.fromLTRB(16, 0, 16, 12),
                child: _SkeletonLine(width: 140, height: 16),
              ),
              SizedBox(
                height: 202,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: 3,
                  separatorBuilder: (_, __) => const SizedBox(width: 12),
                  itemBuilder: (_, __) => Container(
                    width: 168,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE5E7EB),
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildEmpty() {
    return RefreshIndicator(
      color: const Color(0xFF16A34A),
      onRefresh: () => ref.refresh(studentHomeProvider.future),
      child: ListView(
        children: [
          SizedBox(height: MediaQuery.of(context).size.height * 0.18),
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: const BoxDecoration(
                    color: Color(0xFFF0FDF4),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.school_rounded,
                    size: 40,
                    color: Color(0xFF16A34A),
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Nothing here yet',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF111827),
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Enroll in a course to see your\nlearning journey here.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: Color(0xFF6B7280),
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 24),
                GestureDetector(
                  onTap: () {
                    // Pull-to-refresh as the primary action since tab switching
                    // requires a parent-level tab controller.
                    ref.refresh(studentHomeProvider);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 13,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF16A34A),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'Refresh',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildError() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.wifi_off_outlined,
            size: 48,
            color: Colors.grey,
          ),
          const SizedBox(height: 16),
          const Text(
            'Could not load your dashboard',
            style: TextStyle(color: Color(0xFF6B7280)),
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: () => ref.refresh(studentHomeProvider),
            child: const Text('Try again'),
          ),
        ],
      ),
    );
  }
}

class _SkeletonLine extends StatelessWidget {
  final double width;
  final double height;

  const _SkeletonLine({required this.width, required this.height});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: const Color(0xFFE5E7EB),
        borderRadius: BorderRadius.circular(6),
      ),
    );
  }
}

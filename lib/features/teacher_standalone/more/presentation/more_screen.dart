import 'package:edveo/features/auth/data/models/me_model.dart';
import 'package:edveo/features/teacher_standalone/more/presentation/file_manager_screen.dart';
import 'package:edveo/features/teacher_standalone/more/quizzes/presentation/quiz_list_screen.dart';
import 'package:edveo/core/storage/token_storage.dart';
import 'package:edveo/features/auth/data/auth_repository.dart';
import 'package:edveo/features/auth/presentation/me_providers.dart';
import 'package:edveo/features/teacher_standalone/more/data/models/more_summary_model.dart';
import 'package:edveo/features/teacher_standalone/more/presentation/change_password_screen.dart';
import 'package:edveo/features/teacher_standalone/more/presentation/notification_preferences_screen.dart';
import 'package:edveo/features/teacher_standalone/more/presentation/placeholder_route_screen.dart';
import 'package:edveo/features/teacher_standalone/more/presentation/providers/more_providers.dart';
import 'package:edveo/features/teacher_standalone/more/presentation/utils/more_formatters.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

// ── Tokens ────────────────────────────────────────────────────────────────────
class _C {
  static const primary = Color(0xFF1D4ED8);
  static const primarySoft = Color(0x141D4ED8);
  static const green = Color(0xFF059669);
  static const greenText = Color(0xFF047857);
  static const red = Color(0xFFDC2626);
  static const bg = Color(0xFFF9FAFB);
  static const surf = Color(0xFFFFFFFF);
  static const border = Color(0xFFE5E7EB);
  static const borderS = Color(0xFFF3F4F6);
  static const text = Color(0xFF111827);
  static const muted = Color(0xFF6B7280);

  static const proBg = Color(0xFFF5F3FF);
  static const proBorder = Color(0xFFDDD6FE);
  static const proIconBg = Color(0xFFEDE9FE);
  static const proFg = Color(0xFF6D28D9);

  static const tileBlue = (Color(0xFFDBEAFE), Color(0xFF1D4ED8));
  static const tilePurple = (Color(0xFFEDE9FE), Color(0xFF7C3AED));
  static const tileGreen = (Color(0xFFD1FAE5), Color(0xFF059669));
  static const tileAmber = (Color(0xFFFEF3C7), Color(0xFFD97706));
  static const tileNeutral = (Color(0xFFF3F4F6), Color(0xFF111827));
}

TextStyle _pjs({
  double size = 14,
  FontWeight weight = FontWeight.w400,
  Color color = _C.text,
  double ls = 0,
}) =>
    GoogleFonts.plusJakartaSans(
      fontSize: size,
      fontWeight: weight,
      color: color,
      letterSpacing: ls,
    );

// ── Screen ────────────────────────────────────────────────────────────────────
class StandaloneMoreScreen extends ConsumerStatefulWidget {
  const StandaloneMoreScreen({super.key});

  @override
  ConsumerState<StandaloneMoreScreen> createState() =>
      _StandaloneMoreScreenState();
}

class _StandaloneMoreScreenState extends ConsumerState<StandaloneMoreScreen> {
  bool _loggingOut = false;

  Future<void> _logout() async {
    if (_loggingOut) return;
    setState(() => _loggingOut = true);

    try {
      await ref.read(authRepositoryProvider).mobileLogout();
    } catch (_) {
      // Always clear local session even when the API call fails.
    }

    ref.read(currentMeProvider.notifier).state = null;
    await TokenStorage.clearSession();
    if (!mounted) return;
    context.go('/');
  }

  void _push(Widget screen) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => screen),
    );
  }

  Future<void> _openBilling() async {
    final uri = Uri.parse('https://edveo.co/billing');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final me = ref.watch(currentMeProvider);
    final summaryAsync = ref.watch(moreSummaryProvider);
    final isLoadingSummary = summaryAsync.isLoading;
    final summary = summaryAsync.when(
      data: (data) => data,
      loading: () => summaryAsync.valueOrNull,
      error: (_, __) => summaryAsync.valueOrNull,
    );

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: _C.bg,
        body: SafeArea(
          bottom: false,
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(18, 14, 18, 12),
                  child: Text(
                    'More',
                    style: _pjs(size: 22, weight: FontWeight.w800, ls: -0.4),
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: _IdentityHeader(
                  me: me,
                  planLabel: summary?.planLabel,
                  planLoading: isLoadingSummary,
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 16)),
              const SliverToBoxAdapter(child: _SectionLabel('STORAGE')),
              SliverToBoxAdapter(
                child: _CardGroup(
                  children: [
                    _MoreRow(
                      icon: Icons.folder_rounded,
                      label: 'File Manager',
                      tileColors: _C.tileBlue,
                      isLast: true,
                      onTap: () => _push(const FileManagerScreen()),
                    ),
                  ],
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 16)),
              const SliverToBoxAdapter(child: _SectionLabel('CREATE')),
              SliverToBoxAdapter(
                child: _CardGroup(
                  children: [
                    _MoreRow(
                      icon: Icons.smart_toy_rounded,
                      label: 'AI Agent',
                      tileColors: _C.tileAmber,
                      onTap: () => _push(
                        const PlaceholderRouteScreen(title: 'AI Agent'),
                      ),
                      trailing: _badgeTrailing(
                        isLoadingSummary,
                        summary,
                        (s) => '${s.aiCreditsRemaining} credits left',
                      ),
                    ),
                    _MoreRow(
                      icon: Icons.auto_awesome_rounded,
                      label: 'Edveo Studio',
                      tileColors: _C.tilePurple,
                      onTap: () => _push(
                        const PlaceholderRouteScreen(title: 'Edveo Studio'),
                      ),
                    ),
                    _MoreRow(
                      icon: Icons.article_rounded,
                      label: 'Blog',
                      tileColors: _C.tileBlue,
                      onTap: () => context.push('/standalone/more/blog'),
                      trailing: _badgeTrailing(
                        isLoadingSummary,
                        summary,
                        (s) => '${s.blogPublishedCount} published',
                      ),
                    ),
                    _MoreRow(
                      icon: Icons.quiz_rounded,
                      label: 'Quizzes',
                      tileColors: _C.tilePurple,
                      isLast: true,
                      onTap: () => _push(const QuizListScreen()),
                    ),
                  ],
                ),
              ),
              if (summary?.showUpgradeBanner == true) ...[
                const SliverToBoxAdapter(child: SizedBox(height: 16)),
                SliverToBoxAdapter(
                  child: _UpgradeBanner(onTap: _openBilling),
                ),
              ],
              const SliverToBoxAdapter(child: SizedBox(height: 16)),
              const SliverToBoxAdapter(child: _SectionLabel('BUSINESS')),
              SliverToBoxAdapter(
                child: _CardGroup(
                  children: [
                    _MoreRow(
                      icon: Icons.payments_rounded,
                      label: 'Earnings',
                      tileColors: _C.tileGreen,
                      onTap: () => _push(
                        const PlaceholderRouteScreen(title: 'Earnings'),
                      ),
                      trailing: _earningsTrailing(isLoadingSummary, summary),
                    ),
                    _MoreRow(
                      icon: Icons.local_offer_rounded,
                      label: 'Discount Codes & Coupons',
                      tileColors: _C.tileBlue,
                      onTap: () => _push(
                        const PlaceholderRouteScreen(
                          title: 'Discount Codes & Coupons',
                        ),
                      ),
                    ),
                    _MoreRow(
                      icon: Icons.video_camera_front_rounded,
                      label: '1-on-1 Meetings',
                      tileColors: _C.tileBlue,
                      isLast: true,
                      onTap: () => _push(
                        const PlaceholderRouteScreen(title: '1-on-1 Meetings'),
                      ),
                      trailing: _badgeTrailing(
                        isLoadingSummary,
                        summary,
                        (s) => '${s.meetingsBookedToday} booked today',
                      ),
                    ),
                  ],
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 24)),
              const SliverToBoxAdapter(child: _SectionLabel('SETTINGS')),
              SliverToBoxAdapter(
                child: _CardGroup(
                  children: [
                    _MoreRow(
                      icon: Icons.person_rounded,
                      label: 'Profile',
                      tileColors: _C.tileNeutral,
                      onTap: () => _push(
                        const PlaceholderRouteScreen(title: 'Profile'),
                      ),
                    ),
                    _MoreRow(
                      icon: Icons.lock_rounded,
                      label: 'Password',
                      tileColors: _C.tileNeutral,
                      onTap: () => _push(const ChangePasswordScreen()),
                    ),
                    _MoreRow(
                      icon: Icons.notifications_rounded,
                      label: 'Notifications',
                      tileColors: _C.tileNeutral,
                      isLast: true,
                      onTap: () => _push(
                        const NotificationPreferencesScreen(),
                      ),
                    ),
                  ],
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 24)),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: GestureDetector(
                    onTap: _loggingOut ? null : _logout,
                    behavior: HitTestBehavior.opaque,
                    child: Container(
                      height: 52,
                      decoration: BoxDecoration(
                        color: _C.surf,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: _C.border),
                      ),
                      child: Center(
                        child: _loggingOut
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : Text(
                                'Log Out',
                                style: _pjs(
                                  size: 14,
                                  weight: FontWeight.w700,
                                  color: _C.red,
                                ),
                              ),
                      ),
                    ),
                  ),
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 100)),
            ],
          ),
        ),
      ),
    );
  }
}

Widget _earningsTrailing(bool loading, MoreSummaryModel? summary) {
  if (loading) return const _BadgeSkeleton(width: 100);
  final text = summary == null
      ? '—'
      : formatMonthlyEarnings(summary.monthlyEarningsCents);
  return Text(
    text,
    style: _pjs(size: 11.5, weight: FontWeight.w800, color: _C.green),
  );
}

Widget? _badgeTrailing(
  bool loading,
  MoreSummaryModel? summary,
  String Function(MoreSummaryModel) formatter,
) {
  if (loading) return const _BadgeSkeleton();
  if (summary == null) {
    return Text('—', style: _pjs(size: 11.5, weight: FontWeight.w700));
  }
  return Text(
    formatter(summary),
    style: _pjs(size: 11.5, weight: FontWeight.w700, color: _C.greenText),
  );
}

// ── Profile header ────────────────────────────────────────────────────────────

class _IdentityHeader extends StatelessWidget {
  final MeModel? me;
  final String? planLabel;
  final bool planLoading;

  const _IdentityHeader({
    required this.me,
    required this.planLabel,
    required this.planLoading,
  });

  @override
  Widget build(BuildContext context) {
    final name = me?.displayName ?? '—';
    final initials = me?.initials ?? '?';
    final institutionName = me?.tenant.name.trim() ?? '';
    final institution =
        institutionName.isNotEmpty ? institutionName : '—';

    return Container(
      padding: const EdgeInsets.fromLTRB(18, 12, 18, 24),
      decoration: const BoxDecoration(
        color: _C.surf,
        border: Border(bottom: BorderSide(color: _C.border)),
      ),
      child: Row(
        children: [
          Container(
            width: 62,
            height: 62,
            decoration: const BoxDecoration(
              color: _C.primary,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Color(0x331D4ED8),
                  blurRadius: 14,
                  offset: Offset(0, 6),
                ),
              ],
            ),
            child: Center(
              child: Text(
                initials,
                style: _pjs(size: 20, weight: FontWeight.w800, color: Colors.white),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        name,
                        style: _pjs(size: 18, weight: FontWeight.w800, ls: -0.3),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    if (planLoading)
                      const _BadgeSkeleton(width: 72)
                    else if (planLabel != null)
                      _Chip(label: planLabel!, variant: _ChipVariant.brand),
                  ],
                ),
                const SizedBox(height: 4),
                Text(institution, style: _pjs(size: 13, color: _C.muted)),
                const SizedBox(height: 6),
                Text(
                  'Edit Profile →',
                  style: _pjs(size: 13, weight: FontWeight.w600, color: _C.primary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _BadgeSkeleton extends StatelessWidget {
  final double width;

  const _BadgeSkeleton({this.width = 56});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: 18,
      decoration: BoxDecoration(
        color: _C.borderS,
        borderRadius: BorderRadius.circular(99),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel(this.label);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 8),
      child: Text(
        label,
        style: _pjs(size: 11, weight: FontWeight.w700, ls: 1.2, color: _C.muted),
      ),
    );
  }
}

class _CardGroup extends StatelessWidget {
  final List<Widget> children;
  const _CardGroup({required this.children});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        decoration: BoxDecoration(
          color: _C.surf,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: _C.border),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(children: children),
      ),
    );
  }
}

class _MoreRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final (Color, Color)? tileColors;
  final bool isLast;
  final Widget? trailing;
  final VoidCallback? onTap;

  const _MoreRow({
    required this.icon,
    required this.label,
    this.tileColors,
    this.isLast = false,
    this.trailing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = tileColors ?? _C.tileNeutral;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        constraints: const BoxConstraints(minHeight: 52),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          border: isLast
              ? null
              : const Border(bottom: BorderSide(color: _C.borderS)),
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: colors.$1,
                borderRadius: BorderRadius.circular(9),
              ),
              child: Icon(icon, size: 18, color: colors.$2),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: _pjs(size: 14, weight: FontWeight.w600, ls: -0.1),
              ),
            ),
            if (trailing != null) ...[
              const SizedBox(width: 8),
              trailing!,
            ],
            const SizedBox(width: 12),
            const Icon(Icons.chevron_right_rounded, size: 18, color: Color(0xFFC7CDD6)),
          ],
        ),
      ),
    );
  }
}

enum _ChipVariant { brand }

class _Chip extends StatelessWidget {
  final String label;
  final _ChipVariant variant;

  const _Chip({required this.label, this.variant = _ChipVariant.brand});

  @override
  Widget build(BuildContext context) {
    final (bg, fg) = switch (variant) {
      _ChipVariant.brand => (_C.primarySoft, _C.primary),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(99),
      ),
      child: Text(
        label,
        style: _pjs(size: 10.5, weight: FontWeight.w700, ls: 0.2, color: fg),
      ),
    );
  }
}

class _UpgradeBanner extends StatelessWidget {
  final VoidCallback onTap;

  const _UpgradeBanner({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          decoration: BoxDecoration(
            color: _C.proBg,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: _C.proBorder),
          ),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: _C.proIconBg,
                  borderRadius: BorderRadius.circular(9),
                ),
                child: const Icon(
                  Icons.rocket_launch_rounded,
                  size: 18,
                  color: _C.proFg,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Unlock Pro features — Student analytics, white label, custom domain',
                  style: _pjs(size: 12.5, weight: FontWeight.w600),
                ),
              ),
              const Icon(Icons.chevron_right_rounded, color: _C.proFg),
            ],
          ),
        ),
      ),
    );
  }
}

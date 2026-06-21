import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/auth/session_manager.dart';
import '../../../core/storage/token_storage.dart';
import '../data/auth_repository.dart';
import '../data/branding_repository.dart';
import 'me_providers.dart';
import '../../../core/models/tenant_branding.dart';
import 'widgets/institution_avatar.dart';

// ── Color helpers ─────────────────────────────────────────────────────────────

Color _parseHex(String hex) {
  final cleaned = hex.replaceFirst('#', '');
  final value = int.tryParse(
    cleaned.length == 6 ? 'FF$cleaned' : cleaned,
    radix: 16,
  );
  return value != null ? Color(value) : const Color(0xFF2563EB);
}

// ── Providers ─────────────────────────────────────────────────────────────────

/// Cached branding loaded once at role-router mount.
/// Do NOT re-fetch — read from TokenStorage slug and reuse existing repo.
final _brandingProvider =
    FutureProvider.autoDispose<TenantBranding?>((ref) async {
  final slug = await TokenStorage.getTenantSlug();
  if (slug == null || slug.isEmpty) return null;
  try {
    return await ref.read(brandingRepositoryProvider).fetchBranding(slug);
  } catch (_) {
    return null;
  }
});

// ── Screen ────────────────────────────────────────────────────────────────────

class RoleRouterScreen extends ConsumerStatefulWidget {
  const RoleRouterScreen({super.key});

  @override
  ConsumerState<RoleRouterScreen> createState() => _RoleRouterScreenState();
}

class _RoleRouterScreenState extends ConsumerState<RoleRouterScreen>
    with TickerProviderStateMixin {
  // Timing
  late final DateTime _startTime;

  // Status text state
  String _statusText = 'Setting up your workspace…';
  bool _showSlowConnection = false;
  bool _showRetryButton = false;
  Timer? _slowTimer1;
  Timer? _slowTimer2;
  Timer? _retryTimer;

  // Resolved navigation target
  String? _pendingRoute;
  bool _resolved = false;
  bool _hasError = false;

  // Animation controllers
  late final AnimationController _mountCtrl;
  late final AnimationController _exitCtrl;
  late final AnimationController _spinCtrl;
  late final AnimationController _dotCtrl;

  // Mount animations
  late final Animation<double> _mountOpacity;
  late final Animation<double> _mountScale;

  // Exit animations
  late final Animation<double> _exitOpacity;
  late final Animation<double> _exitScale;

  @override
  void initState() {
    super.initState();
    _startTime = DateTime.now();

    // Mount animation: 200ms ease-out
    _mountCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _mountOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _mountCtrl, curve: Curves.easeOut),
    );
    _mountScale = Tween<double>(begin: 0.96, end: 1.0).animate(
      CurvedAnimation(parent: _mountCtrl, curve: Curves.easeOut),
    );

    // Exit animation: 200ms ease-in
    // Wire navigation to AnimationStatus listener — never await mid-build.
    _exitCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _exitOpacity = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(parent: _exitCtrl, curve: Curves.easeIn),
    );
    _exitScale = Tween<double>(begin: 1.0, end: 0.98).animate(
      CurvedAnimation(parent: _exitCtrl, curve: Curves.easeIn),
    );
    _exitCtrl.addStatusListener(_onExitAnimationStatus);

    // Spinner: 1 turn / second, linear, infinite
    _spinCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat();

    // Dot pulse for reduced motion: 800ms cycle
    _dotCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat();

    // Start mount animation
    _mountCtrl.forward();

    // Slow-network status escalation timers
    _slowTimer1 = Timer(const Duration(seconds: 3), () {
      if (mounted && !_resolved) {
        setState(() => _statusText = 'Almost there…');
      }
    });
    _slowTimer2 = Timer(const Duration(seconds: 6), () {
      if (mounted && !_resolved) {
        setState(() => _showSlowConnection = true);
      }
    });
    _retryTimer = Timer(const Duration(seconds: 6), () {
      if (mounted && !_resolved && _hasError) {
        setState(() => _showRetryButton = true);
      }
    });

    // Fire the /me call immediately, in parallel with frame build
    _resolveRole();
  }

  @override
  void dispose() {
    _exitCtrl.removeStatusListener(_onExitAnimationStatus);
    _mountCtrl.dispose();
    _exitCtrl.dispose();
    _spinCtrl.dispose();
    _dotCtrl.dispose();
    _slowTimer1?.cancel();
    _slowTimer2?.cancel();
    _retryTimer?.cancel();
    super.dispose();
  }

  // ── Exit animation → navigation ──────────────────────────────────────────────

  void _onExitAnimationStatus(AnimationStatus status) {
    if (status == AnimationStatus.completed) {
      // Animation is done — schedule navigation on the next frame.
      // This ensures the GoRouter InheritedElement has no remaining
      // dependents when the route is replaced.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && _pendingRoute != null) {
          context.go(_pendingRoute!);
        }
      });
    }
  }

  // ── Role resolution ──────────────────────────────────────────────────────────

  Future<void> _resolveRole() async {
    try {
      final me = await ref.read(authRepositoryProvider).getCurrentUser();

      if (me == null) {
        await _failAndLogout('Session invalid.');
        return;
      }

      ref.read(currentMeProvider.notifier).state = me;

      String? route;
      switch (me.role) {
        case 'student':
          // Offline-institution students get the institutional shell with
          // attendance, schedule, and fee tracking instead of the online shell.
          route = me.tenant.tenantCategory == 'offline_institution'
              ? '/institutional-student/home'
              : '/student/home';
        case 'teacher':
          route = '/teacher/home';
        case 'owner':
        case 'standalone_teacher':
          route = '/standalone/home';
        default:
          await TokenStorage.clearSession();
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) context.go('/');
          });
          return;
      }

      // Start proactive refresh timer — session confirmed
      if (mounted) {
        ref.read(sessionManagerProvider).startTimer();
      }

      _pendingRoute = route;
      _resolved = true;
      _navigate();
    } catch (_) {
      if (mounted) {
        setState(() {
          _hasError = true;
          _statusText = 'Could not connect. Please try again.';
          _showRetryButton = true;
        });
      }
    }
  }

  /// Decides whether to skip the animation (fast path) or run it (slow path).
  /// Navigation itself is always deferred to addPostFrameCallback or the
  /// exit animation's status listener — never called synchronously.
  void _navigate() {
    if (!mounted || _pendingRoute == null) return;

    final elapsed = DateTime.now().difference(_startTime);

    if (elapsed.inMilliseconds < 300) {
      // Fast path: skip exit animation entirely — navigate next frame.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) context.go(_pendingRoute!);
      });
      return;
    }

    // Slow path: trigger exit animation.
    // Navigation fires from _onExitAnimationStatus when completed.
    _exitCtrl.forward();
  }

  Future<void> _failAndLogout(String reason) async {
    await ref.read(authRepositoryProvider).logout();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.go('/');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(reason)),
        );
      }
    });
  }

  void _retry() {
    setState(() {
      _hasError = false;
      _showRetryButton = false;
      _showSlowConnection = false;
      _statusText = 'Setting up your workspace…';
    });
    _resolveRole();
  }

  // ── Build ─────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final brandingAsync = ref.watch(_brandingProvider);
    final branding = brandingAsync.valueOrNull;

    final accentColor = branding != null
        ? _parseHex(branding.primaryColor)
        : const Color(0xFF2563EB);

    final accentSoft = accentColor.withValues(alpha: 0x22 / 255);
    final accentWash = accentColor.withValues(alpha: 0x10 / 255);
    final accentGlow = accentColor.withValues(alpha: 0x40 / 255);

    final reduceMotion = MediaQuery.disableAnimationsOf(context);

    return Scaffold(
      backgroundColor: Colors.white,
      body: AnimatedBuilder(
        animation: Listenable.merge([_mountCtrl, _exitCtrl]),
        builder: (context, _) {
          // Compose opacity/scale from mount then exit
          final opacity = _exitCtrl.isAnimating || _exitCtrl.value > 0
              ? _exitOpacity.value
              : _mountOpacity.value;
          final scale = _exitCtrl.isAnimating || _exitCtrl.value > 0
              ? _exitScale.value
              : _mountScale.value;

          return Opacity(
            opacity: opacity,
            child: Transform.scale(
              scale: scale,
              child: _Content(
                branding: branding,
                accentColor: accentColor,
                accentSoft: accentSoft,
                accentGlow: accentGlow,
                accentWash: accentWash,
                statusText: _statusText,
                showSlowConnection: _showSlowConnection,
                showRetryButton: _showRetryButton,
                spinCtrl: _spinCtrl,
                dotCtrl: _dotCtrl,
                reduceMotion: reduceMotion,
                onRetry: _retry,
              ),
            ),
          );
        },
      ),
    );
  }
}

// ── Content widget ─────────────────────────────────────────────────────────────

class _Content extends StatelessWidget {
  final TenantBranding? branding;
  final Color accentColor;
  final Color accentSoft;
  final Color accentGlow;
  final Color accentWash;
  final String statusText;
  final bool showSlowConnection;
  final bool showRetryButton;
  final AnimationController spinCtrl;
  final AnimationController dotCtrl;
  final bool reduceMotion;
  final VoidCallback onRetry;

  const _Content({
    required this.branding,
    required this.accentColor,
    required this.accentSoft,
    required this.accentGlow,
    required this.accentWash,
    required this.statusText,
    required this.showSlowConnection,
    required this.showRetryButton,
    required this.spinCtrl,
    required this.dotCtrl,
    required this.reduceMotion,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final name = branding?.name ?? '';
    final city = branding?.city ?? '';

    // ── Stack layout: avoids Column height constraints entirely ──────────────
    // Layer 1: radial wash (fill)
    // Layer 2: centered composition with optical lift (Transform.translate)
    // Layer 3: footer pinned to bottom (Positioned)
    return Stack(
      children: [
        // Background wash — fills entire screen, no pointer events
        Positioned.fill(
          child: IgnorePointer(
            child: CustomPaint(
              painter: _RadialWashPainter(washColor: accentWash),
            ),
          ),
        ),

        // Main composition — centered with -40px optical lift
        Positioned.fill(
          child: Center(
            child: Transform.translate(
              offset: const Offset(0, -40),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Avatar: 96×96, radius 24, accent bg, glow shadow
                    InstitutionAvatar(
                      institutionName: name,
                      accentColor: accentColor,
                      logoUrl: branding?.logoUrl,
                      size: 96,
                      borderRadius: 24,
                      shadow: BoxShadow(
                        color: accentGlow,
                        offset: const Offset(0, 16),
                        blurRadius: 40,
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Institution name
                    if (name.isNotEmpty)
                      Text(
                        name,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF111827),
                          letterSpacing: -0.3,
                          height: 1.2,
                        ),
                        textAlign: TextAlign.center,
                      ),

                    // Institution city — -6px visual tuck via Transform (NOT SizedBox)
                    if (city.isNotEmpty)
                      Transform.translate(
                        offset: const Offset(0, -6),
                        child: Text(
                          city,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w400,
                            color: const Color(0xFF6B7280),
                            height: 1.3,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),

                    const SizedBox(height: 18),

                    // Spinner or dot pulse (reduced motion)
                    Semantics(
                      label: 'Loading your workspace',
                      child: reduceMotion
                          ? _DotPulse(
                              ctrl: dotCtrl,
                              accentColor: accentColor,
                            )
                          : _Spinner(
                              ctrl: spinCtrl,
                              accentColor: accentColor,
                              trackColor: accentSoft,
                            ),
                    ),

                    const SizedBox(height: 12),

                    // Status text
                    Text(
                      statusText,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF6B7280),
                        height: 1.4,
                      ),
                      textAlign: TextAlign.center,
                    ),

                    // Slow connection sub-line (after 6s)
                    if (showSlowConnection) ...[
                      const SizedBox(height: 4),
                      Text(
                        'Slow connection?',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFF6B7280),
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],

                    // Retry button (after error + 6s)
                    if (showRetryButton) ...[
                      const SizedBox(height: 12),
                      GestureDetector(
                        onTap: onRetry,
                        child: Text(
                          'Retry',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: accentColor,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),

        // Footer — pinned 56px from bottom, never causes overflow
        Positioned(
          bottom: 56,
          left: 0,
          right: 0,
          child: Center(
            child: Text(
              'powered by edveo',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF9CA3AF),
                letterSpacing: 0.3,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ── Custom spinner ─────────────────────────────────────────────────────────────

class _Spinner extends StatelessWidget {
  final Animation<double> ctrl;
  final Color accentColor;
  final Color trackColor;

  const _Spinner({
    required this.ctrl,
    required this.accentColor,
    required this.trackColor,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: ctrl,
      builder: (_, __) => CustomPaint(
        size: const Size(36, 36),
        painter: _SpinnerPainter(
          progress: ctrl.value,
          accentColor: accentColor,
          trackColor: trackColor,
        ),
      ),
    );
  }
}

class _SpinnerPainter extends CustomPainter {
  final double progress; // 0.0 → 1.0 linear
  final Color accentColor;
  final Color trackColor;

  _SpinnerPainter({
    required this.progress,
    required this.accentColor,
    required this.trackColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    const radius = 14.0;
    const strokeWidth = 3.0;

    // Track: full circle
    final trackPaint = Paint()
      ..color = trackColor
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    canvas.drawCircle(center, radius, trackPaint);

    // Active arc: 90° rotating linearly
    final arcPaint = Paint()
      ..color = accentColor
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final startAngle = -math.pi / 2 + (progress * 2 * math.pi);
    const sweepAngle = math.pi / 2;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle,
      false,
      arcPaint,
    );
  }

  @override
  bool shouldRepaint(_SpinnerPainter old) =>
      old.progress != progress ||
      old.accentColor != accentColor ||
      old.trackColor != trackColor;
}

// ── Dot pulse (reduced motion) ────────────────────────────────────────────────

class _DotPulse extends StatelessWidget {
  final Animation<double> ctrl;
  final Color accentColor;

  const _DotPulse({required this.ctrl, required this.accentColor});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: ctrl,
      builder: (_, __) {
        final t = ctrl.value;

        double dotOpacity(double phase) {
          final v = math.sin((t + phase) * math.pi);
          return 0.3 + (v.clamp(0.0, 1.0) * 0.7);
        }

        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _Dot(opacity: dotOpacity(0.0), color: accentColor),
            const SizedBox(width: 6),
            _Dot(opacity: dotOpacity(0.33), color: accentColor),
            const SizedBox(width: 6),
            _Dot(opacity: dotOpacity(0.66), color: accentColor),
          ],
        );
      },
    );
  }
}

class _Dot extends StatelessWidget {
  final double opacity;
  final Color color;

  const _Dot({required this.opacity, required this.color});

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: opacity.clamp(0.0, 1.0),
      child: Container(
        width: 7,
        height: 7,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}

// ── Radial background wash ────────────────────────────────────────────────────

class _RadialWashPainter extends CustomPainter {
  final Color washColor;

  _RadialWashPainter({required this.washColor});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width * 0.5, size.height * 0.38);
    final radius = size.width * 0.8;

    final paint = Paint()
      ..shader = RadialGradient(
        colors: [washColor, Colors.transparent],
        stops: const [0.0, 0.6],
      ).createShader(Rect.fromCircle(center: center, radius: radius));

    canvas.drawRect(Offset.zero & size, paint);
  }

  @override
  bool shouldRepaint(_RadialWashPainter old) => old.washColor != washColor;
}

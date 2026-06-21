import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:edveo/features/auth/data/auth_repository.dart';
import 'package:edveo/features/auth/data/branding_repository.dart';
import 'package:edveo/features/auth/data/google_auth_service.dart';
import 'package:edveo/features/auth/presentation/widgets/google_sign_in_button.dart';
import 'package:edveo/features/auth/presentation/widgets/institution_avatar.dart';
import 'package:edveo/core/models/tenant_branding.dart';

class LoginScreen extends ConsumerStatefulWidget {
  final String tenantSlug;
  const LoginScreen({super.key, required this.tenantSlug});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  TenantBranding? _branding;
  bool _brandingLoading = true;

  final _emailController    = TextEditingController();
  final _passwordController = TextEditingController();
  bool _loginLoading = false;
  bool _googleLoading = false;
  String? _error;

  final GoogleAuthService _googleAuthService = GoogleAuthService();

  @override
  void initState() {
    super.initState();
    _loadBranding();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _loadBranding() async {
    try {
      final branding = await ref
          .read(brandingRepositoryProvider)
          .fetchBranding(widget.tenantSlug);
      setState(() { _branding = branding; });
    } catch (_) {
      // Branding failure is non-fatal — login still works without it
    } finally {
      setState(() { _brandingLoading = false; });
    }
  }

  Future<void> _signInWithGoogle() async {
    setState(() { _googleLoading = true; _error = null; });

    try {
      final idToken = await _googleAuthService.getIdToken();

      if (idToken == null) {
        // User cancelled the account picker — silent, no error shown.
        setState(() { _googleLoading = false; });
        return;
      }

      await ref.read(authRepositoryProvider).loginWithGoogle(
        idToken: idToken,
        tenantSlug: widget.tenantSlug,
      );

      if (mounted) context.go('/role-router');
    } on GoogleAuthException {
      // Configuration or platform error — show generic message.
      setState(() {
        _error = 'Google Sign-In is not available. Please use your email and password.';
      });
    } on DioException catch (e) {
      final errorCode =
          e.response?.data?['error']?['code'] as String?;
      setState(() { _error = _mapGoogleErrorCode(errorCode); });
    } catch (_) {
      setState(() { _error = 'Google Sign-In failed. Please try again.'; });
    } finally {
      if (mounted) setState(() { _googleLoading = false; });
    }
  }

  String _mapGoogleErrorCode(String? code) => switch (code) {
    'GOOGLE_USER_NOT_REGISTERED' =>
      'No account found for your Google identity in this institution. Contact your admin.',
    'GOOGLE_LOGIN_DISABLED' =>
      'Google login is not enabled for this institution.',
    'RATE_LIMITED' || 'RATE_LIMIT_EXCEEDED' =>
      'Too many attempts. Please wait and try again.',
    _ =>
      'Google Sign-In failed. Please try again or use your email and password.',
  };

  Future<void> _login() async {
    final email    = _emailController.text.trim();
    final password = _passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      setState(() { _error = 'Email and password are required.'; });
      return;
    }

    setState(() { _loginLoading = true; _error = null; });

    try {
      final result = await ref.read(authRepositoryProvider).login(
        email:      email,
        password:   password,
        tenantSlug: widget.tenantSlug,
      );

      if (result.isSuccess) {
        if (mounted) context.go('/role-router');
      } else {
        setState(() { _error = result.errorMessage; });
      }
    } catch (_) {
      setState(() { _error = 'Login failed. Please try again.'; });
    } finally {
      if (mounted) setState(() { _loginLoading = false; });
    }
  }

  Color get _accentColor {
    final hex = _branding?.primaryColor ?? '#2563EB';
    return _parseHex(hex);
  }

  static Color _parseHex(String hex) {
    final cleaned = hex.replaceFirst('#', '');
    final value = int.tryParse(
      cleaned.length == 6 ? 'FF$cleaned' : cleaned,
      radix: 16,
    );
    return value != null ? Color(value) : const Color(0xFF2563EB);
  }

  @override
  Widget build(BuildContext context) {
    if (_brandingLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(_branding?.name ?? 'Login'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (_branding != null) ...[
              Center(
                child: InstitutionAvatar(
                  institutionName: _branding!.name,
                  logoUrl: _branding!.logoUrl,
                  accentColor: _accentColor,
                  size: 56,
                  borderRadius: 18,
                  shadow: BoxShadow(
                    color: _accentColor.withValues(alpha: 0.15),
                    offset: const Offset(0, 8),
                    blurRadius: 24,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Center(
                child: Text(
                  _branding!.name,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
              Center(
                child: Text(
                  _branding!.city,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
            ],
            const SizedBox(height: 32),
            TextField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Password',
                border: OutlineInputBorder(),
              ),
            ),
            if (_error != null) ...[
              const SizedBox(height: 12),
              Text(_error!, style: const TextStyle(color: Colors.red)),
            ],
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _loginLoading ? null : _login,
              child: _loginLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Log in'),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Row(
                children: [
                  Expanded(child: Divider()),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12),
                    child: Text('or', style: TextStyle(color: Colors.grey)),
                  ),
                  Expanded(child: Divider()),
                ],
              ),
            ),
            GoogleSignInButton(
              onPressed: _signInWithGoogle,
              isLoading: _googleLoading,
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../data/branding_repository.dart';
import '../data/auth_repository.dart';
import '../../../core/models/tenant_branding.dart';

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
  String? _error;

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
            if (_branding?.logoUrl != null)
              Center(
                child: Image.network(
                  _branding!.logoUrl!,
                  height: 80,
                  errorBuilder: (_, __, ___) => const Icon(Icons.school, size: 80),
                ),
              ),
            const SizedBox(height: 8),
            if (_branding != null) ...[
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
          ],
        ),
      ),
    );
  }
}

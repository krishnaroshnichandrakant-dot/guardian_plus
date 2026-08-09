import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/design_tokens.dart';
import '../providers/auth_provider.dart';

/// Login / Account creation screen
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key, required this.role});
  final UserRole role;
  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _isLogin = true;
  bool _loading = false;
  bool _passVisible = false;
  String? _error;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(_isLogin ? 'Sign In' : 'Create Account'),
        backgroundColor: AppColors.background,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(DesignTokens.screenPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: DesignTokens.spacingXl),
            Text(
              _isLogin ? 'Welcome back' : 'Create your account',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: DesignTokens.spacingXs),
            Text(
              'Role: ${_roleLabel(widget.role)}',
              style: const TextStyle(color: AppColors.cyberBlue, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: DesignTokens.spacingXxl),
            TextField(
              controller: _emailCtrl,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                labelText: 'Email address',
                prefixIcon: Icon(Icons.email_outlined),
              ),
            ),
            const SizedBox(height: DesignTokens.spacingLg),
            TextField(
              controller: _passCtrl,
              obscureText: !_passVisible,
              decoration: InputDecoration(
                labelText: 'Password',
                prefixIcon: const Icon(Icons.lock_outline_rounded),
                suffixIcon: IconButton(
                  icon: Icon(_passVisible ? Icons.visibility_off : Icons.visibility),
                  onPressed: () => setState(() => _passVisible = !_passVisible),
                ),
              ),
            ),
            if (_error != null) ...[
              const SizedBox(height: DesignTokens.spacingMd),
              Container(
                padding: const EdgeInsets.all(DesignTokens.spacingMd),
                decoration: BoxDecoration(
                  color: AppColors.errorRed.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(DesignTokens.radiusSm),
                  border: Border.all(color: AppColors.errorRed.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.error_outline_rounded, color: AppColors.errorRed, size: 16),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _error!,
                        style: const TextStyle(color: AppColors.errorRed, fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: DesignTokens.spacingXl),
            ElevatedButton(
              onPressed: _loading ? null : _submit,
              child: _loading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : Text(_isLogin ? 'Sign In' : 'Create Account'),
            ),
            const SizedBox(height: DesignTokens.spacingLg),
            Center(
              child: TextButton(
                onPressed: () => setState(() {
                  _isLogin = !_isLogin;
                  _error = null;
                }),
                child: Text(
                  _isLogin
                      ? "Don't have an account? Create one"
                      : 'Already have an account? Sign in',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _submit() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    final authService = ref.read(authServiceProvider);
    AuthResult result;

    if (_isLogin) {
      result = await authService.signInWithEmail(_emailCtrl.text, _passCtrl.text);
    } else {
      result = await authService.createAccount(
        email: _emailCtrl.text,
        password: _passCtrl.text,
        role: widget.role,
        ageYears: null, // collected in ConsentScreen
      );
    }

    setState(() => _loading = false);

    if (result.isSuccess) {
      if (mounted) {
        // Pairing required for parent/child roles
        if (widget.role == UserRole.parent || widget.role == UserRole.child) {
          context.go(Routes.pairing);
        } else {
          context.go(Routes.cybersecurityDashboard);
        }
      }
    } else {
      setState(() => _error = result.errorMessage);
    }
  }

  String _roleLabel(UserRole role) {
    switch (role) {
      case UserRole.individual: return 'Individual';
      case UserRole.parent: return 'Parent';
      case UserRole.child: return 'Child';
      case UserRole.womensSafety: return "Women's Safety";
    }
  }
}

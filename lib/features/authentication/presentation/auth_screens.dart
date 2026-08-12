import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme/aurum_colors.dart';
import '../../../app/theme/aurum_spacing.dart';
import '../../../app/theme/aurum_typography.dart';
import '../../../core/storage/biometric_service.dart';
import '../../../shared/services/providers.dart';
import '../../../shared/widgets/aurum_primitives.dart';
import '../../../shared/widgets/google_sign_in_button.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  var _obscurePassword = true;
  var _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    try {
      await ref.read(authControllerProvider.notifier).signIn(
            email: _emailController.text.trim(),
            password: _passwordController.text,
          );

      final authState = ref.read(authControllerProvider).valueOrNull;
      if (authState?.isAuthenticated == true && mounted) {
        await _maybeEnableBiometric();
        if (mounted) context.go('/home');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Login failed: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _signInWithGoogle() async {
    setState(() => _isLoading = true);
    try {
      await ref.read(authControllerProvider.notifier).signInWithGoogle();
      final authState = ref.read(authControllerProvider).valueOrNull;
      if (authState?.isAuthenticated == true && mounted) {
        await _maybeEnableBiometric();
        if (mounted) context.go('/home');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Google sign-in failed')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _maybeEnableBiometric() async {
    final biometric = BiometricService();
    final available = await biometric.isBiometricAvailable();
    if (!available || !mounted) return;

    final enable = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AurumColors.surface,
        title: const Text('Secure your account'),
        content: const Text('Would you like to use fingerprint or face authentication for faster future logins?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Not now')),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Enable')),
        ],
      ),
    );

    if (enable == true) {
      await biometric.setBiometricEnabled(true);
      // Store a placeholder token that biometric can unlock
      await biometric.storeBiometricToken('biometric-session-token');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(backgroundColor: AurumColors.canvas, elevation: 0),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AurumSpacing.lg),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const AurumBrand(compact: true),
                const SizedBox(height: AurumSpacing.xxxl),
                Text('Welcome back', style: AurumTypography.h1),
                const SizedBox(height: AurumSpacing.xs),
                Text('Sign in to access your market intelligence workspace.', style: AurumTypography.bodyLarge),
                const SizedBox(height: AurumSpacing.xxl),

                Text('Email', style: AurumTypography.label),
                const SizedBox(height: AurumSpacing.xs),
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(hintText: 'you@example.com'),
                  validator: (v) => (v == null || !v.contains('@')) ? 'Enter a valid email' : null,
                ),
                const SizedBox(height: AurumSpacing.md),

                Text('Password', style: AurumTypography.label),
                const SizedBox(height: AurumSpacing.xs),
                TextFormField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  decoration: InputDecoration(
                    hintText: 'Enter your password',
                    suffixIcon: IconButton(
                      icon: Icon(_obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined),
                      onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                    ),
                  ),
                  validator: (v) => (v == null || v.length < 6) ? 'Password must be at least 6 characters' : null,
                ),

                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () => context.push('/forgot-password'),
                    child: Text('Forgot password?', style: AurumTypography.label.copyWith(color: AurumColors.goldSoft)),
                  ),
                ),

                const SizedBox(height: AurumSpacing.lg),
                AurumButton(
                  label: 'Log in',
                  isLoading: _isLoading,
                  onPressed: _isLoading ? null : _submit,
                ),

                const SizedBox(height: AurumSpacing.xl),
                const Row(children: [
                  Expanded(child: Divider()),
                  Padding(padding: EdgeInsets.symmetric(horizontal: 12), child: Text('OR')),
                  Expanded(child: Divider()),
                ]),
                const SizedBox(height: AurumSpacing.lg),

                GoogleSignInButton(
                  isLoading: _isLoading,
                  onPressed: _isLoading ? null : _signInWithGoogle,
                ),

                const SizedBox(height: AurumSpacing.xl),
                Center(
                  child: TextButton(
                    onPressed: () => context.go('/register'),
                    child: Text("Don't have an account? Create Account", style: AurumTypography.label.copyWith(color: AurumColors.goldSoft)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  var _acceptedTerms = false;
  var _obscure = true;
  var _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate() || !_acceptedTerms) {
      if (!_acceptedTerms) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please accept the Terms & Privacy Policy')),
        );
      }
      return;
    }

    setState(() => _isLoading = true);
    try {
      await ref.read(authControllerProvider.notifier).register(
            name: _nameController.text.trim(),
            email: _emailController.text.trim(),
            password: _passwordController.text,
          );
      if (mounted) context.go('/home');
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Registration failed')));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _googleSignUp() async {
    setState(() => _isLoading = true);
    try {
      await ref.read(authControllerProvider.notifier).signInWithGoogle();
      if (mounted) context.go('/home');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(backgroundColor: AurumColors.canvas, elevation: 0),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AurumSpacing.lg),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const AurumBrand(compact: true),
                const SizedBox(height: AurumSpacing.xxl),
                Text('Create your AURUM account', style: AurumTypography.h1),
                const SizedBox(height: AurumSpacing.sm),
                Text('Join the premium market intelligence platform.', style: AurumTypography.bodyLarge),
                const SizedBox(height: AurumSpacing.xxl),

                Text('Full Name', style: AurumTypography.label),
                TextFormField(controller: _nameController, decoration: const InputDecoration(hintText: 'Your full name'), validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null),
                const SizedBox(height: AurumSpacing.md),

                Text('Email', style: AurumTypography.label),
                TextFormField(controller: _emailController, keyboardType: TextInputType.emailAddress, decoration: const InputDecoration(hintText: 'you@example.com'), validator: (v) => (v == null || !v.contains('@')) ? 'Valid email required' : null),
                const SizedBox(height: AurumSpacing.md),

                Text('Password', style: AurumTypography.label),
                TextFormField(
                  controller: _passwordController,
                  obscureText: _obscure,
                  decoration: InputDecoration(
                    hintText: 'Create a strong password',
                    suffixIcon: IconButton(icon: Icon(_obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined), onPressed: () => setState(() => _obscure = !_obscure)),
                  ),
                  validator: (v) => (v == null || v.length < 8) ? 'At least 8 characters' : null,
                ),
                const SizedBox(height: AurumSpacing.md),

                Text('Confirm Password', style: AurumTypography.label),
                TextFormField(
                  controller: _confirmController,
                  obscureText: _obscure,
                  decoration: const InputDecoration(hintText: 'Repeat password'),
                  validator: (v) => v != _passwordController.text ? 'Passwords do not match' : null,
                ),

                const SizedBox(height: AurumSpacing.md),
                CheckboxListTile(
                  value: _acceptedTerms,
                  onChanged: (v) => setState(() => _acceptedTerms = v ?? false),
                  title: const Text('I agree to the Terms of Service and Privacy Policy', style: AurumTypography.body),
                  controlAffinity: ListTileControlAffinity.leading,
                  contentPadding: EdgeInsets.zero,
                ),

                const SizedBox(height: AurumSpacing.lg),
                AurumButton(label: 'Create Account', isLoading: _isLoading, onPressed: _isLoading ? null : _submit),

                const SizedBox(height: AurumSpacing.xl),
                const Row(children: [Expanded(child: Divider()), Padding(padding: EdgeInsets.symmetric(horizontal: 12), child: Text('OR')), Expanded(child: Divider())]),
                const SizedBox(height: AurumSpacing.lg),

                GoogleSignInButton(onPressed: _isLoading ? null : _googleSignUp, isLoading: _isLoading),

                const SizedBox(height: AurumSpacing.xl),
                Center(
                  child: TextButton(onPressed: () => context.go('/login'), child: Text('Already have an account? Log in', style: AurumTypography.label.copyWith(color: AurumColors.goldSoft))),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final _emailController = TextEditingController();
  var _submitted = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(backgroundColor: AurumColors.canvas),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AurumSpacing.lg),
          child: _submitted
              ? Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.mark_email_read_outlined, size: 64, color: AurumColors.gold),
                    const SizedBox(height: AurumSpacing.lg),
                    Text('Check your email', style: AurumTypography.h1),
                    const SizedBox(height: AurumSpacing.sm),
                    const Text('If an account exists, we sent password reset instructions.'),
                    const SizedBox(height: AurumSpacing.xl),
                    AurumButton(label: 'Back to Login', onPressed: () => context.go('/login')),
                  ],
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const AurumBrand(compact: true),
                    const SizedBox(height: AurumSpacing.xxl),
                    Text('Reset your password', style: AurumTypography.h1),
                    const SizedBox(height: AurumSpacing.sm),
                    const Text('Enter your email and we will send reset instructions.'),
                    const SizedBox(height: AurumSpacing.xxl),
                    TextFormField(controller: _emailController, decoration: const InputDecoration(hintText: 'Email')),
                    const SizedBox(height: AurumSpacing.lg),
                    AurumButton(
                      label: 'Send reset link',
                      onPressed: () async {
                        await ref.read(authRepositoryProvider).sendPasswordReset(_emailController.text.trim());
                        setState(() => _submitted = true);
                      },
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}

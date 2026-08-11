import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme/aurum_colors.dart';
import '../../../app/theme/aurum_spacing.dart';
import '../../../app/theme/aurum_typography.dart';
import '../../../shared/models/user_data_models.dart';
import '../../../shared/services/providers.dart';
import '../../../shared/widgets/aurum_primitives.dart';

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

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authControllerProvider);
    final isAuthenticating = auth.isLoading || auth.valueOrNull?.status == AuthStatus.authenticating;
    return Scaffold(
      appBar: AppBar(backgroundColor: AurumColors.canvas, surfaceTintColor: Colors.transparent),
      body: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AurumSpacing.lg),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const AurumBrand(compact: true),
                const SizedBox(height: AurumSpacing.xxxl),
                Text('Welcome back', style: AurumTypography.h1),
                const SizedBox(height: AurumSpacing.xs),
                const Text('Sign in to sync your watchlist, analysis history and preferences.', style: AurumTypography.bodyLarge),
                const SizedBox(height: AurumSpacing.xxl),
                Text('Email', style: AurumTypography.label),
                const SizedBox(height: AurumSpacing.xs),
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  autofillHints: const <String>[AutofillHints.email],
                  decoration: const InputDecoration(hintText: 'you@example.com'),
                  validator: _validateEmail,
                ),
                const SizedBox(height: AurumSpacing.md),
                Text('Password', style: AurumTypography.label),
                const SizedBox(height: AurumSpacing.xs),
                TextFormField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  autocorrect: false,
                  enableSuggestions: false,
                  autofillHints: const <String>[AutofillHints.password],
                  decoration: InputDecoration(
                    hintText: 'Enter your password',
                    suffixIcon: IconButton(
                      tooltip: _obscurePassword ? 'Show password' : 'Hide password',
                      onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                      icon: Icon(_obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined),
                    ),
                  ),
                  validator: (String? value) => value == null || value.length < 8 ? 'Use at least 8 characters.' : null,
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () => context.push('/forgot-password'),
                    child: Text('Forgot password?', style: AurumTypography.label.copyWith(color: AurumColors.goldSoft)),
                  ),
                ),
                if (auth.hasError) ...<Widget>[
                  Text('Unable to sign in. Please try again.', style: AurumTypography.body.copyWith(color: AurumColors.negative)),
                  const SizedBox(height: AurumSpacing.sm),
                ],
                AurumButton(
                  label: 'Sign in',
                  isLoading: isAuthenticating,
                  onPressed: isAuthenticating ? null : _submit,
                ),
                const SizedBox(height: AurumSpacing.sm),
                AurumButton(
                  label: 'Continue as guest',
                  variant: AurumButtonVariant.secondary,
                  onPressed: () => context.go('/home'),
                ),
                const SizedBox(height: AurumSpacing.xl),
                Center(
                  child: TextButton(
                    onPressed: () => context.go('/register'),
                    child: Text('New to AURUM? Create an account', style: AurumTypography.label.copyWith(color: AurumColors.goldSoft)),
                  ),
                ),
                const SizedBox(height: AurumSpacing.md),
                const Center(child: Text('Demo authentication UI — no real credentials are sent.', textAlign: TextAlign.center, style: AurumTypography.caption)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    await ref.read(authControllerProvider.notifier).signIn(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );
    if (mounted && ref.read(authControllerProvider).valueOrNull?.isAuthenticated == true) context.go('/home');
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

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authControllerProvider);
    final isAuthenticating = auth.isLoading || auth.valueOrNull?.status == AuthStatus.authenticating;
    return Scaffold(
      appBar: AppBar(backgroundColor: AurumColors.canvas, surfaceTintColor: Colors.transparent),
      body: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AurumSpacing.lg),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const AurumBrand(compact: true),
                const SizedBox(height: AurumSpacing.xxl),
                Text('Create your workspace', style: AurumTypography.h1),
                const SizedBox(height: AurumSpacing.xs),
                const Text('Keep your research preferences and saved assets in one place.', style: AurumTypography.bodyLarge),
                const SizedBox(height: AurumSpacing.xxl),
                _field(label: 'Name', controller: _nameController, hint: 'Your name', validator: (String? value) => value == null || value.trim().isEmpty ? 'Enter your name.' : null),
                _field(label: 'Email', controller: _emailController, hint: 'you@example.com', keyboardType: TextInputType.emailAddress, validator: _validateEmail),
                _field(label: 'Password', controller: _passwordController, hint: 'At least 8 characters', obscure: true, validator: (String? value) => value == null || value.length < 8 ? 'Use at least 8 characters.' : null),
                _field(label: 'Confirm password', controller: _confirmController, hint: 'Repeat password', obscure: true, validator: (String? value) => value != _passwordController.text ? 'Passwords do not match.' : null),
                CheckboxListTile(
                  contentPadding: EdgeInsets.zero,
                  value: _acceptedTerms,
                  activeColor: AurumColors.gold,
                  checkColor: AurumColors.ink,
                  onChanged: (bool? value) => setState(() => _acceptedTerms = value ?? false),
                  title: const Text('I understand AURUM provides analysis, not financial advice.', style: AurumTypography.body),
                ),
                if (auth.hasError) ...<Widget>[
                  Text('Unable to create an account. Please try again.', style: AurumTypography.body.copyWith(color: AurumColors.negative)),
                  const SizedBox(height: AurumSpacing.sm),
                ],
                AurumButton(label: 'Create account', isLoading: isAuthenticating, onPressed: isAuthenticating ? null : _submit),
                const SizedBox(height: AurumSpacing.lg),
                Center(child: TextButton(onPressed: () => context.go('/login'), child: Text('Already have an account? Sign in', style: AurumTypography.label.copyWith(color: AurumColors.goldSoft)))),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _field({required String label, required TextEditingController controller, required String hint, required String? Function(String?) validator, TextInputType? keyboardType, bool obscure = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AurumSpacing.md),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
        Text(label, style: AurumTypography.label),
        const SizedBox(height: AurumSpacing.xs),
        TextFormField(controller: controller, obscureText: obscure, keyboardType: keyboardType, decoration: InputDecoration(hintText: hint), validator: validator),
      ]),
    );
  }

  Future<void> _submit() async {
    if (!_acceptedTerms) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please acknowledge the analysis and risk notice.')));
      return;
    }
    if (!_formKey.currentState!.validate()) return;
    await ref.read(authControllerProvider.notifier).register(name: _nameController.text.trim(), email: _emailController.text.trim(), password: _passwordController.text);
    if (mounted && ref.read(authControllerProvider).valueOrNull?.isAuthenticated == true) context.go('/home');
  }
}

class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  var _submitted = false;
  var _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(backgroundColor: AurumColors.canvas, surfaceTintColor: Colors.transparent),
      body: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.all(AurumSpacing.lg),
          child: _submitted ? _success() : _form(),
        ),
      ),
    );
  }

  Widget _form() => Form(
        key: _formKey,
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
          const AurumBrand(compact: true),
          const SizedBox(height: AurumSpacing.xxxl),
          Text('Reset your password', style: AurumTypography.h1),
          const SizedBox(height: AurumSpacing.sm),
          const Text('Enter your email and we will send a reset link if an account exists.', style: AurumTypography.bodyLarge),
          const SizedBox(height: AurumSpacing.xxl),
          TextFormField(controller: _emailController, keyboardType: TextInputType.emailAddress, decoration: const InputDecoration(hintText: 'you@example.com'), validator: _validateEmail),
          const SizedBox(height: AurumSpacing.lg),
          AurumButton(label: 'Send reset link', isLoading: _isLoading, onPressed: _isLoading ? null : _submit),
        ]),
      );

  Widget _success() => Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[
        const Icon(Icons.mark_email_read_outlined, color: AurumColors.gold, size: 42),
        const SizedBox(height: AurumSpacing.lg),
        Text('Check your inbox', style: AurumTypography.h1),
        const SizedBox(height: AurumSpacing.sm),
        const Text('If an account matches that email, a password reset link is on its way.', style: AurumTypography.bodyLarge),
        const SizedBox(height: AurumSpacing.xl),
        AurumButton(label: 'Back to sign in', onPressed: () => context.go('/login')),
      ]);

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    await ref.read(authRepositoryProvider).sendPasswordReset(_emailController.text.trim());
    if (mounted) setState(() { _isLoading = false; _submitted = true; });
  }
}

String? _validateEmail(String? value) {
  final normalized = value?.trim() ?? '';
  if (normalized.isEmpty || !normalized.contains('@') || !normalized.contains('.')) return 'Enter a valid email address.';
  return null;
}

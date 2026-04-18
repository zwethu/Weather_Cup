import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:weather_cup/core/theme/app_colors.dart';
import 'package:weather_cup/core/theme/app_text_styles.dart';
import 'package:weather_cup/features/auth/auth_provider.dart';
import 'package:weather_cup/features/profile/user_provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();
    // Clear any leftover error from previous auth attempt
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AuthProvider>().clearError();
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final auth = context.read<AuthProvider>();
    final success = await auth.signIn(
      email: _emailController.text,
      password: _passwordController.text,
    );
    if (!mounted) return;
    if (success) {
      // AuthProvider.signIn already hydrated Hive from Firestore. Refresh
      // UserProvider so the home/profile screens pick up the synced data
      // before the router redirects to /main.
      context.read<UserProvider>().refresh();
      // Let the router's redirect logic decide between /profile-setup and
      // /main based on the freshly-synced profileSetupComplete flag.
      context.go('/main');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(gradient: AppColors.backgroundGradient),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Logo
                    Center(
                      child: Image.asset(
                        'assets/icons/playstore_transparent.png',
                        width: 90,
                        height: 90,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Title
                    Text(
                      'Welcome back',
                      style: AppTextStyles.headline2,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Sign in to continue',
                      style: AppTextStyles.bodyText2.copyWith(
                          color: AppColors.textSecondary),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 40),

                    // Email
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(
                        hintText: 'Email address',
                        prefixIcon: Icon(CupertinoIcons.mail,
                            color: AppColors.iconSecondary),
                      ),
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'Please enter your email';
                        if (!v.contains('@')) return 'Please enter a valid email';
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Password
                    TextFormField(
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      decoration: InputDecoration(
                        hintText: 'Password',
                        prefixIcon: const Icon(CupertinoIcons.lock,
                            color: AppColors.iconSecondary),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword
                                ? CupertinoIcons.eye
                                : CupertinoIcons.eye_slash,
                            color: AppColors.iconSecondary,
                          ),
                          onPressed: () => setState(
                                  () => _obscurePassword = !_obscurePassword),
                        ),
                      ),
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'Please enter your password';
                        return null;
                      },
                    ),
                    const SizedBox(height: 8),

                    // Forgot password
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () => context.push('/forgot-password'),
                        style: TextButton.styleFrom(
                            padding: EdgeInsets.zero,
                            minimumSize: const Size(0, 0),
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap),
                        child: Text('Forgot Password?',
                            style: AppTextStyles.link),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Error
                    Consumer<AuthProvider>(
                      builder: (context, auth, _) {
                        if (auth.errorMessage == null) return const SizedBox.shrink();
                        return Container(
                          padding: const EdgeInsets.all(12),
                          margin: const EdgeInsets.only(bottom: 12),
                          decoration: BoxDecoration(
                            color: AppColors.error.withOpacity(0.08),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                                color: AppColors.error.withOpacity(0.3)),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                  CupertinoIcons.exclamationmark_circle,
                                  color: AppColors.error,
                                  size: 16),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(auth.errorMessage!,
                                    style: AppTextStyles.caption
                                        .copyWith(color: AppColors.error)),
                              ),
                            ],
                          ),
                        );
                      },
                    ),

                    // Sign In button
                    Consumer<AuthProvider>(
                      builder: (context, auth, _) => ElevatedButton(
                        onPressed: auth.isLoading ? null : _submit,
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 200),
                          child: auth.isLoading
                              ? const SizedBox(
                            key: ValueKey('loading'),
                            height: 22,
                            width: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              color: Colors.white,
                            ),
                          )
                              : Text(
                            key: const ValueKey('label'),
                            'Sign In',
                            style: AppTextStyles.buttonText,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Sign up link
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text("Don't have an account?",
                            style: AppTextStyles.bodyText2),
                        const SizedBox(width: 4),
                        GestureDetector(
                          onTap: () => context.push('/register'),
                          child: Text('Sign Up', style: AppTextStyles.link),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
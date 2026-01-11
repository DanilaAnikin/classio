import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/theme_provider.dart';
import '../providers/auth_provider.dart';

/// Login page that adapts to Clean or Playful theme modes.
///
/// Features:
/// - Theme-aware design (Clean = professional, Playful = colorful/friendly)
/// - Form validation for email and password
/// - Loading states with CircularProgressIndicator
/// - Error handling with SnackBar notifications
/// - Password visibility toggle
/// - Registration mode with invite code support
class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _inviteCodeController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isRegistrationMode = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _inviteCodeController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    // Listen to auth state changes to show errors
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.listenManual(
        authNotifierProvider,
        (previous, next) {
          if (next.errorMessage != null) {
            _showErrorSnackBar(next.errorMessage!);
          }
        },
      );
    });
  }

  void _showErrorSnackBar(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Theme.of(context).colorScheme.error,
        behavior: SnackBarBehavior.floating,
        action: SnackBarAction(
          label: 'Dismiss',
          textColor: Colors.white,
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
      ),
    );
  }

  void _toggleMode() {
    setState(() {
      _isRegistrationMode = !_isRegistrationMode;
      // Clear form when switching modes
      _formKey.currentState?.reset();
      _confirmPasswordController.clear();
      _inviteCodeController.clear();
    });
  }

  Future<void> _handleLogin() async {
    if (_formKey.currentState?.validate() ?? false) {
      await ref.read(authNotifierProvider.notifier).signIn(
            _emailController.text.trim(),
            _passwordController.text,
          );
    }
  }

  Future<void> _handleRegistration() async {
    if (_formKey.currentState?.validate() ?? false) {
      await ref.read(authNotifierProvider.notifier).signUp(
            email: _emailController.text.trim(),
            password: _passwordController.text,
            inviteCode: _inviteCodeController.text.trim(),
          );
    }
  }

  Future<void> _handleSubmit() async {
    if (_isRegistrationMode) {
      await _handleRegistration();
    } else {
      await _handleLogin();
    }
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your email';
    }

    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );

    if (!emailRegex.hasMatch(value)) {
      return 'Please enter a valid email address';
    }

    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your password';
    }

    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }

    return null;
  }

  String? _validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please confirm your password';
    }

    if (value != _passwordController.text) {
      return 'Passwords do not match';
    }

    return null;
  }

  String? _validateInviteCode(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your invite code';
    }

    if (value.length < 6) {
      return 'Invite code must be at least 6 characters';
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authNotifierProvider);
    final isPlayful = ref.watch(themeNotifierProvider) == ThemeType.playful;
    final theme = Theme.of(context);
    final isLoading = authState.isLoading || authState.isRegistering;

    return Scaffold(
      body: Container(
        decoration: isPlayful
            ? BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    theme.colorScheme.primary.withValues(alpha: 0.05),
                    theme.colorScheme.secondary.withValues(alpha: 0.05),
                    theme.colorScheme.tertiary.withValues(alpha: 0.05),
                  ],
                ),
              )
            : null,
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Logo/Icon
                    _buildLogo(isPlayful, theme),

                    const SizedBox(height: 32),

                    // Welcome Text
                    _buildWelcomeText(isPlayful, theme),

                    const SizedBox(height: 8),

                    // Subtitle
                    _buildSubtitle(isPlayful, theme),

                    const SizedBox(height: 48),

                    // Email Field
                    _buildEmailField(isLoading, isPlayful, theme),

                    const SizedBox(height: 16),

                    // Password Field
                    _buildPasswordField(isLoading, isPlayful, theme),

                    // Registration-only fields
                    if (_isRegistrationMode) ...[
                      const SizedBox(height: 16),

                      // Confirm Password Field
                      _buildConfirmPasswordField(isLoading, isPlayful, theme),

                      const SizedBox(height: 16),

                      // Invite Code Field
                      _buildInviteCodeField(isLoading, isPlayful, theme),
                    ],

                    const SizedBox(height: 24),

                    // Login/Register Button
                    _buildSubmitButton(isLoading, isPlayful, theme),

                    const SizedBox(height: 16),

                    // Toggle Mode Link
                    _buildToggleModeButton(isPlayful, theme, isLoading),

                    if (!_isRegistrationMode) ...[
                      const SizedBox(height: 8),

                      // Forgot Password Link (only in login mode)
                      _buildForgotPasswordButton(isPlayful, theme),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLogo(bool isPlayful, ThemeData theme) {
    return Hero(
      tag: 'app_logo',
      child: Container(
        width: 120,
        height: 120,
        decoration: BoxDecoration(
          color: isPlayful
              ? theme.colorScheme.primary.withValues(alpha: 0.1)
              : theme.colorScheme.primary.withValues(alpha: 0.08),
          shape: isPlayful ? BoxShape.circle : BoxShape.rectangle,
          borderRadius: isPlayful ? null : BorderRadius.circular(16),
          boxShadow: isPlayful
              ? [
                  BoxShadow(
                    color: theme.colorScheme.primary.withValues(alpha: 0.2),
                    blurRadius: 20,
                    spreadRadius: 2,
                  ),
                ]
              : [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
        ),
        child: Icon(
          Icons.school_rounded,
          size: 64,
          color: theme.colorScheme.primary,
        ),
      ),
    );
  }

  Widget _buildWelcomeText(bool isPlayful, ThemeData theme) {
    return Text(
      _isRegistrationMode ? 'Join Classio' : 'Welcome to Classio',
      style: theme.textTheme.headlineMedium?.copyWith(
        fontWeight: isPlayful ? FontWeight.w800 : FontWeight.w600,
        color: theme.colorScheme.onSurface,
        letterSpacing: isPlayful ? 0.5 : -0.5,
      ),
      textAlign: TextAlign.center,
    );
  }

  Widget _buildSubtitle(bool isPlayful, ThemeData theme) {
    return Text(
      _isRegistrationMode
          ? 'Create your account to get started'
          : 'Sign in to continue',
      style: theme.textTheme.bodyLarge?.copyWith(
        color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
        fontWeight: isPlayful ? FontWeight.w600 : FontWeight.w400,
      ),
      textAlign: TextAlign.center,
    );
  }

  Widget _buildEmailField(bool isLoading, bool isPlayful, ThemeData theme) {
    return Container(
      decoration: isPlayful
          ? BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: theme.colorScheme.primary.withValues(alpha: 0.08),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            )
          : null,
      child: TextFormField(
        controller: _emailController,
        enabled: !isLoading,
        keyboardType: TextInputType.emailAddress,
        textInputAction: TextInputAction.next,
        decoration: InputDecoration(
          labelText: 'Email',
          hintText: 'Enter your email address',
          prefixIcon: Icon(
            Icons.email_outlined,
            color: theme.colorScheme.primary,
          ),
        ),
        validator: _validateEmail,
        autovalidateMode: AutovalidateMode.onUserInteraction,
      ),
    );
  }

  Widget _buildPasswordField(bool isLoading, bool isPlayful, ThemeData theme) {
    return Container(
      decoration: isPlayful
          ? BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: theme.colorScheme.primary.withValues(alpha: 0.08),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            )
          : null,
      child: TextFormField(
        controller: _passwordController,
        enabled: !isLoading,
        obscureText: _obscurePassword,
        textInputAction:
            _isRegistrationMode ? TextInputAction.next : TextInputAction.done,
        onFieldSubmitted: (_) {
          if (!isLoading && !_isRegistrationMode) {
            _handleSubmit();
          }
        },
        decoration: InputDecoration(
          labelText: 'Password',
          hintText: 'Enter your password',
          prefixIcon: Icon(
            Icons.lock_outline_rounded,
            color: theme.colorScheme.primary,
          ),
          suffixIcon: IconButton(
            icon: Icon(
              _obscurePassword
                  ? Icons.visibility_outlined
                  : Icons.visibility_off_outlined,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
            ),
            onPressed: () {
              setState(() {
                _obscurePassword = !_obscurePassword;
              });
            },
          ),
        ),
        validator: _validatePassword,
        autovalidateMode: AutovalidateMode.onUserInteraction,
      ),
    );
  }

  Widget _buildConfirmPasswordField(
      bool isLoading, bool isPlayful, ThemeData theme) {
    return Container(
      decoration: isPlayful
          ? BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: theme.colorScheme.primary.withValues(alpha: 0.08),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            )
          : null,
      child: TextFormField(
        controller: _confirmPasswordController,
        enabled: !isLoading,
        obscureText: _obscureConfirmPassword,
        textInputAction: TextInputAction.next,
        decoration: InputDecoration(
          labelText: 'Confirm Password',
          hintText: 'Re-enter your password',
          prefixIcon: Icon(
            Icons.lock_outline_rounded,
            color: theme.colorScheme.primary,
          ),
          suffixIcon: IconButton(
            icon: Icon(
              _obscureConfirmPassword
                  ? Icons.visibility_outlined
                  : Icons.visibility_off_outlined,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
            ),
            onPressed: () {
              setState(() {
                _obscureConfirmPassword = !_obscureConfirmPassword;
              });
            },
          ),
        ),
        validator: _validateConfirmPassword,
        autovalidateMode: AutovalidateMode.onUserInteraction,
      ),
    );
  }

  Widget _buildInviteCodeField(
      bool isLoading, bool isPlayful, ThemeData theme) {
    return Container(
      decoration: isPlayful
          ? BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: theme.colorScheme.primary.withValues(alpha: 0.08),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            )
          : null,
      child: TextFormField(
        controller: _inviteCodeController,
        enabled: !isLoading,
        textInputAction: TextInputAction.done,
        onFieldSubmitted: (_) {
          if (!isLoading) {
            _handleSubmit();
          }
        },
        decoration: InputDecoration(
          labelText: 'Invite Code',
          hintText: 'Enter your invite code',
          prefixIcon: Icon(
            Icons.vpn_key_outlined,
            color: theme.colorScheme.primary,
          ),
        ),
        validator: _validateInviteCode,
        autovalidateMode: AutovalidateMode.onUserInteraction,
      ),
    );
  }

  Widget _buildSubmitButton(bool isLoading, bool isPlayful, ThemeData theme) {
    return Container(
      decoration: isPlayful
          ? BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              gradient: LinearGradient(
                colors: [
                  theme.colorScheme.primary,
                  theme.colorScheme.secondary,
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: theme.colorScheme.primary.withValues(alpha: 0.3),
                  blurRadius: 16,
                  offset: const Offset(0, 8),
                ),
              ],
            )
          : null,
      child: ElevatedButton(
        onPressed: isLoading ? null : _handleSubmit,
        style: isPlayful
            ? ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                minimumSize: const Size(double.infinity, 56),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
              )
            : ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 52),
              ),
        child: isLoading
            ? SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    theme.colorScheme.onPrimary,
                  ),
                ),
              )
            : Text(
                _isRegistrationMode ? 'Register' : 'Sign In',
                style: TextStyle(
                  fontSize: isPlayful ? 18 : 16,
                  fontWeight: isPlayful ? FontWeight.w700 : FontWeight.w600,
                  letterSpacing: isPlayful ? 0.5 : 0,
                ),
              ),
      ),
    );
  }

  Widget _buildToggleModeButton(
      bool isPlayful, ThemeData theme, bool isLoading) {
    return TextButton(
      onPressed: isLoading ? null : _toggleMode,
      child: Text(
        _isRegistrationMode
            ? 'Already have an account?'
            : "I don't have an account",
        style: TextStyle(
          fontWeight: isPlayful ? FontWeight.w600 : FontWeight.w500,
          fontSize: isPlayful ? 15 : 14,
          color: isLoading
              ? theme.colorScheme.onSurface.withValues(alpha: 0.4)
              : null,
        ),
      ),
    );
  }

  Widget _buildForgotPasswordButton(bool isPlayful, ThemeData theme) {
    return TextButton(
      onPressed: () {
        // TODO: Implement forgot password functionality
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Forgot password feature coming soon!'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      },
      child: Text(
        'Forgot Password?',
        style: TextStyle(
          fontWeight: isPlayful ? FontWeight.w600 : FontWeight.w500,
          fontSize: isPlayful ? 15 : 14,
        ),
      ),
    );
  }
}

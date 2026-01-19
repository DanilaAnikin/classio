import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:classio/core/localization/app_localizations.dart';
import '../../../../core/providers/theme_provider.dart';
import '../../../../core/theme/spacing.dart';
import '../../../../core/theme/app_radius.dart';
import '../../data/repositories/supabase_auth_repository.dart';
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
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isRegistrationMode = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _inviteCodeController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
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

    // Get the ScaffoldMessenger before building the SnackBar
    final scaffoldMessenger = ScaffoldMessenger.of(context);

    scaffoldMessenger.clearSnackBars(); // Clear any existing snackbars first

    scaffoldMessenger.showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Theme.of(context).colorScheme.error,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 6),
        action: SnackBarAction(
          label: 'Dismiss',
          textColor: Colors.white,
          onPressed: () {
            scaffoldMessenger.hideCurrentSnackBar();
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
      _firstNameController.clear();
      _lastNameController.clear();
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
            firstName: _firstNameController.text.trim(),
            lastName: _lastNameController.text.trim(),
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
      return context.l10n.emailRequired;
    }

    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );

    if (!emailRegex.hasMatch(value)) {
      return context.l10n.emailInvalid;
    }

    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return context.l10n.passwordRequired;
    }

    if (value.length < 6) {
      return context.l10n.passwordTooShort;
    }

    return null;
  }

  String? _validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return context.l10n.pleaseConfirmPassword;
    }

    if (value != _passwordController.text) {
      return context.l10n.passwordsDoNotMatch;
    }

    return null;
  }

  String? _validateInviteCode(String? value) {
    if (value == null || value.isEmpty) {
      return context.l10n.inviteCodeRequiredError;
    }

    if (value.length < 6) {
      return context.l10n.inviteCodeTooShort;
    }

    return null;
  }

  String? _validateFirstName(String? value) {
    if (value == null || value.isEmpty) {
      return context.l10n.firstNameRequired;
    }

    if (value.trim().length < 2) {
      return context.l10n.firstNameTooShort;
    }

    return null;
  }

  String? _validateLastName(String? value) {
    if (value == null || value.isEmpty) {
      return context.l10n.lastNameRequired;
    }

    if (value.trim().length < 2) {
      return context.l10n.lastNameTooShort;
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
              padding: EdgeInsets.symmetric(horizontal: AppSpacing.xl),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Logo/Icon
                    _buildLogo(isPlayful, theme),

                    SizedBox(height: AppSpacing.xxl),

                    // Welcome Text
                    _buildWelcomeText(isPlayful, theme),

                    SizedBox(height: AppSpacing.xs),

                    // Subtitle
                    _buildSubtitle(isPlayful, theme),

                    SizedBox(height: AppSpacing.xxxl + AppSpacing.xs),

                    // Email Field
                    _buildEmailField(isLoading, isPlayful, theme),

                    SizedBox(height: AppSpacing.md),

                    // Password Field
                    _buildPasswordField(isLoading, isPlayful, theme),

                    // Registration-only fields
                    if (_isRegistrationMode) ...[
                      SizedBox(height: AppSpacing.md),

                      // First Name Field
                      _buildFirstNameField(isLoading, isPlayful, theme),

                      SizedBox(height: AppSpacing.md),

                      // Last Name Field
                      _buildLastNameField(isLoading, isPlayful, theme),

                      SizedBox(height: AppSpacing.md),

                      // Confirm Password Field
                      _buildConfirmPasswordField(isLoading, isPlayful, theme),

                      SizedBox(height: AppSpacing.md),

                      // Invite Code Field
                      _buildInviteCodeField(isLoading, isPlayful, theme),
                    ],

                    SizedBox(height: AppSpacing.xl),

                    // Login/Register Button
                    _buildSubmitButton(isLoading, isPlayful, theme),

                    SizedBox(height: AppSpacing.md),

                    // Toggle Mode Link
                    _buildToggleModeButton(isPlayful, theme, isLoading),

                    if (!_isRegistrationMode) ...[
                      SizedBox(height: AppSpacing.xs),

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
          borderRadius: isPlayful ? null : AppRadius.largeBorderRadius,
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
      _isRegistrationMode ? context.l10n.joinClassio : context.l10n.welcomeToClassio,
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
          ? context.l10n.createAccountToGetStarted
          : context.l10n.signInToContinue,
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
          labelText: context.l10n.emailLabel,
          hintText: context.l10n.enterYourEmail,
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
          labelText: context.l10n.passwordLabel,
          hintText: context.l10n.enterYourPassword,
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
          labelText: context.l10n.confirmPasswordLabel,
          hintText: context.l10n.reEnterPassword,
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
          labelText: context.l10n.inviteCodeLabel,
          hintText: context.l10n.enterYourInviteCode,
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

  Widget _buildFirstNameField(
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
        controller: _firstNameController,
        enabled: !isLoading,
        textInputAction: TextInputAction.next,
        textCapitalization: TextCapitalization.words,
        decoration: InputDecoration(
          labelText: context.l10n.firstNameLabel,
          hintText: context.l10n.enterYourFirstName,
          prefixIcon: Icon(
            Icons.person_outline,
            color: theme.colorScheme.primary,
          ),
        ),
        validator: _validateFirstName,
        autovalidateMode: AutovalidateMode.onUserInteraction,
      ),
    );
  }

  Widget _buildLastNameField(
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
        controller: _lastNameController,
        enabled: !isLoading,
        textInputAction: TextInputAction.next,
        textCapitalization: TextCapitalization.words,
        decoration: InputDecoration(
          labelText: context.l10n.lastNameLabel,
          hintText: context.l10n.enterYourLastName,
          prefixIcon: Icon(
            Icons.person_outline,
            color: theme.colorScheme.primary,
          ),
        ),
        validator: _validateLastName,
        autovalidateMode: AutovalidateMode.onUserInteraction,
      ),
    );
  }

  Widget _buildSubmitButton(bool isLoading, bool isPlayful, ThemeData theme) {
    return Container(
      decoration: isPlayful
          ? BoxDecoration(
              borderRadius: AppRadius.xlBorderRadius,
              gradient: LinearGradient(
                colors: [
                  theme.colorScheme.primary,
                  theme.colorScheme.secondary,
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: theme.colorScheme.primary.withValues(alpha: 0.3),
                  blurRadius: AppSpacing.md,
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
                  borderRadius: AppRadius.xlBorderRadius,
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
                _isRegistrationMode ? context.l10n.register : context.l10n.signIn,
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
            ? context.l10n.alreadyHaveAccount
            : context.l10n.iDontHaveAccount,
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
      onPressed: () => _showForgotPasswordDialog(isPlayful, theme),
      child: Text(
        context.l10n.forgotPassword,
        style: TextStyle(
          fontWeight: isPlayful ? FontWeight.w600 : FontWeight.w500,
          fontSize: isPlayful ? 15 : 14,
        ),
      ),
    );
  }

  void _showForgotPasswordDialog(bool isPlayful, ThemeData theme) {
    final forgotPasswordEmailController = TextEditingController();
    final forgotPasswordFormKey = GlobalKey<FormState>();
    bool isSubmitting = false;

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(isPlayful ? AppRadius.xl : AppRadius.md),
              ),
              title: Text(
                context.l10n.resetPassword,
                style: TextStyle(
                  fontWeight: isPlayful ? FontWeight.w700 : FontWeight.w600,
                ),
              ),
              content: Form(
                key: forgotPasswordFormKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      context.l10n.resetPasswordInstructions,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                      ),
                    ),
                    SizedBox(height: AppSpacing.md),
                    TextFormField(
                      controller: forgotPasswordEmailController,
                      enabled: !isSubmitting,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.done,
                      onFieldSubmitted: (_) {
                        if (!isSubmitting) {
                          _submitForgotPassword(
                            dialogContext,
                            forgotPasswordFormKey,
                            forgotPasswordEmailController,
                            isPlayful,
                            theme,
                            setDialogState,
                            () => isSubmitting,
                            (value) {
                              isSubmitting = value;
                            },
                          );
                        }
                      },
                      decoration: InputDecoration(
                        labelText: context.l10n.emailLabel,
                        hintText: context.l10n.enterYourEmail,
                        prefixIcon: Icon(
                          Icons.email_outlined,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                      validator: _validateEmail,
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: isSubmitting
                      ? null
                      : () => Navigator.of(dialogContext).pop(),
                  child: Text(
                    context.l10n.cancel,
                    style: TextStyle(
                      color: isSubmitting
                          ? theme.colorScheme.onSurface.withValues(alpha: 0.4)
                          : null,
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: isSubmitting
                      ? null
                      : () => _submitForgotPassword(
                            dialogContext,
                            forgotPasswordFormKey,
                            forgotPasswordEmailController,
                            isPlayful,
                            theme,
                            setDialogState,
                            () => isSubmitting,
                            (value) {
                              isSubmitting = value;
                            },
                          ),
                  child: isSubmitting
                      ? SizedBox(
                          height: 16,
                          width: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              theme.colorScheme.onPrimary,
                            ),
                          ),
                        )
                      : Text(context.l10n.sendResetLink),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _submitForgotPassword(
    BuildContext dialogContext,
    GlobalKey<FormState> formKey,
    TextEditingController emailController,
    bool isPlayful,
    ThemeData theme,
    void Function(void Function()) setDialogState,
    bool Function() getIsSubmitting,
    void Function(bool) setIsSubmitting,
  ) async {
    if (getIsSubmitting()) return;

    if (formKey.currentState?.validate() ?? false) {
      setDialogState(() {
        setIsSubmitting(true);
      });

      try {
        final authRepository =
            ref.read(authRepositoryProvider) as SupabaseAuthRepository;
        final success = await authRepository.resetPassword(
          email: emailController.text.trim(),
        );

        if (!dialogContext.mounted) return;

        Navigator.of(dialogContext).pop();

        if (!mounted) return;

        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                context.l10n.passwordResetLinkSent,
              ),
              backgroundColor: theme.colorScheme.primary,
              behavior: SnackBarBehavior.floating,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                context.l10n.failedToSendResetLink,
              ),
              backgroundColor: theme.colorScheme.error,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      } catch (e) {
        if (!dialogContext.mounted) return;

        setDialogState(() {
          setIsSubmitting(false);
        });

        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(context.l10n.failedToSendResetLink),
            backgroundColor: theme.colorScheme.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }
}

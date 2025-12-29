import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iconsax/iconsax.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/services/biometric_service.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../../../../core/widgets/gradient_button.dart';
import '../../domain/entities/user.dart';
import '../bloc/auth_bloc.dart';
import '../widgets/role_selector.dart';
import '../widgets/animated_background.dart';
import '../widgets/biometric_button.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _biometricService = BiometricService();
  
  UserRole _selectedRole = UserRole.manager;
  bool _rememberMe = false;
  bool _biometricAvailable = false;
  bool _biometricEnabled = false;
  String? _biometricType;

  @override
  void initState() {
    super.initState();
    // Pre-fill demo credentials
    _emailController.text = 'manager@pos.com';
    _passwordController.text = 'manager123';
    _checkBiometricAvailability();
  }

  Future<void> _checkBiometricAvailability() async {
    final canCheck = await _biometricService.canCheckBiometrics();
    
    if (canCheck) {
      String? type;
      if (await _biometricService.hasFaceIdSupport()) {
        type = 'face';
      } else if (await _biometricService.hasFingerprintSupport()) {
        type = 'fingerprint';
      }
      
      setState(() {
        _biometricAvailable = true;
        _biometricType = type;
        // Check if user previously enabled biometric
        // In production, this would come from secure storage
        _biometricEnabled = true; // For demo, always show if available
      });
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _onRoleChanged(UserRole role) {
    setState(() {
      _selectedRole = role;
      // Update demo credentials based on role
      switch (role) {
        case UserRole.owner:
          _emailController.text = 'owner@pos.com';
          _passwordController.text = 'owner123';
          break;
        case UserRole.manager:
          _emailController.text = 'manager@pos.com';
          _passwordController.text = 'manager123';
          break;
        case UserRole.cashier:
          _emailController.text = 'cashier@pos.com';
          _passwordController.text = 'cashier123';
          break;
      }
    });
    context.read<AuthBloc>().add(AuthRoleChanged(role));
  }

  void _onLogin() {
    if (_formKey.currentState?.validate() ?? false) {
      context.read<AuthBloc>().add(
            AuthLoginRequested(
              email: _emailController.text.trim(),
              password: _passwordController.text,
              role: _selectedRole,
            ),
          );
    }
  }

  Future<void> _onBiometricLogin() async {
    final result = await _biometricService.authenticate(
      reason: 'Authenticate to login to POS System',
    );

    if (result.success) {
      // Biometric auth successful, login with cached credentials
      // In production, you would retrieve encrypted credentials here
      if (mounted) {
        context.read<AuthBloc>().add(
              AuthLoginRequested(
                email: _emailController.text.trim(),
                password: _passwordController.text,
                role: _selectedRole,
              ),
            );
      }
    } else {
      // Show error message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result.message),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.error,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            );
          }
        },
        child: Stack(
          children: [
            // Animated background
            const AnimatedBackground(),

            // Main content
            SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: size.height -
                        MediaQuery.of(context).padding.top -
                        MediaQuery.of(context).padding.bottom,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 40),

                      // Logo and title
                      _buildHeader(),

                      const SizedBox(height: 48),

                      // Role selector
                      RoleSelector(
                        selectedRole: _selectedRole,
                        onRoleChanged: _onRoleChanged,
                      ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.2),

                      const SizedBox(height: 40),

                      // Login form
                      _buildLoginForm(),

                      // Biometric login button
                      if (_biometricAvailable && _biometricEnabled) ...[
                        const SizedBox(height: 24),
                        _buildBiometricSection(),
                      ],

                      const SizedBox(height: 40),

                      // Demo credentials info
                      _buildDemoInfo(),

                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        // Animated logo
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            gradient: AppColors.primaryGradient,
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withOpacity(0.4),
                blurRadius: 30,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: const Icon(
            Iconsax.shop5,
            size: 48,
            color: Colors.white,
          ),
        )
            .animate(onPlay: (c) => c.repeat(reverse: true))
            .scale(
              begin: const Offset(1, 1),
              end: const Offset(1.05, 1.05),
              duration: 2000.ms,
              curve: Curves.easeInOut,
            )
            .animate()
            .fadeIn(duration: 400.ms)
            .slideY(begin: -0.3),

        const SizedBox(height: 24),

        // App name
        ShaderMask(
          shaderCallback: (bounds) =>
              AppColors.primaryGradient.createShader(bounds),
          child: const Text(
            AppStrings.appName,
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w800,
              color: Colors.white,
              letterSpacing: -1,
            ),
          ),
        ).animate().fadeIn(delay: 100.ms).slideY(begin: 0.3),

        const SizedBox(height: 8),

        // Tagline
        Text(
          AppStrings.signInToContinue,
          style: TextStyle(
            fontSize: 15,
            color: AppColors.textSecondary.withOpacity(0.8),
          ),
          textAlign: TextAlign.center,
        ).animate().fadeIn(delay: 200.ms),
      ],
    );
  }

  Widget _buildLoginForm() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surface.withOpacity(0.8),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: AppColors.surfaceBorder,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 40,
            offset: const Offset(0, 20),
          ),
        ],
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Email field
            CustomTextField(
              label: AppStrings.email,
              hint: 'Enter your email',
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              prefixIcon: Iconsax.sms,
              validator: (value) {
                if (value?.isEmpty ?? true) {
                  return AppStrings.requiredField;
                }
                if (!value!.contains('@')) {
                  return AppStrings.invalidEmail;
                }
                return null;
              },
            ),

            const SizedBox(height: 20),

            // Password field
            CustomTextField(
              label: AppStrings.password,
              hint: 'Enter your password',
              controller: _passwordController,
              obscureText: true,
              showPasswordToggle: true,
              prefixIcon: Iconsax.lock,
              textInputAction: TextInputAction.done,
              onSubmitted: (_) => _onLogin(),
              validator: (value) {
                if (value?.isEmpty ?? true) {
                  return AppStrings.requiredField;
                }
                if (value!.length < 6) {
                  return AppStrings.passwordTooShort;
                }
                return null;
              },
            ),

            const SizedBox(height: 16),

            // Remember me & Forgot password
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Remember me
                InkWell(
                  onTap: () => setState(() => _rememberMe = !_rememberMe),
                  borderRadius: BorderRadius.circular(8),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 20,
                          height: 20,
                          child: Checkbox(
                            value: _rememberMe,
                            onChanged: (v) =>
                                setState(() => _rememberMe = v ?? false),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          AppStrings.rememberMe,
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Forgot password
                TextButton(
                  onPressed: () {
                    // TODO: Implement forgot password
                  },
                  child: Text(
                    AppStrings.forgotPassword,
                    style: TextStyle(
                      color: AppColors.primary,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Login button
            BlocBuilder<AuthBloc, AuthState>(
              builder: (context, state) {
                return GradientButton(
                  text: AppStrings.signIn,
                  isLoading: state is AuthLoading,
                  onPressed: _onLogin,
                  icon: Iconsax.login,
                );
              },
            ),
          ],
        ),
      ),
    ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.2);
  }

  Widget _buildBiometricSection() {
    return Column(
      children: [
        // Divider with "or"
        Row(
          children: [
            Expanded(
              child: Divider(
                color: AppColors.surfaceBorder,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'or',
                style: TextStyle(
                  color: AppColors.textTertiary,
                  fontSize: 13,
                ),
              ),
            ),
            Expanded(
              child: Divider(
                color: AppColors.surfaceBorder,
              ),
            ),
          ],
        ),
        
        const SizedBox(height: 24),

        // Biometric button
        BiometricButton(
          type: _biometricType ?? 'fingerprint',
          onPressed: _onBiometricLogin,
        ),
      ],
    ).animate().fadeIn(delay: 400.ms);
  }

  Widget _buildDemoInfo() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.info.withAlpha(10),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.info.withOpacity(0.3),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(
                Iconsax.info_circle,
                color: AppColors.info,
                size: 20,
              ),
              const SizedBox(width: 12),
              Text(
                'Demo Credentials',
                style: TextStyle(
                  color: AppColors.info,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Select a role above to auto-fill demo credentials.\n'
            'Passwords: owner123, manager123, cashier123',
            style: TextStyle(
              color: AppColors.info.withOpacity(0.8),
              fontSize: 12,
              height: 1.5,
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 500.ms);
  }
}

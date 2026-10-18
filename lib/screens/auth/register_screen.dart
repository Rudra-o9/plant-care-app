import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_text_field.dart';
import '../../utils/validators.dart';
import '../../services/auth_service.dart';
import '../main_navigation_screen.dart';
import '../../utils/page_transitions.dart';

/// Registration screen with name, surname, 10-digit mobile number, restricted email, and password validation.
class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _surnameController = TextEditingController();
  final _mobileController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _acceptedTerms = false;
  final _authService = AuthService();

  @override
  void dispose() {
    _firstNameController.dispose();
    _surnameController.dispose();
    _mobileController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  double _calculatePasswordStrength(String password) {
    if (password.isEmpty) return 0.0;
    if (password.length < 6) return 0.3;
    if (password.length < 10) return 0.6;
    return 1.0;
  }

  Color _getStrengthColor(double strength) {
    if (strength <= 0.3) return AppColors.error;
    if (strength <= 0.6) return AppColors.warning;
    return AppColors.success;
  }

  void _handleRegister() async {
    if (!_acceptedTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please accept the Terms & Conditions to register.'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    if (_formKey.currentState!.validate()) {
      final success = await _authService.register(
        name: _firstNameController.text,
        surname: _surnameController.text,
        mobileNumber: _mobileController.text,
        email: _emailController.text,
        password: _passwordController.text,
      );

      if (success && mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          AppPageRoute.fadeIn(const MainNavigationScreen()),
          (route) => false,
        );
      } else if (mounted && _authService.errorMessage != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_authService.errorMessage!),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final passwordStrength = _calculatePasswordStrength(_passwordController.text);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
          child: ListenableBuilder(
            listenable: _authService,
            builder: (context, _) {
              return Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Create your account 🌱',
                      style: AppTextStyles.displayMedium.copyWith(fontSize: 26),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Start your personal plant-care journey with us.',
                      style: AppTextStyles.bodyMedium,
                    ),
                    const SizedBox(height: 28),

                    // First Name Input
                    AppTextField(
                      controller: _firstNameController,
                      label: 'First Name',
                      hint: 'Alex',
                      prefixIcon: Icons.person_outline_rounded,
                      textCapitalization: TextCapitalization.words,
                      validator: (val) => Validators.validateName(val, 'First Name'),
                    ),
                    const SizedBox(height: 16),

                    // Surname Input
                    AppTextField(
                      controller: _surnameController,
                      label: 'Surname',
                      hint: 'Rivera',
                      prefixIcon: Icons.person_outline_rounded,
                      textCapitalization: TextCapitalization.words,
                      validator: (val) => Validators.validateName(val, 'Surname'),
                    ),
                    const SizedBox(height: 16),

                    // Mobile Number Input (strictly 10 digits)
                    AppTextField(
                      controller: _mobileController,
                      label: 'Mobile Number',
                      hint: '10-digit mobile number',
                      prefixIcon: Icons.phone_outlined,
                      keyboardType: TextInputType.phone,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(10),
                      ],
                      maxLength: 10,
                      validator: Validators.validateMobileNumber,
                    ),
                    const SizedBox(height: 16),

                    // Email Input (restricted format)
                    AppTextField(
                      controller: _emailController,
                      label: 'Email Address',
                      hint: 'name@example.com',
                      prefixIcon: Icons.email_outlined,
                      keyboardType: TextInputType.emailAddress,
                      validator: Validators.validateEmail,
                    ),
                    const SizedBox(height: 16),

                    // Password Input
                    AppTextField(
                      controller: _passwordController,
                      label: 'Password',
                      hint: 'Min. 6 characters',
                      prefixIcon: Icons.lock_outline_rounded,
                      isPassword: true,
                      onChanged: (val) => setState(() {}),
                      validator: Validators.validatePassword,
                    ),
                    const SizedBox(height: 8),

                    // Password Strength Bar Indicator
                    if (_passwordController.text.isNotEmpty) ...[
                      Row(
                        children: [
                          Expanded(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: LinearProgressIndicator(
                                value: passwordStrength,
                                backgroundColor: AppColors.border,
                                valueColor: AlwaysStoppedAnimation<Color>(_getStrengthColor(passwordStrength)),
                                minHeight: 5,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            passwordStrength <= 0.3 ? 'Weak' : (passwordStrength <= 0.6 ? 'Good' : 'Strong'),
                            style: AppTextStyles.caption.copyWith(
                              color: _getStrengthColor(passwordStrength),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                    ],

                    // Confirm Password Input
                    AppTextField(
                      controller: _confirmPasswordController,
                      label: 'Confirm Password',
                      hint: 'Re-enter your password',
                      prefixIcon: Icons.lock_clock_outlined,
                      isPassword: true,
                      validator: (val) => Validators.validateConfirmPassword(val, _passwordController.text),
                    ),
                    const SizedBox(height: 16),

                    // Terms & Conditions Checkbox
                    Row(
                      children: [
                        Checkbox(
                          value: _acceptedTerms,
                          activeColor: AppColors.primary,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                          onChanged: (val) {
                            setState(() {
                              _acceptedTerms = val ?? false;
                            });
                          },
                        ),
                        Expanded(
                          child: Text.rich(
                            TextSpan(
                              text: 'I agree to the ',
                              style: AppTextStyles.bodySmall,
                              children: [
                                TextSpan(
                                  text: 'Terms of Service',
                                  style: AppTextStyles.bodySmall.copyWith(
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const TextSpan(text: ' & '),
                                TextSpan(
                                  text: 'Privacy Policy',
                                  style: AppTextStyles.bodySmall.copyWith(
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Register Button
                    AppButton(
                      text: 'Create Account',
                      isLoading: _authService.isLoading,
                      onPressed: _handleRegister,
                    ),
                    const SizedBox(height: 24),

                    // Navigation to Login
                    Center(
                      child: Wrap(
                        alignment: WrapAlignment.center,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          Text(
                            'Already have an account? ',
                            style: AppTextStyles.bodyMedium,
                          ),
                          GestureDetector(
                            onTap: () {
                              Navigator.of(context).pop();
                            },
                            child: Text(
                              'Login',
                              style: AppTextStyles.titleMedium.copyWith(
                                color: AppColors.primary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

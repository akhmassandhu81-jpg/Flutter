import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:learning_plateform/navigation/auth_gate.dart';
import 'package:learning_plateform/services/auth_service.dart';
import 'package:learning_plateform/utils/app_colors.dart';
import 'package:learning_plateform/utils/app_text_styles.dart';
import 'dart:math' as math;

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _agreedToTerms = false;
  bool _isLoading = false;

  late AnimationController _animController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOut),
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.08), end: Offset.zero).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOut),
    );

    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    _fullNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF06091A),
              Color(0xFF0D1230),
              Color(0xFF060918),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            stops: [0.0, 0.5, 1.0],
          ),
        ),
        child: Stack(
          children: [
            // Background particles
            ...List.generate(18, (i) => _buildParticle(i)),

            // Scrollable content
            SafeArea(
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: SlideTransition(
                  position: _slideAnimation,
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 28.0),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const SizedBox(height: 40),

                          // Logo
                          Center(child: _buildLogo()),

                          const SizedBox(height: 20),

                          // LMS ARENA label
                          Center(
                            child: Text(
                              'LMS ARENA',
                              style: AppTextStyles.caption.copyWith(
                                color: AppColors.accentCyan,
                                fontSize: 12,
                                letterSpacing: 4.0,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),

                          const SizedBox(height: 20),

                          // Title
                          Center(
                            child: Text(
                              'Create Your Account',
                              style: AppTextStyles.heading2.copyWith(
                                fontSize: 26,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.2,
                              ),
                            ),
                          ),

                          const SizedBox(height: 8),

                          // Subtitle
                          Center(
                            child: Text(
                              'Join LMS ARENA and start learning smarter.',
                              style: AppTextStyles.body2.copyWith(
                                color: AppColors.textSecondary,
                                fontSize: 13,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),

                          const SizedBox(height: 32),

                          // ── Full Name ────────────────────────────────────
                          _buildFieldLabel('Full Name'),
                          const SizedBox(height: 10),
                          _buildTextField(
                            controller: _fullNameController,
                            hint: 'Enter your full name',
                            prefixIcon: Icons.person_outline,
                            keyboardType: TextInputType.name,
                            textCapitalization: TextCapitalization.words,
                            validator: (v) {
                              if (v == null || v.trim().isEmpty) {
                                return 'Please enter your full name';
                              }
                              if (v.trim().length < 2) {
                                return 'Name must be at least 2 characters';
                              }
                              return null;
                            },
                          ),

                          const SizedBox(height: 18),

                          // ── Email Address ────────────────────────────────
                          _buildFieldLabel('Email Address'),
                          const SizedBox(height: 10),
                          _buildTextField(
                            controller: _emailController,
                            hint: 'Enter your email address',
                            prefixIcon: Icons.email_outlined,
                            keyboardType: TextInputType.emailAddress,
                            validator: (v) {
                              if (v == null || v.isEmpty) {
                                return 'Please enter your email';
                              }
                              final emailRegex = RegExp(
                                  r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
                              if (!emailRegex.hasMatch(v)) {
                                return 'Please enter a valid email';
                              }
                              return null;
                            },
                          ),

                          const SizedBox(height: 18),

                          // ── Password ─────────────────────────────────────
                          _buildFieldLabel('Password'),
                          const SizedBox(height: 10),
                          _buildTextField(
                            controller: _passwordController,
                            hint: 'Create a password',
                            prefixIcon: Icons.lock_outline,
                            obscureText: _obscurePassword,
                            suffixIcon: GestureDetector(
                              onTap: () => setState(
                                  () => _obscurePassword = !_obscurePassword),
                              child: Icon(
                                _obscurePassword
                                    ? Icons.visibility_off_outlined
                                    : Icons.visibility_outlined,
                                color: AppColors.textTertiary,
                                size: 20,
                              ),
                            ),
                            validator: (v) {
                              if (v == null || v.isEmpty) {
                                return 'Please create a password';
                              }
                              if (v.length < 8) {
                                return 'Password must be at least 8 characters';
                              }
                              return null;
                            },
                          ),

                          const SizedBox(height: 8),

                          // Password hint
                          Row(
                            children: [
                              Container(
                                width: 6,
                                height: 6,
                                decoration: const BoxDecoration(
                                  color: AppColors.accentCyan,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Use at least 8 characters with numbers & symbols',
                                style: AppTextStyles.caption.copyWith(
                                  color: AppColors.textSecondary,
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 18),

                          // ── Confirm Password ──────────────────────────────
                          _buildFieldLabel('Confirm Password'),
                          const SizedBox(height: 10),
                          _buildTextField(
                            controller: _confirmPasswordController,
                            hint: 'Re-enter your password',
                            prefixIcon: Icons.lock_outline,
                            obscureText: _obscureConfirmPassword,
                            suffixIcon: GestureDetector(
                              onTap: () => setState(() =>
                                  _obscureConfirmPassword =
                                      !_obscureConfirmPassword),
                              child: Icon(
                                _obscureConfirmPassword
                                    ? Icons.visibility_off_outlined
                                    : Icons.visibility_outlined,
                                color: AppColors.textTertiary,
                                size: 20,
                              ),
                            ),
                            validator: (v) {
                              if (v == null || v.isEmpty) {
                                return 'Please confirm your password';
                              }
                              if (v != _passwordController.text) {
                                return 'Passwords do not match';
                              }
                              return null;
                            },
                          ),

                          const SizedBox(height: 20),

                          // ── Terms & Privacy checkbox ──────────────────────
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              SizedBox(
                                width: 20,
                                height: 20,
                                child: Checkbox(
                                  value: _agreedToTerms,
                                  onChanged: (val) => setState(
                                      () => _agreedToTerms = val ?? false),
                                  activeColor: AppColors.accentBlue,
                                  checkColor: Colors.white,
                                  side: BorderSide(
                                    color: _agreedToTerms
                                        ? AppColors.accentBlue
                                        : AppColors.textTertiary,
                                    width: 1.5,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  materialTapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: RichText(
                                  text: TextSpan(
                                    style: AppTextStyles.caption.copyWith(
                                      color: AppColors.textSecondary,
                                      fontSize: 12,
                                    ),
                                    children: [
                                      const TextSpan(text: 'I agree to the '),
                                      TextSpan(
                                        text: 'Terms of Service',
                                        style: AppTextStyles.caption.copyWith(
                                          color: AppColors.accentCyan,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                        ),
                                        recognizer: TapGestureRecognizer()
                                          ..onTap = () {
                                            // TODO: open Terms of Service
                                          },
                                      ),
                                      const TextSpan(text: ' and '),
                                      TextSpan(
                                        text: 'Privacy Policy',
                                        style: AppTextStyles.caption.copyWith(
                                          color: AppColors.accentCyan,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                        ),
                                        recognizer: TapGestureRecognizer()
                                          ..onTap = () {
                                            // TODO: open Privacy Policy
                                          },
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 28),

                          // ── Create Account button ─────────────────────────
                          _buildCreateAccountButton(),

                          const SizedBox(height: 24),

                          // ── OR divider ────────────────────────────────────
                          Row(
                            children: [
                              Expanded(
                                  child: Container(
                                      height: 1,
                                      color: AppColors.borderColor)),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16),
                                child: Text(
                                  'OR',
                                  style: AppTextStyles.caption.copyWith(
                                    color: AppColors.textTertiary,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                              Expanded(
                                  child: Container(
                                      height: 1,
                                      color: AppColors.borderColor)),
                            ],
                          ),

                          const SizedBox(height: 24),

                          // ── Continue with Google ──────────────────────────
                          _buildGoogleButton(),

                          const SizedBox(height: 50),

                          // ── Already have an account? Sign In ──────────────
                          Center(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'Already have an account?  ',
                                  style: AppTextStyles.body2.copyWith(
                                    color: AppColors.textSecondary,
                                    fontSize: 13,
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () => Navigator.pop(context),
                                  child: Text(
                                    'Sign In',
                                    style: AppTextStyles.body2.copyWith(
                                      color: AppColors.accentCyan,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 32),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Field label ───────────────────────────────────────────────────────────
  Widget _buildFieldLabel(String label) {
    return Text(
      label,
      style: AppTextStyles.body2.copyWith(
        color: AppColors.textPrimary,
        fontSize: 13,
        fontWeight: FontWeight.w500,
      ),
    );
  }

  // ── Logo ──────────────────────────────────────────────────────────────────
  Widget _buildLogo() {
    return Container(
      width: 72,
      height: 72,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1F3A),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.accentCyan.withValues(alpha: 0.25),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.accentCyan.withValues(alpha: 0.18),
            blurRadius: 22,
            spreadRadius: 3,
          ),
        ],
      ),
      child: CustomPaint(painter: _LogoPainter()),
    );
  }

  // ── Text field ────────────────────────────────────────────────────────────
  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData prefixIcon,
    TextInputType keyboardType = TextInputType.text,
    TextCapitalization textCapitalization = TextCapitalization.none,
    bool obscureText = false,
    Widget? suffixIcon,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      textCapitalization: textCapitalization,
      style: AppTextStyles.body2.copyWith(
        color: AppColors.textPrimary,
        fontSize: 14,
      ),
      validator: validator,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: AppTextStyles.body2.copyWith(
          color: AppColors.textTertiary,
          fontSize: 14,
        ),
        prefixIcon: Icon(prefixIcon, color: AppColors.textTertiary, size: 20),
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: const Color(0xFF111428),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: AppColors.borderColor.withValues(alpha: 0.6),
            width: 1,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide:
              const BorderSide(color: AppColors.accentBlue, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.redAccent, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide:
              const BorderSide(color: Colors.redAccent, width: 1.5),
        ),
        contentPadding:
            const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      ),
    );
  }

  // ── Create Account button ─────────────────────────────────────────────────
  Widget _buildCreateAccountButton() {
    return GestureDetector(
      onTap: _isLoading ? null : _handleCreateAccount,
      child: Container(
        height: 54,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF4A9FFF), Color(0xFF7C3AED)],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: AppColors.accentBlue.withValues(alpha: 0.35),
              blurRadius: 20,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: _isLoading
            ? const Center(
                child: SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                      color: Colors.white, strokeWidth: 2),
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Create Account',
                    style: AppTextStyles.button.copyWith(fontSize: 16),
                  ),
                  const SizedBox(width: 10),
                  const Icon(Icons.arrow_forward,
                      color: Colors.white, size: 20),
                ],
              ),
      ),
    );
  }

  // ── Google button ─────────────────────────────────────────────────────────
  Widget _buildGoogleButton() {
    return GestureDetector(
      onTap: _handleGoogleSignUp,
      child: Container(
        height: 54,
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.borderColor, width: 1.2),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 22,
              height: 22,
              child: CustomPaint(painter: _GoogleIconPainter()),
            ),
            const SizedBox(width: 12),
            Text(
              'Continue with Google',
              style: AppTextStyles.body1.copyWith(
                color: AppColors.textPrimary,
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Background particle ───────────────────────────────────────────────────
  Widget _buildParticle(int index) {
    final rng = math.Random(index * 13);
    final left = rng.nextDouble() * 380;
    final top = rng.nextDouble() * 820;
    final size = rng.nextDouble() * 3 + 1.5;
    final opacity = 0.20 + rng.nextDouble() * 0.25;

    return Positioned(
      left: left,
      top: top,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: AppColors.accentCyan.withValues(alpha: opacity),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: AppColors.accentCyan.withValues(alpha: 0.12),
              blurRadius: 6,
            ),
          ],
        ),
      ),
    );
  }

  // ── Handlers ──────────────────────────────────────────────────────────────
  void _handleCreateAccount() async {
    // 1. Form validation (name, email, password, confirm password)
    if (!_formKey.currentState!.validate()) return;

    // 2. Terms & conditions guard
    if (!_agreedToTerms) {
      _showSnackBar(
        'Please agree to the Terms of Service and Privacy Policy.',
      );
      return;
    }

    setState(() => _isLoading = true);

    // 3. Call AuthService — Firebase Auth + Firestore write
    final result = await AuthService.instance.register(
      fullName: _fullNameController.text,
      email: _emailController.text,
      password: _passwordController.text,
    );

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (result.isSuccess) {
      // 4. Navigate to AuthGate which resolves to HomeScreen
      Navigator.pushAndRemoveUntil(
        context,
        PageRouteBuilder(
          pageBuilder: (_, animation, __) => const AuthGate(),
          transitionsBuilder: (_, animation, __, child) =>
              FadeTransition(opacity: animation, child: child),
          transitionDuration: const Duration(milliseconds: 400),
        ),
        (route) => false, // clear the entire back-stack
      );
    } else {
      // 5. Show user-friendly error — never a raw Firebase code
      _showSnackBar(result.errorMessage!);
    }
  }

  void _handleGoogleSignUp() {
    // TODO: wire Google Sign-In + Firebase
  }

  // ── Snack bar helper ──────────────────────────────────────────────────────
  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.cardBackground,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      ),
    );
  }
}

// ── Logo painter ──────────────────────────────────────────────────────────
class _LogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..shader = AppColors.primaryGradient.createShader(
        Rect.fromLTWH(0, 0, size.width, size.height),
      )
      ..style = PaintingStyle.fill;

    final path = Path()
      ..moveTo(size.width * 0.5, size.height * 0.15)
      ..lineTo(size.width * 0.85, size.height * 0.82)
      ..lineTo(size.width * 0.15, size.height * 0.82)
      ..close();
    canvas.drawPath(path, paint);

    final innerPaint = Paint()
      ..color = AppColors.accentCyan.withValues(alpha: 0.55)
      ..style = PaintingStyle.fill;

    final inner = Path()
      ..moveTo(size.width * 0.5, size.height * 0.32)
      ..lineTo(size.width * 0.66, size.height * 0.65)
      ..lineTo(size.width * 0.34, size.height * 0.65)
      ..close();
    canvas.drawPath(inner, innerPaint);

    final glowPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.25)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);
    canvas.drawCircle(
        Offset(size.width * 0.5, size.height * 0.28), 6, glowPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}

// ── Google "G" icon ───────────────────────────────────────────────────────
class _GoogleIconPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final bgPaint = Paint()..color = Colors.white;
    canvas.drawCircle(
        Offset(size.width / 2, size.height / 2), size.width / 2, bgPaint);

    final textPainter = TextPainter(
      text: TextSpan(
        text: 'G',
        style: TextStyle(
          color: const Color(0xFF4285F4),
          fontSize: size.width * 0.75,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    textPainter.paint(
      canvas,
      Offset(
        (size.width - textPainter.width) / 2,
        (size.height - textPainter.height) / 2,
      ),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}

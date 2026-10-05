import 'package:flutter/material.dart';
import 'package:learning_plateform/navigation/auth_gate.dart';
import 'package:learning_plateform/services/auth_service.dart';
import 'package:learning_plateform/utils/app_colors.dart';
import 'package:learning_plateform/utils/app_text_styles.dart';
import 'package:learning_plateform/screens/signup_screen.dart';
import 'dart:math' as math;

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _obscurePassword = true;
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
    _emailController.dispose();
    _passwordController.dispose();
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

            // Main scrollable content
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
                          const SizedBox(height: 48),

                          // Logo
                          Center(child: _buildLogo()),

                          const SizedBox(height: 28),

                          // LMS ARENA label
                          Center(
                            child: Text(
                              'LMS ARENA',
                              style: AppTextStyles.caption.copyWith(
                                color: AppColors.textSecondary,
                                fontSize: 13,
                                letterSpacing: 4.0,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),

                          const SizedBox(height: 28),

                          // Welcome Back
                          Center(
                            child: Text(
                              'Welcome Back',
                              style: AppTextStyles.heading2.copyWith(
                                fontSize: 28,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.2,
                              ),
                            ),
                          ),

                          const SizedBox(height: 8),

                          // Subtitle
                          Center(
                            child: Text(
                              'Sign in to continue your learning journey.',
                              style: AppTextStyles.body2.copyWith(
                                color: AppColors.textSecondary,
                                fontSize: 13,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),

                          const SizedBox(height: 36),

                          // Email label
                          Text(
                            'Email Address',
                            style: AppTextStyles.body2.copyWith(
                              color: AppColors.textPrimary,
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),

                          const SizedBox(height: 10),

                          // Email field
                          _buildTextField(
                            controller: _emailController,
                            hint: 'Enter your email address',
                            prefixIcon: Icons.email_outlined,
                            keyboardType: TextInputType.emailAddress,
                            validator: (v) {
                              if (v == null || v.isEmpty) {
                                return 'Please enter your email';
                              }
                              if (!v.contains('@')) {
                                return 'Please enter a valid email';
                              }
                              return null;
                            },
                          ),

                          const SizedBox(height: 20),

                          // Password row (label + forgot)
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Password',
                                style: AppTextStyles.body2.copyWith(
                                  color: AppColors.textPrimary,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              GestureDetector(
                                onTap: _handleForgotPassword,
                                child: Text(
                                  'Forgot Password?',
                                  style: AppTextStyles.caption.copyWith(
                                    color: AppColors.accentBlue,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 10),

                          // Password field
                          _buildTextField(
                            controller: _passwordController,
                            hint: '••••••••••••',
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
                                return 'Please enter your password';
                              }
                              return null;
                            },
                          ),

                          const SizedBox(height: 32),

                          // Sign In button
                          _buildSignInButton(),

                          const SizedBox(height: 28),

                          // OR divider
                          Row(
                            children: [
                              Expanded(
                                child: Container(
                                  height: 1,
                                  color: AppColors.borderColor,
                                ),
                              ),
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
                                  color: AppColors.borderColor,
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 28),

                          // Continue with Google button
                          _buildGoogleButton(),

                          const SizedBox(height: 60),

                          // Sign Up row
                          Center(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  "Don't have an account?  ",
                                  style: AppTextStyles.body2.copyWith(
                                    color: AppColors.textSecondary,
                                    fontSize: 13,
                                  ),
                                ),
                                GestureDetector(
                                  behavior: HitTestBehavior.opaque,
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      PageRouteBuilder(
                                        pageBuilder: (_, animation, __) =>
                                            const SignupScreen(),
                                        transitionsBuilder:
                                            (_, animation, __, child) {
                                          return FadeTransition(
                                              opacity: animation, child: child);
                                        },
                                        transitionDuration:
                                            const Duration(milliseconds: 400),
                                      ),
                                    );
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 8, horizontal: 4),
                                    child: Text(
                                      'Sign Up',
                                      style: AppTextStyles.body2.copyWith(
                                        color: AppColors.accentCyan,
                                        fontSize: 13,
                                        fontWeight: FontWeight.w700,
                                      ),
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

  // ── Logo (same style as splash) ───────────────────────────────────────────
  Widget _buildLogo() {
    return Container(
      width: 80,
      height: 80,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1F3A),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: AppColors.accentCyan.withValues(alpha: 0.25),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.accentCyan.withValues(alpha: 0.18),
            blurRadius: 24,
            spreadRadius: 4,
          ),
        ],
      ),
      child: CustomPaint(painter: _LogoPainter()),
    );
  }

  // ── Input field ───────────────────────────────────────────────────────────
  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData prefixIcon,
    TextInputType keyboardType = TextInputType.text,
    bool obscureText = false,
    Widget? suffixIcon,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
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
        prefixIcon: Icon(
          prefixIcon,
          color: AppColors.textTertiary,
          size: 20,
        ),
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
          borderSide: const BorderSide(
            color: AppColors.accentBlue,
            width: 1.5,
          ),
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

  // ── Sign In button ────────────────────────────────────────────────────────
  Widget _buildSignInButton() {
    return GestureDetector(
      onTap: _isLoading ? null : _handleSignIn,
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
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Sign In',
                    style: AppTextStyles.button.copyWith(fontSize: 16),
                  ),
                  const SizedBox(width: 10),
                  const Icon(
                    Icons.arrow_forward,
                    color: Colors.white,
                    size: 20,
                  ),
                ],
              ),
      ),
    );
  }

  // ── Google button ─────────────────────────────────────────────────────────
  Widget _buildGoogleButton() {
    return GestureDetector(
      onTap: _handleGoogleSignIn,
      child: Container(
        height: 54,
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: AppColors.borderColor,
            width: 1.2,
          ),
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
    final rng = math.Random(index * 7);
    final left = rng.nextDouble() * 380;
    final top = rng.nextDouble() * 820;
    final size = rng.nextDouble() * 3 + 1.5;
    final opacity = 0.25 + rng.nextDouble() * 0.2;

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
              color: AppColors.accentCyan.withValues(alpha: 0.15),
              blurRadius: 6,
            ),
          ],
        ),
      ),
    );
  }

  // ── Handlers ──────────────────────────────────────────────────────────────
  void _handleSignIn() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    // Firebase Authentication — credentials checked server-side
    final result = await AuthService.instance.login(
      email: _emailController.text,
      password: _passwordController.text,
    );

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (result.isSuccess) {
      // Navigate to AuthGate — clears the back-stack so back button
      // cannot return to login while authenticated
      Navigator.pushAndRemoveUntil(
        context,
        PageRouteBuilder(
          pageBuilder: (_, animation, __) => const AuthGate(),
          transitionsBuilder: (_, animation, __, child) =>
              FadeTransition(opacity: animation, child: child),
          transitionDuration: const Duration(milliseconds: 400),
        ),
        (route) => false,
      );
    } else {
      _showSnackBar(result.errorMessage!);
    }
  }

  void _handleGoogleSignIn() {
    // TODO: wire Google Sign-In + Firebase
  }

  // ── Forgot password ───────────────────────────────────────────────────────
  void _handleForgotPassword() async {
    final email = _emailController.text.trim();

    if (email.isEmpty) {
      _showSnackBar('Please enter your email address first.');
      return;
    }

    final result = await AuthService.instance.sendPasswordReset(email);

    if (!mounted) return;

    if (result.isSuccess) {
      _showSnackBar('Password reset email sent. Please check your inbox.');
    } else {
      _showSnackBar(result.errorMessage!);
    }
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

// ── Logo painter (same style as splash) ───────────────────────────────────
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

// ── Google coloured "G" icon ───────────────────────────────────────────────
class _GoogleIconPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(0, 0, size.width, size.height);

    final bgPaint = Paint()..color = Colors.white;
    canvas.drawCircle(rect.center, size.width / 2, bgPaint);

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

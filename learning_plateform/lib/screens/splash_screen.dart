import 'package:flutter/material.dart';
import 'package:learning_plateform/utils/app_colors.dart';
import 'package:learning_plateform/utils/app_text_styles.dart';
import 'package:learning_plateform/navigation/auth_gate.dart';
import 'dart:math' as math;

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _progressAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 2500),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.5, curve: Curves.easeIn),
      ),
    );

    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.5, curve: Curves.easeOutBack),
      ),
    );

    _progressAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.5, 1.0, curve: Curves.easeInOut),
      ),
    );

    _controller.forward();

    // Navigate to AuthGate after splash animation completes.
    // AuthGate listens to Firebase authStateChanges and routes to either
    // HomeScreen (logged in) or LoginScreen (not logged in).
    Future.delayed(const Duration(milliseconds: 3000), () {
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder: (_, animation, __) => const AuthGate(),
          transitionsBuilder: (_, animation, __, child) {
            return FadeTransition(opacity: animation, child: child);
          },
          transitionDuration: const Duration(milliseconds: 500),
        ),
      );
    });
  }

  @override
  void dispose() {
    _controller.dispose();
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
              AppColors.primaryBackground,
              Color(0xFF1E2952),
              AppColors.primaryBackground,
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Stack(
          children: [
            // Animated background particles
            ...List.generate(20, (index) => _buildFloatingParticle(index)),

            // Main content
            SafeArea(
              child: Column(
                children: [
                  // Top bar with classes indicator
                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        FadeTransition(
                          opacity: _fadeAnimation,
                          child: Row(
                            children: [
                              Container(
                                width: 8,
                                height: 8,
                                decoration: const BoxDecoration(
                                  color: AppColors.accentCyan,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'CLASSES 6-13',
                                style: AppTextStyles.caption.copyWith(
                                  color: AppColors.textPrimary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        FadeTransition(
                          opacity: _fadeAnimation,
                          child: Row(
                            children: [
                              _buildTopIcon(Icons.notifications_outlined),
                              const SizedBox(width: 16),
                              _buildTopIcon(Icons.account_circle_outlined),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Center logo and branding
                  Expanded(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Logo with animation
                          ScaleTransition(
                            scale: _scaleAnimation,
                            child: FadeTransition(
                              opacity: _fadeAnimation,
                              child: _buildLogo(),
                            ),
                          ),

                          const SizedBox(height: 40),

                          // App name
                          FadeTransition(
                            opacity: _fadeAnimation,
                            child: Text(
                              'LMS ARENA',
                              style: AppTextStyles.heading1.copyWith(
                                fontSize: 36,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 4.0,
                              ),
                            ),
                          ),

                          const SizedBox(height: 16),

                          // Tagline
                          FadeTransition(
                            opacity: _fadeAnimation,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                _buildTaglineText('LEARN'),
                                _buildDot(),
                                _buildTaglineText('INTERACT'),
                                _buildDot(),
                                _buildTaglineText('ACHIEVE'),
                              ],
                            ),
                          ),

                          const SizedBox(height: 60),

                          // Next-Gen Learning Platform badge
                          FadeTransition(
                            opacity: _fadeAnimation,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 12,
                              ),
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: AppColors.accentCyan
                                      .withValues(alpha: 0.3),
                                  width: 1,
                                ),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                'NEXT-GEN  |  LIVE-Active Learning Platform',
                                style: AppTextStyles.caption.copyWith(
                                  color: AppColors.accentCyan,
                                  fontSize: 11,
                                  letterSpacing: 1.5,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Bottom loading indicator
                  Padding(
                    padding: const EdgeInsets.only(bottom: 60.0),
                    child: Column(
                      children: [
                        FadeTransition(
                          opacity: _fadeAnimation,
                          child: Text(
                            'LOADING WORKSPACE',
                            style: AppTextStyles.caption.copyWith(
                              fontSize: 10,
                              letterSpacing: 2.0,
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Progress bar
                        AnimatedBuilder(
                          animation: _progressAnimation,
                          builder: (context, child) {
                            return Container(
                              width: 200,
                              height: 4,
                              decoration: BoxDecoration(
                                color: AppColors.borderColor,
                                borderRadius: BorderRadius.circular(2),
                              ),
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: Container(
                                  width: 200 * _progressAnimation.value,
                                  height: 4,
                                  decoration: BoxDecoration(
                                    gradient: AppColors.primaryGradient,
                                    borderRadius: BorderRadius.circular(2),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),

                        const SizedBox(height: 16),

                        // Dots indicator
                        FadeTransition(
                          opacity: _fadeAnimation,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: List.generate(3, (index) {
                              return AnimatedBuilder(
                                animation: _controller,
                                builder: (context, child) {
                                  final delay = index * 0.2;
                                  final progress =
                                      (_controller.value - delay).clamp(0.0, 1.0);
                                  return Container(
                                    margin: const EdgeInsets.symmetric(
                                        horizontal: 4),
                                    width: 8,
                                    height: 8,
                                    decoration: BoxDecoration(
                                      color: AppColors.accentCyan
                                          .withValues(alpha: progress),
                                      shape: BoxShape.circle,
                                    ),
                                  );
                                },
                              );
                            }),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFloatingParticle(int index) {
    final random = math.Random(index);
    final left = random.nextDouble() * 400;
    final top = random.nextDouble() * 800;
    final size = random.nextDouble() * 4 + 2;
    final duration = random.nextInt(3000) + 2000;

    return Positioned(
      left: left,
      top: top,
      child: TweenAnimationBuilder(
        tween: Tween<double>(begin: 0.2, end: 1.0),
        duration: Duration(milliseconds: duration),
        curve: Curves.easeInOut,
        builder: (context, double value, child) {
          return Opacity(
            opacity: value * 0.6,
            child: Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                color: AppColors.accentCyan.withValues(alpha: 0.5),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.accentCyan.withValues(alpha: 0.3),
                    blurRadius: 8,
                    spreadRadius: 2,
                  ),
                ],
              ),
            ),
          );
        },
        onEnd: () {},
      ),
    );
  }

  Widget _buildLogo() {
    return Container(
      width: 140,
      height: 140,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.cardBackground.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(32),
        border: Border.all(
          color: AppColors.accentCyan.withValues(alpha: 0.3),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.accentCyan.withValues(alpha: 0.2),
            blurRadius: 30,
            spreadRadius: 5,
          ),
        ],
      ),
      child: CustomPaint(painter: LogoPainter()),
    );
  }

  Widget _buildTopIcon(IconData icon) {
    return Icon(icon, color: AppColors.textSecondary, size: 20);
  }

  Widget _buildTaglineText(String text) {
    return Text(
      text,
      style: AppTextStyles.caption.copyWith(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: AppColors.textSecondary,
        letterSpacing: 1.5,
      ),
    );
  }

  Widget _buildDot() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8),
      width: 4,
      height: 4,
      decoration: const BoxDecoration(
        color: AppColors.accentCyan,
        shape: BoxShape.circle,
      ),
    );
  }
}

// ── Logo painter ──────────────────────────────────────────────────────────
class LogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..shader = AppColors.primaryGradient.createShader(
        Rect.fromLTWH(0, 0, size.width, size.height),
      )
      ..style = PaintingStyle.fill;

    final path = Path()
      ..moveTo(size.width * 0.5, size.height * 0.2)
      ..lineTo(size.width * 0.8, size.height * 0.8)
      ..lineTo(size.width * 0.2, size.height * 0.8)
      ..close();
    canvas.drawPath(path, paint);

    final accentPaint = Paint()
      ..color = AppColors.accentCyan.withValues(alpha: 0.5)
      ..style = PaintingStyle.fill;

    final innerPath = Path()
      ..moveTo(size.width * 0.5, size.height * 0.35)
      ..lineTo(size.width * 0.65, size.height * 0.65)
      ..lineTo(size.width * 0.35, size.height * 0.65)
      ..close();
    canvas.drawPath(innerPath, accentPaint);

    final glowPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.3)
      ..style = PaintingStyle.fill
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
    canvas.drawCircle(
        Offset(size.width * 0.5, size.height * 0.3), 8, glowPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

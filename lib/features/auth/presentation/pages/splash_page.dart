import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:honset_app/config/theme/app_colors.dart';
import 'package:honset_app/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:honset_app/features/auth/presentation/cubit/auth_state.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage>
    with TickerProviderStateMixin {
  // ── Animation controllers ────────────────────────────────────────────
  late final AnimationController _logoController;
  late final AnimationController _contentController;
  late final AnimationController _glowController;

  // ── Animations ───────────────────────────────────────────────────────
  late final Animation<double> _logoScale;
  late final Animation<double> _logoOpacity;
  late final Animation<double> _taglineOpacity;
  late final Animation<Offset> _taglineSlide;
  late final Animation<double> _indicatorOpacity;
  late final Animation<double> _glowPulse;

  @override
  void initState() {
    super.initState();

    // Logo: scale up + fade in (0–800ms)
    _logoController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _logoScale = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.easeOutBack),
    );
    _logoOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _logoController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
    );

    // Tagline + indicator: staggered fade in (300ms delay)
    _contentController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _taglineOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _contentController,
        curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
      ),
    );
    _taglineSlide = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _contentController,
        curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
      ),
    );
    _indicatorOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _contentController,
        curve: const Interval(0.5, 1.0, curve: Curves.easeOut),
      ),
    );

    // Background glow: gentle pulsing loop
    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    )..repeat(reverse: true);
    _glowPulse = Tween<double>(begin: 0.08, end: 0.18).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );

    // Kick off the staggered sequence
    _logoController.forward();
    Future<void>.delayed(const Duration(milliseconds: 300), () {
      if (mounted) _contentController.forward();
    });

    // Navigate after animations settle
    Future<void>.delayed(const Duration(milliseconds: 2200), () {
      if (!mounted) return;
      final state = context.read<AuthCubit>().state;
      context.go(state.status == AuthStatus.authenticated ? '/home' : '/login');
    });
  }

  @override
  void dispose() {
    _logoController.dispose();
    _contentController.dispose();
    _glowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final logoSize = math.min(size.width * 0.4, 160.0);

    return Scaffold(
      backgroundColor: AppColors.scaffoldDark,
      body: Stack(
        children: [
          // ── Radial glow behind logo ────────────────────────────────
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _glowPulse,
              builder: (context, _) => CustomPaint(
                painter: _GlowPainter(
                  color: AppColors.electricBlue,
                  opacity: _glowPulse.value,
                  radius: logoSize * 1.8,
                ),
              ),
            ),
          ),

          // ── Main content ───────────────────────────────────────────
          Positioned.fill(
            child: SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                // Top spacer – push content to visual center
                const Spacer(flex: 4),

                // Logo
                FadeTransition(
                  opacity: _logoOpacity,
                  child: ScaleTransition(
                    scale: _logoScale,
                    child: Container(
                      width: logoSize,
                      height: logoSize,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.electricBlue
                                .withValues(alpha: 0.15),
                            blurRadius: 40,
                            spreadRadius: 8,
                          ),
                        ],
                      ),
                      child: ClipOval(
                        child: Image.asset(
                          'assets/images/icon.png',
                          width: logoSize,
                          height: logoSize,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 32),

                // Tagline
                SlideTransition(
                  position: _taglineSlide,
                  child: FadeTransition(
                    opacity: _taglineOpacity,
                    child: Column(
                      children: [
                        Text(
                          'HONEST ACADEMY',
                          style: TextStyle(
                            color: AppColors.pureWhite,
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 4.0,
                            height: 1.2,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'FITNESS & SQUASH ACADEMY',
                          style: TextStyle(
                            color: AppColors.subtitleGray,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 3.0,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Bottom spacer – balanced visual weight
                const Spacer(flex: 4),

                // Loading indicator
                FadeTransition(
                  opacity: _indicatorOpacity,
                  child: SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.0,
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        AppColors.electricBlue,
                      ),
                      backgroundColor:
                          AppColors.electricBlue.withValues(alpha: 0.15),
                    ),
                  ),
                ),

                const SizedBox(height: 48),
              ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Custom painter for the radial blue glow behind the logo
// ─────────────────────────────────────────────────────────────────────────────
class _GlowPainter extends CustomPainter {
  _GlowPainter({
    required this.color,
    required this.opacity,
    required this.radius,
  });

  final Color color;
  final double opacity;
  final double radius;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height * 0.38);
    final paint = Paint()
      ..shader = RadialGradient(
        colors: [
          color.withValues(alpha: opacity),
          color.withValues(alpha: opacity * 0.4),
          color.withValues(alpha: 0.0),
        ],
        stops: const [0.0, 0.5, 1.0],
      ).createShader(
        Rect.fromCircle(center: center, radius: radius),
      );

    canvas.drawCircle(center, radius, paint);
  }

  @override
  bool shouldRepaint(_GlowPainter oldDelegate) =>
      oldDelegate.opacity != opacity ||
      oldDelegate.radius != radius ||
      oldDelegate.color != color;
}

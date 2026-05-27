import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../core/enums/splash/splash_destination.dart';
import '../../../core/l10n/generated/l10n.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/styles/app_colors.dart';
import '../../../core/utils/color_extensions.dart';
import '../../../core/utils/responsive_layout.dart';
import '../bloc/splash_routing/splash_routing_bloc.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  // Logo: fade + scale (delay 300ms)
  late final AnimationController _logoController;
  late final Animation<double> _logoOpacity;
  late final Animation<double> _logoScale;

  // Tagline: fade (delay 500ms)
  late final AnimationController _taglineController;
  late final Animation<double> _taglineOpacity;

  // Spinner: fade (delay 800ms)
  late final AnimationController _spinnerController;
  late final Animation<double> _spinnerOpacity;

  @override
  void initState() {
    super.initState();

    // ── Logo controller ──────────────────────────────────────────
    _logoController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _logoOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _logoController,
        curve: const Interval(0.0, 0.67, curve: Curves.easeIn),
      ),
    );
    _logoScale = Tween<double>(begin: 0.7, end: 1.0).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.elasticOut),
    );

    // ── Tagline controller ────────────────────────────────────────
    _taglineController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _taglineOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _taglineController, curve: Curves.easeIn),
    );

    // ── Spinner controller ────────────────────────────────────────
    _spinnerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _spinnerOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _spinnerController, curve: Curves.easeIn),
    );

    // ── Staggered start ───────────────────────────────────────────
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) _logoController.forward();
    });
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) _taglineController.forward();
    });
    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted) _spinnerController.forward();
    });
  }

  @override
  void dispose() {
    _logoController.dispose();
    _taglineController.dispose();
    _spinnerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);

    return BlocListener<SplashRoutingBloc, SplashRoutingState>(
      listener: (context, state) async {
        Future<void> delayedGo(String route) async {
          await Future.delayed(const Duration(milliseconds: 2000));
          if (!context.mounted) return;
          context.go(route);
        }

        if (state is SplashLoaded) {
          final route = () {
            switch (state.destination) {
              case SplashDestination.login:
                return Routes.loginPath;
              case SplashDestination.mobileSettings:
                return Routes.settingsPath;
              case SplashDestination.screenDisplay:
                return Routes.displayPath;
            }
          }();
          await delayedGo(route);
        } else if (state is SplashError) {
          context.read<SplashRoutingBloc>().add(SplashCheckStatus());
        }
      },
      child: Scaffold(
        body: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFFF8FAFC), Color(0xFFF0FDFA)],
            ),
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              // ── Decorative blob: top-right ─────────────────────
              Positioned(
                top: -150.h,
                right: -150.w,
                child: Container(
                  width: 450.w,
                  height: 450.w,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.primaryStart.withOpacityCompat(0.07),
                  ),
                ),
              ),

              // ── Decorative blob: bottom-left ───────────────────
              Positioned(
                bottom: -100.h,
                left: -100.w,
                child: Container(
                  width: 350.w,
                  height: 350.w,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.primaryEnd.withOpacityCompat(0.07),
                  ),
                ),
              ),

              // ── Main content ───────────────────────────────────
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo with staggered fade + scale
                  AnimatedBuilder(
                    animation: _logoController,
                    builder: (context, child) {
                      return Opacity(
                        opacity: _logoOpacity.value,
                        child: Transform.scale(
                          scale: _logoScale.value,
                          child: child,
                        ),
                      );
                    },
                    child: Container(
                      width: context.responsive(
                        160.w,
                        tablet: 180.w,
                        desktop: 200.w,
                      ),
                      padding: EdgeInsets.all(16.w),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24.r),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withOpacityCompat(0.15),
                            blurRadius: 24,
                            offset: const Offset(0, 8),
                            spreadRadius: 0,
                          ),
                          BoxShadow(
                            color: AppColors.primaryLight.withOpacityCompat(
                              0.08,
                            ),
                            blurRadius: 48,
                            offset: const Offset(0, 16),
                            spreadRadius: 4,
                          ),
                        ],
                      ),
                      child: Image.asset(
                        'assets/logo.png',
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),

                  SizedBox(height: 28.h),

                  // Tagline with staggered fade
                  FadeTransition(
                    opacity: _taglineOpacity,
                    child: Text(
                      s.splash_app_tagline,
                      style: TextStyle(
                        fontSize: context.adaptiveFont(20.sp),
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ),

                  SizedBox(height: 48.h),

                  // Loading spinner with staggered fade
                  FadeTransition(
                    opacity: _spinnerOpacity,
                    child: SizedBox(
                      width: 28.r,
                      height: 28.r,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: AppColors.primary.withValues(alpha: 0.5),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

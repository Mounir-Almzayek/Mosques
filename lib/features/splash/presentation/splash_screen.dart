import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../core/enums/splash/splash_destination.dart';
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

    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) _logoController.forward();
    });
  }

  @override
  void dispose() {
    _logoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
              case SplashDestination.passwordOnboarding:
                return Routes.passwordOnboardingPath;
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
                top: context.responsive(-150.h, tablet: -100, desktop: -100),
                right: context.responsive(-150.w, tablet: -100, desktop: -100),
                child: Container(
                  width: context.responsive(450.w, tablet: 350, desktop: 400),
                  height: context.responsive(450.w, tablet: 350, desktop: 400),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.primaryStart.withOpacityCompat(0.07),
                  ),
                ),
              ),

              // ── Decorative blob: bottom-left ───────────────────
              Positioned(
                bottom: context.responsive(-100.h, tablet: -60, desktop: -60),
                left: context.responsive(-100.w, tablet: -60, desktop: -60),
                child: Container(
                  width: context.responsive(350.w, tablet: 280, desktop: 320),
                  height: context.responsive(350.w, tablet: 280, desktop: 320),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.primaryEnd.withOpacityCompat(0.07),
                  ),
                ),
              ),

              // ── Main content ───────────────────────────────────
              Center(
                child: SingleChildScrollView(
                  child: AnimatedBuilder(
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
                        tablet: 180,
                        desktop: 180,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(
                          context.responsive(24.r, tablet: 24, desktop: 24),
                        ),
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
                        'assets/big-logo.png',
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

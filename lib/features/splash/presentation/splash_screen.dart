import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'dart:async';
import 'package:go_router/go_router.dart';

import '../../../core/utils/color_extensions.dart';
import '../../../core/l10n/generated/l10n.dart';
import '../../../core/utils/responsive_layout.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/styles/app_colors.dart';
import '../../../core/widgets/logo_rectangle.dart';
import '../bloc/splash_routing/splash_routing_bloc.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool showLogo = false;

  @override
  void initState() {
    super.initState();
    Timer(const Duration(milliseconds: 300), () {
      if (mounted) {
        setState(() {
          showLogo = true;
        });
      }
    });
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
              colors: [Color(0xFFF8FAFC), Colors.white, Color(0xFFF0FDFA)],
              stops: [0.0, 0.5, 1.0],
            ),
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              // 🔹 Decorative Blobs (Inspired by Web GradientBlobs)
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

              // 🔹 Logo Content
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  AnimatedScale(
                    scale: showLogo ? 1.0 : 0.7,
                    duration: const Duration(milliseconds: 1200),
                    curve: Curves.elasticOut,
                    child: AnimatedOpacity(
                      opacity: showLogo ? 1.0 : 0.0,
                      duration: const Duration(milliseconds: 800),
                      child: const LogoRectangle(big: true),
                    ),
                  ),
                  SizedBox(height: 24.h),
                  AnimatedOpacity(
                    opacity: showLogo ? 1.0 : 0.0,
                    duration: const Duration(milliseconds: 1000),
                    child: Text(
                      s.splash_app_tagline,
                      style: TextStyle(
                        fontSize: context.adaptiveFont(20.sp),
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                        letterSpacing: 1.2,
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

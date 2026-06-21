import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/styles/app_colors.dart';
import '../../../core/utils/responsive_layout.dart';
import '../../../core/widgets/media/logo_rectangle.dart';
import 'login_quote.dart';
import 'login_title_block.dart';

class LoginCompactLayout extends StatelessWidget {
  const LoginCompactLayout({super.key, required this.formCard});

  final Widget formCard;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: const BoxDecoration(
        gradient: AppColors.loginBackgroundGradient,
      ),
      child: Stack(
        children: [
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              height: context.responsive(5.h, tablet: 4, desktop: 4),
              decoration: const BoxDecoration(
                gradient: AppColors.accentGradient,
              ),
            ),
          ),
          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: EdgeInsets.symmetric(
                    horizontal: context.responsive(20.w, tablet: 48),
                    vertical: 20,
                  ),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight - 40,
                      maxWidth: context.responsive(
                        double.infinity,
                        tablet: 500,
                      ),
                    ),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const Center(
                            child: LogoRectangle(
                              big: false,
                              width: 180,
                              height: 96,
                            ),
                          ),
                          const SizedBox(height: 22),
                          const LoginTitleBlock(onDark: false),
                          const SizedBox(height: 26),
                          formCard,
                          const SizedBox(height: 22),
                          const LoginQuote(onDark: false),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

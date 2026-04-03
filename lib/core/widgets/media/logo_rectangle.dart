import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../utils/color_extensions.dart';
import '../../utils/responsive_layout.dart';

class LogoRectangle extends StatelessWidget {
  final bool big;
  final String? heroTag;
  final bool isFlat;
  final double? width;
  final double? height;

  const LogoRectangle({
    super.key,
    this.big = true,
    this.heroTag,
    this.isFlat = false,
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    final tag =
        heroTag ??
        'app_logo_${ModalRoute.of(context)?.settings.name ?? 'default'}';

    final double defaultWidth = big
        ? context.responsive(200.w, tablet: 240.w, desktop: 280.w)
        : context.responsive(80.w, tablet: 100.w, desktop: 120.w);

    final double defaultHeight = big
        ? context.responsive(80.h, tablet: 90.h, desktop: 100.h)
        : context.responsive(40.h, tablet: 50.h, desktop: 60.h);

    return Hero(
      tag: tag,
      child: Container(
        width: width ?? defaultWidth,
        height: height ?? defaultHeight,
        decoration: isFlat
            ? null
            : BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14.r),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacityCompat(0.05),
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
        padding: EdgeInsets.all(
          isFlat
              ? 0
              : (big
                    ? context.responsive(12.w, tablet: 16.w)
                    : context.responsive(6.w, tablet: 8.w)),
        ),
        child: Center(
          child: Image.asset(
            big ? "assets/logo.jpg" : "assets/logo.jpg",
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }
}

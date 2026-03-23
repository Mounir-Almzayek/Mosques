import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

const String kPrayerBackgroundSvg1 = 'assets/prayer_card_overlay_layer_1.svg';
const String kPrayerBackgroundSvg2 = 'assets/prayer_card_overlay_layer_2.svg';

/// خلفية البطاقة: طبقتان SVG بلون [prayerCardColor] من إعدادات التصميم.
/// المناطق خارج المسار تبقى شفافة.
class PrayerCardBackground extends StatelessWidget {
  final Color prayerCardColor;
  final Widget child;

  const PrayerCardBackground({
    super.key,
    required this.prayerCardColor,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      clipBehavior: Clip.hardEdge,
      children: [
        Positioned.fill(
          child: SvgPicture.asset(
            kPrayerBackgroundSvg1,
            fit: BoxFit.cover,
            alignment: Alignment.center,
            colorFilter: ColorFilter.mode(
              prayerCardColor.withValues(alpha: 0.5),
              BlendMode.srcIn,
            ),
          ),
        ),
        Positioned.fill(
          child: SvgPicture.asset(
            kPrayerBackgroundSvg2,
            fit: BoxFit.cover,
            alignment: Alignment.center,
            colorFilter: ColorFilter.mode(prayerCardColor, BlendMode.srcIn),
          ),
        ),
        child,
      ],
    );
  }
}

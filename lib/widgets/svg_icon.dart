import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class SvgIcon extends StatelessWidget {
  final String asset;
  final Color? color;
  final double? width;
  final double? height;
  final bool invert;
  const SvgIcon(
    this.asset, {
    super.key,
    this.color,
    this.width,
    this.height,
    this.invert = false,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final themeColor = invert ? colorScheme.onPrimary : colorScheme.primary;
    return SvgPicture(
      SvgAssetLoader(asset),
      width: width,
      height: height,
      colorFilter: ColorFilter.mode(
        color ?? themeColor,
        BlendMode.srcIn,
      ),
    );
  }
}

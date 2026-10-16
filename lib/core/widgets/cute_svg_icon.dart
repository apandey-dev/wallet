import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class CuteSvgIcon extends StatelessWidget {
  final String assetName;
  final double size;
  final Color? color;

  const CuteSvgIcon({
    super.key,
    required this.assetName,
    this.size = 20,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveColor = color ?? Theme.of(context).colorScheme.primary;
    final path = assetName.startsWith('assets/') 
        ? assetName 
        : 'assets/icons/$assetName.svg';

    return SvgPicture.asset(
      path,
      width: size,
      height: size,
      colorFilter: assetName.contains('google')
          ? null // Preserve Google brand colors
          : ColorFilter.mode(effectiveColor, BlendMode.srcIn),
    );
  }
}

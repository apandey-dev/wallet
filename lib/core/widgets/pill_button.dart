import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';

class PillButton extends StatelessWidget {
  final String label;
  final Widget? icon;
  final VoidCallback? onTap;
  final bool isPrimary;
  final bool isLoading;
  final double height;
  final double? width;
  final Color? backgroundColor;
  final Color? textColor;
  final Color? borderColor;
  final EdgeInsetsGeometry? padding;

  const PillButton({
    super.key,
    required this.label,
    this.icon,
    this.onTap,
    this.isPrimary = true,
    this.isLoading = false,
    this.height = 48,
    this.width,
    this.backgroundColor,
    this.textColor,
    this.borderColor,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveBg = backgroundColor ??
        (isPrimary ? AppTheme.accentDark : AppTheme.surfaceWhite);
    final effectiveText = textColor ??
        (isPrimary ? Colors.white : AppTheme.textPrimary);
    final effectiveBorder = borderColor ??
        (isPrimary ? Colors.transparent : AppTheme.borderLight);

    return SizedBox(
      height: height,
      width: width,
      child: Material(
        color: effectiveBg,
        borderRadius: BorderRadius.circular(999),
        child: InkWell(
          onTap: isLoading ? null : onTap,
          borderRadius: BorderRadius.circular(999),
          child: Container(
            padding: padding ?? const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: effectiveBorder, width: 1),
            ),
            alignment: Alignment.center,
            child: isLoading
                ? SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(effectiveText),
                    ),
                  )
                : Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (icon != null) ...[
                        icon!,
                        const SizedBox(width: 8),
                      ],
                      Flexible(
                        child: Text(
                          label,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.mali(
                            color: effectiveText,
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}

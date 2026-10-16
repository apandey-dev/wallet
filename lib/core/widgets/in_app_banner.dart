import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../providers/notification_provider.dart';
import '../theme/app_theme.dart';
import 'cute_svg_icon.dart';

class InAppNotificationBanner extends StatelessWidget {
  final VoidCallback? onNotificationTap;

  const InAppNotificationBanner({super.key, this.onNotificationTap});

  @override
  Widget build(BuildContext context) {
    final notifProvider = context.watch<NotificationProvider>();
    final banner = notifProvider.currentBanner;

    if (banner == null) {
      return const SizedBox.shrink();
    }

    String iconName = 'bell';
    Color iconColor = AppTheme.accentDark;

    if (banner.type == 'budget_alert') {
      iconName = 'alert';
      iconColor = AppTheme.accentPink;
    } else if (banner.type == 'subscription_renewal') {
      iconName = 'sub';
      iconColor = AppTheme.accentYellow;
    } else if (banner.type == 'transaction_logged') {
      iconName = 'wallet';
      iconColor = AppTheme.accentGreen;
    }

    return SafeArea(
      child: Align(
        alignment: Alignment.topCenter,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                notifProvider.dismissBanner();
                onNotificationTap?.call();
              },
              borderRadius: BorderRadius.circular(20),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOutCubic,
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceWhite,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppTheme.borderSubtle, width: 1.2),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.08),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: AppTheme.cardSurface,
                        shape: BoxShape.circle,
                      ),
                      padding: const EdgeInsets.all(9),
                      child: CuteSvgIcon(
                        assetName: iconName,
                        size: 18,
                        color: iconColor,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                banner.title,
                                style: GoogleFonts.mali(
                                  color: AppTheme.textPrimary,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const Spacer(),
                              Text(
                                'now',
                                style: GoogleFonts.mali(
                                  color: AppTheme.textMuted,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(
                            banner.body,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.mali(
                              color: AppTheme.textSecondary,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: () => notifProvider.dismissBanner(),
                      child: const Padding(
                        padding: EdgeInsets.all(4.0),
                        child: Icon(
                          Icons.close_rounded,
                          size: 16,
                          color: AppTheme.textMuted,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/cute_svg_icon.dart';
import '../../providers/notification_provider.dart';

class NotificationCenterSheet extends StatelessWidget {
  const NotificationCenterSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const NotificationCenterSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final notifProvider = context.watch<NotificationProvider>();
    final notifications = notifProvider.notifications;

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.75,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: const BoxDecoration(
        color: AppTheme.surfaceWhite,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppTheme.borderLight,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 18),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Text(
                    'Notifications',
                    style: GoogleFonts.mali(
                      color: AppTheme.textPrimary,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  if (notifProvider.unreadCount > 0) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppTheme.accentPink,
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        '${notifProvider.unreadCount}',
                        style: GoogleFonts.mali(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
              if (notifications.isNotEmpty)
                TextButton(
                  onPressed: () => notifProvider.markAllAsRead(),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: Text(
                    'Mark read',
                    style: GoogleFonts.mali(
                      color: AppTheme.textSecondary,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 14),

          // Notifications List
          if (notifications.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 40),
              child: Center(
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: const BoxDecoration(
                        color: AppTheme.cardSurface,
                        shape: BoxShape.circle,
                      ),
                      child: const CuteSvgIcon(
                        assetName: 'bell',
                        size: 26,
                        color: AppTheme.textMuted,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'All caught up',
                      style: GoogleFonts.mali(
                        color: AppTheme.textSecondary,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'No new telemetry or alerts at this time.',
                      style: GoogleFonts.mali(
                        color: AppTheme.textMuted,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            Flexible(
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: notifications.length,
                separatorBuilder: (_, _) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  final notif = notifications[index];
                  String iconName = 'bell';
                  Color iconColor = AppTheme.accentDark;

                  if (notif.type == 'budget_alert') {
                    iconName = 'alert';
                    iconColor = AppTheme.accentPink;
                  } else if (notif.type == 'subscription_renewal') {
                    iconName = 'sub';
                    iconColor = AppTheme.accentYellow;
                  } else if (notif.type == 'transaction_logged') {
                    iconName = 'wallet';
                    iconColor = AppTheme.accentGreen;
                  }

                  return Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: notif.isRead
                          ? AppTheme.surfaceWhite
                          : AppTheme.cardSurface.withValues(alpha: 0.6),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppTheme.borderSubtle),
                    ),
                    child: InkWell(
                      onTap: () => notifProvider.markAsRead(notif.id),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: const BoxDecoration(
                              color: AppTheme.cardSurface,
                              shape: BoxShape.circle,
                            ),
                            child: CuteSvgIcon(
                              assetName: iconName,
                              size: 16,
                              color: iconColor,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      notif.title,
                                      style: GoogleFonts.mali(
                                        color: notif.isRead
                                            ? AppTheme.textSecondary
                                            : AppTheme.textPrimary,
                                        fontSize: 13,
                                        fontWeight: notif.isRead
                                            ? FontWeight.w600
                                            : FontWeight.w700,
                                      ),
                                    ),
                                    Text(
                                      DateFormat('hh:mm a').format(notif.timestamp),
                                      style: GoogleFonts.mali(
                                        color: AppTheme.textMuted,
                                        fontSize: 10,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  notif.body,
                                  style: GoogleFonts.mali(
                                    color: AppTheme.textSecondary,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (!notif.isRead) ...[
                            const SizedBox(width: 6),
                            Container(
                              margin: const EdgeInsets.only(top: 4),
                              width: 6,
                              height: 6,
                              decoration: const BoxDecoration(
                                color: AppTheme.accentPink,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }
}

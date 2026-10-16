import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/cute_svg_icon.dart';
import '../../core/widgets/pill_button.dart';
import '../../providers/wallet_provider.dart';
import '../sheets/add_subscription_sheet.dart';

class SubscriptionsScreen extends StatelessWidget {
  const SubscriptionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final wallet = context.watch<WalletProvider>();
    final subs = wallet.subscriptions;

    return Scaffold(
      backgroundColor: AppTheme.bgLight,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Subscriptions',
                    style: GoogleFonts.mali(
                      color: AppTheme.textPrimary,
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.5,
                    ),
                  ),
                  GestureDetector(
                    onTap: () => AddSubscriptionSheet.show(context),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                      decoration: BoxDecoration(
                        color: AppTheme.accentDark,
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.add_rounded, size: 16, color: Colors.white),
                          const SizedBox(width: 4),
                          Text(
                            'Add',
                            style: GoogleFonts.mali(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Burn overview card
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceWhite,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppTheme.borderSubtle),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.03),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'MONTHLY COMMITMENT',
                          style: GoogleFonts.mali(
                            color: AppTheme.textMuted,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '₹${wallet.monthlySubscriptionCommitment.toStringAsFixed(0)}',
                          style: GoogleFonts.mali(
                            color: AppTheme.textPrimary,
                            fontSize: 26,
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.5,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppTheme.cardSurface,
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        '${subs.where((s) => s.isActive).length} active',
                        style: GoogleFonts.mali(
                          color: AppTheme.textPrimary,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              Text(
                'ACTIVE SERVICES',
                style: GoogleFonts.mali(
                  color: AppTheme.textMuted,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 10),

              // Subscriptions List
              Expanded(
                child: subs.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const CuteSvgIcon(
                              assetName: 'sub',
                              size: 32,
                              color: AppTheme.textMuted,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'No subscriptions monitored',
                              style: GoogleFonts.mali(
                                color: AppTheme.textSecondary,
                                fontSize: 13,
                              ),
                            ),
                            const SizedBox(height: 12),
                            PillButton(
                              label: 'Add First Plan',
                              isPrimary: false,
                              onTap: () => AddSubscriptionSheet.show(context),
                            ),
                          ],
                        ),
                      )
                    : ListView.separated(
                        physics: const BouncingScrollPhysics(),
                        itemCount: subs.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 8),
                        itemBuilder: (context, index) {
                          final item = subs[index];
                          final days = item.daysUntilRenewal;
                          final isSoon = days <= 3 && days >= 0;

                          return Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                            decoration: BoxDecoration(
                              color: AppTheme.surfaceWhite,
                              borderRadius: BorderRadius.circular(18),
                              border: Border.all(color: AppTheme.borderSubtle),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.02),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    color: AppTheme.cardSurface,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  padding: const EdgeInsets.all(10),
                                  child: CuteSvgIcon(
                                    assetName: item.icon,
                                    size: 18,
                                    color: item.isActive
                                        ? AppTheme.accentDark
                                        : AppTheme.textMuted,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Text(
                                            item.name,
                                            style: GoogleFonts.mali(
                                              color: item.isActive
                                                  ? AppTheme.textPrimary
                                                  : AppTheme.textMuted,
                                              fontSize: 14,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                          if (isSoon && item.isActive) ...[
                                            const SizedBox(width: 6),
                                            Container(
                                              padding: const EdgeInsets.symmetric(
                                                horizontal: 6,
                                                vertical: 2,
                                              ),
                                              decoration: BoxDecoration(
                                                color: AppTheme.accentPink.withValues(alpha: 0.25),
                                                borderRadius: BorderRadius.circular(999),
                                              ),
                                              child: Text(
                                                '$days d left',
                                                style: GoogleFonts.mali(
                                                  color: const Color(0xFFE11D48),
                                                  fontSize: 9,
                                                  fontWeight: FontWeight.w700,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ],
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        '₹${item.amount.toStringAsFixed(0)} / ${item.billingCycle.name}',
                                        style: GoogleFonts.mali(
                                          color: AppTheme.textMuted,
                                          fontSize: 11,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                // Switch toggle
                                Transform.scale(
                                  scale: 0.8,
                                  child: Switch(
                                    value: item.isActive,
                                    activeThumbColor: Colors.white,
                                    activeTrackColor: AppTheme.accentDark,
                                    inactiveThumbColor: AppTheme.textMuted,
                                    inactiveTrackColor: AppTheme.cardSurface,
                                    onChanged: (val) {
                                      wallet.toggleSubscription(item.id);
                                    },
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () => wallet.deleteSubscription(item.id),
                                  child: const Padding(
                                    padding: EdgeInsets.only(left: 4),
                                    child: Icon(
                                      Icons.close_rounded,
                                      size: 16,
                                      color: AppTheme.textMuted,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

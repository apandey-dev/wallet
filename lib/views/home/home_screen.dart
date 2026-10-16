import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/cute_svg_icon.dart';
import '../../models/transaction_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/wallet_provider.dart';
import '../../providers/notification_provider.dart';
import '../transactions/add_transaction_page.dart';
import '../sheets/filter_sheet.dart';
import '../sheets/notification_center_sheet.dart';
import '../sheets/transaction_detail_sheet.dart';
import 'financial_overview_sheet.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final wallet = context.watch<WalletProvider>();
    final notif = context.watch<NotificationProvider>();
    final user = auth.user;
    final accounts = wallet.accounts;

    return Scaffold(
      backgroundColor: AppTheme.bgLight,
      body: SafeArea(
        child: RefreshIndicator(
          color: AppTheme.accentDark,
          backgroundColor: AppTheme.surfaceWhite,
          onRefresh: () async {
            await wallet.init();
          },
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics(),
            ),
            slivers: [
              // Header: Profile & In-App Notification Bell
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 14, 20, 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // User Profile
                      Row(
                        children: [
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppTheme.surfaceWhite,
                              border: Border.all(color: AppTheme.borderLight, width: 1.5),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.04),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: ClipOval(
                              child: user?.photoUrl != null && user!.photoUrl!.isNotEmpty
                                  ? Image.network(
                                      user.photoUrl!,
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, _, _) => const Center(
                                        child: CuteSvgIcon(
                                          assetName: 'user',
                                          size: 20,
                                          color: AppTheme.accentDark,
                                        ),
                                      ),
                                    )
                                  : (user?.displayName.isNotEmpty == true && user?.isGuest == false
                                      ? Center(
                                          child: Text(
                                            user!.displayName[0].toUpperCase(),
                                            style: GoogleFonts.mali(
                                              fontWeight: FontWeight.w700,
                                              fontSize: 18,
                                              color: AppTheme.accentDark,
                                            ),
                                          ),
                                        )
                                      : const Center(
                                          child: CuteSvgIcon(
                                            assetName: 'user',
                                            size: 20,
                                            color: AppTheme.accentDark,
                                          ),
                                        )),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Good Morning',
                                style: GoogleFonts.mali(
                                  color: AppTheme.textSecondary,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              Text(
                                user?.displayName.isNotEmpty == true
                                    ? user!.displayName
                                    : (user?.isGuest == true ? 'Guest User' : 'Wallet User'),
                                style: GoogleFonts.mali(
                                  color: AppTheme.textPrimary,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: -0.3,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),

                      // In-App Notification Bell
                      GestureDetector(
                        onTap: () => NotificationCenterSheet.show(context),
                        child: Stack(
                          clipBehavior: Clip.none,
                          children: [
                            Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: AppTheme.surfaceWhite,
                                border: Border.all(color: AppTheme.borderSubtle, width: 1.2),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.04),
                                    blurRadius: 12,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              padding: const EdgeInsets.all(11),
                              child: const CuteSvgIcon(
                                assetName: 'bell',
                                size: 18,
                                color: AppTheme.textPrimary,
                              ),
                            ),
                            if (notif.unreadCount > 0)
                              Positioned(
                                top: 2,
                                right: 2,
                                child: Container(
                                  width: 9,
                                  height: 9,
                                  decoration: const BoxDecoration(
                                    color: AppTheme.accentPink,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // "My Overview" Section Heading
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          'Total Balance',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.mali(
                            color: AppTheme.textPrimary,
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.3,
                          ),
                        ),
                      ),
                      Text(
                        '${accounts.length} Accounts',
                        style: GoogleFonts.mali(
                          color: AppTheme.textSecondary,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Financial Overview Card (Tapping opens FinancialOverviewSheet!)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 10, 20, 16),
                  child: GestureDetector(
                    onTap: () => FinancialOverviewSheet.show(context),
                    child: Container(
                      padding: const EdgeInsets.all(22),
                      decoration: BoxDecoration(
                        color: AppTheme.cardDark,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.2),
                            blurRadius: 24,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Top row: Overview label & details badge
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  'Financial Overview',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: GoogleFonts.mali(
                                    color: Colors.white,
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(999),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      'Details',
                                      style: GoogleFonts.mali(
                                        color: Colors.white,
                                        fontSize: 10,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    const Icon(Icons.arrow_forward_ios_rounded, color: Colors.white, size: 9),
                                  ],
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 18),

                          // Net Liquidity
                          Text(
                            'Net Liquidity',
                            style: GoogleFonts.mali(
                              color: const Color(0xFF9E9EA7),
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 4),
                          FittedBox(
                            fit: BoxFit.scaleDown,
                            alignment: Alignment.centerLeft,
                            child: Text(
                              '₹${wallet.totalNetWorth.toStringAsFixed(2)}',
                              style: GoogleFonts.mali(
                                color: Colors.white,
                                fontSize: 32,
                                fontWeight: FontWeight.w700,
                                letterSpacing: -0.8,
                              ),
                            ),
                          ),

                          const SizedBox(height: 18),

                          // Inflow / Outflow summary indicators - COMPLETELY OVERFLOW SAFE
                          Row(
                            children: [
                              Expanded(
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.07),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(Icons.arrow_downward_rounded, color: Color(0xFF5DE2A5), size: 14),
                                      const SizedBox(width: 4),
                                      Expanded(
                                        child: FittedBox(
                                          fit: BoxFit.scaleDown,
                                          alignment: Alignment.centerLeft,
                                          child: Text(
                                            'Inflow: ₹${wallet.totalIncome.toStringAsFixed(0)}',
                                            maxLines: 1,
                                            style: GoogleFonts.mali(
                                              color: const Color(0xFF5DE2A5),
                                              fontSize: 11.5,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.07),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(Icons.arrow_upward_rounded, color: Color(0xFFFF9BA9), size: 14),
                                      const SizedBox(width: 4),
                                      Expanded(
                                        child: FittedBox(
                                          fit: BoxFit.scaleDown,
                                          alignment: Alignment.centerLeft,
                                          child: Text(
                                            'Outflow: ₹${wallet.totalExpense.toStringAsFixed(0)}',
                                            maxLines: 1,
                                            style: GoogleFonts.mali(
                                              color: const Color(0xFFFF9BA9),
                                              fontSize: 11.5,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              // Action Buttons Row: Expense | Income | Self Transfer
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    children: [
                      // 1. Expense
                      Expanded(
                        child: _buildActionPill(
                          context: context,
                          label: 'Expense',
                          icon: Icons.north_east_rounded,
                          onTap: () => AddTransactionPage.push(context, initialType: TransactionType.expense),
                        ),
                      ),
                      const SizedBox(width: 12),

                      // 2. Income
                      Expanded(
                        child: _buildActionPill(
                          context: context,
                          label: 'Income',
                          icon: Icons.south_west_rounded,
                          onTap: () => AddTransactionPage.push(context, initialType: TransactionType.income),
                        ),
                      ),
                      const SizedBox(width: 12),

                      // 3. Self Transfer
                      Expanded(
                        child: _buildActionPill(
                          context: context,
                          label: 'Transfer',
                          icon: Icons.swap_horiz_rounded,
                          onTap: () => AddTransactionPage.push(context, initialType: TransactionType.transfer),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Transaction Section Header
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 26, 20, 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Recent Transactions',
                        style: GoogleFonts.mali(
                          color: AppTheme.textPrimary,
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.3,
                        ),
                      ),
                      GestureDetector(
                        onTap: () => FilterSheet.show(context),
                        child: Text(
                          'Filter',
                          style: GoogleFonts.mali(
                            color: AppTheme.textSecondary,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Transactions Slivers List
              if (wallet.filteredTransactions.isEmpty)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 40),
                    child: Center(
                      child: Text(
                        'No transactions logged.',
                        style: GoogleFonts.mali(
                          color: AppTheme.textMuted,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final item = wallet.filteredTransactions[index];
                        final isExpense = item.type == TransactionType.expense;
                        final isTransfer = item.type == TransactionType.transfer;

                        return Container(
                          margin: const EdgeInsets.only(bottom: 10),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppTheme.surfaceWhite,
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(color: AppTheme.borderSubtle, width: 1),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.02),
                                blurRadius: 10,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: InkWell(
                            onTap: () => TransactionDetailSheet.show(context, item),
                            borderRadius: BorderRadius.circular(18),
                            child: Row(
                              children: [
                                Container(
                                  width: 44,
                                  height: 44,
                                  decoration: BoxDecoration(
                                    color: AppTheme.cardSurface,
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  padding: const EdgeInsets.all(11),
                                  child: CuteSvgIcon(
                                    assetName: item.icon,
                                    size: 20,
                                    color: AppTheme.accentDark,
                                  ),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        item.title,
                                        style: GoogleFonts.mali(
                                          color: AppTheme.textPrimary,
                                          fontSize: 14,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        '${item.category} • ${DateFormat('MMM dd').format(item.date)}',
                                        style: GoogleFonts.mali(
                                          color: AppTheme.textMuted,
                                          fontSize: 11,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Text(
                                  isTransfer
                                      ? '⇄₹${item.amount.toStringAsFixed(2)}'
                                      : '${isExpense ? '-' : '+'}₹${item.amount.toStringAsFixed(2)}',
                                  style: GoogleFonts.mali(
                                    color: isTransfer
                                        ? AppTheme.accentDark
                                        : (isExpense ? const Color(0xFFE11D48) : const Color(0xFF10B981)),
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                      childCount: wallet.filteredTransactions.length,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionPill({
    required BuildContext context,
    required String label,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: AppTheme.surfaceWhite,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppTheme.borderSubtle, width: 1.2),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: const BoxDecoration(
                color: AppTheme.cardDark,
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: Colors.white,
                size: 18,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: GoogleFonts.mali(
                color: AppTheme.textPrimary,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

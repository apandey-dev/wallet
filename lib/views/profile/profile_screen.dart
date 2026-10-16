import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/cute_svg_icon.dart';
import '../../core/widgets/pill_button.dart';
import '../../providers/auth_provider.dart';
import '../../providers/wallet_provider.dart';
import '../budget/budget_page.dart';
import '../sheets/edit_profile_sheet.dart';
import '../../services/pdf_export_service.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  void _exportPdfStatement(BuildContext context) {
    final wallet = context.read<WalletProvider>();
    final user = context.read<AuthProvider>().user;
    PdfExportService.generateAndPrintStatement(
      context: context,
      user: user,
      wallet: wallet,
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final wallet = context.watch<WalletProvider>();
    final user = auth.user;

    return Scaffold(
      backgroundColor: AppTheme.bgLight,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Account Settings',
                style: GoogleFonts.mali(
                  color: AppTheme.textPrimary,
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 16),

              // Enhanced Premium Profile Card
              GestureDetector(
                onTap: () => EditProfileSheet.show(context),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceWhite,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: AppTheme.borderSubtle, width: 1.2),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.accentDark.withValues(alpha: 0.04),
                        blurRadius: 16,
                        offset: const Offset(0, 5),
                      ),
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.015),
                        blurRadius: 4,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      // Top Row: Avatar + Name/Email + Edit Action
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // Avatar with chic gradient border & camera edit badge
                          Stack(
                            children: [
                              Container(
                                width: 62,
                                height: 62,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: const LinearGradient(
                                    colors: [Color(0xFFE2E8F0), Color(0xFFF1F5F9)],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  border: Border.all(
                                    color: AppTheme.accentDark.withValues(alpha: 0.12),
                                    width: 2.5,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(alpha: 0.05),
                                      blurRadius: 8,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: ClipOval(
                                  child: user?.photoUrl != null && user!.photoUrl!.isNotEmpty
                                      ? Image.network(
                                          user.photoUrl!,
                                          width: 62,
                                          height: 62,
                                          fit: BoxFit.cover,
                                          errorBuilder: (_, _, _) => const Center(
                                            child: CuteSvgIcon(
                                              assetName: 'user',
                                              size: 28,
                                              color: AppTheme.accentDark,
                                            ),
                                          ),
                                        )
                                      : Center(
                                          child: Text(
                                            user?.displayName.isNotEmpty == true
                                                ? user!.displayName[0].toUpperCase()
                                                : 'U',
                                            style: GoogleFonts.mali(
                                              color: AppTheme.accentDark,
                                              fontSize: 24,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                        ),
                                ),
                              ),
                              Positioned(
                                bottom: 0,
                                right: 0,
                                child: Container(
                                  padding: const EdgeInsets.all(5),
                                  decoration: BoxDecoration(
                                    color: AppTheme.accentDark,
                                    shape: BoxShape.circle,
                                    border: Border.all(color: Colors.white, width: 2),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withValues(alpha: 0.15),
                                        blurRadius: 4,
                                        offset: const Offset(0, 1),
                                      ),
                                    ],
                                  ),
                                  child: const Icon(
                                    Icons.edit_rounded,
                                    size: 11,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(width: 14),

                          // User info block
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Flexible(
                                      child: Text(
                                        user?.displayName.isNotEmpty == true
                                            ? user!.displayName
                                            : (user?.isGuest == true ? 'Guest Explorer' : 'My Account'),
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
                                    const SizedBox(width: 5),
                                    const Icon(
                                      Icons.verified_rounded,
                                      size: 15,
                                      color: Color(0xFF3B82F6),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 2),
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.alternate_email_rounded,
                                      size: 12,
                                      color: AppTheme.textMuted,
                                    ),
                                    const SizedBox(width: 3),
                                    Flexible(
                                      child: Text(
                                        user?.email.isNotEmpty == true
                                            ? user!.email
                                            : (user?.isGuest == true ? 'guest@zerowallet.app' : 'Not linked'),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: GoogleFonts.mali(
                                          color: AppTheme.textSecondary,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                // Status Pill
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2.5),
                                  decoration: BoxDecoration(
                                    color: user?.isGuest == true
                                        ? const Color(0xFFFFF1F2)
                                        : const Color(0xFFECFDF5),
                                    borderRadius: BorderRadius.circular(999),
                                    border: Border.all(
                                      color: user?.isGuest == true
                                          ? const Color(0xFFFECDD3)
                                          : const Color(0xFFA7F3D0),
                                      width: 0.8,
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Container(
                                        width: 6,
                                        height: 6,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: user?.isGuest == true
                                              ? const Color(0xFFE11D48)
                                              : const Color(0xFF059669),
                                        ),
                                      ),
                                      const SizedBox(width: 5),
                                      Text(
                                        user?.isGuest == true
                                            ? 'Guest Mode • Local'
                                            : 'Cloud Sync • Google',
                                        style: GoogleFonts.mali(
                                          color: user?.isGuest == true
                                              ? const Color(0xFFBE123C)
                                              : const Color(0xFF047857),
                                          fontSize: 10,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(width: 10),

                          // Edit button pill
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: AppTheme.cardSurface,
                              borderRadius: BorderRadius.circular(999),
                              border: Border.all(color: AppTheme.borderLight),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.edit_outlined, size: 13, color: AppTheme.accentDark),
                                const SizedBox(width: 4),
                                Text(
                                  'Edit',
                                  style: GoogleFonts.mali(
                                    color: AppTheme.accentDark,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      // Subtle divider
                      Container(
                        height: 1,
                        color: AppTheme.borderSubtle,
                      ),

                      const SizedBox(height: 14),

                      // Bottom Snapshot Telemetry Row (Net Worth, Accounts, Budget)
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Net Worth',
                                  style: GoogleFonts.mali(
                                    color: AppTheme.textMuted,
                                    fontSize: 10.5,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                FittedBox(
                                  fit: BoxFit.scaleDown,
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                    '₹${wallet.totalNetWorth.toStringAsFixed(0)}',
                                    style: GoogleFonts.mali(
                                      color: AppTheme.textPrimary,
                                      fontSize: 15,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            height: 28,
                            width: 1,
                            color: AppTheme.borderSubtle,
                          ),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.only(left: 12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Accounts',
                                    style: GoogleFonts.mali(
                                      color: AppTheme.textMuted,
                                      fontSize: 10.5,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  FittedBox(
                                    fit: BoxFit.scaleDown,
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                      '${wallet.accounts.length} Active',
                                      style: GoogleFonts.mali(
                                        color: AppTheme.textPrimary,
                                        fontSize: 15,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Container(
                            height: 28,
                            width: 1,
                            color: AppTheme.borderSubtle,
                          ),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.only(left: 12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Monthly Cap',
                                    style: GoogleFonts.mali(
                                      color: AppTheme.textMuted,
                                      fontSize: 10.5,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  FittedBox(
                                    fit: BoxFit.scaleDown,
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                      '₹${wallet.monthlyBudget.toStringAsFixed(0)}',
                                      style: GoogleFonts.mali(
                                        color: AppTheme.textPrimary,
                                        fontSize: 15,
                                        fontWeight: FontWeight.w700,
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

              const SizedBox(height: 20),

              // Financial Statements Section Header
              Text(
                'Financial Statements',
                style: GoogleFonts.mali(
                  color: AppTheme.textPrimary,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 10),

              // Real PDF Statement Generation Card
              GestureDetector(
                onTap: () => _exportPdfStatement(context),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceWhite,
                    borderRadius: BorderRadius.circular(20),
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
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: const Color(0xFFFEE2E2),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Icon(Icons.picture_as_pdf_rounded, size: 22, color: Color(0xFFDC2626)),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Flexible(
                                  child: Text(
                                    'Download PDF Statement',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: GoogleFonts.mali(
                                      color: AppTheme.textPrimary,
                                      fontSize: 14.5,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFFCE7F3),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    'OFFICIAL',
                                    style: GoogleFonts.mali(
                                      color: const Color(0xFFBE185D),
                                      fontSize: 9.5,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 3),
                            Text(
                              'Formatted printable ledger with line items & totals',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.mali(
                                color: AppTheme.textMuted,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                        decoration: BoxDecoration(
                          color: AppTheme.accentDark,
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.print_rounded, size: 14, color: Colors.white),
                            const SizedBox(width: 5),
                            Text(
                              'Print / Save',
                              style: GoogleFonts.mali(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Budget Planner & Limits Tile -> Navigates to dedicated BudgetPage
              GestureDetector(
                onTap: () => BudgetPage.push(context),
                child: Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceWhite,
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(color: AppTheme.borderSubtle),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.02),
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(9),
                        decoration: const BoxDecoration(
                          color: AppTheme.cardSurface,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.pie_chart_outline_rounded, size: 20, color: AppTheme.accentDark),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Budget Planner & Limits',
                              style: GoogleFonts.mali(
                                color: AppTheme.textPrimary,
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            Text(
                              '₹${wallet.monthlyBudget.toStringAsFixed(0)} monthly • ${wallet.categories.length} category caps',
                              style: GoogleFonts.mali(
                                color: AppTheme.textSecondary,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppTheme.textMuted),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Logout Button
              PillButton(
                label: 'Sign Out Session',
                isPrimary: false,
                textColor: const Color(0xFFE11D48),
                borderColor: const Color(0xFFE11D48).withValues(alpha: 0.3),
                width: double.infinity,
                onTap: () => auth.logout(),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}

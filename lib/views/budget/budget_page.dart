import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/cute_svg_icon.dart';
import '../../core/widgets/pill_button.dart';
import '../../providers/auth_provider.dart';
import '../../providers/wallet_provider.dart';
import '../sheets/set_budget_sheet.dart';

class BudgetPage extends StatelessWidget {
  const BudgetPage({super.key});

  static Future<void> push(BuildContext context) {
    return Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const BudgetPage(),
      ),
    );
  }

  void _showCategoryBudgetSheet(BuildContext context, String categoryName, double currentBudget) {
    final controller = TextEditingController(text: currentBudget.toStringAsFixed(0));

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        final bottomInset = MediaQuery.of(ctx).viewInsets.bottom;
        return Container(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 14,
            bottom: 24 + bottomInset,
          ),
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
                  Expanded(
                    child: Text(
                      'Budget for $categoryName',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.mali(
                        color: AppTheme.textPrimary,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppTheme.cardSurface,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      'Monthly Cap',
                      style: GoogleFonts.mali(
                        color: AppTheme.textSecondary,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Set the maximum planned expenditure for this category in the current billing cycle.',
                style: GoogleFonts.mali(
                  color: AppTheme.textSecondary,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 18),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: AppTheme.cardSurface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppTheme.borderSubtle),
                ),
                child: Row(
                  children: [
                    Text(
                      '₹',
                      style: GoogleFonts.mali(
                        color: AppTheme.textPrimary,
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: controller,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        autofocus: true,
                        style: GoogleFonts.mali(
                          color: AppTheme.textPrimary,
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                        ),
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          isDense: true,
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              PillButton(
                label: 'Save Budget Limit',
                isPrimary: true,
                width: double.infinity,
                onTap: () {
                  final val = double.tryParse(controller.text.trim()) ?? 0.0;
                  if (val > 0) {
                    context.read<WalletProvider>().setCategoryBudget(categoryName, val);
                  }
                  Navigator.pop(ctx);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final wallet = context.watch<WalletProvider>();
    final auth = context.watch<AuthProvider>();

    final monthlyBudget = wallet.monthlyBudget;
    final totalSpent = wallet.totalExpense;
    final remainingBudget = wallet.remainingMonthlyBudget;
    final overallRatio = wallet.budgetUsedPercentage;

    final categories = wallet.categories;

    return Scaffold(
      backgroundColor: AppTheme.bgLight,
      appBar: AppBar(
        backgroundColor: AppTheme.bgLight,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Budget & Limits',
          style: GoogleFonts.mali(
            color: AppTheme.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.tune_rounded, size: 20, color: AppTheme.accentDark),
            tooltip: 'Adjust Monthly Target',
            onPressed: () => SetBudgetSheet.show(context),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Hero Overall Monthly Budget Card
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceWhite,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: AppTheme.borderSubtle),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.03),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'MONTHLY BUDGET POOL',
                          style: GoogleFonts.mali(
                            color: AppTheme.textMuted,
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.5,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: overallRatio > 0.9
                                ? const Color(0xFFFEE2E2)
                                : (overallRatio > 0.7 ? const Color(0xFFFEF3C7) : const Color(0xFFD1FAE5)),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            overallRatio > 1.0
                                ? 'Exceeded'
                                : '${(overallRatio * 100).toStringAsFixed(0)}% Used',
                            style: GoogleFonts.mali(
                              color: overallRatio > 0.9
                                  ? const Color(0xFFDC2626)
                                  : (overallRatio > 0.7 ? const Color(0xFFD97706) : const Color(0xFF059669)),
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Text(
                          '₹${monthlyBudget.toStringAsFixed(0)}',
                          style: GoogleFonts.mali(
                            color: AppTheme.textPrimary,
                            fontSize: 30,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.8,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'planned cap',
                          style: GoogleFonts.mali(
                            color: AppTheme.textSecondary,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),

                    // Progress Bar
                    ClipRRect(
                      borderRadius: BorderRadius.circular(999),
                      child: LinearProgressIndicator(
                        value: overallRatio.clamp(0.0, 1.0),
                        minHeight: 8,
                        backgroundColor: AppTheme.cardSurface,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          overallRatio > 0.9
                              ? const Color(0xFFE11D48)
                              : (overallRatio > 0.7 ? const Color(0xFFF59E0B) : const Color(0xFF10B981)),
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Spending Details Row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Spent So Far',
                              style: GoogleFonts.mali(
                                color: AppTheme.textMuted,
                                fontSize: 11,
                              ),
                            ),
                            Text(
                              '₹${totalSpent.toStringAsFixed(0)}',
                              style: GoogleFonts.mali(
                                color: const Color(0xFFE11D48),
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              'Remaining Left',
                              style: GoogleFonts.mali(
                                color: AppTheme.textMuted,
                                fontSize: 11,
                              ),
                            ),
                            Text(
                              '₹${remainingBudget.toStringAsFixed(0)}',
                              style: GoogleFonts.mali(
                                color: const Color(0xFF059669),
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    PillButton(
                      label: 'Adjust Monthly Target',
                      icon: const Icon(Icons.edit_outlined, size: 14, color: AppTheme.textPrimary),
                      isPrimary: false,
                      height: 40,
                      width: double.infinity,
                      onTap: () async {
                        await SetBudgetSheet.show(context);
                        final userBudget = auth.user?.monthlyBudget;
                        if (userBudget != null && userBudget > 0) {
                          wallet.setMonthlyBudget(userBudget);
                        }
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // 50-30-20 Rule Reference Card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF1B1B22),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.1),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.pie_chart_rounded, size: 14, color: Colors.white),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '50 / 30 / 20 Smart Allocation',
                          style: GoogleFonts.mali(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        _buildAllocationStat(
                          'Needs (50%)',
                          '₹${(monthlyBudget * 0.50).toStringAsFixed(0)}',
                          const Color(0xFFE2E8F0),
                        ),
                        const SizedBox(width: 8),
                        _buildAllocationStat(
                          'Wants (30%)',
                          '₹${(monthlyBudget * 0.30).toStringAsFixed(0)}',
                          const Color(0xFF86EFAC),
                        ),
                        const SizedBox(width: 8),
                        _buildAllocationStat(
                          'Savings (20%)',
                          '₹${(monthlyBudget * 0.20).toStringAsFixed(0)}',
                          const Color(0xFFFBCFE8),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Category Budgets Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Category Budgets',
                    style: GoogleFonts.mali(
                      color: AppTheme.textPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    '${categories.length} categories',
                    style: GoogleFonts.mali(
                      color: AppTheme.textMuted,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Category List
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: categories.length,
                separatorBuilder: (_, _) => const SizedBox(height: 10),
                itemBuilder: (context, index) {
                  final cat = categories[index];
                  final catBudget = wallet.getCategoryBudget(cat.name);
                  final catSpent = wallet.getCategorySpent(cat.name);
                  final catRatio = catBudget > 0 ? (catSpent / catBudget).clamp(0.0, 1.0) : 0.0;
                  final catLeft = (catBudget - catSpent).clamp(0.0, double.infinity);
                  final isExceeded = catSpent > catBudget;

                  return Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppTheme.surfaceWhite,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: AppTheme.borderSubtle),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 38,
                              height: 38,
                              decoration: BoxDecoration(
                                color: AppTheme.cardSurface,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              padding: const EdgeInsets.all(9),
                              child: CuteSvgIcon(
                                assetName: cat.icon,
                                size: 18,
                                color: AppTheme.accentDark,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    cat.name,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: GoogleFonts.mali(
                                      color: AppTheme.textPrimary,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  Text(
                                    isExceeded
                                        ? 'Exceeded by ₹${(catSpent - catBudget).toStringAsFixed(0)}'
                                        : '₹${catLeft.toStringAsFixed(0)} left',
                                    style: GoogleFonts.mali(
                                      color: isExceeded ? const Color(0xFFDC2626) : AppTheme.textMuted,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  '₹${catSpent.toStringAsFixed(0)} / ₹${catBudget.toStringAsFixed(0)}',
                                  style: GoogleFonts.mali(
                                    color: AppTheme.textPrimary,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () => _showCategoryBudgetSheet(context, cat.name, catBudget),
                                  child: Padding(
                                    padding: const EdgeInsets.only(top: 2),
                                    child: Text(
                                      'Edit Cap',
                                      style: GoogleFonts.mali(
                                        color: AppTheme.accentDark,
                                        fontSize: 11,
                                        fontWeight: FontWeight.w700,
                                        decoration: TextDecoration.underline,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(999),
                          child: LinearProgressIndicator(
                            value: catRatio,
                            minHeight: 5,
                            backgroundColor: AppTheme.cardSurface,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              isExceeded
                                  ? const Color(0xFFE11D48)
                                  : (catRatio > 0.8 ? const Color(0xFFF59E0B) : const Color(0xFF10B981)),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAllocationStat(String title, String amount, Color textColor) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.mali(
                color: const Color(0xFF9E9EA7),
                fontSize: 10,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              amount,
              style: GoogleFonts.mali(
                color: textColor,
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

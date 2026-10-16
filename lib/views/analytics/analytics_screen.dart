import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart' hide TextDirection;
import '../../core/theme/app_theme.dart';
import '../../core/widgets/cute_svg_icon.dart';
import '../../models/category_model.dart';
import '../../models/transaction_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/wallet_provider.dart';
import '../../providers/notification_provider.dart';
import '../sheets/notification_center_sheet.dart';
import '../budget/budget_page.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  // If null, displays all expense transactions; else filters to this category
  String? _selectedCategoryName;

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final wallet = context.watch<WalletProvider>();
    final notif = context.watch<NotificationProvider>();
    final user = auth.user;

    final monthlyInflow = wallet.totalIncome > 0 ? wallet.totalIncome : 85000.0;
    final totalSpent = wallet.totalExpense;

    final categories = wallet.categories;

    // Filter transactions based on selected category in the grid
    final allExpenseTransactions = wallet.transactions
        .where((t) => t.type == TransactionType.expense)
        .toList();

    final displayedTransactions = _selectedCategoryName == null
        ? allExpenseTransactions
        : allExpenseTransactions.where((t) => t.category == _selectedCategoryName).toList();

    return Scaffold(
      backgroundColor: AppTheme.bgLight,
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // Top Bar: Profile & Notification Bell
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 14, 20, 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
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
                          padding: const EdgeInsets.all(10),
                          child: const CuteSvgIcon(
                            assetName: 'user',
                            size: 20,
                            color: AppTheme.accentDark,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Hi ${(user?.displayName ?? 'Sarah').split(' ').first}!',
                          style: GoogleFonts.mali(
                            color: AppTheme.textPrimary,
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.3,
                          ),
                        ),
                      ],
                    ),
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

            // Top Portfolio Inflow & Outflow Summary Banner
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceWhite,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: AppTheme.borderSubtle),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.03),
                        blurRadius: 14,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Monthly Outflow',
                                style: GoogleFonts.mali(
                                  color: AppTheme.textSecondary,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 3),
                              FittedBox(
                                fit: BoxFit.scaleDown,
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  '₹${totalSpent.toStringAsFixed(0)}',
                                  style: GoogleFonts.mali(
                                    color: const Color(0xFFE11D48),
                                    fontSize: 26,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: -0.6,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          GestureDetector(
                            onTap: () => BudgetPage.push(context),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: AppTheme.cardSurface,
                                borderRadius: BorderRadius.circular(999),
                                border: Border.all(color: AppTheme.borderSubtle),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.tune_rounded, size: 13, color: AppTheme.accentDark),
                                  const SizedBox(width: 5),
                                  Text(
                                    'Budget Caps',
                                    style: GoogleFonts.mali(
                                      color: AppTheme.accentDark,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF0FDF4),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: const Color(0xFFDCFCE7)),
                              ),
                              child: Row(
                                children: [
                                  const CuteSvgIcon(assetName: 'income', size: 16, color: Color(0xFF16A34A)),
                                  const SizedBox(width: 6),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Inflow Pool',
                                          style: GoogleFonts.mali(
                                            color: const Color(0xFF15803D),
                                            fontSize: 10,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        FittedBox(
                                          fit: BoxFit.scaleDown,
                                          alignment: Alignment.centerLeft,
                                          child: Text(
                                            '₹${monthlyInflow.toStringAsFixed(0)}',
                                            style: GoogleFonts.mali(
                                              color: const Color(0xFF16A34A),
                                              fontSize: 12,
                                              fontWeight: FontWeight.w700,
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
                          const SizedBox(width: 8),
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                              decoration: BoxDecoration(
                                color: const Color(0xFFEFF6FF),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: const Color(0xFFDBEAFE)),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.savings_outlined, size: 16, color: Color(0xFF2563EB)),
                                  const SizedBox(width: 6),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Headroom',
                                          style: GoogleFonts.mali(
                                            color: const Color(0xFF1D4ED8),
                                            fontSize: 10,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        FittedBox(
                                          fit: BoxFit.scaleDown,
                                          alignment: Alignment.centerLeft,
                                          child: Text(
                                            '₹${max(0.0, monthlyInflow - totalSpent).toStringAsFixed(0)}',
                                            style: GoogleFonts.mali(
                                              color: const Color(0xFF2563EB),
                                              fontSize: 12,
                                              fontWeight: FontWeight.w700,
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
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Section Header: Expenses Breakdown
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 6, 20, 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Expense Breakdown',
                      style: GoogleFonts.mali(
                        color: AppTheme.textPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    if (_selectedCategoryName != null)
                      GestureDetector(
                        onTap: () => setState(() => _selectedCategoryName = null),
                        child: Text(
                          'Show All',
                          style: GoogleFonts.mali(
                            color: AppTheme.accentDark,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      )
                    else
                      Text(
                        '${categories.length} categories',
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

            // Grid Cards for Category Breakdown
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 1.15,
                ),
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final cat = categories[index];
                    final spent = wallet.getCategorySpent(cat.name);
                    final budget = wallet.getCategoryBudget(cat.name);
                    final isSelected = _selectedCategoryName == cat.name;

                    return _buildCategoryGridCard(
                      category: cat,
                      spent: spent,
                      budget: budget,
                      totalExpense: totalSpent,
                      isSelected: isSelected,
                      onTap: () {
                        setState(() {
                          if (_selectedCategoryName == cat.name) {
                            _selectedCategoryName = null;
                          } else {
                            _selectedCategoryName = cat.name;
                          }
                        });
                      },
                    );
                  },
                  childCount: categories.length,
                ),
              ),
            ),

            // Itemized Transactions Header for Selected / All Categories
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 22, 20, 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _selectedCategoryName == null
                          ? 'Recent Expenses'
                          : '$_selectedCategoryName Activity',
                      style: GoogleFonts.mali(
                        color: AppTheme.textPrimary,
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      '${displayedTransactions.length} logs',
                      style: GoogleFonts.mali(
                        color: AppTheme.textMuted,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Transactions List
            if (displayedTransactions.isEmpty)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 30),
                  child: Center(
                    child: Text(
                      _selectedCategoryName == null
                          ? 'No expense transactions recorded.'
                          : 'No expenses under $_selectedCategoryName.',
                      style: GoogleFonts.mali(color: AppTheme.textMuted, fontSize: 13),
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
                      final tx = displayedTransactions[index];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.all(12),
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
                              width: 42,
                              height: 42,
                              decoration: BoxDecoration(
                                color: AppTheme.cardSurface,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              padding: const EdgeInsets.all(10),
                              child: CuteSvgIcon(
                                assetName: tx.icon,
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
                                    tx.title,
                                    style: GoogleFonts.mali(
                                      color: AppTheme.textPrimary,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    '${tx.category} • ${DateFormat('MMM dd').format(tx.date)}',
                                    style: GoogleFonts.mali(
                                      color: AppTheme.textMuted,
                                      fontSize: 11,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Text(
                              '-₹${tx.amount.toStringAsFixed(2)}',
                              style: GoogleFonts.mali(
                                color: const Color(0xFFE11D48),
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                    childCount: displayedTransactions.length,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryGridCard({
    required CategoryModel category,
    required double spent,
    required double budget,
    required double totalExpense,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final double percentage = totalExpense > 0 ? (spent / totalExpense * 100) : 0.0;
    final double budgetRatio = budget > 0 ? (spent / budget).clamp(0.0, 1.0) : 0.0;
    final bool isExceeded = spent > budget;

    // Badge color reflecting status
    Color badgeColor = const Color(0xFF10B981);
    if (percentage > 30 || isExceeded) {
      badgeColor = const Color(0xFFE11D48);
    } else if (percentage > 15 || budgetRatio > 0.7) {
      badgeColor = const Color(0xFFF59E0B);
    }

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(13),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.accentDark : AppTheme.surfaceWhite,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppTheme.accentDark : AppTheme.borderSubtle,
            width: isSelected ? 1.5 : 1.0,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isSelected ? 0.12 : 0.02),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Top Row: Category icon in soft rounded box + percentage tag
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: isSelected ? Colors.white.withValues(alpha: 0.15) : AppTheme.cardSurface,
                    borderRadius: BorderRadius.circular(11),
                  ),
                  padding: const EdgeInsets.all(8),
                  child: CuteSvgIcon(
                    assetName: category.icon,
                    size: 18,
                    color: isSelected ? Colors.white : AppTheme.accentDark,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? Colors.white.withValues(alpha: 0.18)
                        : badgeColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    '${percentage.toStringAsFixed(0)}%',
                    style: GoogleFonts.mali(
                      color: isSelected ? Colors.white : badgeColor,
                      fontSize: 10.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),

            // Middle: Category Name & Spent Amount
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  category.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.mali(
                    color: isSelected ? Colors.white.withValues(alpha: 0.85) : AppTheme.textSecondary,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    '₹${spent.toStringAsFixed(0)}',
                    style: GoogleFonts.mali(
                      color: isSelected ? Colors.white : AppTheme.textPrimary,
                      fontSize: 19,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.5,
                    ),
                  ),
                ),
              ],
            ),

            // Bottom: Progress bar & Budget indicator
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(999),
                  child: LinearProgressIndicator(
                    value: budgetRatio,
                    minHeight: 4,
                    backgroundColor: isSelected ? Colors.white.withValues(alpha: 0.15) : AppTheme.cardSurface,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      isSelected
                          ? Colors.white
                          : (isExceeded ? const Color(0xFFE11D48) : badgeColor),
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: Text(
                        'Cap ₹${budget.toStringAsFixed(0)}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.mali(
                          color: isSelected ? Colors.white.withValues(alpha: 0.7) : AppTheme.textMuted,
                          fontSize: 9.5,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    Text(
                      isExceeded ? 'Exceeded' : '${(budgetRatio * 100).toStringAsFixed(0)}%',
                      style: GoogleFonts.mali(
                        color: isSelected
                            ? Colors.white.withValues(alpha: 0.9)
                            : (isExceeded ? const Color(0xFFE11D48) : AppTheme.textMuted),
                        fontSize: 9.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

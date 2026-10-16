import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/cute_svg_icon.dart';
import '../../core/widgets/pill_button.dart';
import '../../models/transaction_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/wallet_provider.dart';
import '../categories/categories_page.dart';
import '../budget/budget_page.dart';

class AddTransactionPage extends StatefulWidget {
  final TransactionType initialType;

  const AddTransactionPage({
    super.key,
    this.initialType = TransactionType.expense,
  });

  static Future<void> push(BuildContext context, {TransactionType initialType = TransactionType.expense}) {
    return Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => AddTransactionPage(initialType: initialType),
      ),
    );
  }

  @override
  State<AddTransactionPage> createState() => _AddTransactionPageState();
}

class _AddTransactionPageState extends State<AddTransactionPage> {
  final _amountController = TextEditingController();
  final _titleController = TextEditingController();
  final _noteController = TextEditingController();

  late TransactionType _selectedType;
  String? _selectedAccountId;
  String? _selectedToAccountId;
  String _selectedCategory = 'Food & Coffee';
  String _selectedIcon = 'coffee';

  // Budget Allocation Options
  String _selectedBudgetPot = 'Needs (50%)';
  String _selectedDepositPot = 'Monthly Pool';

  @override
  void initState() {
    super.initState();
    _selectedType = widget.initialType;
    _amountController.addListener(() {
      if (mounted) setState(() {});
    });
    final accounts = context.read<WalletProvider>().accounts;
    if (accounts.isNotEmpty) {
      _selectedAccountId = accounts.first.id;
      if (accounts.length > 1) {
        _selectedToAccountId = accounts[1].id;
      }
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _titleController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  void _save() {
    final amountText = _amountController.text.trim();
    final titleText = _titleController.text.trim();

    if (amountText.isEmpty) return;
    final amount = double.tryParse(amountText) ?? 0.0;
    if (amount <= 0) return;

    final user = context.read<AuthProvider>().user;
    final wallet = context.read<WalletProvider>();

    String finalTitle = titleText;
    if (finalTitle.isEmpty) {
      if (_selectedType == TransactionType.transfer) {
        final fromAcc = wallet.accounts.firstWhere((a) => a.id == _selectedAccountId).name;
        final toAcc = wallet.accounts.firstWhere((a) => a.id == _selectedToAccountId).name;
        finalTitle = 'Transfer: $fromAcc → $toAcc';
      } else {
        finalTitle = _selectedType == TransactionType.expense ? 'Expense' : 'Income';
      }
    }

    String noteStr = _noteController.text.trim();
    if (_selectedType == TransactionType.expense) {
      noteStr = noteStr.isEmpty ? 'Bucket: $_selectedBudgetPot' : '$noteStr • [$_selectedBudgetPot]';
    } else if (_selectedType == TransactionType.income) {
      noteStr = noteStr.isEmpty ? 'Deposit: $_selectedDepositPot' : '$noteStr • [$_selectedDepositPot]';
    }

    final tx = TransactionModel(
      id: const Uuid().v4(),
      title: finalTitle,
      amount: amount,
      category: _selectedType == TransactionType.transfer ? 'Self Transfer' : _selectedCategory,
      type: _selectedType,
      date: DateTime.now(),
      note: noteStr.isEmpty ? null : noteStr,
      icon: _selectedType == TransactionType.transfer ? 'wallet' : _selectedIcon,
      accountId: _selectedAccountId,
      toAccountId: _selectedType == TransactionType.transfer ? _selectedToAccountId : null,
    );

    wallet.addTransaction(tx, monthlyBudget: user?.monthlyBudget);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final wallet = context.watch<WalletProvider>();
    final accounts = wallet.accounts;

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
          'Log Entry',
          style: GoogleFonts.mali(
            color: AppTheme.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Flow Type Switcher Tabs (Expense | Income | Self Transfer)
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: AppTheme.cardSurface,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    _buildFlowTab('Expense', TransactionType.expense),
                    _buildFlowTab('Income', TransactionType.income),
                    _buildFlowTab('Self Transfer', TransactionType.transfer),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Amount Input
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceWhite,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppTheme.borderSubtle),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.02),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'AMOUNT',
                      style: GoogleFonts.mali(
                        color: AppTheme.textMuted,
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Text(
                          _selectedType == TransactionType.expense
                              ? '- ₹'
                              : (_selectedType == TransactionType.income ? '+ ₹' : '⇄ ₹'),
                          style: GoogleFonts.mali(
                            color: _selectedType == TransactionType.expense
                                ? const Color(0xFFE11D48)
                                : (_selectedType == TransactionType.income
                                    ? const Color(0xFF10B981)
                                    : AppTheme.accentDark),
                            fontSize: 28,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextField(
                            controller: _amountController,
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            autofocus: true,
                            style: GoogleFonts.mali(
                              color: AppTheme.textPrimary,
                              fontSize: 28,
                              fontWeight: FontWeight.w700,
                            ),
                            decoration: InputDecoration(
                              hintText: '0',
                              hintStyle: GoogleFonts.mali(
                                color: AppTheme.textMuted,
                                fontSize: 28,
                                fontWeight: FontWeight.w700,
                              ),
                              border: InputBorder.none,
                              isDense: true,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 18),

              // Account Selection (Source Account)
              Text(
                _selectedType == TransactionType.transfer ? 'SOURCE ACCOUNT (FROM)' : 'ACCOUNT',
                style: GoogleFonts.mali(
                  color: AppTheme.textMuted,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),

              SizedBox(
                height: 72,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: accounts.length,
                  separatorBuilder: (_, _) => const SizedBox(width: 10),
                  itemBuilder: (context, index) {
                    final acc = accounts[index];
                    final isSelected = _selectedAccountId == acc.id;
                    return GestureDetector(
                      onTap: () => setState(() => _selectedAccountId = acc.id),
                      child: Container(
                        width: 140,
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: isSelected ? AppTheme.accentDark : AppTheme.surfaceWhite,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isSelected ? AppTheme.accentDark : AppTheme.borderSubtle,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.02),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              acc.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.mali(
                                color: isSelected ? Colors.white : AppTheme.textPrimary,
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              '₹${acc.balance.toStringAsFixed(0)}',
                              style: GoogleFonts.mali(
                                color: isSelected
                                    ? Colors.white.withValues(alpha: 0.8)
                                    : AppTheme.textSecondary,
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),

              // If Self Transfer: Destination Account Selector
              if (_selectedType == TransactionType.transfer) ...[
                const SizedBox(height: 18),
                Text(
                  'DESTINATION ACCOUNT (TO)',
                  style: GoogleFonts.mali(
                    color: AppTheme.textMuted,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),

                SizedBox(
                  height: 72,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: accounts.length,
                    separatorBuilder: (_, _) => const SizedBox(width: 10),
                    itemBuilder: (context, index) {
                      final acc = accounts[index];
                      final isSelected = _selectedToAccountId == acc.id;
                      final isSameAsSource = _selectedAccountId == acc.id;

                      return GestureDetector(
                        onTap: isSameAsSource ? null : () => setState(() => _selectedToAccountId = acc.id),
                        child: Opacity(
                          opacity: isSameAsSource ? 0.35 : 1.0,
                          child: Container(
                            width: 140,
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: isSelected ? AppTheme.accentDark : AppTheme.surfaceWhite,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: isSelected ? AppTheme.accentDark : AppTheme.borderSubtle,
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  acc.name,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: GoogleFonts.mali(
                                    color: isSelected ? Colors.white : AppTheme.textPrimary,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  '₹${acc.balance.toStringAsFixed(0)}',
                                  style: GoogleFonts.mali(
                                    color: isSelected
                                        ? Colors.white.withValues(alpha: 0.8)
                                        : AppTheme.textSecondary,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],

              // Categories (only for Expense and Income)
              if (_selectedType != TransactionType.transfer) ...[
                const SizedBox(height: 18),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'CATEGORY',
                      style: GoogleFonts.mali(
                        color: AppTheme.textMuted,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    GestureDetector(
                      onTap: () async {
                        final selected = await CategoriesPage.push(
                          context,
                          selectedCategoryName: _selectedCategory,
                        );
                        if (selected != null) {
                          setState(() {
                            _selectedCategory = selected.name;
                            _selectedIcon = selected.icon;
                          });
                        }
                      },
                      child: Text(
                        'View All',
                        style: GoogleFonts.mali(
                          color: AppTheme.textPrimary,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                SizedBox(
                  height: 40,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: wallet.categories.length,
                    separatorBuilder: (_, _) => const SizedBox(width: 8),
                    itemBuilder: (context, index) {
                      final cat = wallet.categories[index];
                      final isSelected = _selectedCategory == cat.name;
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedCategory = cat.name;
                            _selectedIcon = cat.icon;
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14),
                          decoration: BoxDecoration(
                            color: isSelected ? AppTheme.accentDark : AppTheme.surfaceWhite,
                            borderRadius: BorderRadius.circular(999),
                            border: Border.all(
                              color: isSelected ? AppTheme.accentDark : AppTheme.borderSubtle,
                            ),
                          ),
                          child: Row(
                            children: [
                              CuteSvgIcon(
                                assetName: cat.icon,
                                size: 16,
                                color: isSelected ? Colors.white : AppTheme.textSecondary,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                cat.name,
                                style: GoogleFonts.mali(
                                  color: isSelected ? Colors.white : AppTheme.textSecondary,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],

              // Budget Option & Allocation Section (Expense & Income/Deposit)
              _buildBudgetSection(wallet),

              const SizedBox(height: 18),

              // Title / Description
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceWhite,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppTheme.borderSubtle),
                ),
                child: TextField(
                  controller: _titleController,
                  style: GoogleFonts.mali(
                    color: AppTheme.textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                  decoration: InputDecoration(
                    hintText: _selectedType == TransactionType.transfer
                        ? 'Transfer note (e.g. Bank to Cash)'
                        : 'Description (e.g. Uber Ride, Dinner)',
                    hintStyle: GoogleFonts.mali(color: AppTheme.textMuted, fontSize: 13),
                    border: InputBorder.none,
                    isDense: true,
                  ),
                ),
              ),

              const SizedBox(height: 28),

              // Confirm Button
              PillButton(
                label: _selectedType == TransactionType.transfer
                    ? 'Execute Self Transfer'
                    : 'Confirm Transaction',
                isPrimary: true,
                width: double.infinity,
                onTap: _save,
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBudgetSection(WalletProvider wallet) {
    final enteredAmount = double.tryParse(_amountController.text.trim()) ?? 0.0;

    if (_selectedType == TransactionType.expense) {
      final catBudget = wallet.getCategoryBudget(_selectedCategory);
      final catSpent = wallet.getCategorySpent(_selectedCategory);
      final projectedSpent = catSpent + enteredAmount;
      final catRatio = catBudget > 0 ? (projectedSpent / catBudget).clamp(0.0, 1.0) : 0.0;
      final remaining = (catBudget - projectedSpent).clamp(0.0, double.infinity);
      final isExceeded = projectedSpent > catBudget;

      return Container(
        margin: const EdgeInsets.only(top: 18),
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.track_changes_rounded, size: 16, color: AppTheme.accentDark),
                    const SizedBox(width: 6),
                    Text(
                      'BUDGET ALLOCATION',
                      style: GoogleFonts.mali(
                        color: AppTheme.textMuted,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ],
                ),
                GestureDetector(
                  onTap: () => BudgetPage.push(context),
                  child: Text(
                    'Budget Page →',
                    style: GoogleFonts.mali(
                      color: AppTheme.accentDark,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    '$_selectedCategory Cap',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.mali(
                      color: AppTheme.textPrimary,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                Text(
                  '₹${catSpent.toStringAsFixed(0)} / ₹${catBudget.toStringAsFixed(0)}',
                  style: GoogleFonts.mali(
                    color: AppTheme.textPrimary,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
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
            const SizedBox(height: 6),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  isExceeded
                      ? 'Exceeds cap by ₹${(projectedSpent - catBudget).toStringAsFixed(0)}'
                      : '₹${remaining.toStringAsFixed(0)} left after this',
                  style: GoogleFonts.mali(
                    color: isExceeded ? const Color(0xFFDC2626) : AppTheme.textMuted,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  '${(catRatio * 100).toStringAsFixed(0)}%',
                  style: GoogleFonts.mali(
                    color: isExceeded ? const Color(0xFFDC2626) : AppTheme.textSecondary,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              '50/30/20 Smart Bucket:',
              style: GoogleFonts.mali(
                color: AppTheme.textSecondary,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                _buildPotChip('Needs (50%)'),
                const SizedBox(width: 6),
                _buildPotChip('Wants (30%)'),
                const SizedBox(width: 6),
                _buildPotChip('Savings (20%)'),
              ],
            ),
          ],
        ),
      );
    } else if (_selectedType == TransactionType.income) {
      return Container(
        margin: const EdgeInsets.only(top: 18),
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.savings_outlined, size: 16, color: Color(0xFF10B981)),
                    const SizedBox(width: 6),
                    Text(
                      'DEPOSIT BUDGET OPTION',
                      style: GoogleFonts.mali(
                        color: AppTheme.textMuted,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ],
                ),
                GestureDetector(
                  onTap: () => BudgetPage.push(context),
                  child: Text(
                    'Budget Page →',
                    style: GoogleFonts.mali(
                      color: AppTheme.accentDark,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              'Allocate this incoming deposit:',
              style: GoogleFonts.mali(
                color: AppTheme.textPrimary,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                _buildDepositPotChip('Monthly Pool'),
                const SizedBox(width: 6),
                _buildDepositPotChip('Savings Vault'),
                const SizedBox(width: 6),
                _buildDepositPotChip('Emergency Fund'),
              ],
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppTheme.cardSurface,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline_rounded, size: 15, color: Color(0xFF059669)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      enteredAmount > 0
                          ? 'Depositing ₹${enteredAmount.toStringAsFixed(0)} expands your monthly budget pool.'
                          : 'Enter amount above to preview budget boost.',
                      style: GoogleFonts.mali(
                        color: AppTheme.textSecondary,
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }
    return const SizedBox.shrink();
  }

  Widget _buildPotChip(String label) {
    final isSelected = _selectedBudgetPot == label;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedBudgetPot = label),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 7),
          decoration: BoxDecoration(
            color: isSelected ? AppTheme.accentDark : AppTheme.cardSurface,
            borderRadius: BorderRadius.circular(10),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.mali(
              color: isSelected ? Colors.white : AppTheme.textSecondary,
              fontSize: 10.5,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDepositPotChip(String label) {
    final isSelected = _selectedDepositPot == label;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedDepositPot = label),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 7),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF0F766E) : AppTheme.cardSurface,
            borderRadius: BorderRadius.circular(10),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.mali(
              color: isSelected ? Colors.white : AppTheme.textSecondary,
              fontSize: 10.5,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFlowTab(String title, TransactionType type) {
    final isSelected = _selectedType == type;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedType = type),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 9),
          decoration: BoxDecoration(
            color: isSelected ? AppTheme.surfaceWhite : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          alignment: Alignment.center,
          child: Text(
            title,
            style: GoogleFonts.mali(
              color: isSelected ? AppTheme.textPrimary : AppTheme.textMuted,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/cute_svg_icon.dart';
import '../../core/widgets/pill_button.dart';
import '../../models/account_model.dart';
import '../../models/transaction_model.dart';
import '../../providers/wallet_provider.dart';
import '../sheets/transaction_detail_sheet.dart';

class AccountsScreen extends StatefulWidget {
  const AccountsScreen({super.key});

  @override
  State<AccountsScreen> createState() => _AccountsScreenState();
}

class _AccountsScreenState extends State<AccountsScreen> {
  String? _selectedAccountId;

  void _showAddAccountDialog(BuildContext context) {
    final nameCtrl = TextEditingController();
    final balanceCtrl = TextEditingController();
    String type = 'bank';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setModalState) {
            final bottomInset = MediaQuery.of(ctx).viewInsets.bottom;
            return Container(
              padding: EdgeInsets.only(left: 20, right: 20, top: 16, bottom: 24 + bottomInset),
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
                  Text(
                    'Add New Account',
                    style: GoogleFonts.mali(
                      color: AppTheme.textPrimary,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: AppTheme.cardSurface,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: TextField(
                      controller: nameCtrl,
                      style: GoogleFonts.mali(color: AppTheme.textPrimary, fontSize: 14, fontWeight: FontWeight.w600),
                      decoration: InputDecoration(
                        hintText: 'Account Name (e.g. HDFC Salary, Axis Bank)',
                        hintStyle: GoogleFonts.mali(color: AppTheme.textMuted, fontSize: 13),
                        border: InputBorder.none,
                        isDense: true,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: AppTheme.cardSurface,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: TextField(
                      controller: balanceCtrl,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      style: GoogleFonts.mali(color: AppTheme.textPrimary, fontSize: 14, fontWeight: FontWeight.w700),
                      decoration: InputDecoration(
                        hintText: 'Initial Balance (₹)',
                        hintStyle: GoogleFonts.mali(color: AppTheme.textMuted, fontSize: 13),
                        border: InputBorder.none,
                        isDense: true,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: ['bank', 'cash', 'savings'].map((t) {
                      final isSelected = type == t;
                      return Expanded(
                        child: GestureDetector(
                          onTap: () => setModalState(() => type = t),
                          child: Container(
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            padding: const EdgeInsets.symmetric(vertical: 9),
                            decoration: BoxDecoration(
                              color: isSelected ? AppTheme.accentDark : AppTheme.cardSurface,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              t.toUpperCase(),
                              style: GoogleFonts.mali(
                                color: isSelected ? Colors.white : AppTheme.textSecondary,
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 24),
                  PillButton(
                    label: 'Create Account',
                    isPrimary: true,
                    width: double.infinity,
                    onTap: () {
                      final name = nameCtrl.text.trim();
                      final bal = double.tryParse(balanceCtrl.text.trim()) ?? 0.0;
                      if (name.isNotEmpty) {
                        final newAcc = AccountModel(
                          id: const Uuid().v4(),
                          name: name,
                          balance: bal,
                          type: type,
                          icon: type == 'cash' ? 'income' : 'wallet',
                        );
                        context.read<WalletProvider>().addAccount(newAcc);
                        Navigator.pop(ctx);
                      }
                    },
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _confirmDeleteAccount(BuildContext context, AccountModel acc) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.surfaceWhite,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Delete Account?',
          style: GoogleFonts.mali(fontWeight: FontWeight.w700, fontSize: 16, color: AppTheme.textPrimary),
        ),
        content: Text(
          'Are you sure you want to remove "${acc.name}"? This action cannot be undone.',
          style: GoogleFonts.mali(fontSize: 13, color: AppTheme.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancel', style: GoogleFonts.mali(color: AppTheme.textSecondary, fontWeight: FontWeight.w600)),
          ),
          TextButton(
            onPressed: () {
              context.read<WalletProvider>().deleteAccount(acc.id);
              Navigator.pop(ctx);
            },
            child: Text('Delete', style: GoogleFonts.mali(color: const Color(0xFFE11D48), fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final wallet = context.watch<WalletProvider>();
    final accounts = wallet.accounts;

    if (_selectedAccountId == null && accounts.isNotEmpty) {
      _selectedAccountId = accounts.first.id;
    } else if (accounts.isNotEmpty && !accounts.any((a) => a.id == _selectedAccountId)) {
      _selectedAccountId = accounts.first.id;
    }

    final currentAcc = accounts.firstWhere(
      (a) => a.id == _selectedAccountId,
      orElse: () => accounts.isNotEmpty ? accounts.first : AccountModel(id: '', name: 'None', balance: 0),
    );

    final accTransactions = currentAcc.id.isNotEmpty
        ? wallet.getTransactionsForAccount(currentAcc.id)
        : <TransactionModel>[];

    final accIncome = currentAcc.id.isNotEmpty ? wallet.getAccountIncome(currentAcc.id) : 0.0;
    final accExpense = currentAcc.id.isNotEmpty ? wallet.getAccountExpense(currentAcc.id) : 0.0;

    return Scaffold(
      backgroundColor: AppTheme.bgLight,
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // Top Bar
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 14, 20, 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Accounts & Liquidity',
                      style: GoogleFonts.mali(
                        color: AppTheme.textPrimary,
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.4,
                      ),
                    ),
                    GestureDetector(
                      onTap: () => _showAddAccountDialog(context),
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
              ),
            ),

            // Accounts Horizontal Carousel OR Prominent "Add First Account" Card
            if (accounts.isEmpty)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: AppTheme.surfaceWhite,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: AppTheme.borderSubtle),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.02),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Container(
                          width: 58,
                          height: 58,
                          decoration: const BoxDecoration(
                            color: AppTheme.cardSurface,
                            shape: BoxShape.circle,
                          ),
                          padding: const EdgeInsets.all(16),
                          child: const CuteSvgIcon(
                            assetName: 'wallet',
                            size: 26,
                            color: AppTheme.accentDark,
                          ),
                        ),
                        const SizedBox(height: 14),
                        Text(
                          'No Accounts Connected',
                          style: GoogleFonts.mali(
                            color: AppTheme.textPrimary,
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Add your bank, cash wallet, or savings account to track balances seamlessly.',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.mali(
                            color: AppTheme.textSecondary,
                            fontSize: 12,
                            height: 1.4,
                          ),
                        ),
                        const SizedBox(height: 18),
                        PillButton(
                          label: '+ Add First Account',
                          isPrimary: true,
                          width: double.infinity,
                          onTap: () => _showAddAccountDialog(context),
                        ),
                      ],
                    ),
                  ),
                ),
              )
            else
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: SizedBox(
                    height: 156,
                    child: ListView.separated(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      scrollDirection: Axis.horizontal,
                      itemCount: accounts.length,
                      separatorBuilder: (_, _) => const SizedBox(width: 14),
                      itemBuilder: (context, index) {
                        final acc = accounts[index];
                        final isSelected = _selectedAccountId == acc.id;

                        return GestureDetector(
                          onTap: () => setState(() => _selectedAccountId = acc.id),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            width: 240,
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: isSelected ? AppTheme.cardDark : AppTheme.surfaceWhite,
                              borderRadius: BorderRadius.circular(22),
                              border: Border.all(
                                color: isSelected ? AppTheme.cardDark : AppTheme.borderSubtle,
                                width: 1.5,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: isSelected ? 0.15 : 0.03),
                                  blurRadius: 14,
                                  offset: const Offset(0, 5),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                // Top row with truncated long name + type badge & delete
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        acc.name,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: GoogleFonts.mali(
                                          color: isSelected ? Colors.white : AppTheme.textPrimary,
                                          fontSize: 14,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                                      decoration: BoxDecoration(
                                        color: isSelected
                                            ? Colors.white.withValues(alpha: 0.15)
                                            : AppTheme.cardSurface,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        acc.type.toUpperCase(),
                                        style: GoogleFonts.mali(
                                          color: isSelected ? Colors.white : AppTheme.textSecondary,
                                          fontSize: 9,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ),
                                    if (isSelected && accounts.length > 1) ...[
                                      const SizedBox(width: 6),
                                      GestureDetector(
                                        onTap: () => _confirmDeleteAccount(context, acc),
                                        child: Icon(
                                          Icons.close_rounded,
                                          size: 16,
                                          color: Colors.white.withValues(alpha: 0.7),
                                        ),
                                      ),
                                    ],
                                  ],
                                ),

                                // Balance block with robust sizing
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Balance',
                                      style: GoogleFonts.mali(
                                        color: isSelected ? const Color(0xFF9E9EA7) : AppTheme.textMuted,
                                        fontSize: 10,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    FittedBox(
                                      fit: BoxFit.scaleDown,
                                      alignment: Alignment.centerLeft,
                                      child: Text(
                                        '₹${acc.balance.toStringAsFixed(2)}',
                                        style: GoogleFonts.mali(
                                          color: isSelected ? Colors.white : AppTheme.textPrimary,
                                          fontSize: 22,
                                          fontWeight: FontWeight.w700,
                                          letterSpacing: -0.5,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),

            if (accounts.isNotEmpty) ...[
              // Selected Account Inflow / Outflow Summary Card
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 6, 20, 14),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                    decoration: BoxDecoration(
                      color: AppTheme.surfaceWhite,
                      borderRadius: BorderRadius.circular(18),
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
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'TOTAL INFLOW',
                                style: GoogleFonts.mali(
                                  color: AppTheme.textMuted,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 4),
                              FittedBox(
                                fit: BoxFit.scaleDown,
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  '+₹${accIncome.toStringAsFixed(0)}',
                                  style: GoogleFonts.mali(
                                    color: const Color(0xFF10B981),
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(width: 1, height: 32, color: AppTheme.borderSubtle),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'TOTAL OUTFLOW',
                                style: GoogleFonts.mali(
                                  color: AppTheme.textMuted,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 4),
                              FittedBox(
                                fit: BoxFit.scaleDown,
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  '-₹${accExpense.toStringAsFixed(0)}',
                                  style: GoogleFonts.mali(
                                    color: const Color(0xFFE11D48),
                                    fontSize: 16,
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
              ),

              // Account Activity Header
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          '${currentAcc.name} History',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.mali(
                            color: AppTheme.textPrimary,
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${accTransactions.length} logs',
                        style: GoogleFonts.mali(
                          color: AppTheme.textMuted,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Per-Account Transactions List
              if (accTransactions.isEmpty)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 36),
                    child: Center(
                      child: Text(
                        'No transactions recorded for this account.',
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
                        final item = accTransactions[index];
                        final isExpense = item.type == TransactionType.expense ||
                            (item.type == TransactionType.transfer && item.accountId == currentAcc.id);

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
                          child: InkWell(
                            onTap: () => TransactionDetailSheet.show(context, item),
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
                                    assetName: item.icon,
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
                                  '${isExpense ? '-' : '+'}₹${item.amount.toStringAsFixed(2)}',
                                  style: GoogleFonts.mali(
                                    color: isExpense ? const Color(0xFFE11D48) : const Color(0xFF10B981),
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                      childCount: accTransactions.length,
                    ),
                  ),
                ),
            ],
          ],
        ),
      ),
    );
  }
}

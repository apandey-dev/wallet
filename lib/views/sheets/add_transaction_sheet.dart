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

class AddTransactionSheet extends StatefulWidget {
  const AddTransactionSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const AddTransactionSheet(),
    );
  }

  @override
  State<AddTransactionSheet> createState() => _AddTransactionSheetState();
}

class _AddTransactionSheetState extends State<AddTransactionSheet> {
  final _amountController = TextEditingController();
  final _titleController = TextEditingController();
  final _noteController = TextEditingController();

  TransactionType _selectedType = TransactionType.expense;
  String _selectedCategory = 'Food & Coffee';
  String _selectedIcon = 'coffee';

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

    if (amountText.isEmpty || titleText.isEmpty) {
      return;
    }

    final amount = double.tryParse(amountText) ?? 0.0;
    if (amount <= 0) return;

    final user = context.read<AuthProvider>().user;
    final wallet = context.read<WalletProvider>();

    final tx = TransactionModel(
      id: const Uuid().v4(),
      title: titleText,
      amount: amount,
      category: _selectedCategory,
      type: _selectedType,
      date: DateTime.now(),
      note: _noteController.text.trim().isEmpty ? null : _noteController.text.trim(),
      icon: _selectedIcon,
    );

    wallet.addTransaction(tx, monthlyBudget: user?.monthlyBudget);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

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
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle bar
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

            // Header & Type Switcher Pills
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'New Entry',
                  style: GoogleFonts.mali(
                    color: AppTheme.textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(3),
                  decoration: BoxDecoration(
                    color: AppTheme.cardSurface,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Row(
                    children: [
                      _buildTypePill('Expense', TransactionType.expense),
                      _buildTypePill('Income', TransactionType.income),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 18),

            // Amount Field
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: AppTheme.cardSurface,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  Text(
                    _selectedType == TransactionType.expense ? '- ₹' : '+ ₹',
                    style: GoogleFonts.mali(
                      color: _selectedType == TransactionType.expense
                          ? const Color(0xFFE11D48)
                          : const Color(0xFF10B981),
                      fontSize: 24,
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
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                      ),
                      decoration: InputDecoration(
                        hintText: '0',
                        hintStyle: GoogleFonts.mali(
                          color: AppTheme.textMuted,
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                        ),
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // Title Field
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: AppTheme.cardSurface,
                borderRadius: BorderRadius.circular(16),
              ),
              child: TextField(
                controller: _titleController,
                style: GoogleFonts.mali(
                  color: AppTheme.textPrimary,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
                decoration: InputDecoration(
                  hintText: 'Description (e.g. Uber Ride, Starbucks)',
                  hintStyle: GoogleFonts.mali(color: AppTheme.textMuted, fontSize: 13),
                  border: InputBorder.none,
                  isDense: true,
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Category Label & View All Link
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

            // Category Chips with Cute Rounded SVG Icons
            SizedBox(
              height: 40,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: context.watch<WalletProvider>().categories.length,
                separatorBuilder: (_, _) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final cat = context.watch<WalletProvider>().categories[index];
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
                        color: isSelected ? AppTheme.accentDark : AppTheme.cardSurface,
                        borderRadius: BorderRadius.circular(999),
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

            const SizedBox(height: 24),

            // Save Pill Button
            PillButton(
              label: 'Save Transaction',
              isPrimary: true,
              width: double.infinity,
              onTap: _save,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTypePill(String label, TransactionType type) {
    final isSelected = _selectedType == type;
    return GestureDetector(
      onTap: () => setState(() => _selectedType = type),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.surfaceWhite : Colors.transparent,
          borderRadius: BorderRadius.circular(999),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Text(
          label,
          style: GoogleFonts.mali(
            color: isSelected ? AppTheme.textPrimary : AppTheme.textMuted,
            fontSize: 12,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

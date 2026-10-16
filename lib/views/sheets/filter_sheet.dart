import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/pill_button.dart';
import '../../models/transaction_model.dart';
import '../../providers/wallet_provider.dart';

class FilterSheet extends StatefulWidget {
  const FilterSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => const FilterSheet(),
    );
  }

  @override
  State<FilterSheet> createState() => _FilterSheetState();
}

class _FilterSheetState extends State<FilterSheet> {
  late String _selectedCategory;
  late TransactionType? _selectedType;

  final List<String> _categories = [
    'All',
    'Food & Coffee',
    'Shopping',
    'Subscriptions',
    'Bills & Utilities',
    'Travel',
    'Health',
    'Salary',
    'General',
  ];

  @override
  void initState() {
    super.initState();
    final wallet = context.read<WalletProvider>();
    _selectedCategory = wallet.filterCategory;
    _selectedType = wallet.filterType;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
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
              Text(
                'Filters',
                style: GoogleFonts.mali(
                  color: AppTheme.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedCategory = 'All';
                    _selectedType = null;
                  });
                },
                child: Text(
                  'Reset',
                  style: GoogleFonts.mali(
                    color: AppTheme.textMuted,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),

          Text(
            'FLOW TYPE',
            style: GoogleFonts.mali(
              color: AppTheme.textMuted,
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              _buildTypeChip('All', null),
              const SizedBox(width: 8),
              _buildTypeChip('Expenses', TransactionType.expense),
              const SizedBox(width: 8),
              _buildTypeChip('Income', TransactionType.income),
            ],
          ),

          const SizedBox(height: 18),

          Text(
            'CATEGORIES',
            style: GoogleFonts.mali(
              color: AppTheme.textMuted,
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _categories.map((cat) {
              final isSelected = _selectedCategory == cat;
              return GestureDetector(
                onTap: () => setState(() => _selectedCategory = cat),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: isSelected ? AppTheme.accentDark : AppTheme.cardSurface,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    cat,
                    style: GoogleFonts.mali(
                      color: isSelected ? Colors.white : AppTheme.textSecondary,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),

          const SizedBox(height: 24),

          PillButton(
            label: 'Apply Filters',
            isPrimary: true,
            width: double.infinity,
            onTap: () {
              final wallet = context.read<WalletProvider>();
              wallet.setFilterCategory(_selectedCategory);
              wallet.setFilterType(_selectedType);
              Navigator.pop(context);
            },
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _buildTypeChip(String label, TransactionType? type) {
    final isSelected = _selectedType == type;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedType = type),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 9),
          decoration: BoxDecoration(
            color: isSelected ? AppTheme.accentDark : AppTheme.cardSurface,
            borderRadius: BorderRadius.circular(12),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: GoogleFonts.mali(
              color: isSelected ? Colors.white : AppTheme.textSecondary,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }
}

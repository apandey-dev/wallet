import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/cute_svg_icon.dart';
import '../../core/widgets/pill_button.dart';
import '../../models/transaction_model.dart';
import '../../providers/wallet_provider.dart';

class TransactionDetailSheet extends StatelessWidget {
  final TransactionModel transaction;

  const TransactionDetailSheet({super.key, required this.transaction});

  static Future<void> show(BuildContext context, TransactionModel transaction) {
    return showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => TransactionDetailSheet(transaction: transaction),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isExpense = transaction.type == TransactionType.expense;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: const BoxDecoration(
        color: AppTheme.surfaceWhite,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
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
          const SizedBox(height: 20),

          // Icon container
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              color: AppTheme.cardSurface,
              shape: BoxShape.circle,
            ),
            padding: const EdgeInsets.all(15),
            child: CuteSvgIcon(
              assetName: transaction.icon,
              size: 26,
              color: AppTheme.accentDark,
            ),
          ),

          const SizedBox(height: 14),

          // Amount
          Text(
            '${isExpense ? '-' : '+'} ₹${transaction.amount.toStringAsFixed(2)}',
            style: GoogleFonts.mali(
              color: isExpense ? const Color(0xFFE11D48) : const Color(0xFF10B981),
              fontSize: 28,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.5,
            ),
          ),

          const SizedBox(height: 4),

          // Title
          Text(
            transaction.title,
            style: GoogleFonts.mali(
              color: AppTheme.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),

          const SizedBox(height: 20),

          // Details Card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.cardSurface,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Column(
              children: [
                _buildRow('Category', transaction.category),
                const Divider(color: AppTheme.borderLight, height: 16),
                _buildRow(
                  'Date',
                  DateFormat('dd MMMM yyyy, hh:mm a').format(transaction.date),
                ),
                if (transaction.note != null && transaction.note!.isNotEmpty) ...[
                  const Divider(color: AppTheme.borderLight, height: 16),
                  _buildRow('Note', transaction.note!),
                ],
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Delete button
          PillButton(
            label: 'Delete Transaction',
            isPrimary: false,
            textColor: const Color(0xFFE11D48),
            borderColor: const Color(0xFFE11D48).withValues(alpha: 0.3),
            width: double.infinity,
            onTap: () {
              context.read<WalletProvider>().deleteTransaction(transaction.id);
              Navigator.pop(context);
            },
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _buildRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.mali(
            color: AppTheme.textMuted,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
        Text(
          value,
          style: GoogleFonts.mali(
            color: AppTheme.textPrimary,
            fontSize: 13,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

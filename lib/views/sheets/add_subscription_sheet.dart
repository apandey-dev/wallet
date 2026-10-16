import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/pill_button.dart';
import '../../models/subscription_model.dart';
import '../../providers/wallet_provider.dart';

class AddSubscriptionSheet extends StatefulWidget {
  const AddSubscriptionSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const AddSubscriptionSheet(),
    );
  }

  @override
  State<AddSubscriptionSheet> createState() => _AddSubscriptionSheetState();
}

class _AddSubscriptionSheetState extends State<AddSubscriptionSheet> {
  final _nameController = TextEditingController();
  final _amountController = TextEditingController();

  BillingCycle _cycle = BillingCycle.monthly;
  final DateTime _renewalDate = DateTime.now().add(const Duration(days: 30));

  @override
  void dispose() {
    _nameController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  void _save() {
    final name = _nameController.text.trim();
    final amountText = _amountController.text.trim();

    if (name.isEmpty || amountText.isEmpty) return;
    final amount = double.tryParse(amountText) ?? 0.0;
    if (amount <= 0) return;

    final sub = SubscriptionModel(
      id: const Uuid().v4(),
      name: name,
      amount: amount,
      billingCycle: _cycle,
      nextRenewalDate: _renewalDate,
      category: 'Subscriptions',
      icon: 'sub',
      isActive: true,
    );

    context.read<WalletProvider>().addSubscription(sub);
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
              'Add Recurring Plan',
              style: GoogleFonts.mali(
                color: AppTheme.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 16),

            // Service name
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: AppTheme.cardSurface,
                borderRadius: BorderRadius.circular(16),
              ),
              child: TextField(
                controller: _nameController,
                style: GoogleFonts.mali(
                  color: AppTheme.textPrimary,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
                decoration: InputDecoration(
                  hintText: 'Service Name (e.g. Netflix, Spotify)',
                  hintStyle: GoogleFonts.mali(color: AppTheme.textMuted, fontSize: 13),
                  border: InputBorder.none,
                  isDense: true,
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ),

            const SizedBox(height: 12),

            // Amount
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: AppTheme.cardSurface,
                borderRadius: BorderRadius.circular(16),
              ),
              child: TextField(
                controller: _amountController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                style: GoogleFonts.mali(
                  color: AppTheme.textPrimary,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
                decoration: InputDecoration(
                  hintText: 'Amount (₹)',
                  hintStyle: GoogleFonts.mali(color: AppTheme.textMuted, fontSize: 13),
                  border: InputBorder.none,
                  isDense: true,
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Cycle pills
            Text(
              'BILLING CYCLE',
              style: GoogleFonts.mali(
                color: AppTheme.textMuted,
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                _buildCyclePill('Monthly', BillingCycle.monthly),
                const SizedBox(width: 10),
                _buildCyclePill('Yearly', BillingCycle.yearly),
              ],
            ),

            const SizedBox(height: 24),

            PillButton(
              label: 'Track Subscription',
              isPrimary: true,
              width: double.infinity,
              onTap: _save,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCyclePill(String label, BillingCycle cycle) {
    final isSelected = _cycle == cycle;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _cycle = cycle),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? AppTheme.accentDark : AppTheme.cardSurface,
            borderRadius: BorderRadius.circular(14),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: GoogleFonts.mali(
              color: isSelected ? Colors.white : AppTheme.textSecondary,
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }
}

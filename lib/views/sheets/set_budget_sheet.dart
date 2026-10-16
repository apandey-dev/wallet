import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/pill_button.dart';
import '../../providers/auth_provider.dart';
import '../../providers/notification_provider.dart';

class SetBudgetSheet extends StatefulWidget {
  const SetBudgetSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const SetBudgetSheet(),
    );
  }

  @override
  State<SetBudgetSheet> createState() => _SetBudgetSheetState();
}

class _SetBudgetSheetState extends State<SetBudgetSheet> {
  final _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    final budget = context.read<AuthProvider>().user?.monthlyBudget ?? 25000.0;
    _controller.text = budget.toStringAsFixed(0);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _save() {
    final text = _controller.text.trim();
    final budget = double.tryParse(text) ?? 0.0;
    if (budget <= 0) return;

    context.read<AuthProvider>().updateBudget(budget);
    context.read<NotificationProvider>().addNotification(
      title: 'Target Limit Updated',
      body: 'Your spending threshold is now set to ₹${budget.toStringAsFixed(0)}.',
      type: 'info',
    );
    Navigator.pop(context);
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
            'Monthly Target Limit',
            style: GoogleFonts.mali(
              color: AppTheme.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'You will receive in-app alerts when reaching 80% and 100% of this limit.',
            style: GoogleFonts.mali(
              color: AppTheme.textSecondary,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 18),

          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: AppTheme.cardSurface,
              borderRadius: BorderRadius.circular(16),
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
                    controller: _controller,
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

          const SizedBox(height: 24),

          PillButton(
            label: 'Save Target Limit',
            isPrimary: true,
            width: double.infinity,
            onTap: _save,
          ),
        ],
      ),
    );
  }
}

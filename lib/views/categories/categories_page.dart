import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/cute_svg_icon.dart';
import '../../core/widgets/pill_button.dart';
import '../../models/category_model.dart';
import '../../providers/wallet_provider.dart';

class CategoriesPage extends StatefulWidget {
  final String? selectedCategoryName;

  const CategoriesPage({super.key, this.selectedCategoryName});

  static Future<CategoryModel?> push(BuildContext context, {String? selectedCategoryName}) {
    return Navigator.of(context).push<CategoryModel>(
      MaterialPageRoute(
        builder: (_) => CategoriesPage(selectedCategoryName: selectedCategoryName),
      ),
    );
  }

  @override
  State<CategoriesPage> createState() => _CategoriesPageState();
}

class _CategoriesPageState extends State<CategoriesPage> {
  late String? _selectedName;

  final List<String> _availableIcons = [
    'coffee',
    'shopping',
    'sub',
    'bill',
    'travel',
    'health',
    'income',
    'wallet',
  ];

  @override
  void initState() {
    super.initState();
    _selectedName = widget.selectedCategoryName;
  }

  void _showAddCategorySheet(BuildContext context) {
    final nameCtrl = TextEditingController();
    String chosenIcon = 'shopping';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setSheetState) {
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
                    'Create New Category',
                    style: GoogleFonts.mali(
                      color: AppTheme.textPrimary,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Name field
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: AppTheme.cardSurface,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: TextField(
                      controller: nameCtrl,
                      autofocus: true,
                      style: GoogleFonts.mali(color: AppTheme.textPrimary, fontSize: 14, fontWeight: FontWeight.w600),
                      decoration: InputDecoration(
                        hintText: 'Category Name (e.g. Dining, Crypto, Gaming)',
                        hintStyle: GoogleFonts.mali(color: AppTheme.textMuted, fontSize: 13),
                        border: InputBorder.none,
                        isDense: true,
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),
                  Text(
                    'CHOOSE ICON',
                    style: GoogleFonts.mali(
                      color: AppTheme.textMuted,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Icon picker row
                  SizedBox(
                    height: 52,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: _availableIcons.length,
                      separatorBuilder: (_, _) => const SizedBox(width: 10),
                      itemBuilder: (context, index) {
                        final icon = _availableIcons[index];
                        final isChosen = chosenIcon == icon;
                        return GestureDetector(
                          onTap: () => setSheetState(() => chosenIcon = icon),
                          child: Container(
                            width: 52,
                            height: 52,
                            decoration: BoxDecoration(
                              color: isChosen ? AppTheme.accentDark : AppTheme.cardSurface,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: isChosen ? AppTheme.accentDark : AppTheme.borderSubtle,
                              ),
                            ),
                            padding: const EdgeInsets.all(14),
                            child: CuteSvgIcon(
                              assetName: icon,
                              size: 20,
                              color: isChosen ? Colors.white : AppTheme.textPrimary,
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 24),

                  PillButton(
                    label: 'Save Category',
                    isPrimary: true,
                    width: double.infinity,
                    onTap: () {
                      final name = nameCtrl.text.trim();
                      if (name.isNotEmpty) {
                        context.read<WalletProvider>().addCategory(name, chosenIcon);
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

  @override
  Widget build(BuildContext context) {
    final wallet = context.watch<WalletProvider>();
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
          'All Categories',
          style: GoogleFonts.mali(
            color: AppTheme.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 18),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppTheme.cardSurface,
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              '${categories.length} total',
              style: GoogleFonts.mali(
                color: AppTheme.textSecondary,
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: categories.isEmpty
                  ? Center(
                      child: Text(
                        'No categories available.',
                        style: GoogleFonts.mali(color: AppTheme.textMuted, fontSize: 13),
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(20, 10, 20, 16),
                      itemCount: categories.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 8),
                      itemBuilder: (context, index) {
                        final cat = categories[index];
                        final isSelected = _selectedName == cat.name;

                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                          decoration: BoxDecoration(
                            color: isSelected ? AppTheme.cardDark : AppTheme.surfaceWhite,
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(
                              color: isSelected ? AppTheme.cardDark : AppTheme.borderSubtle,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: isSelected ? 0.08 : 0.02),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: InkWell(
                            onTap: () {
                              setState(() => _selectedName = cat.name);
                              Navigator.pop(context, cat);
                            },
                            child: Row(
                              children: [
                                Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? Colors.white.withValues(alpha: 0.15)
                                        : AppTheme.cardSurface,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  padding: const EdgeInsets.all(10),
                                  child: CuteSvgIcon(
                                    assetName: cat.icon,
                                    size: 18,
                                    color: isSelected ? Colors.white : AppTheme.accentDark,
                                  ),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Text(
                                    cat.name,
                                    style: GoogleFonts.mali(
                                      color: isSelected ? Colors.white : AppTheme.textPrimary,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                                if (!cat.isDefault)
                                  GestureDetector(
                                    onTap: () => wallet.deleteCategory(cat.id),
                                    child: Container(
                                      padding: const EdgeInsets.all(6),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFE11D48).withValues(alpha: 0.1),
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                        Icons.delete_outline_rounded,
                                        size: 16,
                                        color: Color(0xFFE11D48),
                                      ),
                                    ),
                                  )
                                else
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: isSelected
                                          ? Colors.white.withValues(alpha: 0.1)
                                          : AppTheme.cardSurface,
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      'DEFAULT',
                                      style: GoogleFonts.mali(
                                        color: isSelected ? Colors.white70 : AppTheme.textMuted,
                                        fontSize: 9,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),

            // Bottom Buttons (2 distinct buttons: Add Category & Done / Delete)
            Container(
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 16),
              decoration: BoxDecoration(
                color: AppTheme.surfaceWhite,
                border: const Border(
                  top: BorderSide(color: AppTheme.borderSubtle, width: 1.2),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: PillButton(
                      label: '+ Add Category',
                      isPrimary: true,
                      onTap: () => _showAddCategorySheet(context),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: PillButton(
                      label: 'Done',
                      isPrimary: false,
                      onTap: () => Navigator.pop(context),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

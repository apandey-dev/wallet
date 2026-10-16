import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/cute_svg_icon.dart';
import '../../core/widgets/pill_button.dart';
import '../../providers/auth_provider.dart';
import '../../providers/notification_provider.dart';

class EditProfileSheet extends StatefulWidget {
  const EditProfileSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => const EditProfileSheet(),
    );
  }

  @override
  State<EditProfileSheet> createState() => _EditProfileSheetState();
}

class _EditProfileSheetState extends State<EditProfileSheet> {
  late TextEditingController _nameController;
  late TextEditingController _urlController;
  String? _selectedPhotoUrl;
  bool _showCustomUrlField = false;

  // Curated list of cute avatar presets
  static const List<Map<String, String>> _avatarPresets = [
    {
      'name': 'Alex',
      'url': 'https://api.dicebear.com/7.x/avataaars/png?seed=Alex&backgroundColor=b6e3f4',
    },
    {
      'name': 'Chloe',
      'url': 'https://api.dicebear.com/7.x/avataaars/png?seed=Chloe&backgroundColor=ffd5dc',
    },
    {
      'name': 'Milo',
      'url': 'https://api.dicebear.com/7.x/avataaars/png?seed=Milo&backgroundColor=c0aede',
    },
    {
      'name': 'Willow',
      'url': 'https://api.dicebear.com/7.x/avataaars/png?seed=Willow&backgroundColor=d1f4db',
    },
    {
      'name': 'Nova (Bot)',
      'url': 'https://api.dicebear.com/7.x/bottts/png?seed=Nova&backgroundColor=d1d4f9',
    },
    {
      'name': 'Pixel (Bot)',
      'url': 'https://api.dicebear.com/7.x/bottts/png?seed=Pixel&backgroundColor=ffdfbf',
    },
    {
      'name': 'Kai',
      'url': 'https://api.dicebear.com/7.x/notionists/png?seed=Kai&backgroundColor=ffe4e6',
    },
  ];

  @override
  void initState() {
    super.initState();
    final user = context.read<AuthProvider>().user;
    _nameController = TextEditingController(text: user?.displayName ?? '');
    _selectedPhotoUrl = user?.photoUrl;
    _urlController = TextEditingController(text: user?.photoUrl ?? '');
    _showCustomUrlField = _selectedPhotoUrl != null &&
        !_avatarPresets.any((preset) => preset['url'] == _selectedPhotoUrl);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _urlController.dispose();
    super.dispose();
  }

  void _saveProfile() {
    final name = _nameController.text.trim();
    if (name.isEmpty) return;

    final auth = context.read<AuthProvider>();
    auth.updateProfile(
      displayName: name,
      photoUrl: _selectedPhotoUrl,
    );

    context.read<NotificationProvider>().addNotification(
      title: 'Profile Updated',
      body: 'Your name and avatar have been saved successfully.',
      type: 'info',
    );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final user = auth.user;
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 16,
        bottom: 20 + bottomInset,
      ),
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.88,
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
            // Handle Bar
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
            const SizedBox(height: 16),

            // Header Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Edit Profile',
                      style: GoogleFonts.mali(
                        color: AppTheme.textPrimary,
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      'Customize your display name & avatar',
                      style: GoogleFonts.mali(
                        color: AppTheme.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded, size: 22, color: AppTheme.textMuted),
                  onPressed: () => Navigator.pop(context),
                  tooltip: 'Close',
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Avatar Live Preview Center
            Center(
              child: Column(
                children: [
                  Stack(
                    children: [
                      Container(
                        width: 88,
                        height: 88,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppTheme.cardSurface,
                          border: Border.all(
                            color: AppTheme.accentDark.withValues(alpha: 0.15),
                            width: 3,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: AppTheme.accentDark.withValues(alpha: 0.08),
                              blurRadius: 16,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: ClipOval(
                          child: _selectedPhotoUrl != null && _selectedPhotoUrl!.isNotEmpty
                              ? Image.network(
                                  _selectedPhotoUrl!,
                                  width: 88,
                                  height: 88,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, _, _) => _buildFallbackAvatar(),
                                  loadingBuilder: (ctx, child, progress) {
                                    if (progress == null) return child;
                                    return const Center(
                                      child: SizedBox(
                                        width: 24,
                                        height: 24,
                                        child: CircularProgressIndicator(strokeWidth: 2),
                                      ),
                                    );
                                  },
                                )
                              : _buildFallbackAvatar(),
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: AppTheme.accentDark,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                          child: const Icon(
                            Icons.edit_rounded,
                            size: 14,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _nameController.text.trim().isNotEmpty
                        ? _nameController.text.trim()
                        : (user?.displayName.isNotEmpty == true ? user!.displayName : (user?.isGuest == true ? 'Guest Explorer' : 'My Account')),
                    style: GoogleFonts.mali(
                      color: AppTheme.textPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    user?.email.isNotEmpty == true
                        ? user!.email
                        : (user?.isGuest == true ? 'guest@zerowallet.app' : 'Not linked'),
                    style: GoogleFonts.mali(
                      color: AppTheme.textMuted,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Name Field
            Text(
              'Display Name',
              style: GoogleFonts.mali(
                color: AppTheme.textPrimary,
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                color: AppTheme.cardSurface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppTheme.borderSubtle),
              ),
              child: TextField(
                controller: _nameController,
                onChanged: (_) => setState(() {}),
                style: GoogleFonts.mali(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textPrimary,
                ),
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.person_outline_rounded, size: 20, color: AppTheme.textSecondary),
                  suffixIcon: _nameController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear_rounded, size: 18, color: AppTheme.textMuted),
                          onPressed: () {
                            _nameController.clear();
                            setState(() {});
                          },
                        )
                      : null,
                  hintText: 'Enter your name',
                  hintStyle: GoogleFonts.mali(color: AppTheme.textMuted, fontSize: 13),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Preset Avatars Section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Choose Avatar Preset',
                  style: GoogleFonts.mali(
                    color: AppTheme.textPrimary,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                if (_selectedPhotoUrl != null)
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedPhotoUrl = null;
                        _urlController.clear();
                      });
                    },
                    child: Text(
                      'Clear Avatar',
                      style: GoogleFonts.mali(
                        color: const Color(0xFFE11D48),
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 10),

            // Horizontal preset list
            SizedBox(
              height: 72,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                itemCount: _avatarPresets.length + 1,
                separatorBuilder: (_, _) => const SizedBox(width: 10),
                itemBuilder: (ctx, index) {
                  if (index == 0) {
                    // Default / Clean Initial Option
                    final isSelected = _selectedPhotoUrl == null;
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedPhotoUrl = null;
                          _urlController.clear();
                        });
                      },
                      child: Container(
                        width: 60,
                        decoration: BoxDecoration(
                          color: isSelected ? AppTheme.accentDark.withValues(alpha: 0.1) : AppTheme.cardSurface,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isSelected ? AppTheme.accentDark : AppTheme.borderSubtle,
                            width: isSelected ? 2 : 1,
                          ),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const CuteSvgIcon(assetName: 'user', size: 24, color: AppTheme.accentDark),
                            const SizedBox(height: 4),
                            Text(
                              'Default',
                              style: GoogleFonts.mali(
                                fontSize: 9.5,
                                fontWeight: FontWeight.w700,
                                color: isSelected ? AppTheme.accentDark : AppTheme.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  final preset = _avatarPresets[index - 1];
                  final isSelected = _selectedPhotoUrl == preset['url'];

                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedPhotoUrl = preset['url'];
                        _urlController.text = preset['url']!;
                      });
                    },
                    child: Container(
                      width: 60,
                      decoration: BoxDecoration(
                        color: isSelected ? AppTheme.accentDark.withValues(alpha: 0.08) : AppTheme.cardSurface,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isSelected ? AppTheme.accentDark : AppTheme.borderSubtle,
                          width: isSelected ? 2.5 : 1,
                        ),
                      ),
                      padding: const EdgeInsets.all(4),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.network(
                              preset['url']!,
                              width: 38,
                              height: 38,
                              fit: BoxFit.cover,
                              errorBuilder: (_, _, _) => const Icon(Icons.face, size: 28),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            preset['name']!,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.mali(
                              fontSize: 9,
                              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                              color: isSelected ? AppTheme.accentDark : AppTheme.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 16),

            // Toggle custom URL link
            GestureDetector(
              onTap: () {
                setState(() {
                  _showCustomUrlField = !_showCustomUrlField;
                });
              },
              child: Row(
                children: [
                  Icon(
                    _showCustomUrlField ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded,
                    size: 18,
                    color: AppTheme.textSecondary,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    _showCustomUrlField ? 'Hide Custom Image URL' : 'Or paste a custom image URL...',
                    style: GoogleFonts.mali(
                      color: AppTheme.textSecondary,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),

            if (_showCustomUrlField) ...[
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  color: AppTheme.cardSurface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppTheme.borderSubtle),
                ),
                child: TextField(
                  controller: _urlController,
                  onChanged: (val) {
                    setState(() {
                      _selectedPhotoUrl = val.trim().isNotEmpty ? val.trim() : null;
                    });
                  },
                  style: GoogleFonts.mali(
                    fontSize: 13,
                    color: AppTheme.textPrimary,
                  ),
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.link_rounded, size: 18, color: AppTheme.textSecondary),
                    hintText: 'https://example.com/avatar.png',
                    hintStyle: GoogleFonts.mali(color: AppTheme.textMuted, fontSize: 12),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                ),
              ),
            ],

            const SizedBox(height: 24),

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: PillButton(
                    label: 'Cancel',
                    isPrimary: false,
                    onTap: () => Navigator.pop(context),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: PillButton(
                    label: 'Save Changes',
                    icon: const Icon(Icons.check_rounded, size: 16, color: Colors.white),
                    isPrimary: true,
                    onTap: _saveProfile,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFallbackAvatar() {
    final name = _nameController.text.trim();
    final initial = name.isNotEmpty ? name[0].toUpperCase() : 'U';

    return Container(
      decoration: const BoxDecoration(
        color: AppTheme.cardSurface,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          initial,
          style: GoogleFonts.mali(
            color: AppTheme.accentDark,
            fontSize: 32,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

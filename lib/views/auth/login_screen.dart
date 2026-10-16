import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/cute_svg_icon.dart';
import '../../core/widgets/pill_button.dart';
import '../../providers/auth_provider.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();

    return Scaffold(
      backgroundColor: AppTheme.bgLight,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Spacer(flex: 2),

              // Centered Brand Icon with Soft Glow
              Center(
                child: Container(
                  width: 84,
                  height: 84,
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceWhite,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppTheme.borderSubtle, width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.04),
                        blurRadius: 24,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(22),
                  child: const CuteSvgIcon(
                    assetName: 'wallet',
                    size: 38,
                    color: AppTheme.accentDark,
                  ),
                ),
              ),

              const SizedBox(height: 28),

              // Title: "Wallet" in Mali
              Text(
                'Wallet',
                textAlign: TextAlign.center,
                style: GoogleFonts.mali(
                  color: AppTheme.textPrimary,
                  fontSize: 36,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.5,
                ),
              ),

              const SizedBox(height: 10),

              // Subtitle
              Text(
                'Smart, minimal telemetry for your\nspending, cards and subscriptions.',
                textAlign: TextAlign.center,
                style: GoogleFonts.mali(
                  color: AppTheme.textSecondary,
                  fontSize: 14,
                  height: 1.5,
                  fontWeight: FontWeight.w500,
                ),
              ),

              const Spacer(flex: 3),

              const SizedBox(height: 16),

              // Pill 1: Continue with Google
              PillButton(
                label: 'Continue with Google',
                icon: const CuteSvgIcon(
                  assetName: 'google',
                  size: 19,
                ),
                isPrimary: true,
                isLoading: authProvider.isLoading,
                width: double.infinity,
                onTap: () async {
                  await context.read<AuthProvider>().loginWithGoogle();
                },
              ),

              const SizedBox(height: 12),

              // Pill 2: Continue as Guest
              PillButton(
                label: 'Continue as Guest',
                isPrimary: false,
                isLoading: authProvider.isLoading,
                width: double.infinity,
                onTap: () async {
                  await context.read<AuthProvider>().loginAsGuest();
                },
              ),

              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}

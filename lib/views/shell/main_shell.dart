import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/cute_svg_icon.dart';
import '../../core/widgets/in_app_banner.dart';
import '../home/home_screen.dart';
import '../accounts/accounts_screen.dart';
import '../analytics/analytics_screen.dart';
import '../profile/profile_screen.dart';
import '../transactions/add_transaction_page.dart';
import '../sheets/notification_center_sheet.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    HomeScreen(),
    AccountsScreen(),
    AnalyticsScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgLight,
      body: Stack(
        children: [
          // Current Selected Screen
          IndexedStack(
            index: _currentIndex,
            children: _screens,
          ),

          // Real-time In-App Notification Dropdown Banner
          InAppNotificationBanner(
            onNotificationTap: () => NotificationCenterSheet.show(context),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => AddTransactionPage.push(context),
        backgroundColor: AppTheme.accentDark,
        elevation: 4,
        shape: const CircleBorder(),
        child: const Icon(Icons.add_rounded, color: Colors.white, size: 26),
      ),
      // Material 3 NavigationBar with NavigationDestination
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: AppTheme.surfaceWhite,
          border: const Border(
            top: BorderSide(color: AppTheme.borderSubtle, width: 1.2),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 16,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: NavigationBar(
          selectedIndex: _currentIndex,
          onDestinationSelected: (index) => setState(() => _currentIndex = index),
          backgroundColor: AppTheme.surfaceWhite,
          indicatorColor: AppTheme.accentDark,
          elevation: 0,
          destinations: const [
            NavigationDestination(
              icon: CuteSvgIcon(assetName: 'wallet', size: 20, color: AppTheme.textMuted),
              selectedIcon: CuteSvgIcon(assetName: 'wallet', size: 20, color: Colors.white),
              label: 'Wallet',
            ),
            NavigationDestination(
              icon: Icon(Icons.account_balance_wallet_outlined, size: 22, color: AppTheme.textMuted),
              selectedIcon: Icon(Icons.account_balance_wallet_rounded, size: 22, color: Colors.white),
              label: 'Accounts',
            ),
            NavigationDestination(
              icon: Icon(Icons.pie_chart_outline_rounded, size: 22, color: AppTheme.textMuted),
              selectedIcon: Icon(Icons.pie_chart_rounded, size: 22, color: Colors.white),
              label: 'Portfolio',
            ),
            NavigationDestination(
              icon: Icon(Icons.person_outline_rounded, size: 22, color: AppTheme.textMuted),
              selectedIcon: Icon(Icons.person_rounded, size: 22, color: Colors.white),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'core/theme/app_theme.dart';
import 'services/storage_service.dart';
import 'services/firebase_service.dart';
import 'providers/auth_provider.dart';
import 'providers/notification_provider.dart';
import 'providers/wallet_provider.dart';
import 'views/auth/login_screen.dart';
import 'views/shell/main_shell.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: AppTheme.surfaceWhite,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );

  runApp(const WalletApp());
}

class WalletApp extends StatelessWidget {
  const WalletApp({super.key});

  @override
  Widget build(BuildContext context) {
    final storageService = StorageService();
    final firebaseService = FirebaseService();

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => AuthProvider(storageService, firebaseService)..init(),
        ),
        ChangeNotifierProvider(
          create: (_) => NotificationProvider(storageService)..init(),
        ),
        ChangeNotifierProxyProvider<NotificationProvider, WalletProvider>(
          create: (_) => WalletProvider(storageService, firebaseService)..init(),
          update: (_, notifProvider, walletProvider) {
            walletProvider!.updateNotificationProvider(notifProvider);
            return walletProvider;
          },
        ),
      ],
      child: MaterialApp(
        title: 'Wallet',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.theme,
        home: const AuthGate(),
      ),
    );
  }
}

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    if (!auth.isInitialized) {
      return const Scaffold(
        backgroundColor: AppTheme.bgLight,
        body: Center(
          child: SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(AppTheme.accentDark),
            ),
          ),
        ),
      );
    }

    if (auth.isLoggedIn) {
      return const MainShell();
    }

    return const LoginScreen();
  }
}

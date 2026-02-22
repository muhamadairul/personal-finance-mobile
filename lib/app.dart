import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pencatat_keuangan/config/app_theme.dart';
import 'package:pencatat_keuangan/screens/splash/splash_screen.dart';
import 'package:pencatat_keuangan/screens/auth/login_screen.dart';
import 'package:pencatat_keuangan/screens/auth/register_screen.dart';
import 'package:pencatat_keuangan/screens/home/home_screen.dart';
import 'package:pencatat_keuangan/screens/transaction/transaction_form_screen.dart';
import 'package:pencatat_keuangan/screens/budget/budget_list_screen.dart';
import 'package:pencatat_keuangan/screens/transaction/transaction_list_screen.dart';

// Theme mode provider
final themeModeProvider = StateProvider<ThemeMode>((ref) => ThemeMode.light);

class PencatatKeuanganApp extends ConsumerWidget {
  const PencatatKeuanganApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);

    return MaterialApp(
      title: 'Pencatat Keuangan',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      initialRoute: '/',
      routes: {
        '/': (context) => const SplashScreen(),
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/home': (context) => const HomeScreen(),
        '/transaction': (context) => const TransactionListScreen(),
        '/transaction/add': (context) => const TransactionFormScreen(),
        '/budget': (context) => const BudgetListScreen(),
      },
    );
  }
}

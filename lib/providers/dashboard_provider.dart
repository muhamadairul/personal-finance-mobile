import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pencatat_keuangan/models/transaction.dart';
import 'package:pencatat_keuangan/models/wallet.dart';

class DashboardState {
  final double totalBalance;
  final double monthlyIncome;
  final double monthlyExpense;
  final List<double> weeklyExpenses; // 7 days
  final List<Transaction> recentTransactions;
  final List<Wallet> wallets;
  final bool isLoading;

  const DashboardState({
    this.totalBalance = 0,
    this.monthlyIncome = 0,
    this.monthlyExpense = 0,
    this.weeklyExpenses = const [],
    this.recentTransactions = const [],
    this.wallets = const [],
    this.isLoading = false,
  });

  DashboardState copyWith({
    double? totalBalance,
    double? monthlyIncome,
    double? monthlyExpense,
    List<double>? weeklyExpenses,
    List<Transaction>? recentTransactions,
    List<Wallet>? wallets,
    bool? isLoading,
  }) {
    return DashboardState(
      totalBalance: totalBalance ?? this.totalBalance,
      monthlyIncome: monthlyIncome ?? this.monthlyIncome,
      monthlyExpense: monthlyExpense ?? this.monthlyExpense,
      weeklyExpenses: weeklyExpenses ?? this.weeklyExpenses,
      recentTransactions: recentTransactions ?? this.recentTransactions,
      wallets: wallets ?? this.wallets,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class DashboardNotifier extends StateNotifier<DashboardState> {
  DashboardNotifier() : super(const DashboardState());

  Future<void> fetchDashboard() async {
    state = state.copyWith(isLoading: true);

    // Mock data
    await Future.delayed(const Duration(milliseconds: 500));

    final mockWallets = [
      Wallet(
        id: 1,
        name: 'Dompet Tunai',
        type: 'cash',
        balance: 1250000,
        icon: Icons.account_balance_wallet.codePoint,
        color: 0xFF6C63FF,
      ),
      Wallet(
        id: 2,
        name: 'Bank BCA',
        type: 'bank',
        balance: 15400000,
        icon: Icons.account_balance.codePoint,
        color: 0xFF00C853,
      ),
      Wallet(
        id: 3,
        name: 'GoPay',
        type: 'ewallet',
        balance: 450000,
        icon: Icons.payment.codePoint,
        color: 0xFF2196F3,
      ),
    ];

    final now = DateTime.now();
    final mockTransactions = [
      Transaction(
        id: 1,
        type: 'expense',
        amount: 50000,
        categoryId: 1,
        walletId: 1,
        note: 'Makan Siang',
        date: now,
        categoryName: 'Makan',
        categoryIcon: Icons.restaurant.codePoint,
        categoryColor: 0xFFFF6B6B,
        walletName: 'Dompet Tunai',
      ),
      Transaction(
        id: 2,
        type: 'income',
        amount: 5000000,
        categoryId: 9,
        walletId: 2,
        note: 'Gaji Bulanan',
        date: now.subtract(const Duration(days: 1)),
        categoryName: 'Gaji',
        categoryIcon: Icons.account_balance_wallet.codePoint,
        categoryColor: 0xFF00C853,
        walletName: 'Bank BCA',
      ),
      Transaction(
        id: 3,
        type: 'expense',
        amount: 20000,
        categoryId: 2,
        walletId: 1,
        note: 'Transportasi',
        date: now.subtract(const Duration(days: 2)),
        categoryName: 'Transportasi',
        categoryIcon: Icons.directions_car.codePoint,
        categoryColor: 0xFF4ECDC4,
        walletName: 'Dompet Tunai',
      ),
      Transaction(
        id: 4,
        type: 'expense',
        amount: 150000,
        categoryId: 3,
        walletId: 2,
        note: 'Belanja Bulanan',
        date: now.subtract(const Duration(days: 3)),
        categoryName: 'Belanja',
        categoryIcon: Icons.shopping_bag.codePoint,
        categoryColor: 0xFFFFBE0B,
        walletName: 'Bank BCA',
      ),
      Transaction(
        id: 5,
        type: 'expense',
        amount: 35000,
        categoryId: 5,
        walletId: 3,
        note: 'Nonton Film',
        date: now.subtract(const Duration(days: 4)),
        categoryName: 'Hiburan',
        categoryIcon: Icons.movie.codePoint,
        categoryColor: 0xFFFF9671,
        walletName: 'GoPay',
      ),
    ];

    state = DashboardState(
      totalBalance: mockWallets.fold(0, (sum, w) => sum + w.balance),
      monthlyIncome: 5000000,
      monthlyExpense: 2500000,
      weeklyExpenses: [120000, 85000, 200000, 50000, 175000, 90000, 65000],
      recentTransactions: mockTransactions,
      wallets: mockWallets,
      isLoading: false,
    );
  }
}

final dashboardProvider =
    StateNotifierProvider<DashboardNotifier, DashboardState>((ref) {
      return DashboardNotifier();
    });

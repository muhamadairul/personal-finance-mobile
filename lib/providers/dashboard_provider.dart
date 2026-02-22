import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pencatat_keuangan/models/transaction.dart';
import 'package:pencatat_keuangan/models/wallet.dart';
import 'package:pencatat_keuangan/services/api_service.dart';
import 'package:pencatat_keuangan/config/api_config.dart';

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
  final ApiService _apiService = ApiService();

  DashboardNotifier() : super(const DashboardState());

  Future<void> fetchDashboard() async {
    state = state.copyWith(isLoading: true);

    try {
      final response = await _apiService.get(ApiConfig.dashboard);
      final data = response.data;

      final List transactionsJson = data['recent_transactions'] ?? [];
      final List walletsJson = data['wallets'] ?? [];

      final weeklyRaw = data['weekly_expenses'] as List? ?? [];
      final weeklyExpenses = weeklyRaw
          .map<double>((e) => (e as num).toDouble())
          .toList();

      state = DashboardState(
        totalBalance: (data['total_balance'] as num?)?.toDouble() ?? 0,
        monthlyIncome: (data['monthly_income'] as num?)?.toDouble() ?? 0,
        monthlyExpense: (data['monthly_expense'] as num?)?.toDouble() ?? 0,
        weeklyExpenses: weeklyExpenses,
        recentTransactions: transactionsJson
            .map((json) => Transaction.fromJson(json))
            .toList(),
        wallets: walletsJson.map((json) => Wallet.fromJson(json)).toList(),
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false);
    }
  }
}

final dashboardProvider =
    StateNotifierProvider<DashboardNotifier, DashboardState>((ref) {
      return DashboardNotifier();
    });

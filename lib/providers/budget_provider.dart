import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pencatat_keuangan/models/budget.dart';
import 'package:pencatat_keuangan/services/api_service.dart';
import 'package:pencatat_keuangan/config/api_config.dart';

class BudgetState {
  final List<Budget> budgets;
  final bool isLoading;
  final int selectedMonth;
  final int selectedYear;

  BudgetState({
    this.budgets = const [],
    this.isLoading = false,
    int? selectedMonth,
    int? selectedYear,
  }) : selectedMonth = selectedMonth ?? DateTime.now().month,
       selectedYear = selectedYear ?? DateTime.now().year;

  BudgetState copyWith({
    List<Budget>? budgets,
    bool? isLoading,
    int? selectedMonth,
    int? selectedYear,
  }) {
    return BudgetState(
      budgets: budgets ?? this.budgets,
      isLoading: isLoading ?? this.isLoading,
      selectedMonth: selectedMonth ?? this.selectedMonth,
      selectedYear: selectedYear ?? this.selectedYear,
    );
  }

  double get totalBudget => budgets.fold(0, (sum, b) => sum + b.amount);
  double get totalSpent => budgets.fold(0, (sum, b) => sum + b.spent);
  double get totalPercentage =>
      totalBudget > 0 ? (totalSpent / totalBudget * 100).clamp(0, 100) : 0;
}

class BudgetNotifier extends StateNotifier<BudgetState> {
  final ApiService _apiService = ApiService();

  BudgetNotifier() : super(BudgetState());

  Future<void> fetchBudgets({int? month, int? year}) async {
    state = state.copyWith(
      isLoading: true,
      selectedMonth: month,
      selectedYear: year,
    );

    try {
      final response = await _apiService.get(
        ApiConfig.budgets,
        queryParameters: {
          'month': state.selectedMonth,
          'year': state.selectedYear,
        },
      );
      final List data = response.data['data'];
      final budgets = data.map((json) => Budget.fromJson(json)).toList();
      state = state.copyWith(budgets: budgets, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false);
    }
  }

  void previousMonth() {
    int m = state.selectedMonth - 1;
    int y = state.selectedYear;
    if (m < 1) {
      m = 12;
      y--;
    }
    fetchBudgets(month: m, year: y);
  }

  void nextMonth() {
    int m = state.selectedMonth + 1;
    int y = state.selectedYear;
    if (m > 12) {
      m = 1;
      y++;
    }
    fetchBudgets(month: m, year: y);
  }

  Future<void> addBudget(Budget budget) async {
    try {
      final response = await _apiService.post(
        ApiConfig.budgets,
        data: {
          'category_id': budget.categoryId,
          'amount': budget.amount,
          'month': state.selectedMonth,
          'year': state.selectedYear,
        },
      );
      final newBudget = Budget.fromJson(response.data['data']);
      state = state.copyWith(budgets: [...state.budgets, newBudget]);
    } catch (_) {}
  }

  Future<void> updateBudget(Budget budget) async {
    try {
      final response = await _apiService.put(
        '${ApiConfig.budgets}/${budget.id}',
        data: {
          'category_id': budget.categoryId,
          'amount': budget.amount,
          'month': state.selectedMonth,
          'year': state.selectedYear,
        },
      );
      final updated = Budget.fromJson(response.data['data']);
      state = state.copyWith(
        budgets: state.budgets
            .map((b) => b.id == updated.id ? updated : b)
            .toList(),
      );
    } catch (_) {}
  }
}

final budgetProvider = StateNotifierProvider<BudgetNotifier, BudgetState>((
  ref,
) {
  return BudgetNotifier();
});

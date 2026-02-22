import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pencatat_keuangan/models/budget.dart';

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
  BudgetNotifier() : super(BudgetState());

  Future<void> fetchBudgets({int? month, int? year}) async {
    state = state.copyWith(
      isLoading: true,
      selectedMonth: month,
      selectedYear: year,
    );
    await Future.delayed(const Duration(milliseconds: 300));

    state = state.copyWith(
      budgets: [
        Budget(
          id: 1,
          categoryId: 1,
          amount: 1000000,
          spent: 850000,
          month: state.selectedMonth,
          year: state.selectedYear,
          categoryName: 'Makan',
          categoryIcon: Icons.restaurant.codePoint,
          categoryColor: 0xFFFF6B6B,
        ),
        Budget(
          id: 2,
          categoryId: 5,
          amount: 500000,
          spent: 325000,
          month: state.selectedMonth,
          year: state.selectedYear,
          categoryName: 'Hiburan',
          categoryIcon: Icons.movie.codePoint,
          categoryColor: 0xFFFF9671,
        ),
        Budget(
          id: 3,
          categoryId: 2,
          amount: 500000,
          spent: 200000,
          month: state.selectedMonth,
          year: state.selectedYear,
          categoryName: 'Transportasi',
          categoryIcon: Icons.directions_car.codePoint,
          categoryColor: 0xFF4ECDC4,
        ),
      ],
      isLoading: false,
    );
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
    state = state.copyWith(budgets: [...state.budgets, budget]);
  }

  Future<void> updateBudget(Budget budget) async {
    state = state.copyWith(
      budgets: state.budgets
          .map((b) => b.id == budget.id ? budget : b)
          .toList(),
    );
  }
}

final budgetProvider = StateNotifierProvider<BudgetNotifier, BudgetState>((
  ref,
) {
  return BudgetNotifier();
});

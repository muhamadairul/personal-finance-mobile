import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pencatat_keuangan/services/api_service.dart';
import 'package:pencatat_keuangan/config/api_config.dart';

class ReportState {
  final double totalIncome;
  final double totalExpense;
  final double net;
  final Map<String, double> categoryBreakdown; // category name -> amount
  final Map<String, int> categoryColors;
  final List<double> monthlyIncome; // last 6 months
  final List<double> monthlyExpense;
  final List<String> monthLabels;
  final bool isLoading;

  const ReportState({
    this.totalIncome = 0,
    this.totalExpense = 0,
    this.net = 0,
    this.categoryBreakdown = const {},
    this.categoryColors = const {},
    this.monthlyIncome = const [],
    this.monthlyExpense = const [],
    this.monthLabels = const [],
    this.isLoading = false,
  });

  ReportState copyWith({
    double? totalIncome,
    double? totalExpense,
    double? net,
    Map<String, double>? categoryBreakdown,
    Map<String, int>? categoryColors,
    List<double>? monthlyIncome,
    List<double>? monthlyExpense,
    List<String>? monthLabels,
    bool? isLoading,
  }) {
    return ReportState(
      totalIncome: totalIncome ?? this.totalIncome,
      totalExpense: totalExpense ?? this.totalExpense,
      net: net ?? this.net,
      categoryBreakdown: categoryBreakdown ?? this.categoryBreakdown,
      categoryColors: categoryColors ?? this.categoryColors,
      monthlyIncome: monthlyIncome ?? this.monthlyIncome,
      monthlyExpense: monthlyExpense ?? this.monthlyExpense,
      monthLabels: monthLabels ?? this.monthLabels,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class ReportNotifier extends StateNotifier<ReportState> {
  final ApiService _apiService = ApiService();

  ReportNotifier() : super(const ReportState());

  Future<void> fetchReport() async {
    state = state.copyWith(isLoading: true);

    try {
      // Fetch both endpoints in parallel
      final results = await Future.wait([
        _apiService.get(ApiConfig.reportMonthly),
        _apiService.get(ApiConfig.reportCategory),
      ]);

      final monthlyData = results[0].data;
      final categoryData = results[1].data;

      // Parse monthly trend
      final monthlyIncomeRaw = monthlyData['monthly_income'] as List? ?? [];
      final monthlyExpenseRaw = monthlyData['monthly_expense'] as List? ?? [];
      final monthLabelsRaw = monthlyData['month_labels'] as List? ?? [];

      // Parse category breakdown
      final breakdownRaw =
          categoryData['category_breakdown'] as Map<String, dynamic>? ?? {};
      final colorsRaw =
          categoryData['category_colors'] as Map<String, dynamic>? ?? {};

      final categoryBreakdown = breakdownRaw.map(
        (key, value) => MapEntry(key, (value as num).toDouble()),
      );
      final categoryColors = colorsRaw.map(
        (key, value) => MapEntry(key, (value as num).toInt()),
      );

      state = ReportState(
        totalIncome: (monthlyData['total_income'] as num?)?.toDouble() ?? 0,
        totalExpense: (monthlyData['total_expense'] as num?)?.toDouble() ?? 0,
        net: (monthlyData['net'] as num?)?.toDouble() ?? 0,
        categoryBreakdown: categoryBreakdown,
        categoryColors: categoryColors,
        monthlyIncome: monthlyIncomeRaw
            .map<double>((e) => (e as num).toDouble())
            .toList(),
        monthlyExpense: monthlyExpenseRaw
            .map<double>((e) => (e as num).toDouble())
            .toList(),
        monthLabels: monthLabelsRaw.map<String>((e) => e.toString()).toList(),
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false);
    }
  }
}

final reportProvider = StateNotifierProvider<ReportNotifier, ReportState>((
  ref,
) {
  return ReportNotifier();
});

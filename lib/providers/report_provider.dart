import 'package:flutter_riverpod/flutter_riverpod.dart';

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
  ReportNotifier() : super(const ReportState());

  Future<void> fetchReport() async {
    state = state.copyWith(isLoading: true);
    await Future.delayed(const Duration(milliseconds: 500));

    state = ReportState(
      totalIncome: 7000000,
      totalExpense: 2500000,
      net: 4500000,
      categoryBreakdown: {
        'Makan': 850000,
        'Transportasi': 200000,
        'Belanja': 500000,
        'Hiburan': 325000,
        'Tagihan': 400000,
        'Kesehatan': 225000,
      },
      categoryColors: {
        'Makan': 0xFFFF6B6B,
        'Transportasi': 0xFF4ECDC4,
        'Belanja': 0xFFFFBE0B,
        'Hiburan': 0xFFFF9671,
        'Tagihan': 0xFF845EC2,
        'Kesehatan': 0xFF00C9A7,
      },
      monthlyIncome: [5000000, 5500000, 6000000, 5000000, 7000000, 6500000],
      monthlyExpense: [3000000, 2800000, 3500000, 2200000, 2500000, 3000000],
      monthLabels: ['Sep', 'Okt', 'Nov', 'Des', 'Jan', 'Feb'],
      isLoading: false,
    );
  }
}

final reportProvider = StateNotifierProvider<ReportNotifier, ReportState>((
  ref,
) {
  return ReportNotifier();
});

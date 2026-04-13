import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
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
  final String? error;
  final int selectedMonth;
  final int selectedYear;

  ReportState({
    this.totalIncome = 0,
    this.totalExpense = 0,
    this.net = 0,
    this.categoryBreakdown = const {},
    this.categoryColors = const {},
    this.monthlyIncome = const [],
    this.monthlyExpense = const [],
    this.monthLabels = const [],
    this.isLoading = false,
    this.error,
    int? selectedMonth,
    int? selectedYear,
  })  : selectedMonth = selectedMonth ?? DateTime.now().month,
        selectedYear = selectedYear ?? DateTime.now().year;

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
    String? error,
    int? selectedMonth,
    int? selectedYear,
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
      error: error,
      selectedMonth: selectedMonth ?? this.selectedMonth,
      selectedYear: selectedYear ?? this.selectedYear,
    );
  }
}

class ReportNotifier extends StateNotifier<ReportState> {
  final ApiService _apiService = ApiService();

  ReportNotifier() : super(ReportState());

  void setMonth(int month, int year) {
    state = state.copyWith(selectedMonth: month, selectedYear: year);
    fetchReport();
  }

  Future<void> fetchReport() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final queryParams = {
        'month': state.selectedMonth.toString(),
        'year': state.selectedYear.toString(),
      };

      // Fetch both endpoints in parallel
      final results = await Future.wait([
        _apiService.get(ApiConfig.reportMonthly, queryParameters: queryParams),
        _apiService.get(ApiConfig.reportCategory, queryParameters: queryParams),
      ]);

      final monthlyData = results[0].data;
      final categoryData = results[1].data;

      // Parse monthly trend
      final monthlyIncomeRaw = monthlyData['monthly_income'] as List? ?? [];
      final monthlyExpenseRaw = monthlyData['monthly_expense'] as List? ?? [];
      final monthLabelsRaw = monthlyData['month_labels'] as List? ?? [];

      // Parse category breakdown — PHP may return [] (List) when empty instead of {} (Map)
      final rawBreakdown = categoryData['category_breakdown'];
      final breakdownRaw = rawBreakdown is Map<String, dynamic>
          ? rawBreakdown
          : <String, dynamic>{};
      final rawColors = categoryData['category_colors'];
      final colorsRaw = rawColors is Map<String, dynamic>
          ? rawColors
          : <String, dynamic>{};

      final categoryBreakdown = breakdownRaw.map(
        (key, value) => MapEntry(key, (value as num).toDouble()),
      );
      final categoryColors = colorsRaw.map(
        (key, value) => MapEntry(key, (value as num).toInt()),
      );

      state = state.copyWith(
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
        error: null,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Gagal memuat laporan: ${e.toString()}',
      );
    }
  }

  /// Download export file (PDF or Excel). Returns the saved file path.
  Future<String> exportFile(String type) async {
    final queryParams = {
      'month': state.selectedMonth.toString(),
      'year': state.selectedYear.toString(),
    };

    final endpoint = type == 'pdf' ? ApiConfig.exportPdf : ApiConfig.exportExcel;
    final ext = type == 'pdf' ? 'pdf' : 'xlsx';
    final filename =
        'transaksi_${state.selectedYear}_${state.selectedMonth}.$ext';

    final dir = await getApplicationDocumentsDirectory();
    final savePath = '${dir.path}/$filename';

    await _apiService.downloadFile(endpoint, savePath, queryParams: queryParams);
    return savePath;
  }
}

final reportProvider = StateNotifierProvider<ReportNotifier, ReportState>((
  ref,
) {
  return ReportNotifier();
});

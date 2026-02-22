class ApiConfig {
  static const String baseUrl = 'http://localhost:8000/api';
  static const bool useMockData = true; // Set to false when backend is ready

  // Auth endpoints
  static const String login = '/login';
  static const String register = '/register';
  static const String logout = '/logout';
  static const String user = '/user';

  // Dashboard
  static const String dashboard = '/dashboard';

  // Transactions
  static const String transactions = '/transactions';

  // Wallets
  static const String wallets = '/wallets';

  // Categories
  static const String categories = '/categories';

  // Budgets
  static const String budgets = '/budgets';

  // Reports
  static const String reportMonthly = '/reports/monthly';
  static const String reportCategory = '/reports/category';

  // Export
  static const String exportCsv = '/export/csv';
  static const String exportPdf = '/export/pdf';
}

class ApiConfig {
  static const String baseUrl =
      'https://db28-103-163-103-209.ngrok-free.app/api';

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

  // Profile
  static const String updateProfile = '/user/profile';
  static const String uploadPhoto = '/user/photo';
}

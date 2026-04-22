class ApiConfig {
  static const String baseUrl = 'https://pencatat-keuangan-main-2b3tsn.free.laravel.cloud/api';

  // Auth endpoints
  static const String login = '/login';
  static const String register = '/register';
  static const String logout = '/logout';
  static const String user = '/user';
  static const String socialLogin = '/auth/social';

  // Forgot Password
  static const String forgotPasswordEmail = '/password/email';
  static const String forgotPasswordVerifyOtp = '/password/verify-otp';
  static const String forgotPasswordReset = '/password/reset';

  // FCM Token
  static const String updateFcmToken = '/user/fcm-token';

  // Dashboard
  static const String dashboard = '/dashboard';

  // Notifications
  static const String notifications = '/notifications';
  static const String notificationsUnreadCount = '/notifications/unread-count';
  static const String notificationsReadAll = '/notifications/read-all';
  static const String notificationsRead = '/notifications/'; // append {id}/read

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
  static const String exportExcel = '/export/excel';
  static const String exportPdf = '/export/pdf';

  // Profile
  static const String updateProfile = '/user/profile';
  static const String uploadPhoto = '/user/photo';
  static const String deletePhoto = '/user/photo';

  // Subscription
  static const String subscriptionPlans = '/subscription/plans';
  static const String subscriptionStatus = '/subscription/status';
  static const String subscriptionPayQris = '/subscription/pay/qris';
  static const String subscriptionPayVa = '/subscription/pay/va';
  static const String subscriptionPayEwallet = '/subscription/pay/ewallet';
  static const String subscriptionCheck = '/subscription/check'; // + /{id}
  static const String subscriptionHistory = '/subscription/history';
}

import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:pencatat_keuangan/services/api_service.dart';
import 'package:pencatat_keuangan/config/api_config.dart';
import 'package:pencatat_keuangan/app.dart';

/// Triggers whenever a new foreground push notification arrives.
/// Dashboard listens to this to refresh the badge counter in real-time.
final ValueNotifier<int> notificationTrigger = ValueNotifier(0);

/// Handles FCM push notifications: permission, token, foreground display, tap actions.
class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;

  /// Initialize notification service. Call once after Firebase.initializeApp().
  Future<void> initialize() async {
    if (_initialized) return;
    _initialized = true;

    // Setup local notifications for foreground display
    await _setupLocalNotifications();

    // Request permission (important for Android 13+)
    await _requestPermission();

    // Listen for foreground messages
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

    // Listen for notification taps (when app is in background)
    FirebaseMessaging.onMessageOpenedApp.listen(_handleNotificationTap);

    // Check if app was opened from a terminated-state notification
    final initialMessage = await _messaging.getInitialMessage();
    if (initialMessage != null) {
      _handleNotificationTap(initialMessage);
    }

    debugPrint('NotificationService initialized');
  }

  /// Request notification permission.
  Future<void> _requestPermission() async {
    final settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );

    debugPrint('Notification permission: ${settings.authorizationStatus}');
  }

  /// Setup flutter_local_notifications for foreground message display.
  Future<void> _setupLocalNotifications() async {
    const androidChannel = AndroidNotificationChannel(
      'finance_notifications',
      'Notifikasi Keuangan',
      description: 'Notifikasi pengingat dan langganan',
      importance: Importance.high,
    );

    // Create the notification channel on Android
    await _localNotifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(androidChannel);

    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const initSettings = InitializationSettings(android: androidSettings);

    await _localNotifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (response) {
        // Handle notification tap from local notification (foreground tap)
        debugPrint('Local notification tapped: ${response.payload}');
        _navigateToNotifications();
      },
    );
  }

  /// Get the current FCM token and register it with the backend.
  Future<void> registerToken() async {
    try {
      final token = await _messaging.getToken();
      if (token != null) {
        debugPrint('FCM Token: ${token.substring(0, 20)}...');
        await _sendTokenToBackend(token);
      }

      // Listen for token refresh
      _messaging.onTokenRefresh.listen((newToken) {
        debugPrint('FCM Token refreshed');
        _sendTokenToBackend(newToken);
      });
    } catch (e) {
      debugPrint('FCM token registration error: $e');
    }
  }

  /// Send FCM token to backend.
  Future<void> _sendTokenToBackend(String token) async {
    try {
      await ApiService().post(
        ApiConfig.updateFcmToken,
        data: {'fcm_token': token},
      );
      debugPrint('FCM token sent to backend');
    } catch (e) {
      debugPrint('Failed to send FCM token to backend: $e');
    }
  }

  /// Get notifications list from backend
  Future<List<dynamic>> getNotifications() async {
    try {
      final response = await ApiService().get(ApiConfig.notifications);
      return response.data['data'] as List<dynamic>;
    } catch (e) {
      debugPrint('Failed to fetch notifications: $e');
      return [];
    }
  }

  /// Get unread notification count from backend
  Future<int> getUnreadCount() async {
    try {
      final response = await ApiService().get(ApiConfig.notificationsUnreadCount);
      return response.data['unread_count'] as int? ?? 0;
    } catch (e) {
      debugPrint('Failed to fetch unread count: $e');
      return 0;
    }
  }

  /// Mark a notification as read
  Future<bool> markAsRead(String id) async {
    try {
      await ApiService().post('${ApiConfig.notificationsRead}$id/read');
      return true;
    } catch (e) {
      debugPrint('Failed to mark notification as read: $e');
      return false;
    }
  }

  /// Unregister token (called on logout).
  Future<void> unregisterToken() async {
    try {
      await _messaging.deleteToken();
      debugPrint('FCM token deleted');
    } catch (e) {
      debugPrint('FCM token deletion error: $e');
    }
  }

  /// Handle foreground FCM message — display as local notification.
  void _handleForegroundMessage(RemoteMessage message) {
    debugPrint('Foreground message: ${message.notification?.title}');

    final notification = message.notification;
    if (notification == null) return;

    _localNotifications.show(
      notification.hashCode,
      notification.title,
      notification.body,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'finance_notifications',
          'Notifikasi Keuangan',
          channelDescription: 'Notifikasi pengingat dan langganan',
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
      ),
      payload: message.data['type'],
    );

    // Trigger real-time badge counter refresh
    notificationTrigger.value++;
  }

  /// Handle notification tap (app opened from background/terminated).
  void _handleNotificationTap(RemoteMessage message) {
    final type = message.data['type'];
    debugPrint('Notification tapped, type: $type');
    _navigateToNotifications();
  }

  /// Navigate to notifications screen using the global navigator key.
  void _navigateToNotifications() {
    // Small delay to ensure the app is fully rendered (especially from terminated state)
    Future.delayed(const Duration(milliseconds: 500), () {
      navigatorKey.currentState?.pushNamed('/notifications');
    });
  }
}

import 'dart:developer';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/material.dart';
import 'package:minsellprice/services/navigation_service.dart';

class NotificationService {
  // Singleton pattern - ensures only one instance exists
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  // Track if notification service has been initialized
  bool _isInitialized = false;

  // Plugin instance for handling local notifications
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  // Getter to check if service is initialized
  bool get isInitialized => _isInitialized;

  // Main initialization method - sets up local notifications
  Future<void> initialize() async {
    if (_isInitialized) return; // Skip if already initialized

    try {
      // Setup local notification channels and permissions
      await _initializeLocalNotifications();
      _isInitialized = true;
      log('Local notification service initialized successfully');
    } catch (e) {
      log('Error initializing notification service: $e');
    }
  }

  // Setup notification channels and permissions for Android/iOS
  Future<void> _initializeLocalNotifications() async {
    // Android settings - uses app icon and requests permissions
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    // iOS settings - requests alert, badge, and sound permissions
    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    // Combine platform-specific settings
    const InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    // Initialize plugin with settings and tap handler
    await _localNotifications.initialize(initializationSettings,
        onDidReceiveNotificationResponse: _onNotificationTapped);
  }

  // Called when user taps on a notification
  void _onNotificationTapped(NotificationResponse response) {
    log('Notification tapped: ${response.payload}');
    // Extract payload data and handle navigation
    if (response.payload != null) {
      _handleNotificationNavigation({'data': response.payload});
    }
  }

  // Navigate to appropriate screen based on notification type
  void _handleNotificationNavigation(Map<String, dynamic> data) {
    // Log navigation attempt for debugging
    log('Navigate to notification screen: $data');

    // Use global navigation service to open notification screen
    final navigationService = NavigationService();
    navigationService.navigateToNotifications();
  }

  // Display a custom notification with title, body, and optional payload
  Future<void> showStaticNotification({
    required String title,
    required String body,
    String? payload,
    String? imageUrl,
  }) async {
    // Android notification channel settings
    const AndroidNotificationDetails androidPlatformChannelSpecifics = AndroidNotificationDetails(
      'static_notifications',
      'Static Notifications',
      channelDescription: 'Static in-app notifications',
      importance: Importance.defaultImportance,
      priority: Priority.defaultPriority,
      showWhen: true,
      enableVibration: true,
      playSound: true,
    );

    // iOS notification settings
    const DarwinNotificationDetails iOSPlatformChannelSpecifics = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    // Combine platform settings
    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: iOSPlatformChannelSpecifics,
    );

    // Show notification with unique ID and payload
    await _localNotifications.show(
      DateTime.now().millisecondsSinceEpoch.remainder(100000),
      title,
      body,
      platformChannelSpecifics,
      payload: payload,
    );
  }

  // Show price drop notification with formatted price information
  Future<void> showPriceDropNotification({
    required String productName,
    required double oldPrice,
    required double newPrice,
    required String productId,
    String? productImage,
  }) async {
    // Create formatted title and body with price details
    final title = 'Price Drop Alert! 🎉';
    final body =
        '$productName price dropped from \$${oldPrice.toStringAsFixed(2)} to \$${newPrice.toStringAsFixed(2)}';

    // Display notification with product-specific payload
    await showStaticNotification(
      title: title,
      body: body,
      payload: 'product:$productId',
    );
  }

  // Display welcome notification for new users
  Future<void> showWelcomeNotification() async {
    await showStaticNotification(
      title: 'Welcome to MinSellPrice! 👋',
      body: 'Start tracking prices and never miss a deal again!',
      payload: 'welcome',
    );
  }

  // Announce new app features to users
  Future<void> showFeatureAnnouncement({
    required String featureName,
    required String description,
  }) async {
    await showStaticNotification(
      title: 'New Feature: $featureName 🆕',
      body: description,
      payload: 'feature:$featureName',
    );
  }

  // Show reminder notifications for user engagement
  Future<void> showReminderNotification({
    required String title,
    required String message,
  }) async {
    await showStaticNotification(
      title: title,
      body: message,
      payload: 'reminder',
    );
  }

  // Remove all active notifications from the system
  Future<void> cancelAllNotifications() async {
    await _localNotifications.cancelAll();
  }

  // Remove a specific notification by its ID
  Future<void> cancelNotification(int id) async {
    await _localNotifications.cancel(id);
  }
}

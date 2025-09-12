import 'dart:developer';
import 'dart:io';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:minsellprice/services/notification_service.dart';
import 'package:minsellprice/services/navigation_service.dart';

/// Firebase Push Notification Service
/// Handles all Firebase Cloud Messaging operations including:
/// - Token management
/// - Message handling (foreground, background, terminated)
/// - Topic subscriptions
/// - Cloud Function calls for sending notifications
class FirebasePushNotificationService {
  // Singleton pattern
  static final FirebasePushNotificationService _instance =
      FirebasePushNotificationService._internal();

  factory FirebasePushNotificationService() => _instance;

  FirebasePushNotificationService._internal();

  // Firebase Messaging instance
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  // Cloud Functions instance
  final FirebaseFunctions _functions = FirebaseFunctions.instance;

  // Current FCM token
  String? _fcmToken;

  // Getter for FCM token
  String? get fcmToken => _fcmToken;

  // Track if service is initialized
  bool _isInitialized = false;

  // Getter to check if service is initialized
  bool get isInitialized => _isInitialized;

  /// Initialize Firebase Push Notification Service
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      log('🚀 Initializing Firebase Push Notification Service...');

      // Request permission for notifications
      await _requestPermission();

      // Get FCM token
      await _getFCMToken();

      // Setup message handlers
      _setupMessageHandlers();

      // Setup token refresh listener
      _setupTokenRefreshListener();

      _isInitialized = true;
      log('✅ Firebase Push Notification Service initialized successfully');
    } catch (e) {
      log('❌ Error initializing Firebase Push Notification Service: $e');
    }
  }

  /// Request notification permission
  Future<bool> _requestPermission() async {
    try {
      // Request permission for iOS
      if (Platform.isIOS) {
        final settings = await _messaging.requestPermission(
          alert: true,
          announcement: false,
          badge: true,
          carPlay: false,
          criticalAlert: false,
          provisional: false,
          sound: true,
        );

        if (settings.authorizationStatus == AuthorizationStatus.authorized) {
          log('✅ iOS notification permission granted');
          return true;
        } else if (settings.authorizationStatus ==
            AuthorizationStatus.provisional) {
          log('⚠️ iOS notification permission granted provisionally');
          return true;
        } else {
          log('❌ iOS notification permission denied');
          return false;
        }
      }

      // For Android, permission is handled by the app manifest
      log('✅ Android notification permission handled by manifest');
      return true;
    } catch (e) {
      log('❌ Error requesting notification permission: $e');
      return false;
    }
  }

  /// Get FCM token
  Future<void> _getFCMToken() async {
    try {
      _fcmToken = await _messaging.getToken();
      if (_fcmToken != null) {
        log('📱 FCM Token: $_fcmToken');
      } else {
        log('❌ Failed to get FCM token');
      }
    } catch (e) {
      log('❌ Error getting FCM token: $e');
    }
  }

  /// Setup message handlers for different app states
  void _setupMessageHandlers() {
    // Handle messages when app is in foreground
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

    // Handle messages when app is opened from background
    FirebaseMessaging.onMessageOpenedApp.listen(handleBackgroundMessage);

    // Handle messages when app is terminated
    _handleTerminatedMessage();
  }

  /// Setup token refresh listener
  void _setupTokenRefreshListener() {
    _messaging.onTokenRefresh.listen((String token) {
      _fcmToken = token;
      log('🔄 FCM Token refreshed: $token');
      // Here you can send the new token to your server
      _sendTokenToServer(token);
    });
  }

  /// Handle foreground messages
  Future<void> _handleForegroundMessage(RemoteMessage message) async {
    log('📨 Received foreground message: ${message.messageId}');
    log('📨 Message data: ${message.data}');
    log('📨 Message notification: ${message.notification?.title}');

    // Show local notification for foreground messages
    await _showLocalNotificationFromFirebase(message);
  }

  /// Handle background messages (when app is opened from background)
  Future<void> handleBackgroundMessage(RemoteMessage message) async {
    log('📨 Received background message: ${message.messageId}');
    log('📨 Message data: ${message.data}');

    // Navigate to notification screen
    _navigateToNotificationScreen(message);
  }

  /// Handle terminated messages (when app is opened from terminated state)
  Future<void> _handleTerminatedMessage() async {
    try {
      final RemoteMessage? initialMessage =
          await _messaging.getInitialMessage();
      if (initialMessage != null) {
        log('📨 Received terminated message: ${initialMessage.messageId}');
        log('📨 Message data: ${initialMessage.data}');

        // Navigate to notification screen
        _navigateToNotificationScreen(initialMessage);
      }
    } catch (e) {
      log('❌ Error handling terminated message: $e');
    }
  }

  /// Show local notification from Firebase message
  Future<void> _showLocalNotificationFromFirebase(RemoteMessage message) async {
    try {
      final notification = message.notification;
      final data = message.data;

      if (notification != null) {
        // Determine notification type
        final type = data['type'] ?? 'general';

        if (type == 'price_drop') {
          // Show price drop notification using existing service
          await NotificationService().showPriceDropNotification(
            productName: data['productName'] ?? 'Product',
            oldPrice: data['oldPrice'] ?? '0.00',
            newPrice: double.tryParse(data['newPrice'] ?? '0.00') ?? 0.0,
            productId: int.tryParse(data['productId'] ?? '0') ?? 0,
            productImage: data['productImage'],
          );
        } else if (type == 'welcome_alert') {
          // Show welcome notification using existing service
          await NotificationService().showWelcomeDropNotification(
            productName: data['productName'] ?? 'Product',
            productImage: data['productImage'],
            productId: int.tryParse(data['productId'] ?? '0') ?? 0,
            currentPrice: data['currentPrice'],
          );
        } else {
          // Show general notification
          await NotificationService().showStaticNotification(
            title: notification.title ?? 'Notification',
            body: notification.body ?? '',
            payload: 'firebase:${message.messageId}',
            imageUrl: data['productImage'],
          );
        }
      }
    } catch (e) {
      log('❌ Error showing local notification from Firebase: $e');
    }
  }

  /// Navigate to notification screen
  void _navigateToNotificationScreen(RemoteMessage message) {
    try {
      final data = message.data;
      final type = data['type'] ?? 'general';

      if (type == 'price_drop' || type == 'welcome_alert') {
        // Navigate to notification screen with data
        log('📱 Navigating to notification screen with type: $type');

        // Navigate to notification screen
        final navigationService = NavigationService();
        navigationService.navigateToNotifications();
      } else {
        // Navigate to general notification screen
        final navigationService = NavigationService();
        navigationService.navigateToNotifications();
      }
    } catch (e) {
      log('❌ Error navigating to notification screen: $e');
    }
  }

  /// Send FCM token to server
  Future<void> _sendTokenToServer(String token) async {
    try {
      // Here you can implement logic to send the token to your server
      // For example, store it in Firebase Firestore or your backend
      log('📤 Sending FCM token to server: $token');

      // Example: Store in Firestore
      // await FirebaseFirestore.instance
      //     .collection('user_tokens')
      //     .doc('current_user')
      //     .set({'fcm_token': token});
    } catch (e) {
      log('❌ Error sending FCM token to server: $e');
    }
  }

  /// Send push notification via Cloud Function
  Future<bool> sendPushNotification({
    required String token,
    required String title,
    required String body,
    String type = 'general',
    String? productId,
    String? productName,
    String? oldPrice,
    String? newPrice,
    String? productImage,
    String? savings,
    String? savingsPercentage,
    Map<String, String>? additionalData,
  }) async {
    try {
      log('📤 Sending push notification to token: $token');

      final callable = _functions.httpsCallable('sendPushNotification');

      final result = await callable.call({
        'token': token,
        'title': title,
        'body': body,
        'type': type,
        'productId': productId,
        'productName': productName,
        'oldPrice': oldPrice,
        'newPrice': newPrice,
        'productImage': productImage,
        'savings': savings,
        'savingsPercentage': savingsPercentage,
        'data': additionalData ?? {},
      });

      log('✅ Push notification sent successfully: ${result.data}');
      return true;
    } catch (e) {
      log('❌ Error sending push notification: $e');
      return false;
    }
  }

  /// Send bulk push notification via Cloud Function
  Future<bool> sendBulkPushNotification({
    required List<String> tokens,
    required String title,
    required String body,
    String type = 'general',
    String? productId,
    String? productName,
    String? oldPrice,
    String? newPrice,
    String? productImage,
    String? savings,
    String? savingsPercentage,
    Map<String, String>? additionalData,
  }) async {
    try {
      log('📤 Sending bulk push notification to ${tokens.length} tokens');

      final callable = _functions.httpsCallable('sendBulkPushNotification');

      final result = await callable.call({
        'tokens': tokens,
        'title': title,
        'body': body,
        'type': type,
        'productId': productId,
        'productName': productName,
        'oldPrice': oldPrice,
        'newPrice': newPrice,
        'productImage': productImage,
        'savings': savings,
        'savingsPercentage': savingsPercentage,
        'data': additionalData ?? {},
      });

      log('✅ Bulk push notification sent successfully: ${result.data}');
      return true;
    } catch (e) {
      log('❌ Error sending bulk push notification: $e');
      return false;
    }
  }

  /// Send topic-based push notification via Cloud Function
  Future<bool> sendTopicNotification({
    required String topic,
    required String title,
    required String body,
    String type = 'general',
    String? productId,
    String? productName,
    String? oldPrice,
    String? newPrice,
    String? productImage,
    String? savings,
    String? savingsPercentage,
    Map<String, String>? additionalData,
  }) async {
    try {
      log('📤 Sending topic push notification to topic: $topic');

      final callable = _functions.httpsCallable('sendTopicNotification');

      final result = await callable.call({
        'topic': topic,
        'title': title,
        'body': body,
        'type': type,
        'productId': productId,
        'productName': productName,
        'oldPrice': oldPrice,
        'newPrice': newPrice,
        'productImage': productImage,
        'savings': savings,
        'savingsPercentage': savingsPercentage,
        'data': additionalData ?? {},
      });

      log('✅ Topic push notification sent successfully: ${result.data}');
      return true;
    } catch (e) {
      log('❌ Error sending topic push notification: $e');
      return false;
    }
  }

  /// Subscribe to topic
  Future<bool> subscribeToTopic(String topic) async {
    try {
      log('📤 Subscribing to topic: $topic');

      final callable = _functions.httpsCallable('subscribeToTopic');

      final result = await callable.call({
        'token': _fcmToken,
        'topic': topic,
      });

      log('✅ Successfully subscribed to topic: ${result.data}');
      return true;
    } catch (e) {
      log('❌ Error subscribing to topic: $e');
      return false;
    }
  }

  /// Unsubscribe from topic
  Future<bool> unsubscribeFromTopic(String topic) async {
    try {
      log('📤 Unsubscribing from topic: $topic');

      final callable = _functions.httpsCallable('unsubscribeFromTopic');

      final result = await callable.call({
        'token': _fcmToken,
        'topic': topic,
      });

      log('✅ Successfully unsubscribed from topic: ${result.data}');
      return true;
    } catch (e) {
      log('❌ Error unsubscribing from topic: $e');
      return false;
    }
  }

  /// Send price drop notification
  Future<bool> sendPriceDropNotification({
    required String token,
    required String productName,
    required String oldPrice,
    required String newPrice,
    required String productId,
    String? productImage,
  }) async {
    try {
      final oldPriceValue = double.parse(oldPrice);
      final newPriceValue = double.parse(newPrice);
      final savings = oldPriceValue - newPriceValue;
      final savingsPercentage =
          (savings / oldPriceValue * 100).toStringAsFixed(1);

      return await sendPushNotification(
        token: token,
        title: 'Price Drop Alert!',
        body:
            '$productName price dropped from \$$oldPrice to \$$newPrice - Save \$${savings.toStringAsFixed(2)}!',
        type: 'price_drop',
        productId: productId,
        productName: productName,
        oldPrice: oldPrice,
        newPrice: newPrice,
        productImage: productImage,
        savings: savings.toStringAsFixed(2),
        savingsPercentage: savingsPercentage,
      );
    } catch (e) {
      log('❌ Error sending price drop notification: $e');
      return false;
    }
  }

  /// Send welcome notification
  Future<bool> sendWelcomeNotification({
    required String token,
    required String productName,
    required String productId,
    String? productImage,
    String? currentPrice,
  }) async {
    try {
      return await sendPushNotification(
        token: token,
        title: 'Welcome to Price Alerts! 🎉',
        body: 'You\'ll be notified when prices drop for $productName',
        type: 'welcome_alert',
        productId: productId,
        productName: productName,
        productImage: productImage,
        additionalData: {
          'currentPrice': currentPrice ?? '',
        },
      );
    } catch (e) {
      log('❌ Error sending welcome notification: $e');
      return false;
    }
  }

  /// Get current FCM token
  Future<String?> getCurrentToken() async {
    try {
      _fcmToken = await _messaging.getToken();
      return _fcmToken;
    } catch (e) {
      log('❌ Error getting current FCM token: $e');
      return null;
    }
  }

  /// Delete FCM token
  Future<void> deleteToken() async {
    try {
      await _messaging.deleteToken();
      _fcmToken = null;
      log('✅ FCM token deleted successfully');
    } catch (e) {
      log('❌ Error deleting FCM token: $e');
    }
  }
}

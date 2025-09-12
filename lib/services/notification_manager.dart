import 'dart:developer';
import 'package:minsellprice/services/notification_service.dart';
import 'package:minsellprice/services/firebase_push_notification_service.dart';

/// Notification Manager
/// Centralized service that manages both local and Firebase push notifications
/// Provides a unified interface for sending notifications
class NotificationManager {
  // Singleton pattern
  static final NotificationManager _instance = NotificationManager._internal();

  factory NotificationManager() => _instance;

  NotificationManager._internal();

  // Services
  final NotificationService _localNotificationService = NotificationService();
  final FirebasePushNotificationService _firebasePushService =
      FirebasePushNotificationService();

  /// Initialize notification manager
  Future<void> initialize() async {
    try {
      log('🚀 Initializing Notification Manager...');

      // Initialize local notification service
      await _localNotificationService.initialize();

      // Initialize Firebase push notification service
      await _firebasePushService.initialize();

      log('✅ Notification Manager initialized successfully');
    } catch (e) {
      log('❌ Error initializing Notification Manager: $e');
    }
  }

  /// Send price drop notification (both local and Firebase)
  Future<bool> sendPriceDropNotification({
    required String productName,
    required String oldPrice,
    required double newPrice,
    required int productId,
    String? productImage,
    String? firebaseToken,
    bool sendLocal = true,
    bool sendFirebase = false,
  }) async {
    try {
      log('📤 Sending price drop notification for product: $productName');

      bool localSuccess = true;
      bool firebaseSuccess = true;

      // Send local notification
      if (sendLocal) {
        try {
          await _localNotificationService.showPriceDropNotification(
            productName: productName,
            oldPrice: oldPrice,
            newPrice: newPrice,
            productId: productId,
            productImage: productImage,
          );
          log('✅ Local price drop notification sent successfully');
        } catch (e) {
          log('❌ Error sending local price drop notification: $e');
          localSuccess = false;
        }
      }

      // Send Firebase push notification
      if (sendFirebase && firebaseToken != null) {
        try {
          firebaseSuccess =
              await _firebasePushService.sendPriceDropNotification(
            token: firebaseToken,
            productName: productName,
            oldPrice: oldPrice,
            newPrice: newPrice.toString(),
            productId: productId.toString(),
            productImage: productImage,
          );

          if (firebaseSuccess) {
            log('✅ Firebase price drop notification sent successfully');
          } else {
            log('❌ Firebase price drop notification failed');
          }
        } catch (e) {
          log('❌ Error sending Firebase price drop notification: $e');
          firebaseSuccess = false;
        }
      }

      return localSuccess && firebaseSuccess;
    } catch (e) {
      log('❌ Error in sendPriceDropNotification: $e');
      return false;
    }
  }

  /// Send welcome notification (both local and Firebase)
  Future<bool> sendWelcomeNotification({
    required String productName,
    required int productId,
    String? productImage,
    String? currentPrice,
    String? firebaseToken,
    bool sendLocal = true,
    bool sendFirebase = false,
  }) async {
    try {
      log('📤 Sending welcome notification for product: $productName');

      bool localSuccess = true;
      bool firebaseSuccess = true;

      // Send local notification
      if (sendLocal) {
        try {
          await _localNotificationService.showWelcomeDropNotification(
            productName: productName,
            productId: productId,
            productImage: productImage,
            currentPrice: currentPrice,
          );
          log('✅ Local welcome notification sent successfully');
        } catch (e) {
          log('❌ Error sending local welcome notification: $e');
          localSuccess = false;
        }
      }

      // Send Firebase push notification
      if (sendFirebase && firebaseToken != null) {
        try {
          firebaseSuccess = await _firebasePushService.sendWelcomeNotification(
            token: firebaseToken,
            productName: productName,
            productId: productId.toString(),
            productImage: productImage,
            currentPrice: currentPrice,
          );

          if (firebaseSuccess) {
            log('✅ Firebase welcome notification sent successfully');
          } else {
            log('❌ Firebase welcome notification failed');
          }
        } catch (e) {
          log('❌ Error sending Firebase welcome notification: $e');
          firebaseSuccess = false;
        }
      }

      return localSuccess && firebaseSuccess;
    } catch (e) {
      log('❌ Error in sendWelcomeNotification: $e');
      return false;
    }
  }

  /// Send general notification (both local and Firebase)
  Future<bool> sendGeneralNotification({
    required String title,
    required String body,
    String? payload,
    String? imageUrl,
    String? firebaseToken,
    bool sendLocal = true,
    bool sendFirebase = false,
  }) async {
    try {
      log('📤 Sending general notification: $title');

      bool localSuccess = true;
      bool firebaseSuccess = true;

      // Send local notification
      if (sendLocal) {
        try {
          await _localNotificationService.showStaticNotification(
            title: title,
            body: body,
            payload: payload,
            imageUrl: imageUrl,
          );
          log('✅ Local general notification sent successfully');
        } catch (e) {
          log('❌ Error sending local general notification: $e');
          localSuccess = false;
        }
      }

      // Send Firebase push notification
      if (sendFirebase && firebaseToken != null) {
        try {
          firebaseSuccess = await _firebasePushService.sendPushNotification(
            token: firebaseToken,
            title: title,
            body: body,
            type: 'general',
            additionalData: {
              'payload': payload ?? '',
              'imageUrl': imageUrl ?? '',
            },
          );

          if (firebaseSuccess) {
            log('✅ Firebase general notification sent successfully');
          } else {
            log('❌ Firebase general notification failed');
          }
        } catch (e) {
          log('❌ Error sending Firebase general notification: $e');
          firebaseSuccess = false;
        }
      }

      return localSuccess && firebaseSuccess;
    } catch (e) {
      log('❌ Error in sendGeneralNotification: $e');
      return false;
    }
  }

  /// Send bulk notifications (Firebase only)
  Future<bool> sendBulkNotification({
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
      log('📤 Sending bulk notification to ${tokens.length} tokens');

      final success = await _firebasePushService.sendBulkPushNotification(
        tokens: tokens,
        title: title,
        body: body,
        type: type,
        productId: productId,
        productName: productName,
        oldPrice: oldPrice,
        newPrice: newPrice,
        productImage: productImage,
        savings: savings,
        savingsPercentage: savingsPercentage,
        additionalData: additionalData,
      );

      if (success) {
        log('✅ Bulk notification sent successfully');
      } else {
        log('❌ Bulk notification failed');
      }

      return success;
    } catch (e) {
      log('❌ Error in sendBulkNotification: $e');
      return false;
    }
  }

  /// Send topic-based notification (Firebase only)
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
      log('📤 Sending topic notification to topic: $topic');

      final success = await _firebasePushService.sendTopicNotification(
        topic: topic,
        title: title,
        body: body,
        type: type,
        productId: productId,
        productName: productName,
        oldPrice: oldPrice,
        newPrice: newPrice,
        productImage: productImage,
        savings: savings,
        savingsPercentage: savingsPercentage,
        additionalData: additionalData,
      );

      if (success) {
        log('✅ Topic notification sent successfully');
      } else {
        log('❌ Topic notification failed');
      }

      return success;
    } catch (e) {
      log('❌ Error in sendTopicNotification: $e');
      return false;
    }
  }

  /// Subscribe to topic
  Future<bool> subscribeToTopic(String topic) async {
    try {
      log('📤 Subscribing to topic: $topic');

      final success = await _firebasePushService.subscribeToTopic(topic);

      if (success) {
        log('✅ Successfully subscribed to topic: $topic');
      } else {
        log('❌ Failed to subscribe to topic: $topic');
      }

      return success;
    } catch (e) {
      log('❌ Error in subscribeToTopic: $e');
      return false;
    }
  }

  /// Unsubscribe from topic
  Future<bool> unsubscribeFromTopic(String topic) async {
    try {
      log('📤 Unsubscribing from topic: $topic');

      final success = await _firebasePushService.unsubscribeFromTopic(topic);

      if (success) {
        log('✅ Successfully unsubscribed from topic: $topic');
      } else {
        log('❌ Failed to unsubscribe from topic: $topic');
      }

      return success;
    } catch (e) {
      log('❌ Error in unsubscribeFromTopic: $e');
      return false;
    }
  }

  /// Get current FCM token
  Future<String?> getCurrentFCMToken() async {
    try {
      return await _firebasePushService.getCurrentToken();
    } catch (e) {
      log('❌ Error getting current FCM token: $e');
      return null;
    }
  }

  /// Check if services are initialized
  bool get isLocalNotificationInitialized =>
      _localNotificationService.isInitialized;
  bool get isFirebasePushInitialized => _firebasePushService.isInitialized;
  bool get isFullyInitialized =>
      isLocalNotificationInitialized && isFirebasePushInitialized;
}

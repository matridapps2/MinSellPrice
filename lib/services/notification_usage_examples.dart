import 'dart:developer';
import 'package:minsellprice/services/notification_manager.dart';
import 'package:minsellprice/services/notification_api_service.dart';

/// Notification Usage Examples
/// This file contains examples of how to use the notification system
/// in your existing code
class NotificationUsageExamples {
  /// Example 1: Send price drop notification when product price changes
  static Future<void> handlePriceDrop({
    required String productName,
    required String oldPrice,
    required String newPrice,
    required int productId,
    String? productImage,
    String? emailId,
    String? deviceToken,
  }) async {
    try {
      log('📤 Handling price drop for product: $productName');

      // Calculate savings
      final oldPriceValue = double.parse(oldPrice);
      final newPriceValue = double.parse(newPrice);
      final savings = oldPriceValue - newPriceValue;
      final savingsPercentage =
          (savings / oldPriceValue * 100).toStringAsFixed(1);

      // Send notification via API service (handles both local and Firebase)
      if (emailId != null && deviceToken != null) {
        await NotificationApiService().sendPriceDropNotificationToServer(
          emailId: emailId,
          deviceToken: deviceToken,
          productName: productName,
          oldPrice: oldPrice,
          newPrice: newPrice,
          productId: productId,
          productImage: productImage,
          savings: savings.toStringAsFixed(2),
          savingsPercentage: savingsPercentage,
        );
      } else {
        // Send local notification only
        await NotificationManager().sendPriceDropNotification(
          productName: productName,
          oldPrice: oldPrice,
          newPrice: newPriceValue,
          productId: productId,
          productImage: productImage,
          sendLocal: true,
          sendFirebase: false,
        );
      }

      log('✅ Price drop notification sent successfully');
    } catch (e) {
      log('❌ Error handling price drop: $e');
    }
  }

  /// Example 2: Send welcome notification when user sets price alert
  static Future<void> handlePriceAlertSet({
    required String productName,
    required int productId,
    String? productImage,
    String? currentPrice,
    String? emailId,
    String? deviceToken,
  }) async {
    try {
      log('📤 Handling price alert set for product: $productName');

      // Send notification via API service (handles both local and Firebase)
      if (emailId != null && deviceToken != null) {
        await NotificationApiService().sendWelcomeNotificationToServer(
          emailId: emailId,
          deviceToken: deviceToken,
          productName: productName,
          productId: productId,
          productImage: productImage,
          currentPrice: currentPrice,
        );
      } else {
        // Send local notification only
        await NotificationManager().sendWelcomeNotification(
          productName: productName,
          productId: productId,
          productImage: productImage,
          currentPrice: currentPrice,
          sendLocal: true,
          sendFirebase: false,
        );
      }

      log('✅ Welcome notification sent successfully');
    } catch (e) {
      log('❌ Error handling price alert set: $e');
    }
  }

  /// Example 3: Send general notification for app updates
  static Future<void> handleAppUpdate({
    required String title,
    required String body,
    String? emailId,
    String? deviceToken,
  }) async {
    try {
      log('📤 Handling app update notification: $title');

      // Send notification via API service (handles both local and Firebase)
      if (emailId != null && deviceToken != null) {
        await NotificationApiService().sendGeneralNotificationToServer(
          emailId: emailId,
          deviceToken: deviceToken,
          title: title,
          body: body,
          type: 'app_update',
        );
      } else {
        // Send local notification only
        await NotificationManager().sendGeneralNotification(
          title: title,
          body: body,
          sendLocal: true,
          sendFirebase: false,
        );
      }

      log('✅ App update notification sent successfully');
    } catch (e) {
      log('❌ Error handling app update: $e');
    }
  }

  /// Example 4: Send bulk notification to all users
  static Future<void> handleBulkNotification({
    required List<String> fcmTokens,
    required String title,
    required String body,
    String type = 'general',
  }) async {
    try {
      log('📤 Handling bulk notification to ${fcmTokens.length} users: $title');

      // Send bulk notification
      await NotificationManager().sendBulkNotification(
        tokens: fcmTokens,
        title: title,
        body: body,
        type: type,
      );

      log('✅ Bulk notification sent successfully');
    } catch (e) {
      log('❌ Error handling bulk notification: $e');
    }
  }

  /// Example 5: Send topic-based notification
  static Future<void> handleTopicNotification({
    required String topic,
    required String title,
    required String body,
    String type = 'general',
  }) async {
    try {
      log('📤 Handling topic notification to topic: $topic');

      // Send topic notification
      await NotificationManager().sendTopicNotification(
        topic: topic,
        title: title,
        body: body,
        type: type,
      );

      log('✅ Topic notification sent successfully');
    } catch (e) {
      log('❌ Error handling topic notification: $e');
    }
  }

  /// Example 6: Subscribe user to topic
  static Future<void> handleTopicSubscription({
    required String topic,
  }) async {
    try {
      log('📤 Subscribing user to topic: $topic');

      // Subscribe to topic
      final success = await NotificationManager().subscribeToTopic(topic);

      if (success) {
        log('✅ Successfully subscribed to topic: $topic');
      } else {
        log('❌ Failed to subscribe to topic: $topic');
      }
    } catch (e) {
      log('❌ Error handling topic subscription: $e');
    }
  }

  /// Example 7: Unsubscribe user from topic
  static Future<void> handleTopicUnsubscription({
    required String topic,
  }) async {
    try {
      log('📤 Unsubscribing user from topic: $topic');

      // Unsubscribe from topic
      final success = await NotificationManager().unsubscribeFromTopic(topic);

      if (success) {
        log('✅ Successfully unsubscribed from topic: $topic');
      } else {
        log('❌ Failed to unsubscribe from topic: $topic');
      }
    } catch (e) {
      log('❌ Error handling topic unsubscription: $e');
    }
  }

  /// Example 8: Get current FCM token
  static Future<String?> getCurrentToken() async {
    try {
      log('📤 Getting current FCM token');

      // Get current FCM token
      final token = await NotificationManager().getCurrentFCMToken();

      if (token != null) {
        log('✅ FCM token retrieved: ${token.substring(0, 20)}...');
      } else {
        log('❌ No FCM token available');
      }

      return token;
    } catch (e) {
      log('❌ Error getting FCM token: $e');
      return null;
    }
  }

  /// Example 9: Check notification system status
  static Future<void> checkNotificationStatus() async {
    try {
      log('📤 Checking notification system status');

      // Check if services are initialized
      final isLocalInitialized =
          NotificationManager().isLocalNotificationInitialized;
      final isFirebaseInitialized =
          NotificationManager().isFirebasePushInitialized;
      final isFullyInitialized = NotificationManager().isFullyInitialized;

      log('📊 Notification System Status:');
      log('  - Local Notifications: ${isLocalInitialized ? "✅" : "❌"}');
      log('  - Firebase Push: ${isFirebaseInitialized ? "✅" : "❌"}');
      log('  - Fully Initialized: ${isFullyInitialized ? "✅" : "❌"}');

      // Get FCM token
      final token = await getCurrentToken();
      log('  - FCM Token: ${token != null ? "✅ Available" : "❌ Not Available"}');
    } catch (e) {
      log('❌ Error checking notification status: $e');
    }
  }
}

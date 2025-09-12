import 'dart:developer';
import 'dart:convert';
import 'package:minsellprice/services/notification_manager.dart';

/// Notification API Service
/// Handles server-side notification operations including:
/// - Sending notifications to server
/// - Managing notification preferences
/// - Handling notification responses
class NotificationApiService {
  // Singleton pattern
  static final NotificationApiService _instance =
      NotificationApiService._internal();

  factory NotificationApiService() => _instance;

  NotificationApiService._internal();

  /// Send price drop notification to server
  Future<bool> sendPriceDropNotificationToServer({
    required String emailId,
    required String deviceToken,
    required String productName,
    required String oldPrice,
    required String newPrice,
    required int productId,
    String? productImage,
    String? savings,
    String? savingsPercentage,
  }) async {
    try {
      log('📤 Sending price drop notification to server for product: $productName');

      // Get current FCM token
      final fcmToken = await NotificationManager().getCurrentFCMToken();

      if (fcmToken == null) {
        log('❌ No FCM token available for server notification');
        return false;
      }

      // Send local notification
      final localSuccess =
          await NotificationManager().sendPriceDropNotification(
        productName: productName,
        oldPrice: oldPrice,
        newPrice: double.parse(newPrice),
        productId: productId,
        productImage: productImage,
        sendLocal: true,
        sendFirebase: false, // We'll handle Firebase separately
      );

      // Send Firebase push notification
      final firebaseSuccess =
          await NotificationManager().sendPriceDropNotification(
        productName: productName,
        oldPrice: oldPrice,
        newPrice: double.parse(newPrice),
        productId: productId,
        productImage: productImage,
        firebaseToken: fcmToken,
        sendLocal: false,
        sendFirebase: true,
      );

      // Send to server for logging/analytics
      final serverSuccess = await _sendNotificationToServer(
        emailId: emailId,
        deviceToken: deviceToken,
        fcmToken: fcmToken,
        type: 'price_drop',
        productId: productId,
        productName: productName,
        oldPrice: oldPrice,
        newPrice: newPrice,
        productImage: productImage,
        savings: savings,
        savingsPercentage: savingsPercentage,
      );

      final overallSuccess = localSuccess && firebaseSuccess && serverSuccess;

      if (overallSuccess) {
        log('✅ Price drop notification sent successfully (local, Firebase, server)');
      } else {
        log('⚠️ Price drop notification partially sent (local: $localSuccess, Firebase: $firebaseSuccess, server: $serverSuccess)');
      }

      return overallSuccess;
    } catch (e) {
      log('❌ Error sending price drop notification to server: $e');
      return false;
    }
  }

  /// Send welcome notification to server
  Future<bool> sendWelcomeNotificationToServer({
    required String emailId,
    required String deviceToken,
    required String productName,
    required int productId,
    String? productImage,
    String? currentPrice,
  }) async {
    try {
      log('📤 Sending welcome notification to server for product: $productName');

      // Get current FCM token
      final fcmToken = await NotificationManager().getCurrentFCMToken();

      if (fcmToken == null) {
        log('❌ No FCM token available for server notification');
        return false;
      }

      // Send local notification
      final localSuccess = await NotificationManager().sendWelcomeNotification(
        productName: productName,
        productId: productId,
        productImage: productImage,
        currentPrice: currentPrice,
        sendLocal: true,
        sendFirebase: false, // We'll handle Firebase separately
      );

      // Send Firebase push notification
      final firebaseSuccess =
          await NotificationManager().sendWelcomeNotification(
        productName: productName,
        productId: productId,
        productImage: productImage,
        currentPrice: currentPrice,
        firebaseToken: fcmToken,
        sendLocal: false,
        sendFirebase: true,
      );

      // Send to server for logging/analytics
      final serverSuccess = await _sendNotificationToServer(
        emailId: emailId,
        deviceToken: deviceToken,
        fcmToken: fcmToken,
        type: 'welcome_alert',
        productId: productId,
        productName: productName,
        productImage: productImage,
        currentPrice: currentPrice,
      );

      final overallSuccess = localSuccess && firebaseSuccess && serverSuccess;

      if (overallSuccess) {
        log('✅ Welcome notification sent successfully (local, Firebase, server)');
      } else {
        log('⚠️ Welcome notification partially sent (local: $localSuccess, Firebase: $firebaseSuccess, server: $serverSuccess)');
      }

      return overallSuccess;
    } catch (e) {
      log('❌ Error sending welcome notification to server: $e');
      return false;
    }
  }

  /// Send general notification to server
  Future<bool> sendGeneralNotificationToServer({
    required String emailId,
    required String deviceToken,
    required String title,
    required String body,
    String? payload,
    String? imageUrl,
    String type = 'general',
  }) async {
    try {
      log('📤 Sending general notification to server: $title');

      // Get current FCM token
      final fcmToken = await NotificationManager().getCurrentFCMToken();

      if (fcmToken == null) {
        log('❌ No FCM token available for server notification');
        return false;
      }

      // Send local notification
      final localSuccess = await NotificationManager().sendGeneralNotification(
        title: title,
        body: body,
        payload: payload,
        imageUrl: imageUrl,
        sendLocal: true,
        sendFirebase: false, // We'll handle Firebase separately
      );

      // Send Firebase push notification
      final firebaseSuccess =
          await NotificationManager().sendGeneralNotification(
        title: title,
        body: body,
        payload: payload,
        imageUrl: imageUrl,
        firebaseToken: fcmToken,
        sendLocal: false,
        sendFirebase: true,
      );

      // Send to server for logging/analytics
      final serverSuccess = await _sendNotificationToServer(
        emailId: emailId,
        deviceToken: deviceToken,
        fcmToken: fcmToken,
        type: type,
        title: title,
        body: body,
        payload: payload,
        imageUrl: imageUrl,
      );

      final overallSuccess = localSuccess && firebaseSuccess && serverSuccess;

      if (overallSuccess) {
        log('✅ General notification sent successfully (local, Firebase, server)');
      } else {
        log('⚠️ General notification partially sent (local: $localSuccess, Firebase: $firebaseSuccess, server: $serverSuccess)');
      }

      return overallSuccess;
    } catch (e) {
      log('❌ Error sending general notification to server: $e');
      return false;
    }
  }

  /// Send notification to server for logging/analytics
  Future<bool> _sendNotificationToServer({
    required String emailId,
    required String deviceToken,
    required String fcmToken,
    required String type,
    int? productId,
    String? productName,
    String? oldPrice,
    String? newPrice,
    String? productImage,
    String? savings,
    String? savingsPercentage,
    String? currentPrice,
    String? title,
    String? body,
    String? payload,
    String? imageUrl,
  }) async {
    try {
      // Create notification data
      final notificationData = {
        'emailId': emailId,
        'deviceToken': deviceToken,
        'fcmToken': fcmToken,
        'type': type,
        'timestamp': DateTime.now().toIso8601String(),
        'productId': productId,
        'productName': productName,
        'oldPrice': oldPrice,
        'newPrice': newPrice,
        'productImage': productImage,
        'savings': savings,
        'savingsPercentage': savingsPercentage,
        'currentPrice': currentPrice,
        'title': title,
        'body': body,
        'payload': payload,
        'imageUrl': imageUrl,
      };

      // Remove null values
      notificationData.removeWhere((key, value) => value == null);

      // Here you can implement your server API call
      // For now, we'll just log the data
      log('📤 Notification data for server: ${json.encode(notificationData)}');

      // Example API call (replace with your actual API endpoint)
      // final response = await http.post(
      //   Uri.parse('${Constants.baseUrl}/api/notifications/send'),
      //   headers: {
      //     'Content-Type': 'application/json',
      //   },
      //   body: json.encode(notificationData),
      // );

      // if (response.statusCode == 200) {
      //   log('✅ Notification sent to server successfully');
      //   return true;
      // } else {
      //   log('❌ Server returned error: ${response.statusCode}');
      //   return false;
      // }

      // For now, return true as we're just logging
      return true;
    } catch (e) {
      log('❌ Error sending notification to server: $e');
      return false;
    }
  }

  /// Update notification preferences
  Future<bool> updateNotificationPreferences({
    required String emailId,
    required String deviceToken,
    required Map<String, dynamic> preferences,
  }) async {
    try {
      log('📤 Updating notification preferences for user: $emailId');

      // Here you can implement your server API call
      // For now, we'll just log the preferences
      log('📤 Notification preferences: ${json.encode(preferences)}');

      // Example API call (replace with your actual API endpoint)
      // final response = await http.post(
      //   Uri.parse('${Constants.baseUrl}/api/notifications/preferences'),
      //   headers: {
      //     'Content-Type': 'application/json',
      //   },
      //   body: json.encode({
      //     'emailId': emailId,
      //     'deviceToken': deviceToken,
      //     'preferences': preferences,
      //   }),
      // );

      // if (response.statusCode == 200) {
      //   log('✅ Notification preferences updated successfully');
      //   return true;
      // } else {
      //   log('❌ Server returned error: ${response.statusCode}');
      //   return false;
      // }

      // For now, return true as we're just logging
      return true;
    } catch (e) {
      log('❌ Error updating notification preferences: $e');
      return false;
    }
  }

  /// Get notification history
  Future<List<Map<String, dynamic>>> getNotificationHistory({
    required String emailId,
    required String deviceToken,
    int limit = 50,
    int offset = 0,
  }) async {
    try {
      log('📤 Getting notification history for user: $emailId');

      // Here you can implement your server API call
      // For now, we'll return an empty list
      log('📤 Notification history request: limit=$limit, offset=$offset');

      // Example API call (replace with your actual API endpoint)
      // final response = await http.get(
      //   Uri.parse('${Constants.baseUrl}/api/notifications/history?emailId=$emailId&deviceToken=$deviceToken&limit=$limit&offset=$offset'),
      //   headers: {
      //     'Content-Type': 'application/json',
      //   },
      // );

      // if (response.statusCode == 200) {
      //   final data = json.decode(response.body);
      //   log('✅ Notification history retrieved successfully');
      //   return List<Map<String, dynamic>>.from(data['notifications'] ?? []);
      // } else {
      //   log('❌ Server returned error: ${response.statusCode}');
      //   return [];
      // }

      // For now, return empty list
      return [];
    } catch (e) {
      log('❌ Error getting notification history: $e');
      return [];
    }
  }
}

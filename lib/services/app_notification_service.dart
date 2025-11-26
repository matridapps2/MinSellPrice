import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:minsellprice/services/notification_service.dart';
import 'package:minsellprice/services/work_manager_service.dart';
import 'package:minsellprice/core/apis/apis_calls.dart';
import 'package:minsellprice/services/navigation_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Service to handle automatic notification checking when app opens and comes to foreground
class AppNotificationService {
  static final AppNotificationService _instance =
      AppNotificationService._internal();
  factory AppNotificationService() => _instance;
  AppNotificationService._internal();

  Timer? _notificationCheckTimer;
  bool _isInitialized = false;
  String? _deviceId;
  String? _userEmail;
  BuildContext? _context;

  /// Initialize the service
  Future<void> initialize(BuildContext context) async {
    if (_isInitialized) return;

    _context = context;
    await _getDeviceId();
    await _getUserEmail();
    _isInitialized = true;

    log('AppNotificationService initialized successfully');
  }

  /// Start automatic notification checking
  Future<void> startAutoNotificationChecking() async {
    if (!_isInitialized) {
      log('AppNotificationService not initialized, skipping auto notification check');
      return;
    }

    log('🚀 Starting automatic notification checking...');

    // Check for notifications immediately when app opens
    await _checkForAutoNotifications();

    // Set up periodic checking every 30 seconds while app is active
    _notificationCheckTimer?.cancel();
    _notificationCheckTimer =
        Timer.periodic(const Duration(seconds: 30), (timer) {
      if (_context != null && _context!.mounted) {
        _checkForAutoNotifications();
      }
    });

    log('✅ Automatic notification checking started');
  }

  /// Stop automatic notification checking
  void stopAutoNotificationChecking() {
    _notificationCheckTimer?.cancel();
    _notificationCheckTimer = null;
    log('🛑 Automatic notification checking stopped');
  }

  /// Check for auto-triggered notifications
  Future<void> _checkForAutoNotifications() async {
    log('🔍 Checking for auto-notifications...');

    try {
      // Check for notifications in the queue system
      final prefs = await SharedPreferences.getInstance();
      final queueCount = prefs.getInt('notification_queue_count') ?? 0;

      if (queueCount > 0) {
        log('✅ Found $queueCount notifications in queue');
        await _showAllNotificationsFromQueue();
      } else {
        log('❌ No notifications in queue');

        // Fallback to old system for backward compatibility
        final notificationData =
            await WorkManagerService.checkAutoTriggeredNotification();

        if (notificationData != null) {
          log('✅ Auto-notification found (fallback): $notificationData');
          await _showAutoNotification(notificationData);
          await WorkManagerService.clearAutoTriggeredNotification();
        } else {
          log('❌ No auto-notifications found');
        }
      }
    } catch (e) {
      log('❌ Error checking for auto-notifications: $e');
    }
  }

  /// Show auto-triggered notification
  Future<void> _showAutoNotification(
      Map<String, dynamic> notificationData) async {
    try {
      final notificationService = NotificationService();
      if (!notificationService.isInitialized) {
        await notificationService.initialize();
      }

      await notificationService.showPriceDropNotification(
        productName: notificationData['product_name'] ?? '---',
        oldPrice: notificationData['OldPrice'] ?? '0.00',
        newPrice:
            double.tryParse(notificationData['NewPrice'] ?? '0.00') ?? 0.00,
        productId: int.tryParse(notificationData['product_id'] ?? '0') ?? 0,
        productImage: notificationData['product_image'] ?? '',
      );

      log('🚨 Price drop detected! Notification sent automatically!');
      log('✅ Auto-notification shown successfully');
    } catch (e) {
      log('❌ Error showing auto-notification: $e');
    }
  }

  /// Show all notifications from queue
  Future<void> _showAllNotificationsFromQueue() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final queueJson = prefs.getString('notification_queue') ?? '[]';

      List<Map<String, dynamic>> notificationQueue = [];
      try {
        final queue = json.decode(queueJson) as List;
        notificationQueue = queue.cast<Map<String, dynamic>>();
      } catch (e) {
        log('⚠️ Error parsing notification queue: $e');
        return;
      }

      if (notificationQueue.isEmpty) {
        log('📭 No notifications in queue to display');
        return;
      }

      log('📋 Displaying ${notificationQueue.length} notifications from queue');

      final notificationService = NotificationService();
      if (!notificationService.isInitialized) {
        await notificationService.initialize();
      }

      // Show each notification in the queue
      for (int i = 0; i < notificationQueue.length; i++) {
        final notification = notificationQueue[i];

        log('🔔 Showing notification ${i + 1}/${notificationQueue.length}: ${notification['product_name']}');

        try {
          await notificationService.showPriceDropNotification(
            productName: notification['product_name'] ?? '---',
            oldPrice: notification['old_price'] ?? '---',
            newPrice:
                double.tryParse(notification['new_price'] ?? '---') ?? 0.00,
            productId: int.tryParse(notification['product_id'] ?? '0') ?? 0,
            productImage: notification['product_image'] ?? '',
          );

          // Add a small delay between notifications to avoid overwhelming the user
          if (i < notificationQueue.length - 1) {
            await Future.delayed(const Duration(milliseconds: 500));
          }
        } catch (e) {
          log('❌ Error showing notification ${i + 1}: $e');
        }
      }

      log('🚨 ${notificationQueue.length} price drop notifications sent!');

      // Clear the queue after showing all notifications
      await _clearNotificationQueue();

      log('✅ All notifications from queue displayed successfully');
    } catch (e) {
      log('❌ Error showing notifications from queue: $e');
    }
  }

  /// Clear notification queue
  Future<void> _clearNotificationQueue() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('notification_queue');
      await prefs.remove('notification_queue_count');
      log('🗑️ Notification queue cleared');
    } catch (e) {
      log('❌ Error clearing notification queue: $e');
    }
  }

  /// Check for notifications from API when app opens
  Future<void> checkForNotificationsOnAppOpen() async {
    if (!_isInitialized) {
      log('AppNotificationService not initialized, skipping API check');
      return;
    }

    log('🔍 Checking for notifications on app open...');

    try {
      // Make API call to check for notifications immediately
      await _fetchNotificationsFromAPI();

      log('✅ App open notification check completed');
    } catch (e) {
      log('❌ Error checking notifications on app open: $e');
    }
  }

  /// Fetch notifications from API
  Future<void> _fetchNotificationsFromAPI() async {
    try {
      // Get current device token and user email
      await _getDeviceId();
      await _getUserEmail();

      // Use unified method that handles both email and device token scenarios
      // Get current context from NavigationService if not available
      BuildContext? apiContext =
          _context ?? NavigationService().getNavigatorKey().currentContext;

      if (apiContext == null) {
        log('❌ No context available for API call - skipping notification check');
        return;
      }

      final responseBody = await BrandsApi.fetchPriceAlertProduct(
        emailId: _userEmail,
        deviceToken: _deviceId,
        context: apiContext,
      );

      if (responseBody != 'error' && responseBody.isNotEmpty) {
        log('✅ API call successful using unified method!');
        log('📏 Response body length: ${responseBody.length}');

        try {
          final data = json.decode(responseBody);
          log('📊 Response type: ${data.runtimeType}');
          log('🔍 Response data: $data');

          // Process the data for notifications
          await _processApiDataForNotifications(data);

          log('✅ API data processing completed');
        } catch (jsonError) {
          log('❌ Error parsing JSON response: $jsonError');
          log('📄 Raw response: $responseBody');
        }
      } else {
        log('❌ API call failed or returned error');
        log('📄 Response: $responseBody');
      }
    } catch (e) {
      log('❌ Error fetching notifications from API: $e');
    }
  }

  /// Process API response data for notifications
  Future<void> _processApiDataForNotifications(dynamic data) async {
    log('🔧 Processing API data for notifications...');

    try {
      if (data is List) {
        log('🔍 Processing List response with ${data.length} items');
        for (int i = 0; i < data.length; i++) {
          final item = data[i];
          if (item is Map<String, dynamic>) {
            await _processNotificationItem(item);
          }
        }
      } else if (data is Map<String, dynamic>) {
        log('🔍 Processing single Map response: ${data.keys.toList()}');
        await _processNotificationItem(data);
      } else {
        log('⚠️ Response is neither List nor Map, cannot process: ${data.runtimeType}');
      }

      log('✅ Data processing completed');
    } catch (e) {
      log('❌ Error processing API data: $e');
    }
  }

  /// Process individual notification item
  Future<void> _processNotificationItem(Map<String, dynamic> item) async {
    log('🔍 Processing notification item: ${item.keys.toList()}');

    try {
      if (item.containsKey('device_token') && item.containsKey('product_id')) {
        final responseDeviceToken = item['device_token'];
        final responseEmail = item['email'];
        final isNotificationSent =
            int.tryParse(item['isNotificationSent']?.toString() ?? '0') ?? 0;

        log('🔍 Processing notification data:');
        log('   Response device token: $responseDeviceToken');
        log('   Response email: $responseEmail');
        log('   Current device token: $_deviceId');
        log('   Current user email: $_userEmail');
        log('   Notification already sent: ${isNotificationSent == 1 ? "YES" : "NO"}');
        log('   User login status: ${_userEmail != null && _userEmail!.isNotEmpty ? "LOGGED IN" : "NOT LOGGED IN"}');

        // Skip notifications that have already been sent
        if (isNotificationSent == 1) {
          log('⏭️ Skipping notification - already sent (isNotificationSent = 1)');
          return;
        }

        bool shouldShowNotification = false;

        // LOGIN CASE: First check both email and device token
        // Then filter for null device tokens and isNotificationSent = 0
        if (_userEmail != null && _userEmail!.isNotEmpty) {
          if (responseEmail == _userEmail) {
            // Email matches - now check device token and notification status
            if (responseDeviceToken == null ||
                responseDeviceToken.toString().isEmpty ||
                responseDeviceToken.toString() == 'null') {
              // Device token is null - this is a user-specific notification
              if (isNotificationSent == 0) {
                // Notification not yet sent - show it
                shouldShowNotification = true;
                log('✅ LOGIN CASE: Email matches + device token is null + not sent (showing notification)');
                log('🔍 This is a user-specific notification that hasn\'t been sent yet');
              } else {
                log('⏭️ LOGIN CASE: Email matches + device token is null BUT already sent (skipping)');
                log('   isNotificationSent = $isNotificationSent (0 = not sent, 1 = sent)');
              }
            } else {
              // Device token is not null - skip this notification
              log('⏭️ LOGIN CASE: Email matches BUT device token is not null (skipping)');
              log('   Device token: $responseDeviceToken');
              log('🔍 For login users, only show notifications where device_token is null');
            }
          } else {
            log('❌ LOGIN CASE: Email does not match current user');
            log('   Response email: $responseEmail, Current email: $_userEmail');
          }
        } else {
          // LOGGED OUT CASE: Check only device token
          // Show notification if device token matches current device
          if (_deviceId != null && responseDeviceToken == _deviceId) {
            shouldShowNotification = true;
            log('✅ LOGGED OUT CASE: Device token matches (showing notification)');
          } else {
            log('❌ LOGGED OUT CASE: Device token does not match');
            log('   Response device token: $responseDeviceToken');
            log('   Current device token: $_deviceId');
          }
        }

        if (shouldShowNotification) {
          log('🎉 NOTIFICATION APPROVED! Auto-triggering for product: ${item['product_name']}');

          // Check if data is valid before showing notification
          bool isDataValid = _validateNotificationData(item);

          if (isDataValid) {
            log('✅ Data validation passed - showing notification');
            await _autoTriggerNotification(item);
          } else {
            log('❌ Data validation failed - skipping notification');
          }
        }
      }
    } catch (e) {
      log('❌ Error processing notification item: $e');
    }
  }

  /// Validate notification data
  bool _validateNotificationData(Map<String, dynamic> data) {
    try {
      final requiredFields = [
        'product_name',
        'OldPrice',
        'NewPrice',
        'product_id',
        'product_image'
      ];

      for (String field in requiredFields) {
        final value = data[field];
        if (value == null ||
            value.toString().isEmpty ||
            value.toString() == '---') {
          log('❌ Validation failed: $field is empty or null ($value)');
          return false;
        }
      }

      final oldPrice = double.tryParse(data['OldPrice']?.toString() ?? '');
      final newPrice = double.tryParse(data['NewPrice']?.toString() ?? '');

      if (oldPrice == null || newPrice == null) {
        log('❌ Validation failed: Invalid price format');
        log('   Old Price: ${data['OldPrice']}');
        log('   New Price: ${data['NewPrice']}');
        return false;
      }

      // ✅ Check if prices are actually different
      if (oldPrice == newPrice) {
        log('❌ Validation failed: Prices are the same - no price drop');
        log('   Old Price: \$${oldPrice.toStringAsFixed(2)}');
        log('   New Price: \$${newPrice.toStringAsFixed(2)}');
        log('   Price Difference: \$${(newPrice - oldPrice).toStringAsFixed(2)}');
        log('   💡 Notification skipped - no actual price change detected');
        return false;
      }

      // ✅ Check if it's actually a price drop (new price < old price)
      if (newPrice > oldPrice) {
        log('❌ Validation failed: New price is higher than old price - not a drop');
        log('   Old Price: \$${oldPrice.toStringAsFixed(2)}');
        log('   New Price: \$${newPrice.toStringAsFixed(2)}');
        log('   Price Difference: \$${(newPrice - oldPrice).toStringAsFixed(2)} (price increased)');
        log('   💡 Notification skipped - price increased, not decreased');
        return false;
      }

      final productId = int.tryParse(data['product_id']?.toString() ?? '0');
      if (productId == null || productId <= 0) {
        log('❌ Validation failed: Invalid product ID: ${data['product_id']}');
        return false;
      }

      final imageUrl = data['product_image']?.toString() ?? '';
      if (imageUrl.isEmpty || !imageUrl.startsWith('http')) {
        log('❌ Validation failed: Invalid image URL: $imageUrl');
        return false;
      }

      // Check if notification has already been sent
      final isNotificationSent =
          int.tryParse(data['isNotificationSent']?.toString() ?? '0') ?? 0;
      if (isNotificationSent == 1) {
        log('❌ Validation failed: Notification already sent (isNotificationSent = 1)');
        return false;
      }

      // ✅ Price drop detected - calculate savings
      final priceDifference = oldPrice - newPrice;
      final savingsPercentage = ((priceDifference / oldPrice) * 100);

      log('✅ Price drop detected!');
      log('   Old Price: \$${oldPrice.toStringAsFixed(2)}');
      log('   New Price: \$${newPrice.toStringAsFixed(2)}');
      log('   💰 Savings: \$${priceDifference.toStringAsFixed(2)}');
      log('   📊 Savings Percentage: ${savingsPercentage.toStringAsFixed(1)}%');

      // ✅ Check for minimum price difference (prevents $0.00 savings notifications)
      const minimumPriceDifference = 0.01; // $0.01 minimum difference
      if (priceDifference < minimumPriceDifference) {
        log('❌ Validation failed: Price difference too small');
        log('   Price Difference: \$${priceDifference.toStringAsFixed(2)}');
        log('   Minimum Required: \$${minimumPriceDifference.toStringAsFixed(2)}');
        log('   💡 Notification skipped - price change too small to notify');
        return false;
      }

      // ✅ Check for zero or negative prices
      if (oldPrice <= 0 || newPrice <= 0) {
        log('❌ Validation failed: Invalid price values (zero or negative)');
        log('   Old Price: \$${oldPrice.toStringAsFixed(2)}');
        log('   New Price: \$${newPrice.toStringAsFixed(2)}');
        log('   💡 Notification skipped - invalid price values');
        return false;
      }

      log('✅ All data validation checks passed');
      log('📊 Notification status: isNotificationSent = $isNotificationSent (0 = not sent, 1 = sent)');
      return true;
    } catch (e) {
      log('❌ Error during data validation: $e');
      return false;
    }
  }

  /// Auto-trigger notification
  Future<void> _autoTriggerNotification(Map<String, dynamic> data) async {
    try {
      log('Auto-triggering notification for product: ${data['product_name']}');

      // Store notification data in a queue system for multiple notifications
      await _addNotificationToQueue(data);

      // Update notification sent status to 1 (sent) via API
      await _updateNotificationSentStatus(data);

      log('✅ Auto-notification data stored successfully');
    } catch (e) {
      log('❌ Error in auto-trigger notification: $e');
    }
  }

  /// Add notification to queue system for multiple notifications
  Future<void> _addNotificationToQueue(Map<String, dynamic> data) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Get existing notifications queue
      final existingQueueJson = prefs.getString('notification_queue') ?? '[]';
      List<Map<String, dynamic>> notificationQueue = [];

      try {
        final existingQueue = json.decode(existingQueueJson) as List;
        notificationQueue = existingQueue.cast<Map<String, dynamic>>();
      } catch (e) {
        log('⚠️ Error parsing existing notification queue, starting fresh: $e');
        notificationQueue = [];
      }

      // Create new notification data
      final notificationData = {
        'product_name': data['product_name'] ?? '---',
        'old_price': data['OldPrice']?.toString() ?? '0.00',
        'new_price': data['NewPrice']?.toString() ?? '0.00',
        'product_id': data['product_id']?.toString() ?? '0',
        'product_image': data['product_image'] ?? '',
        'timestamp': data['DataNTime'] ?? DateTime.now().toIso8601String(),
        'added_at': DateTime.now().toIso8601String(),
      };

      // Check if this notification already exists in queue (avoid duplicates)
      final productId = data['product_id']?.toString() ?? '0';
      final existingIndex = notificationQueue
          .indexWhere((item) => item['product_id'] == productId);

      if (existingIndex >= 0) {
        log('🔄 Updating existing notification in queue for product: $productId');
        notificationQueue[existingIndex] = notificationData;
      } else {
        log('➕ Adding new notification to queue for product: $productId');
        notificationQueue.add(notificationData);
      }

      // Store updated queue
      await prefs.setString(
          'notification_queue', json.encode(notificationQueue));
      await prefs.setBool('auto_notification_triggered', true);
      await prefs.setInt('notification_queue_count', notificationQueue.length);

      log('✅ Notification added to queue successfully');
      log('📊 Total notifications in queue: ${notificationQueue.length}');
      log('🔍 Queue contents: ${notificationQueue.map((n) => n['product_name']).toList()}');
    } catch (e) {
      log('❌ Error adding notification to queue: $e');
    }
  }

  /// Get device ID
  Future<void> _getDeviceId() async {
    if (_deviceId != null) return;

    try {
      DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();

      if (Platform.isAndroid) {
        AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
        _deviceId = androidInfo.id;
        log('📱 Android Unique ID: $_deviceId');
      } else if (Platform.isIOS) {
        IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
        _deviceId = iosInfo.identifierForVendor;
        log('📱 iOS Unique ID: $_deviceId');
      }
    } catch (e) {
      log('❌ Error getting device ID: $e');
    }
  }

  /// Update notification sent status via API
  Future<void> _updateNotificationSentStatus(
      Map<String, dynamic> notificationData) async {
    try {
      final productId =
          int.tryParse(notificationData['product_id']?.toString() ?? '0') ?? 0;
      final emailId = _userEmail ?? '';
      final deviceId = _deviceId ?? '';

      if (productId > 0) {
        log('🔄 Updating notification sent status for product: $productId');
        log('📧 User email: $emailId');
        log('📱 Device token: $deviceId');

        // LOGIN CASE: Pass only email, device token should be empty
        // LOGGED OUT CASE: Pass only device token, email should be empty
        String finalEmailId = '';
        String finalDeviceId = '';

        if (_userEmail != null && _userEmail!.isNotEmpty) {
          // LOGIN CASE: Only pass email
          finalEmailId = emailId;
          finalDeviceId = ''; // Empty device token for login case
          log('🔐 LOGIN CASE: Passing only email, device token will be empty');
        } else {
          // LOGGED OUT CASE: Only pass device token
          finalEmailId = ''; // Empty email for logged out case
          finalDeviceId = deviceId;
          log('🔓 LOGGED OUT CASE: Passing only device token, email will be empty');
        }

        await BrandsApi.updateSentNotificationStatus(
          emailId: finalEmailId,
          deviceID: finalDeviceId,
          productId: productId,
          isNotificationSent: 1, // Set to 1 (sent)
        );

        log('✅ Notification sent status updated successfully for product: $productId');
        log('📤 API called with - Email: "$finalEmailId", Device Token: "$finalDeviceId"');
      } else {
        log('⚠️ Cannot update notification status - missing product ID');
        log('   Product ID: $productId');
      }
    } catch (e) {
      log('❌ Error updating notification sent status: $e');
    }
  }

  /// Get user email from Firebase Auth
  Future<void> _getUserEmail() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null && user.email != null && user.email!.isNotEmpty) {
        _userEmail = user.email;
        log('✅ User email: $_userEmail');
      } else {
        _userEmail = null;
        log('❌ No authenticated user found');
      }
    } catch (e) {
      log('❌ Error getting user email: $e');
      _userEmail = null;
    }
  }

  /// Dispose resources
  void dispose() {
    stopAutoNotificationChecking();
    _context = null;
    _isInitialized = false;
    log('🔄 AppNotificationService disposed');
  }
}

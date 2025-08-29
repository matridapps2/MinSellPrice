import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:minsellprice/services/notification_service.dart';
import 'package:minsellprice/services/work_manager_service.dart';
import 'package:minsellprice/core/utils/toast_messages/common_toasts.dart';
import 'package:minsellprice/core/apis/apis_calls.dart';
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
      final notificationData =
          await WorkManagerService.checkAutoTriggeredNotification();

      if (notificationData != null && _context != null && _context!.mounted) {
        log('✅ Auto-notification found: $notificationData');
        await _showAutoNotification(notificationData);
        await WorkManagerService.clearAutoTriggeredNotification();
      } else {
        log('❌ No auto-notifications found');
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

      if (_context != null && _context!.mounted) {
        CommonToasts.centeredMobile(
          context: _context!,
          msg: '🚨 Price drop detected! Notification sent automatically!',
        );
      }

      log('✅ Auto-notification shown successfully');
    } catch (e) {
      log('❌ Error showing auto-notification: $e');
      if (_context != null && _context!.mounted) {
        CommonToasts.centeredMobile(
          context: _context!,
          msg: 'Error showing auto-notification: $e',
        );
      }
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
      // Wait a bit for the app to fully load
      await Future.delayed(const Duration(seconds: 3));

      // Make API call to check for notifications
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

      // Construct API URL based on authentication status
      String apiUrl;
      if (_userEmail != null && _userEmail!.isNotEmpty) {
        // LOGIN CASE: Pass only email to API (device token will be empty)
        apiUrl =
            'https://growth.matridtech.net/api/fetch-product-data?email=$_userEmail';
        log('✅ LOGIN CASE: Calling API with email only: $_userEmail');
        log('📋 API will return notifications for this user - we will filter for null device tokens');
        log('🔍 Response filtering: Only show notifications where device_token is null');
      } else if (_deviceId != null && _deviceId!.isNotEmpty) {
        // LOGGED OUT CASE: Pass only device token to API (email will be empty)
        apiUrl =
            'https://growth.matridtech.net/api/fetch-product-data?device_token=$_deviceId';
        log('✅ LOGGED OUT CASE: Calling API with device token only: $_deviceId');
        log('📋 API will return notifications for this device - showing response as-is');
      } else {
        log('❌ No email or device token available for API call');
        return;
      }

      log('🌐 Making API call to: $apiUrl');

      // Make the API call
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ).timeout(const Duration(seconds: 30));

      log('📥 API Response received');
      log('📊 Status: ${response.statusCode}');
      log('📏 Body length: ${response.body.length}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        log('✅ API call successful!');
        log('📊 Response type: ${data.runtimeType}');
        log('🔍 Response data: $data');

        // Process the data for notifications
        await _processApiDataForNotifications(data);

        log('✅ API data processing completed');
      } else {
        log('❌ API call failed with status: ${response.statusCode}');
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

      // ✅ NEW: Check if prices are actually different
      if (oldPrice == newPrice) {
        log('❌ Validation failed: Prices are the same - no price drop');
        log('   Old Price: \$${oldPrice.toStringAsFixed(2)}');
        log('   New Price: \$${newPrice.toStringAsFixed(2)}');
        log('   Price Difference: \$${(newPrice - oldPrice).toStringAsFixed(2)}');
        log('   💡 Notification skipped - no actual price change detected');
        return false;
      }

      // ✅ NEW: Check if it's actually a price drop (new price < old price)
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

      // ✅ NEW: Check for minimum price difference (optional - prevents tiny price changes)
      final minimumPriceDifference = 0.01; // $0.01 minimum difference
      if (priceDifference < minimumPriceDifference) {
        log('❌ Validation failed: Price difference too small');
        log('   Price Difference: \$${priceDifference.toStringAsFixed(2)}');
        log('   Minimum Required: \$${minimumPriceDifference.toStringAsFixed(2)}');
        log('   💡 Notification skipped - price change too small to notify');
        return false;
      }

      // ✅ NEW: Check for zero or negative prices
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

      // Store notification data for immediate UI consumption
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('auto_notification_triggered', true);
      await prefs.setString(
          'auto_notification_product_name', data['product_name'] ?? '---');
      await prefs.setString('auto_notification_old_price',
          data['OldPrice']?.toString() ?? '0.00');
      await prefs.setString('auto_notification_new_price',
          data['NewPrice']?.toString() ?? '0.00');
      await prefs.setString('auto_notification_product_id',
          data['product_id']?.toString() ?? '0');
      await prefs.setString(
          'auto_notification_product_image', data['product_image'] ?? '');
      await prefs.setString('auto_notification_timestamp',
          data['DataNTime'] ?? DateTime.now().toIso8601String());

      // Update notification sent status to 1 (sent) via API
      await _updateNotificationSentStatus(data);

      log('✅ Auto-notification data stored successfully');
    } catch (e) {
      log('❌ Error in auto-trigger notification: $e');
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

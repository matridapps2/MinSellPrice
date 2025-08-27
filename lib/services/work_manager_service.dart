import 'dart:developer';
import 'dart:convert';
import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:workmanager/workmanager.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class WorkManagerService {
  static const String _taskName = 'fetchProductDataTask';
  static const String _apiUrl =
      'https://growth.matridtech.net/api/fetch-product-data';

  // Initialize WorkManager
  static Future<void> initialize() async {
    try {
      await Workmanager().initialize(
        callbackDispatcher,
        isInDebugMode: true, // Set to false in production
      );
      log('WorkManager initialized successfully');
    } catch (e) {
      log('Error initializing WorkManager: $e');
    }
  }

  // Start periodic task
  static Future<void> startPeriodicTask() async {
    try {
      log('🚀 Starting WorkManager periodic task...');

      // Cancel any existing task first
      await Workmanager().cancelAll();
      log('✅ Cancelled existing tasks');

      // Try a different approach - use one-off tasks that reschedule themselves
      await Workmanager().registerOneOffTask(
        '${_taskName}_1',
        '${_taskName}_1',
        initialDelay: const Duration(seconds: 10), // Start after 10 seconds
        constraints: Constraints(
          networkType: NetworkType.connected,
          requiresBatteryNotLow: false,
          requiresCharging: false,
          requiresDeviceIdle: false,
          requiresStorageNotLow: false,
        ),
      );

      log('✅ One-off task registered - will run in 10 seconds and reschedule itself');

      log('✅ Periodic task registered successfully - will run every 15 minutes');
      log('⏰ First execution in 10 seconds, then every 15 minutes');

      // Manual testing tasks - commented out for production
      /*
      // Also register a one-time task to test immediately
      await Workmanager().registerOneOffTask(
        'testTask',
        'testTask',
        initialDelay: const Duration(seconds: 2), // Test in 2 seconds
      );
      log('🧪 Test task registered - will run in 2 seconds to verify execution');

      // Try a different approach - use constraints that might work better
      await Workmanager().registerOneOffTask(
        'immediateTask',
        'immediateTask',
        initialDelay: const Duration(seconds: 0), // Run immediately
        constraints: Constraints(
          networkType: NetworkType.connected,
          requiresBatteryNotLow: false,
          requiresCharging: false,
          requiresDeviceIdle: false,
          requiresStorageNotLow: false,
        ),
      );
      log('⚡ Immediate task registered with constraints - should run right now');

      // Also try a simple task without constraints
      await Workmanager().registerOneOffTask(
        'simpleTask',
        'simpleTask',
        initialDelay: const Duration(seconds: 1), // Run in 1 second
      );
      log('🔧 Simple task registered - will run in 1 second');
      */

      DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();

      String deviceToken = '';
      if (Platform.isAndroid) {
        AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
        deviceToken = androidInfo.id;
        log('✅ Work Android Unique ID: $deviceToken');
        log('📊 Device token length: ${deviceToken.length}');
      }
    } catch (e) {
      log('❌ Error registering periodic task: $e');
    }
  }

  // Stop periodic task
  static Future<void> stopPeriodicTask() async {
    try {
      await Workmanager().cancelAll();
      log('Periodic task stopped successfully');
    } catch (e) {
      log('Error stopping periodic task: $e');
    }
  }

  // Check if task is running
  static Future<bool> isTaskRunning() async {
    try {
      // This is a workaround since WorkManager doesn't provide a direct way to check
      // We'll use SharedPreferences to track the last execution time
      final prefs = await SharedPreferences.getInstance();
      final lastExecution = prefs.getInt('last_api_execution') ?? 0;
      final now = DateTime.now().millisecondsSinceEpoch;
      final difference = now - lastExecution;

      // If last execution was less than 5 minutes ago, task is likely running
      return difference < (5 * 60 * 1000);
    } catch (e) {
      log('Error checking task status: $e');
      return false;
    }
  }

  // Get last execution time
  static Future<DateTime?> getLastExecutionTime() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final lastExecution = prefs.getInt('last_api_execution') ?? 0;
      if (lastExecution > 0) {
        return DateTime.fromMillisecondsSinceEpoch(lastExecution);
      }
      return null;
    } catch (e) {
      log('Error getting last execution time: $e');
      return null;
    }
  }

  // Get next execution time
  static Future<DateTime?> getNextExecutionTime() async {
    try {
      final lastExecution = await getLastExecutionTime();
      if (lastExecution != null) {
        return lastExecution.add(const Duration(minutes: 5));
      }
      return null;
    } catch (e) {
      log('Error getting next execution time: $e');
      return null;
    }
  }

  // Check if there's pending notification data to handle
  static Future<Map<String, dynamic>?> checkPendingNotification() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final showNotification =
          prefs.getBool('show_price_drop_notification') ?? false;

      if (showNotification) {
        // Get all notification data
        final notificationData = {
          'product_name': prefs.getString('notification_product_name') ?? '---',
          'old_price': prefs.getString('notification_old_price') ?? '0.00',
          'new_price': prefs.getString('notification_new_price') ?? '0.00',
          'product_id': prefs.getString('notification_product_id') ?? '0',
          'product_image': prefs.getString('notification_product_image') ?? '',
          'timestamp': prefs.getString('notification_timestamp') ?? '',
        };

        log('Pending notification found: $notificationData');
        return notificationData;
      }

      return null;
    } catch (e) {
      log('Error checking pending notification: $e');
      return null;
    }
  }

  // Clear pending notification data after handling
  static Future<void> clearPendingNotification() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('show_price_drop_notification');
      await prefs.remove('notification_product_name');
      await prefs.remove('notification_old_price');
      await prefs.remove('notification_new_price');
      await prefs.remove('notification_product_id');
      await prefs.remove('notification_product_image');
      await prefs.remove('notification_timestamp');

      log('Pending notification data cleared successfully');
    } catch (e) {
      log('Error clearing pending notification: $e');
    }
  }

  // Auto-trigger notification when device token matches
  static Future<void> _autoTriggerNotification(
      Map<String, dynamic> data) async {
    try {
      log('Auto-triggering notification for product: ${data['product_name']}');

      // Store notification data for immediate UI consumption
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('auto_notification_triggered', true);
      await prefs.setString(
          'auto_notification_product_name', data['product_name'] ?? '---');
      await prefs.setString(
          'auto_notification_old_price',
          data['OldPrice']?.toString() ??
              '0.00'); // Fixed: OldPrice not old_price
      await prefs.setString(
          'auto_notification_new_price',
          data['NewPrice']?.toString() ??
              '0.00'); // Fixed: NewPrice not new_price
      await prefs.setString('auto_notification_product_id',
          data['product_id']?.toString() ?? '0');
      await prefs.setString(
          'auto_notification_product_image', data['product_image'] ?? '');
      await prefs.setString('auto_notification_timestamp',
          data['DataNTime'] ?? DateTime.now().toIso8601String());

      log('Auto-notification data stored successfully');
    } catch (e) {
      log('Error in auto-trigger notification: $e');
    }
  }

  // Check if auto-notification was triggered
  static Future<Map<String, dynamic>?> checkAutoTriggeredNotification() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final autoTriggered =
          prefs.getBool('auto_notification_triggered') ?? false;

      if (autoTriggered) {
        // Get all auto-notification data
        final notificationData = {
          'product_name':
              prefs.getString('auto_notification_product_name') ?? '---',
          'OldPrice': prefs.getString('auto_notification_old_price') ??
              '0.00', // Fixed: Return as OldPrice
          'NewPrice': prefs.getString('auto_notification_new_price') ??
              '0.00', // Fixed: Return as NewPrice
          'product_id': prefs.getString('auto_notification_product_id') ?? '0',
          'product_image':
              prefs.getString('auto_notification_product_image') ?? '',
          'timestamp': prefs.getString('auto_notification_timestamp') ?? '',
        };

        log('Auto-triggered notification found: $notificationData');
        return notificationData;
      }

      return null;
    } catch (e) {
      log('Error checking auto-triggered notification: $e');
      return null;
    }
  }

  // Clear auto-triggered notification data after handling
  static Future<void> clearAutoTriggeredNotification() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('auto_notification_triggered');
      await prefs.remove('auto_notification_product_name');
      await prefs.remove('auto_notification_old_price');
      await prefs.remove('auto_notification_new_price');
      await prefs.remove('auto_notification_product_id');
      await prefs.remove('auto_notification_product_image');
      await prefs.remove('auto_notification_timestamp');

      log('Auto-triggered notification data cleared successfully');
    } catch (e) {
      log('Error clearing auto-triggered notification: $e');
    }
  }

  // Process individual notification item
  static Future<void> _processNotificationItem(
      Map<String, dynamic> item, String? deviceToken, String? email) async {
    try {
      log('🔍 Processing notification item: ${item.keys.toList()}');

      // Check if this is a price drop notification
      if (item.containsKey('device_token') && item.containsKey('product_id')) {
        final responseDeviceToken = item['device_token'];
        final responseEmail = item['email'];

        log('🔍 Processing notification data:');
        log('   Response device token: $responseDeviceToken');
        log('   Response email: $responseEmail');
        log('   Current device token: $deviceToken');
        log('   Current user email: $email');
        log('   User login status: ${email != null && email.isNotEmpty ? "LOGGED IN" : "NOT LOGGED IN"}');

        bool shouldShowNotification = false;

        if (email != null && email.isNotEmpty) {
          // User is logged in - check email matches (device token can be anything)
          if (responseEmail == email) {
            shouldShowNotification = true;
            log('✅ User logged in - email matches (showing notification)');
          } else {
            log('❌ User logged in - notification conditions not met:');
            log('   Response email: $responseEmail, Current email: $email');
          }
        } else {
          // User is not logged in - check device token matches
          if (responseDeviceToken == deviceToken) {
            shouldShowNotification = true;
            log('✅ User not logged in - device token matches (showing notification)');
          } else {
            log('❌ User not logged in - device token does not match:');
            log('   Response device token: $responseDeviceToken');
            log('   Current device token: $deviceToken');
          }
        }

        if (shouldShowNotification) {
          log('🎉 NOTIFICATION APPROVED! Auto-triggering for product: ${item['product_name']}');
          log('📊 Notification details:');
          log('   Product: ${item['product_name']}');
          log('   Old Price: ${item['OldPrice']}');
          log('   New Price: ${item['NewPrice']}');
          log('   Product ID: ${item['product_id']}');

          // Check if data is not empty before showing notification
          bool isDataValid = WorkManagerService._validateNotificationData(item);

          if (isDataValid) {
            log('✅ Data validation passed - showing notification on device');

            // Auto-trigger notification when conditions are met
            await WorkManagerService._autoTriggerNotification(item);

            // Also store the notification data in SharedPreferences for UI handling
            final prefs = await SharedPreferences.getInstance();
            await prefs.setBool('show_price_drop_notification', true);
            await prefs.setString(
                'notification_product_name', item['product_name'] ?? '---');
            await prefs.setString('notification_old_price',
                item['OldPrice']?.toString() ?? '0.00');
            await prefs.setString('notification_new_price',
                item['NewPrice']?.toString() ?? '0.00');
            await prefs.setString('notification_product_id',
                item['product_id']?.toString() ?? '0');
            await prefs.setString(
                'notification_product_image', item['product_image'] ?? '');
            await prefs.setString('notification_timestamp',
                item['DataNTime'] ?? DateTime.now().toIso8601String());

            log('✅ Notification data stored successfully in SharedPreferences');
          } else {
            log('❌ Data validation failed - notification data is empty or invalid');
            log('⚠️ Skipping notification due to invalid data');
          }
        } else {
          log('❌ Notification conditions not met, skipping');
        }
      } else {
        log('❌ Invalid item format - missing required fields');
      }
    } catch (e) {
      log('❌ Error processing notification item: $e');
    }
  }

  // Validate notification data to ensure it's not empty
  static bool _validateNotificationData(Map<String, dynamic> data) {
    try {
      log('🔍 Validating notification data completeness...');

      // Check required fields exist and are not empty
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

      // Check if prices are valid numbers
      final oldPrice = double.tryParse(data['OldPrice']?.toString() ?? '');
      final newPrice = double.tryParse(data['NewPrice']?.toString() ?? '');

      if (oldPrice == null || newPrice == null) {
        log('❌ Validation failed: Invalid price format');
        log('   Old Price: ${data['OldPrice']} (parsed: $oldPrice)');
        log('   New Price: ${data['NewPrice']} (parsed: $newPrice)');
        return false;
      }

      // Check if prices are valid (but don't require price drop)
      log('✅ Prices are valid: Old Price: $oldPrice, New Price: $newPrice');
      log('📊 Price difference: ${newPrice - oldPrice}');

      // Check if product ID is valid
      final productId = int.tryParse(data['product_id']?.toString() ?? '');
      if (productId == null || productId <= 0) {
        log('❌ Validation failed: Invalid product ID: ${data['product_id']}');
        return false;
      }

      // Check if image URL is valid
      final imageUrl = data['product_image']?.toString() ?? '';
      if (imageUrl.isEmpty || !imageUrl.startsWith('http')) {
        log('❌ Validation failed: Invalid image URL: $imageUrl');
        return false;
      }

      log('✅ All data completeness checks passed:');
      log('   Product Name: ${data['product_name']}');
      log('   Old Price: $oldPrice');
      log('   New Price: $newPrice');
      log('   Product ID: $productId');
      log('   Image URL: $imageUrl');
      log('   📊 Data is complete and ready for notification');

      return true;
    } catch (e) {
      log('❌ Error during data validation: $e');
      return false;
    }
  }
}

// This function must be a top-level function
@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    try {
      log('🔄 WorkManager task started: $task');
      log('📱 Task input data: $inputData');

      // Check if this is our product data fetch task
      if (task == 'fetchProductDataTask') {
        log('🎯 Executing product data fetch task...');
        await _fetchProductData();
        log('✅ Product data fetch task completed');
      } else if (task == 'fetchProductDataTask_1') {
        log('🎯 Executing reschedulable product data fetch task...');
        await _fetchProductData();
        log('✅ Product data fetch task completed');

        // Reschedule the task for 15 minutes later
        await Workmanager().registerOneOffTask(
          'fetchProductDataTask_1',
          'fetchProductDataTask_1',
          initialDelay: const Duration(minutes: 15),
          constraints: Constraints(
            networkType: NetworkType.connected,
            requiresBatteryNotLow: false,
            requiresCharging: false,
            requiresDeviceIdle: false,
            requiresStorageNotLow: false,
          ),
        );
        log('🔄 Task rescheduled for 15 minutes from now');
      } else {
        log('⚠️ Unknown task type: $task');
      }

      log('✅ WorkManager task completed successfully: $task');
      return true;
    } catch (e) {
      log('❌ WorkManager task failed: $task, Error: $e');
      return false;
    }
  });
}

// Fetch product data from API
Future<void> _fetchProductData() async {
  try {
    log('🌐 Starting API fetch process...');
    String email = '';
    String deviceToken = '';

    // Get device token first (required for both scenarios)
    try {
      log('📱 Getting device token...');
      DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();

      if (Platform.isAndroid) {
        AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
        deviceToken = androidInfo.id;
        log('✅ Android Unique ID: $deviceToken');
        log('📊 Device token length: ${deviceToken.length}');
      } else if (Platform.isIOS) {
        IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
        deviceToken = iosInfo.identifierForVendor!;
        log('✅ iOS Unique ID: $deviceToken');
        log('📊 Device token length: ${deviceToken.length}');
      }

      if (deviceToken.isNotEmpty) {
        log('✅ Device token obtained successfully');
      } else {
        log('❌ Device token is null or empty');
      }
    } catch (e) {
      log('❌ Error getting device token: $e');
    }

    // Try to get email from Firebase Auth (only if user is logged in)
    try {
      log('🔐 Getting email from Firebase Auth...');
      final user = FirebaseAuth.instance.currentUser;
      if (user != null && user.email != null && user.email!.isNotEmpty) {
        email = user.email ?? '';
        log('✅ Email retrieved from Firebase Auth: $email');
      } else {
        log('⚠️ No user or email found in Firebase Auth');
        log('👤 User object: ${user?.email ?? 'null'}');
      }
    } catch (e) {
      log('❌ Error getting email from Firebase Auth: $e');
    }

    // Fallback to SharedPreferences if Firebase Auth fails
    if (email.isEmpty) {
      final prefs = await SharedPreferences.getInstance();
      email = prefs.getString('email_id') ?? '';
      if (email.isNotEmpty) {
        log('Email retrieved from SharedPreferences: $email');
      }
    }

    // Check if device token is available (required for API call)
    if (deviceToken.isEmpty) {
      log('No device token available, skipping API call');
      return;
    }

    // Construct API URL based on authentication status
    String apiUrl;
    if (email.isNotEmpty) {
      // User is logged in - pass only email
      apiUrl = '${WorkManagerService._apiUrl}?email=$email';
      log('✅ User logged in - calling API with email only: $email');
    } else {
      // User is not logged in - pass only device token
      apiUrl = '${WorkManagerService._apiUrl}?device_token=$deviceToken';
      log('✅ User not logged in - calling API with device token only: $deviceToken');
    }

    log('🌐 Fetching product data from: $apiUrl');
    log('📤 Making POST request...');

    // Make API call
    final response = await http.post(
      Uri.parse(apiUrl),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ).timeout(const Duration(seconds: 30));

    log('📥 API Response received');
    log('📊 Response status: ${response.statusCode}');
    log('📏 Response body length: ${response.body.length}');

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      log('✅ Product data fetched successfully: ${data.length} items');
      log('🔍 API Response Data: $data');
      log('📊 Response data type: ${data.runtimeType}');

      // Check if data is a list or single object
      if (data is List) {
        log('📋 Response is a List with ${data.length} items');
        for (int i = 0; i < data.length; i++) {
          log('📦 Item $i: ${data[i]}');
        }
      } else if (data is Map) {
        log('📋 Response is a Map with keys: ${data.keys.toList()}');
      } else {
        log('⚠️ Response is neither List nor Map: ${data.runtimeType}');
      }

      // Process API response based on authentication status
      if (data is List) {
        log('🔍 Processing List response with ${data.length} items');

        // Process each item in the list
        for (int i = 0; i < data.length; i++) {
          final item = data[i];
          log('📦 Processing item $i: $item');

          if (item is Map<String, dynamic>) {
            await WorkManagerService._processNotificationItem(
                item, deviceToken, email);
          } else {
            log('⚠️ Item $i is not a Map: ${item.runtimeType}');
          }
        }
      } else if (data is Map<String, dynamic>) {
        log('🔍 Processing single Map response: ${data.keys.toList()}');
        await WorkManagerService._processNotificationItem(
            data, deviceToken, email);
      } else {
        log('⚠️ Response is neither List nor Map, cannot process: ${data.runtimeType}');
      }

      // Store the fetched data in SharedPreferences for later use
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('last_fetched_product_data', response.body);

      // Update last execution time
      await prefs.setInt(
          'last_api_execution', DateTime.now().millisecondsSinceEpoch);

      // You can also store additional metadata
      await prefs.setString('last_api_response_status', 'success');
      await prefs.setString(
          'last_api_response_time', DateTime.now().toIso8601String());

      log('💾 API data stored in SharedPreferences');
      log('📊 Total items processed: ${data is List ? data.length : 1}');
      log('🔍 Check SharedPreferences for: last_fetched_product_data');
    } else {
      log('API call failed with status: ${response.statusCode}');
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('last_api_response_status', 'failed');
      await prefs.setString('last_api_error', 'HTTP ${response.statusCode}');
    }
  } catch (e) {
    log('❌ Error fetching product data: $e');
    log('❌ Stack trace: ${StackTrace.current}');

    // Store error information
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('last_api_response_status', 'error');
      await prefs.setString('last_api_error', e.toString());
      await prefs.setString(
          'last_api_error_time', DateTime.now().toIso8601String());
      log('💾 Error details stored in SharedPreferences');
    } catch (storageError) {
      log('❌ Failed to store error details: $storageError');
    }
  }
}

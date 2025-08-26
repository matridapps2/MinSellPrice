import 'dart:developer';
import 'dart:convert';
import 'package:workmanager/workmanager.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

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
      // Cancel any existing task first
      await Workmanager().cancelAll();

      // Register periodic task - every 15 minutes (minimum allowed by WorkManager)
      await Workmanager().registerPeriodicTask(
        _taskName,
        _taskName,
        frequency: const Duration(minutes: 15),
        constraints: Constraints(
          networkType: NetworkType.connected,
          requiresBatteryNotLow: false,
          requiresCharging: false,
          requiresDeviceIdle: false,
          requiresStorageNotLow: false,
        ),
        existingWorkPolicy: ExistingWorkPolicy.replace,
        initialDelay: const Duration(seconds: 10), // Start after 10 seconds
      );

      log('Periodic task registered successfully - will run every 15 minutes');
    } catch (e) {
      log('Error registering periodic task: $e');
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
}

// This function must be a top-level function
@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    try {
      log('WorkManager task started: $task');

      // Check if this is our product data fetch task
      if (task == 'fetchProductDataTask') {
        await _fetchProductData();
      }

      log('WorkManager task completed successfully: $task');
      return true;
    } catch (e) {
      log('WorkManager task failed: $task, Error: $e');
      return false;
    }
  });
}

// Fetch product data from API
Future<void> _fetchProductData() async {
  try {
    // Get email from SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    final email = prefs.getString('email_id');

    if (email == null || email.isEmpty) {
      log('No email found in SharedPreferences, skipping API call');
      return;
    }

    // Construct API URL with email
    final apiUrl = '${WorkManagerService._apiUrl}?email=$email';
    log('Fetching product data from: $apiUrl');

    // Make API call
    final response = await http.get(
      Uri.parse(apiUrl),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ).timeout(const Duration(seconds: 30));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      log('Product data fetched successfully: ${data.length} items');

      // Store the fetched data in SharedPreferences for later use
      await prefs.setString('last_fetched_product_data', response.body);

      // Update last execution time
      await prefs.setInt(
          'last_api_execution', DateTime.now().millisecondsSinceEpoch);

      // You can also store additional metadata
      await prefs.setString('last_api_response_status', 'success');
      await prefs.setString(
          'last_api_response_time', DateTime.now().toIso8601String());
    } else {
      log('API call failed with status: ${response.statusCode}');
      await prefs.setString('last_api_response_status', 'failed');
      await prefs.setString('last_api_error', 'HTTP ${response.statusCode}');
    }
  } catch (e) {
    log('Error fetching product data: $e');

    // Store error information
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('last_api_response_status', 'error');
    await prefs.setString('last_api_error', e.toString());
  }
}

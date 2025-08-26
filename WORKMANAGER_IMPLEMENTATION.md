# WorkManager Implementation Guide

This document explains how WorkManager is implemented in the MinSellPrice app to automatically hit the API every 5 minutes.

## 🎯 Overview

WorkManager is used to schedule and execute background tasks that need to run periodically. In this app, it's configured to:

- **API Endpoint**: `https://growth.matridtech.net/api/fetch-product-data?email={user_email}`
- **Frequency**: Every 5 minutes
- **Trigger**: Automatically starts when user logs in, stops when user logs out
- **Purpose**: Fetch product data in the background to keep the app updated

## 🏗️ Architecture

### 1. WorkManager Service (`lib/services/work_manager_service.dart`)

The core service that handles all WorkManager operations:

```dart
class WorkManagerService {
  static const String _taskName = 'fetchProductDataTask';
  static const String _apiUrl = 'https://growth.matridtech.net/api/fetch-product-data';
  
  // Initialize WorkManager
  static Future<void> initialize() async
  
  // Start periodic task (every 5 minutes)
  static Future<void> startPeriodicTask() async
  
  // Stop periodic task
  static Future<void> stopPeriodicTask() async
  
  // Check if task is running
  static Future<bool> isTaskRunning() async
  
  // Get execution times
  static Future<DateTime?> getLastExecutionTime() async
  static Future<DateTime?> getNextExecutionTime() async
}
```

### 2. Callback Dispatcher

A top-level function that handles task execution:

```dart
@pragma('vm:entry-point')
void callbackDispatcher() {
  WorkManager().executeTask((task, inputData) async {
    if (task == 'fetchProductDataTask') {
      await _fetchProductData();
    }
    return true;
  });
}
```

### 3. API Call Implementation

The actual API call logic:

```dart
Future<void> _fetchProductData() async {
  // Get email from SharedPreferences
  // Make HTTP GET request to the API
  // Store response and metadata
  // Handle errors gracefully
}
```

## 🚀 How It Works

### 1. **Initialization**
- WorkManager is initialized when the app starts
- Happens in `HomePage._initCall()` method

### 2. **User Login**
- When user logs in via Firebase Auth
- `_startWorkManagerTask()` is called
- Periodic task is registered to run every 5 minutes

### 3. **Background Execution**
- WorkManager runs the task in the background
- API call is made to fetch product data
- Results are stored in SharedPreferences
- Execution time is logged

### 4. **User Logout**
- When user logs out
- `_stopWorkManagerTask()` is called
- All scheduled tasks are cancelled

## 📱 UI Integration

### 1. **HomePage Status Indicator**
- Shows green "API Active" when running
- Shows orange "API Inactive" when stopped
- Tap to refresh status
- Only visible when user is logged in

### 2. **Dashboard Widget**
- Comprehensive status display
- Shows last/next execution times
- Start/Stop service buttons
- Real-time status updates

### 3. **Test Button**
- Blue "Test API" button for manual testing
- Useful for debugging and verification

## ⚙️ Configuration

### Task Constraints
```dart
constraints: Constraints(
  networkType: NetworkType.connected,    // Only when internet is available
  requiresBatteryNotLow: false,          // Don't require high battery
  requiresCharging: false,               // Don't require charging
  requiresDeviceIdle: false,             // Can run when device is active
  requiresStorageNotLow: false,          // Don't require high storage
),
```

### Task Policy
```dart
existingWorkPolicy: ExistingWorkPolicy.replace,  // Replace existing tasks
initialDelay: const Duration(seconds: 10),       // Start after 10 seconds
```

## 📊 Data Storage

### SharedPreferences Keys
- `last_api_execution`: Timestamp of last API call
- `last_fetched_product_data`: Raw API response
- `last_api_response_status`: Success/failed/error
- `last_api_response_time`: ISO timestamp of response
- `last_api_error`: Error details if any

### Data Retrieval
```dart
// Get last execution time
final lastExecution = await WorkManagerService.getLastExecutionTime();

// Get next execution time
final nextExecution = await WorkManagerService.getNextExecutionTime();

// Check if service is running
final isRunning = await WorkManagerService.isTaskRunning();
```

## 🔧 Usage Examples

### 1. **Start Service Manually**
```dart
await WorkManagerService.startPeriodicTask();
```

### 2. **Stop Service Manually**
```dart
await WorkManagerService.stopPeriodicTask();
```

### 3. **Check Service Status**
```dart
final isRunning = await WorkManagerService.isTaskRunning();
if (isRunning) {
  print('API service is active');
} else {
  print('API service is inactive');
}
```

### 4. **Get Execution History**
```dart
final lastExecution = await WorkManagerService.getLastExecutionTime();
final nextExecution = await WorkManagerService.getNextExecutionTime();

print('Last API call: $lastExecution');
print('Next API call: $nextExecution');
```

## 🐛 Troubleshooting

### Common Issues

#### 1. **Service Not Starting**
- Check if WorkManager is initialized
- Verify user is logged in
- Check logs for error messages
- Ensure device has internet connection

#### 2. **API Calls Not Working**
- Verify email is stored in SharedPreferences
- Check API endpoint accessibility
- Review network permissions
- Check logs for HTTP errors

#### 3. **Service Stopping Unexpectedly**
- Check battery optimization settings
- Verify app is not being killed by system
- Review WorkManager constraints
- Check device-specific limitations

### Debug Commands

#### Check Logs
```bash
flutter logs
```

#### Manual Test
- Tap the "Test API" button in HomePage
- Check console for manual test logs

#### Status Check
- Use the WorkManager status widget in Dashboard
- Refresh status to get latest information

## 📋 Best Practices

### 1. **Error Handling**
- Always wrap API calls in try-catch blocks
- Log errors for debugging
- Don't crash the app on API failures
- Implement retry logic if needed

### 2. **Resource Management**
- Cancel tasks when user logs out
- Don't start multiple instances
- Monitor battery and network usage
- Clean up resources properly

### 3. **User Experience**
- Show clear status indicators
- Provide manual control options
- Inform users about background activity
- Handle offline scenarios gracefully

## 🔮 Future Enhancements

### 1. **Smart Scheduling**
- Adjust frequency based on user activity
- Implement exponential backoff for failures
- Add user-configurable intervals
- Support different schedules for different users

### 2. **Advanced Monitoring**
- Track API response times
- Monitor success/failure rates
- Implement health checks
- Add performance metrics

### 3. **User Controls**
- Allow users to pause/resume service
- Provide execution history
- Show data usage statistics
- Customize notification preferences

## 📚 Additional Resources

- [WorkManager Flutter Plugin](https://pub.dev/packages/workmanager)
- [Android WorkManager Documentation](https://developer.android.com/topic/libraries/architecture/workmanager)
- [Background Processing Best Practices](https://developer.android.com/guide/background)
- [Flutter Background Execution](https://docs.flutter.dev/development/platform-integration/background-processing)

## 🎉 Summary

WorkManager provides a robust solution for periodic background API calls in your Flutter app. It automatically manages task scheduling, handles system constraints, and ensures reliable execution even when the app is in the background.

The implementation includes:
- ✅ Automatic start/stop based on user login status
- ✅ 5-minute periodic execution
- ✅ Comprehensive error handling
- ✅ User-friendly status indicators
- ✅ Manual control options
- ✅ Detailed logging and monitoring

This setup ensures your app stays updated with the latest product data while providing users with full visibility and control over the background service.

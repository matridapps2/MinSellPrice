# Notification System Implementation Guide

## Overview

This guide explains the new notification system that fixes the issues where notifications only showed when the app opened and API calls weren't running on screen changes. The new system ensures notifications work across all screens and properly handle app lifecycle states.

## Key Components

### 1. AppLifecycleService (`lib/services/app_lifecycle_service.dart`)

A global singleton service that manages app lifecycle and notifications across all screens.

**Features:**
- Monitors app foreground/background states using `WidgetsBindingObserver`
- Automatically checks for notifications when app resumes
- Manages context across different screens
- Provides periodic notification checking while app is in foreground

**Usage:**
```dart
// Initialize in main.dart (already done)
await AppLifecycleService().initialize();

// Set context when screen changes
AppLifecycleService().setCurrentContext(context);

// Force check for notifications
await AppLifecycleService().forceCheckForNotifications(context);
```

### 2. NotificationMixin (`lib/core/mixins/notification_mixin.dart`)

A mixin that can be added to any screen to automatically enable notification checking.

**Features:**
- Automatically checks for notifications when screen opens
- Updates context for the lifecycle service
- Provides manual notification checking methods
- Handles screen lifecycle properly

**Usage:**
```dart
class _MyScreenState extends State<MyScreen> with NotificationMixin {
  // The mixin automatically handles notification checking
  // No additional code needed!
  
  // Optional: Force check for notifications
  void checkNotifications() {
    forceCheckForNotifications();
  }
}
```

### 3. Updated AppNotificationService (`lib/services/app_notification_service.dart`)

Enhanced notification service with better context management and API handling.

**Key Improvements:**
- Better context handling with fallback to NavigationService
- Removed dependency on specific context being mounted
- Improved error handling and logging
- More reliable API calls

## Implementation Details

### App Lifecycle Management

The system now properly handles:

1. **App Open**: Notifications are checked immediately when app opens
2. **App Resume**: Notifications are checked when app comes to foreground
3. **Screen Changes**: Notifications are checked when any screen opens (if using NotificationMixin)
4. **Background**: Periodic checking stops when app goes to background

### Context Management

The system uses a multi-layered approach for context management:

1. **Primary**: Uses the context from the current screen
2. **Fallback**: Uses NavigationService's global context
3. **Safety**: Gracefully handles null contexts

### API Integration

The notification system integrates with the existing API:

- Uses `BrandsApi.fetchPriceAlertProduct()` for fetching notifications
- Handles both logged-in (email) and logged-out (device token) scenarios
- Properly processes API responses and shows notifications
- Updates notification status after showing

## How to Add Notifications to New Screens

### Method 1: Using NotificationMixin (Recommended)

```dart
import 'package:minsellprice/core/mixins/notification_mixin.dart';

class _MyScreenState extends State<MyScreen> with NotificationMixin {
  @override
  void initState() {
    super.initState();
    // NotificationMixin automatically handles notification checking
  }
  
  // Optional: Manual notification check
  void _checkForNotifications() {
    forceCheckForNotifications();
  }
}
```

### Method 2: Manual Integration

```dart
import 'package:minsellprice/services/app_lifecycle_service.dart';

class _MyScreenState extends State<MyScreen> {
  @override
  void initState() {
    super.initState();
    _checkForNotifications();
  }
  
  Future<void> _checkForNotifications() async {
    await AppLifecycleService().checkForNotificationsOnScreenOpen(context);
  }
}
```

## Configuration

### Notification Timing

- **Immediate**: When app opens or screen changes
- **Periodic**: Every 30 seconds while app is in foreground
- **Background**: Handled by WorkManager (existing system)

### API Calls

- **Frequency**: On every screen open and app resume
- **Fallback**: Uses existing WorkManager for background
- **Context**: Automatically managed with fallbacks

## Troubleshooting

### Common Issues

1. **Notifications not showing**: Check if NotificationMixin is added to the screen
2. **API calls failing**: Ensure context is available (system handles this automatically)
3. **Duplicate notifications**: System prevents duplicates using queue management

### Debug Logging

The system provides comprehensive logging:

- `🔄` - Lifecycle events
- `✅` - Success operations
- `❌` - Error conditions
- `🔍` - API calls and data processing
- `🚨` - Notification display

### Testing

To test the notification system:

1. **Screen Changes**: Navigate between screens and check logs
2. **App Lifecycle**: Minimize/restore app and check logs
3. **API Integration**: Monitor API calls in logs
4. **Notification Display**: Check if notifications appear correctly

## Migration from Old System

The new system is backward compatible:

1. **Existing Code**: No changes needed for existing screens
2. **New Screens**: Add NotificationMixin for automatic support
3. **API Calls**: Same API endpoints, improved handling
4. **WorkManager**: Still works for background notifications

## Best Practices

1. **Always use NotificationMixin** for new screens
2. **Don't manually call API** - let the system handle it
3. **Check logs** for debugging notification issues
4. **Test on different screens** to ensure proper context handling

## Files Modified

- `lib/services/app_lifecycle_service.dart` (new)
- `lib/core/mixins/notification_mixin.dart` (new)
- `lib/services/app_notification_service.dart` (updated)
- `lib/main.dart` (updated)
- `lib/widgets/bridge_class/bridge_class.dart` (updated)
- `lib/screens/home_page/home_page.dart` (updated)
- `lib/screens/home_page/notification_screen/notification_screen.dart` (updated)

## Summary

The new notification system provides:

✅ **Notifications on any screen open** (not just app open)
✅ **Proper API calls on screen changes**
✅ **Better context management**
✅ **App lifecycle awareness**
✅ **Easy integration with new screens**
✅ **Backward compatibility**
✅ **Comprehensive logging**

This system ensures users receive notifications regardless of which screen they're on, providing a much better user experience.

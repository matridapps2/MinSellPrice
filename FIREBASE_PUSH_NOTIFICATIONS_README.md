# Firebase Push Notifications Implementation

This document provides a comprehensive guide for the Firebase push notifications implementation in the MinSellPrice Flutter app.

## Overview

The Firebase push notification system has been implemented with the following features:

- **Local Notifications**: Stored on device, work offline
- **Firebase Cloud Messaging**: Push notifications via Firebase
- **Unified Notification Manager**: Centralized service for both types
- **Cloud Functions**: Server-side notification handling
- **Notification Settings**: User preference management
- **Test Interface**: Developer testing tools

## Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                    Notification System                      │
├─────────────────────────────────────────────────────────────┤
│  NotificationManager (Centralized Service)                 │
│  ├── NotificationService (Local Notifications)             │
│  ├── FirebasePushNotificationService (Firebase FCM)        │
│  └── NotificationApiService (Server Integration)           │
├─────────────────────────────────────────────────────────────┤
│  Cloud Functions (Firebase Functions)                      │
│  ├── sendPushNotification                                   │
│  ├── sendBulkPushNotification                              │
│  ├── sendTopicNotification                                  │
│  ├── subscribeToTopic                                       │
│  └── unsubscribeFromTopic                                  │
├─────────────────────────────────────────────────────────────┤
│  UI Components                                              │
│  ├── NotificationScreen (Existing Design)                  │
│  ├── NotificationSettingsScreen (New)                      │
│  └── NotificationTestScreen (New)                          │
└─────────────────────────────────────────────────────────────┘
```

## Features

### 1. Local Notifications
- **Price Drop Alerts**: Rich notifications with product images
- **Welcome Messages**: Confirmation when setting price alerts
- **General Notifications**: App updates and announcements
- **Offline Support**: Works without internet connection

### 2. Firebase Push Notifications
- **Cloud Messaging**: Real-time push notifications
- **Background Handling**: Notifications when app is closed
- **Foreground Handling**: Notifications when app is open
- **Terminated Handling**: Notifications when app is launched

### 3. Cloud Functions
- **Single Token**: Send to individual devices
- **Bulk Notifications**: Send to multiple devices
- **Topic Notifications**: Send to subscribed users
- **Topic Management**: Subscribe/unsubscribe from topics

### 4. Notification Types
- **Price Drop**: `type: 'price_drop'`
- **Welcome Alert**: `type: 'welcome_alert'`
- **General**: `type: 'general'`

## Setup Instructions

### 1. Firebase Configuration
The Firebase configuration is already set up in your project:
- `google-services.json` (Android)
- `firebase_app_id_file.json` (iOS)
- `firebase_options.dart` (Flutter)

### 2. Dependencies
Add the following dependency to `pubspec.yaml`:
```yaml
dependencies:
  cloud_functions: ^5.1.3
```

### 3. Deploy Cloud Functions
```bash
cd functions
npm install
firebase deploy --only functions
```

### 4. Android Configuration
The Android manifest is already configured with:
- `POST_NOTIFICATIONS` permission
- `VIBRATE` permission
- `WAKE_LOCK` permission
- `RECEIVE_BOOT_COMPLETED` permission
- Notification click handling

### 5. iOS Configuration
For iOS, ensure you have:
- Push notification capability enabled
- APNs certificates configured
- Background modes enabled

## Usage

### 1. Basic Usage

```dart
// Initialize notification manager
await NotificationManager().initialize();

// Send price drop notification
await NotificationManager().sendPriceDropNotification(
  productName: 'iPhone 15',
  oldPrice: '999.00',
  newPrice: 799.0,
  productId: 12345,
  productImage: 'https://example.com/image.jpg',
  sendLocal: true,
  sendFirebase: true,
);

// Send welcome notification
await NotificationManager().sendWelcomeNotification(
  productName: 'iPhone 15',
  productId: 12345,
  productImage: 'https://example.com/image.jpg',
  currentPrice: '999.00',
  sendLocal: true,
  sendFirebase: true,
);
```

### 2. Server Integration

```dart
// Send notification via API service
await NotificationApiService().sendPriceDropNotificationToServer(
  emailId: 'user@example.com',
  deviceToken: 'device_id',
  productName: 'iPhone 15',
  oldPrice: '999.00',
  newPrice: '799.00',
  productId: 12345,
  productImage: 'https://example.com/image.jpg',
);
```

### 3. Topic Management

```dart
// Subscribe to topic
await NotificationManager().subscribeToTopic('price_alerts');

// Send topic notification
await NotificationManager().sendTopicNotification(
  topic: 'price_alerts',
  title: 'New Price Alert',
  body: 'Check out the latest deals!',
  type: 'general',
);
```

## API Reference

### NotificationManager

#### Methods

- `initialize()`: Initialize the notification system
- `sendPriceDropNotification(...)`: Send price drop notification
- `sendWelcomeNotification(...)`: Send welcome notification
- `sendGeneralNotification(...)`: Send general notification
- `sendBulkNotification(...)`: Send bulk notifications
- `sendTopicNotification(...)`: Send topic-based notifications
- `subscribeToTopic(topic)`: Subscribe to topic
- `unsubscribeFromTopic(topic)`: Unsubscribe from topic
- `getCurrentFCMToken()`: Get current FCM token

### FirebasePushNotificationService

#### Methods

- `initialize()`: Initialize Firebase push notifications
- `sendPushNotification(...)`: Send single push notification
- `sendBulkPushNotification(...)`: Send bulk push notifications
- `sendTopicNotification(...)`: Send topic notification
- `subscribeToTopic(topic)`: Subscribe to topic
- `unsubscribeFromTopic(topic)`: Unsubscribe from topic

### Cloud Functions

#### Functions

- `sendPushNotification`: Send to single token
- `sendBulkPushNotification`: Send to multiple tokens
- `sendTopicNotification`: Send to topic subscribers
- `subscribeToTopic`: Subscribe user to topic
- `unsubscribeFromTopic`: Unsubscribe user from topic

## Testing

### 1. Notification Test Screen
Access the test screen to test different notification types:
- Price drop notifications
- Welcome notifications
- General notifications
- Local notifications only
- Firebase push notifications only

### 2. Notification Settings Screen
Manage notification preferences:
- Enable/disable notification types
- Configure delivery methods
- Test notification settings

### 3. Cloud Function Testing
Test Cloud Functions using Firebase Console or HTTP requests:

```bash
# Test single notification
curl -X POST https://your-region-your-project.cloudfunctions.net/sendPushNotification \
  -H "Content-Type: application/json" \
  -d '{
    "data": {
      "token": "your-fcm-token",
      "title": "Test Notification",
      "body": "This is a test",
      "type": "general"
    }
  }'
```

## Troubleshooting

### Common Issues

1. **Notifications not received**
   - Check FCM token is valid
   - Verify notification permissions
   - Check device network connection
   - Verify Cloud Functions are deployed

2. **Local notifications not showing**
   - Check notification permissions
   - Verify notification channels are created
   - Check if app is in foreground

3. **Firebase push notifications not working**
   - Verify FCM token is generated
   - Check Firebase configuration
   - Verify Cloud Functions are deployed
   - Check device network connection

### Debug Logs

Enable debug logging to troubleshoot issues:

```dart
// Enable Firebase debug logging
FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
  alert: true,
  badge: true,
  sound: true,
);
```

### Testing Checklist

- [ ] FCM token is generated
- [ ] Notification permissions are granted
- [ ] Cloud Functions are deployed
- [ ] Local notifications work
- [ ] Firebase push notifications work
- [ ] Background notifications work
- [ ] Foreground notifications work
- [ ] Notification clicks navigate correctly
- [ ] Topic subscriptions work
- [ ] Bulk notifications work

## Security Considerations

1. **FCM Token Security**: Store FCM tokens securely on your server
2. **API Keys**: Keep Firebase API keys secure
3. **User Privacy**: Respect user notification preferences
4. **Data Validation**: Validate all notification data before sending

## Performance Optimization

1. **Batch Notifications**: Use bulk notifications for multiple users
2. **Topic Subscriptions**: Use topics for targeted notifications
3. **Local Storage**: Cache notification preferences locally
4. **Error Handling**: Implement proper error handling and retry logic

## Future Enhancements

1. **Rich Notifications**: Add more interactive elements
2. **Scheduled Notifications**: Send notifications at specific times
3. **Notification Analytics**: Track notification performance
4. **A/B Testing**: Test different notification formats
5. **Personalization**: Customize notifications based on user behavior

## Support

For issues or questions:
1. Check the troubleshooting section
2. Review Firebase documentation
3. Check Flutter notification documentation
4. Contact the development team

## Changelog

### Version 1.0.0
- Initial implementation
- Local notifications
- Firebase push notifications
- Cloud Functions
- Notification settings
- Test interface

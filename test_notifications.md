# Manual Testing Guide for Firebase Push Notifications

## 🧪 **Testing Methods**

### 1. **Using the App Test Widget**

Add the `NotificationTestWidget` to any screen in your app:

```dart
import 'package:minsellprice/widgets/notification_test_widget.dart';

// Add this widget to any screen
NotificationTestWidget()
```

### 2. **Using the Test Screen**

Navigate to the test screen programmatically:

```dart
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => const NotificationTestScreen(),
  ),
);
```

### 3. **Using Firebase Console**

1. Go to [Firebase Console](https://console.firebase.google.com)
2. Select your project
3. Go to **Cloud Messaging**
4. Click **"Send your first message"**
5. Fill in the details:
   - **Notification title**: "Test from Console"
   - **Notification text**: "This is a test notification"
   - **Target**: Single device
   - **FCM registration token**: Get from app logs

### 4. **Using cURL Commands**

#### Test Single Notification
```bash
curl -X POST https://us-central1-msp-project-215c5.cloudfunctions.net/sendPushNotification \
  -H "Content-Type: application/json" \
  -d '{
    "data": {
      "token": "YOUR_FCM_TOKEN_HERE",
      "title": "Test Notification",
      "body": "This is a test notification",
      "type": "general"
    }
  }'
```

#### Test Price Drop Notification
```bash
curl -X POST https://us-central1-msp-project-215c5.cloudfunctions.net/sendPushNotification \
  -H "Content-Type: application/json" \
  -d '{
    "data": {
      "token": "YOUR_FCM_TOKEN_HERE",
      "title": "Price Drop Alert!",
      "body": "iPhone 15 price dropped from $999 to $799 - Save $200!",
      "type": "price_drop",
      "productId": "12345",
      "productName": "iPhone 15",
      "oldPrice": "999.00",
      "newPrice": "799.00",
      "productImage": "https://via.placeholder.com/300x300?text=iPhone+15",
      "savings": "200.00",
      "savingsPercentage": "20.0"
    }
  }'
```

#### Test Welcome Notification
```bash
curl -X POST https://us-central1-msp-project-215c5.cloudfunctions.net/sendPushNotification \
  -H "Content-Type: application/json" \
  -d '{
    "data": {
      "token": "YOUR_FCM_TOKEN_HERE",
      "title": "Welcome to Price Alerts! 🎉",
      "body": "You will be notified when prices drop for iPhone 15",
      "type": "welcome_alert",
      "productId": "12345",
      "productName": "iPhone 15",
      "productImage": "https://via.placeholder.com/300x300?text=iPhone+15"
    }
  }'
```

### 5. **Using Postman**

1. **Method**: POST
2. **URL**: `https://us-central1-msp-project-215c5.cloudfunctions.net/sendPushNotification`
3. **Headers**: 
   - `Content-Type: application/json`
4. **Body** (raw JSON):
```json
{
  "data": {
    "token": "YOUR_FCM_TOKEN_HERE",
    "title": "Test from Postman",
    "body": "This is a test notification from Postman",
    "type": "general"
  }
}
```

## 🔍 **Getting Your FCM Token**

### Method 1: From App Logs
1. Run your app
2. Check the console logs for:
   ```
   📱 FCM Token: YOUR_TOKEN_HERE
   ```

### Method 2: Programmatically
```dart
// Get FCM token
final token = await NotificationManager().getCurrentFCMToken();
print('FCM Token: $token');
```

### Method 3: From Test Screen
1. Navigate to `NotificationTestScreen`
2. The FCM token will be displayed in the "User Information" section

## 🧪 **Testing Checklist**

### Local Notifications
- [ ] App is in foreground
- [ ] Notification appears in notification panel
- [ ] Notification has correct title and body
- [ ] Notification has correct icon and color
- [ ] Tapping notification navigates correctly

### Firebase Push Notifications
- [ ] App is in background/closed
- [ ] Notification appears in system notification panel
- [ ] Notification has correct title and body
- [ ] Notification has correct icon and color
- [ ] Tapping notification opens app and navigates correctly

### Price Drop Notifications
- [ ] Rich notification with product image
- [ ] Shows old price, new price, and savings
- [ ] Correct styling and colors
- [ ] Navigation to product details works

### Welcome Notifications
- [ ] Welcome message appears
- [ ] Product information included
- [ ] Green color scheme
- [ ] Navigation works correctly

## 🐛 **Troubleshooting**

### Common Issues

1. **No notifications received**
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

### Debug Steps

1. **Check notification permissions**
   ```dart
   final status = await Permission.notification.status;
   print('Notification permission: $status');
   ```

2. **Check FCM token**
   ```dart
   final token = await FirebaseMessaging.instance.getToken();
   print('FCM Token: $token');
   ```

3. **Check notification system status**
   ```dart
   await NotificationUsageExamples.checkNotificationStatus();
   ```

4. **Check Cloud Functions logs**
   - Go to Firebase Console → Functions → Logs
   - Look for error messages

## 📱 **Testing on Different Devices**

### Android
- Test on different Android versions (API 21+)
- Test with different notification settings
- Test with app in different states (foreground, background, closed)

### iOS
- Test on different iOS versions
- Test with different notification settings
- Test with app in different states

## 🎯 **Test Scenarios**

### Scenario 1: Price Drop Alert
1. Set a price alert for a product
2. Simulate price drop
3. Verify notification is received
4. Check notification content and styling
5. Test navigation to product details

### Scenario 2: Welcome Message
1. Set a new price alert
2. Verify welcome notification is received
3. Check notification content and styling
4. Test navigation

### Scenario 3: General Notification
1. Send a general notification
2. Verify notification is received
3. Check notification content and styling
4. Test navigation

### Scenario 4: Bulk Notifications
1. Send notification to multiple devices
2. Verify all devices receive notification
3. Check notification content and styling

### Scenario 5: Topic Notifications
1. Subscribe to a topic
2. Send topic notification
3. Verify notification is received
4. Unsubscribe from topic
5. Verify no more notifications received

## 📊 **Expected Results**

### Local Notifications
- ✅ Appears in notification panel
- ✅ Correct title and body
- ✅ Correct icon and color
- ✅ Navigation works
- ✅ Works offline

### Firebase Push Notifications
- ✅ Appears in system notification panel
- ✅ Correct title and body
- ✅ Correct icon and color
- ✅ Navigation works
- ✅ Works when app is closed

### Price Drop Notifications
- ✅ Rich notification with image
- ✅ Shows price information
- ✅ Correct styling
- ✅ Navigation to product details

### Welcome Notifications
- ✅ Welcome message
- ✅ Product information
- ✅ Green color scheme
- ✅ Navigation works

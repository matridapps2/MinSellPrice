import 'dart:developer';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'package:minsellprice/services/navigation_service.dart';
import 'package:minsellprice/screens/dashboard_screen/notification_screen/notification_screen.dart';

class NotificationService {
  // Singleton pattern - ensures only one instance exists
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  // Track if notification service has been initialized
  bool _isInitialized = false;

  // Plugin instance for handling local notifications
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  // Store notification data for detailed view
  final Map<String, Map<String, dynamic>> _notificationData = {};

  // Getter to check if service is initialized
  bool get isInitialized => _isInitialized;

  // Main initialization method - sets up local notifications
  Future<void> initialize() async {
    if (_isInitialized) return; // Skip if already initialized

    try {
      // Setup local notification channels and permissions
      await _initializeLocalNotifications();
      _isInitialized = true;
      log('Local notification service initialized successfully');
    } catch (e) {
      log('Error initializing notification service: $e');
    }
  }

  // Setup notification channels and permissions for Android/iOS
  Future<void> _initializeLocalNotifications() async {
    // Android settings - uses app icon and requests permissions
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    // iOS settings - requests alert, badge, and sound permissions
    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    // Combine platform-specific settings
    const InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    // Initialize plugin with settings and tap handler
    await _localNotifications.initialize(initializationSettings,
        onDidReceiveNotificationResponse: _onNotificationTapped);
  }

  // Called when user taps on a notification
  void _onNotificationTapped(NotificationResponse response) {
    log('Notification tapped: ${response.payload}');
    // Extract payload data and handle navigation
    if (response.payload != null) {
      _handleNotificationNavigation({'data': response.payload});
    }
  }

  // Navigate to appropriate screen based on notification type
  void _handleNotificationNavigation(Map<String, dynamic> data) {
    // Log navigation attempt for debugging
    log('Navigate to notification screen: $data');

    // Extract notification data from payload
    final payload = data['data'] as String;
    final parts = payload.split('|');

    if (parts.isNotEmpty && parts[0].startsWith('product:')) {
      final productId = parts[0].replaceFirst('product:', '');
      final notificationType = parts.length > 1 ? parts[1] : '';
      final newPrice = parts.length > 2 ? parts[2] : '';

      log('Product notification tapped - ID: $productId, Type: $notificationType, New Price: $newPrice');

      // Navigate to notification screen with product details
      _navigateToNotificationScreen(productId, notificationType, newPrice);
    } else {
      // Use global navigation service to open notification screen
      final navigationService = NavigationService();
      navigationService.navigateToNotifications();
    }
  }

  // Navigate to notification screen with product details
  void _navigateToNotificationScreen(
      String productId, String notificationType, String newPrice) {
    // Get the global navigator key or context
    final context = NavigationService().navigatorKey.currentContext;
    if (context == null) {
      log('No context available for navigation to notification screen');
      return;
    }

    // Get stored notification data
    final notificationData = _notificationData[productId];
    final productName = notificationData?['productName'] ?? 'Unknown Product';
    final oldPrice = notificationData?['oldPrice'] ?? '0.00';
    final productImage = notificationData?['productImage'];
    final savings = notificationData?['savings'] ?? '0.00';
    final savingsPercentage = notificationData?['savingsPercentage'] ?? '0.0';

    // Create notification data for the screen
    final notificationInfo = {
      'id': productId,
      'title': 'Price Drop Alert!',
      'body':
          '$productName price dropped from \$$oldPrice to \$$newPrice - Save \$$savings!',
      'type': 'price_drop',
      'timestamp': DateTime.now(),
      'isRead': false,
      'productId': productId,
      'productName': productName,
      'oldPrice': oldPrice,
      'newPrice': newPrice,
      'productImage': productImage,
      'savings': savings,
      'savingsPercentage': savingsPercentage,
      'notificationType': notificationType,
    };

    // Navigate to notification screen
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            NotificationScreen(notificationData: notificationInfo),
      ),
    );
  }

  // Download network image to temporary file
  Future<String?> _downloadNetworkImage(String imageUrl) async {
    try {
      log('Downloading network image: $imageUrl');

      // Download the image
      final response = await http.get(Uri.parse(imageUrl));

      if (response.statusCode == 200) {
        // Get temporary directory
        final Directory tempDir = await getTemporaryDirectory();
        final String fileName =
            'notification_${DateTime.now().millisecondsSinceEpoch}.jpg';
        final String filePath = '${tempDir.path}/$fileName';

        // Write the image to temporary file
        final File file = File(filePath);
        await file.writeAsBytes(response.bodyBytes);

        log('Network image downloaded successfully: $filePath');
        return filePath;
      } else {
        log('Failed to download network image. Status code: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      log('Error downloading network image: $e');
      return null;
    }
  }

  // Convert asset path to file path for notifications
  Future<String?> _getAssetFilePath(String assetPath) async {
    try {
      // Check if it's already a file path
      if (File(assetPath).existsSync()) {
        return assetPath;
      }

      // If it's an asset path, convert it to a file path
      if (assetPath.startsWith('assets/')) {
        final ByteData data = await rootBundle.load(assetPath);
        final List<int> bytes = data.buffer.asUint8List();

        // Get temporary directory
        final Directory tempDir = await getTemporaryDirectory();
        final String fileName = assetPath.split('/').last;
        final String filePath = '${tempDir.path}/notification_$fileName';

        // Write the asset to temporary file
        final File file = File(filePath);
        await file.writeAsBytes(bytes);

        log('Asset converted to file path: $filePath');
        return filePath;
      }

      return null;
    } catch (e) {
      log('Error converting asset to file path: $e');
      return null;
    }
  }

  // Get image file path for notification (handles all image types)
  Future<String?> _getImageFilePath(String? imagePath) async {
    if (imagePath == null || imagePath.isEmpty) {
      return null;
    }

    try {
      // Handle network images
      if (imagePath.startsWith('http://') || imagePath.startsWith('https://')) {
        return await _downloadNetworkImage(imagePath);
      }

      // Handle asset images
      if (imagePath.startsWith('assets/')) {
        return await _getAssetFilePath(imagePath);
      }

      // Handle file paths
      if (File(imagePath).existsSync()) {
        return imagePath;
      }

      return null;
    } catch (e) {
      log('Error getting image file path: $e');
      return null;
    }
  }

  // Display a custom notification with title, body, and optional payload
  Future<void> showStaticNotification({
    required String title,
    required String body,
    String? payload,
    String? imageUrl,
  }) async {
    // Android notification channel settings with image support
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'static_notifications',
      'Static Notifications',
      channelDescription: 'Static in-app notifications with product images',
      importance: Importance.high,
      priority: Priority.high,
      showWhen: true,
      enableVibration: true,
      playSound: true,
      styleInformation: BigPictureStyleInformation(
        DrawableResourceAndroidBitmap('@mipmap/ic_launcher'),
        largeIcon: DrawableResourceAndroidBitmap('@mipmap/ic_launcher'),
        contentTitle: 'Price Drop Alert!',
        summaryText: 'Great deals waiting for you!',
        htmlFormatContentTitle: true,
        htmlFormatSummaryText: true,
      ),
    );

    // iOS notification settings with image support
    const DarwinNotificationDetails iOSPlatformChannelSpecifics =
        DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
      attachments: [],
    );

    // Combine platform settings
    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: iOSPlatformChannelSpecifics,
    );

    // Show notification with unique ID and payload
    await _localNotifications.show(
      DateTime.now().millisecondsSinceEpoch.remainder(100000),
      title,
      body,
      platformChannelSpecifics,
      payload: payload,
    );
  }

  // Show price drop notification with formatted price information and product image
  Future<void> showPriceDropNotification({
    required String productName,
    required String oldPrice,
    required double newPrice,
    required int productId,
    String? productImage,
  }) async {
    // Create formatted title and body with price details
    const title = 'Price Drop Alert!';
    final body =
        '$productName price dropped from \$${oldPrice} to \$${newPrice.toStringAsFixed(2)} - Save \$${(double.parse(oldPrice) - newPrice).toStringAsFixed(2)}!';

    // Create detailed notification with product image
    await _showDetailedPriceDropNotification(
      title: title,
      body: body,
      productName: productName,
      oldPrice: oldPrice,
      newPrice: newPrice,
      productId: productId,
      productImage: productImage,
    );
  }

  // Show detailed price drop notification with product image
  Future<void> _showDetailedPriceDropNotification({
    required String title,
    required String body,
    required String productName,
    required String oldPrice,
    required double newPrice,
    required int productId,
    String? productImage,
  }) async {
    try {
      // Calculate savings amount
      final savings = double.parse(oldPrice) - newPrice;
      final savingsPercentage =
          (savings / double.parse(oldPrice) * 100).toStringAsFixed(1);

      // Store notification data for detailed view
      _notificationData[productId.toString()] = {
        'productName': productName,
        'oldPrice': oldPrice,
        'newPrice': newPrice.toStringAsFixed(2),
        'productImage': productImage,
        'savings': savings.toStringAsFixed(2),
        'savingsPercentage': savingsPercentage,
      };

      // Get image file path - handles network, asset, and file images
      String? imageFilePath;
      if (productImage != null && productImage.isNotEmpty) {
        log('Processing product image: $productImage');
        imageFilePath = await _getImageFilePath(productImage);

        if (imageFilePath != null) {
          log('Image file path obtained: $imageFilePath');
        } else {
          log('Failed to get image file path, will use app icon');
        }
      }

      // Create rich notification content
      final richBody = '''
🔥 PRICE DROP ALERT! 🔥

Product: $productName
Old Price: \$${oldPrice}
New Price: \$${newPrice.toStringAsFixed(2)}
You Save: \$${savings.toStringAsFixed(2)} (${savingsPercentage}% off!)

Don't miss this amazing deal! Tap to view product details.
      ''';

      // Android notification with big picture style
      final AndroidNotificationDetails androidDetails =
          AndroidNotificationDetails(
        'price_drop_notifications',
        'Price Drop Alerts',
        channelDescription: 'Get notified when product prices drop',
        importance: Importance.high,
        priority: Priority.high,
        showWhen: true,
        enableVibration: true,
        playSound: true,
        styleInformation: BigPictureStyleInformation(
          // Use product image if available, otherwise use app icon
          imageFilePath != null
              ? FilePathAndroidBitmap(imageFilePath)
              : const DrawableResourceAndroidBitmap('@mipmap/ic_launcher'),
          largeIcon: imageFilePath != null
              ? FilePathAndroidBitmap(imageFilePath)
              : const DrawableResourceAndroidBitmap('@mipmap/ic_launcher'),
          contentTitle: 'Price Drop Alert!',
          summaryText: 'Save \$${savings.toStringAsFixed(2)} on $productName',
          htmlFormatContentTitle: true,
          htmlFormatSummaryText: true,
        ),
        category: AndroidNotificationCategory.promo,
        visibility: NotificationVisibility.public,
        color: const Color(0xFF2196F3), // Blue color for price alerts
        ledColor: const Color(0xFF2196F3),
        ledOnMs: 1000,
        ledOffMs: 500,
        enableLights: true,
        icon: '@mipmap/ic_launcher',
        largeIcon: imageFilePath != null
            ? FilePathAndroidBitmap(imageFilePath)
            : const DrawableResourceAndroidBitmap('@mipmap/ic_launcher'),
      );

      // iOS notification with rich content
      final DarwinNotificationDetails iOSDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
        categoryIdentifier: 'PRICE_DROP',
        threadIdentifier: 'price_alerts',
        attachments: imageFilePath != null
            ? [DarwinNotificationAttachment(imageFilePath)]
            : [],
        interruptionLevel: InterruptionLevel.active,
      );

      // Combine platform settings
      final NotificationDetails platformDetails = NotificationDetails(
        android: androidDetails,
        iOS: iOSDetails,
      );

      // Generate unique notification ID
      final notificationId =
          DateTime.now().millisecondsSinceEpoch.remainder(100000);

      // Show the notification
      await _localNotifications.show(
        notificationId,
        title,
        richBody,
        platformDetails,
        payload: 'product:$productId|price_drop|${newPrice.toStringAsFixed(2)}',
      );

      log('Price drop notification sent successfully for product: $productName');
      if (imageFilePath != null) {
        log('Notification includes product image: $imageFilePath');
      } else {
        log('Notification using app icon (no product image available)');
      }
    } catch (e) {
      log('Error showing price drop notification: $e');
      // Fallback to simple notification if detailed one fails
      await showStaticNotification(
        title: title,
        body: body,
        payload: 'product:$productId',
      );
    }
  }

  // Display welcome notification for new users
  Future<void> showWelcomeNotification() async {
    await showStaticNotification(
      title: 'Welcome to MinSellPrice! 👋',
      body: 'Start tracking prices and never miss a deal again!',
      payload: 'welcome',
    );
  }

  // Announce new app features to users
  Future<void> showFeatureAnnouncement({
    required String featureName,
    required String description,
  }) async {
    await showStaticNotification(
      title: 'New Feature: $featureName 🆕',
      body: description,
      payload: 'feature:$featureName',
    );
  }

  // Show reminder notifications for user engagement
  Future<void> showReminderNotification({
    required String title,
    required String message,
  }) async {
    await showStaticNotification(
      title: title,
      body: message,
      payload: 'reminder',
    );
  }

  // Remove all active notifications from the system
  Future<void> cancelAllNotifications() async {
    await _localNotifications.cancelAll();
  }

  // Remove a specific notification by its ID
  Future<void> cancelNotification(int id) async {
    await _localNotifications.cancel(id);
  }
}

import 'dart:developer';
import 'dart:io';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_database/firebase_database.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  String? _deviceToken;
  bool _isInitialized = false;
  final DatabaseReference _database = FirebaseDatabase.instance.ref();

  // Get device token
  String? get deviceToken => _deviceToken;
  bool get isInitialized => _isInitialized;

  // Initialize notification service
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // Request permission
      NotificationSettings settings =
          await FirebaseMessaging.instance.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );

      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        log('Notification permission granted');

        // Get device token
        _deviceToken = await FirebaseMessaging.instance.getToken();
        log('Device Token: $_deviceToken');

        // Save token to Firebase
        if (_deviceToken != null) {
          await saveTokenToFirebase(_deviceToken!);
        }

        // Setup message handlers
        _setupMessageHandlers();

        _isInitialized = true;
      } else {
        log('Notification permission denied');
      }
    } catch (e) {
      log('Error initializing notification service: $e');
    }
  }

  // Setup message handlers
  void _setupMessageHandlers() {
    // Handle foreground messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      log('Got a message whilst in the foreground!');
      log('Message data: ${message.data}');

      if (message.notification != null) {
        log('Message also contained a notification: ${message.notification}');
        // You can show a local notification here
        _showLocalNotification(message);
      }
    });

    // Handle when app is opened from notification
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      log('App opened from notification');
      // Navigate to specific screen based on message data
      if (message.data['productId'] != null) {
        // Navigate to product details
        log('Navigate to product: ${message.data['productId']}');
        _handleNotificationNavigation(message.data);
      }
    });
  }

  // Show local notification
  void _showLocalNotification(RemoteMessage message) {
    // You can implement local notification here using flutter_local_notifications
    log('Showing local notification: ${message.notification?.title}');
  }

  // Handle notification navigation
  void _handleNotificationNavigation(Map<String, dynamic> data) {
    // Implement navigation logic here
    log('Navigate to: $data');
  }

  // Save token to Firebase
  Future<void> saveTokenToFirebase(String token) async {
    try {
      await _database.child('deviceTokens').child(token).set({
        'token': token,
        'platform': Platform.isAndroid ? 'android' : 'ios',
        'appVersion': '1.0.0',
        'timestamp': ServerValue.timestamp,
      });
      log('Token saved to Firebase successfully');
    } catch (e) {
      log('Error saving token to Firebase: $e');
    }
  }

  // Subscribe to price alerts for a specific product
  Future<bool> subscribeToPriceAlert({
    required String productId,
    required double priceThreshold,
    required double currentPrice,
    required String productName,
    required String productImage,
    required String productMpn,
  }) async {
    if (_deviceToken == null) {
      log('Device token not available');
      return false;
    }

    try {
      // Create a unique key for this alert
      final alertKey = _database.child('priceAlerts').push().key;

      if (alertKey != null) {
        await _database.child('priceAlerts').child(alertKey).set({
          'deviceToken': _deviceToken,
          'productId': productId,
          'priceThreshold': priceThreshold,
          'currentPrice': currentPrice, // Store real current price
          'productName': productName,
          'productImage': productImage, // Store product image
          'productMpn': productMpn, // Store product MPN
          'platform': Platform.isAndroid ? 'android' : 'ios',
          'timestamp': ServerValue.timestamp,
          'isActive': true,
        });

        log('Price alert subscription successful');
        return true;
      } else {
        log('Failed to create alert key');
        return false;
      }
    } catch (e) {
      log('Error subscribing to price alert: $e');
      return false;
    }
  }

  // Unsubscribe from price alerts
  Future<bool> unsubscribeFromPriceAlert({
    required String productId,
  }) async {
    if (_deviceToken == null) {
      log('Device token not available');
      return false;
    }

    try {
      // Find and remove the alert
      final alertsRef = _database.child('priceAlerts');
      final snapshot = await alertsRef
          .orderByChild('deviceToken')
          .equalTo(_deviceToken)
          .get();

      if (snapshot.exists) {
        for (final child in snapshot.children) {
          final data = child.value as Map<dynamic, dynamic>;
          if (data['productId'] == productId) {
            await child.ref.remove();
            log('Price alert unsubscription successful');
            return true;
          }
        }
      }

      log('No matching alert found to unsubscribe');
      return false;
    } catch (e) {
      log('Error unsubscribing from price alert: $e');
      return false;
    }
  }

  // Get all subscribed price alerts
  Future<List<Map<String, dynamic>>> getSubscribedAlerts() async {
    if (_deviceToken == null) {
      log('Device token not available');
      return [];
    }

    try {
      final alertsRef = _database.child('priceAlerts');
      final snapshot = await alertsRef
          .orderByChild('deviceToken')
          .equalTo(_deviceToken)
          .get();

      final List<Map<String, dynamic>> alerts = [];

      if (snapshot.exists) {
        for (final child in snapshot.children) {
          final data = child.value as Map<dynamic, dynamic>;
          alerts.add({
            'alertId': child.key,
            'productId': data['productId'] ?? '',
            'productName': data['productName'] ?? '',
            'priceThreshold': data['priceThreshold'] ?? 0.0,
            'currentPrice': data['currentPrice'] ?? 0.0, // Added current price
            'productImage': data['productImage'] ?? '', // Added product image
            'productMpn': data['productMpn'] ?? '', // Added product MPN
            'isActive': data['isActive'] ?? true,
            'timestamp': data['timestamp'] ?? 0,
          });
        }
      }

      log('Retrieved ${alerts.length} price alerts');
      return alerts;
    } catch (e) {
      log('Error getting subscribed alerts: $e');
      return [];
    }
  }

  // Check if user is subscribed to a specific product
  Future<bool> isSubscribedToProduct(String productId) async {
    if (_deviceToken == null) {
      return false;
    }

    try {
      final alertsRef = _database.child('priceAlerts');
      final snapshot = await alertsRef
          .orderByChild('deviceToken')
          .equalTo(_deviceToken)
          .get();

      if (snapshot.exists) {
        for (final child in snapshot.children) {
          final data = child.value as Map<dynamic, dynamic>;
          if (data['productId'] == productId && data['isActive'] == true) {
            return true;
          }
        }
      }

      return false;
    } catch (e) {
      log('Error checking subscription status: $e');
      return false;
    }
  }
}

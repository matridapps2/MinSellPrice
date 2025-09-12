import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:minsellprice/core/utils/constants/colors.dart';
import 'package:minsellprice/core/utils/constants/size.dart';
import 'package:minsellprice/services/notification_manager.dart';
import 'package:minsellprice/services/notification_api_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'dart:io';

/// Notification Test Screen
/// Allows developers to test different types of notifications
class NotificationTestScreen extends StatefulWidget {
  const NotificationTestScreen({super.key});

  @override
  State<NotificationTestScreen> createState() => _NotificationTestScreenState();
}

class _NotificationTestScreenState extends State<NotificationTestScreen> {
  // Form controllers
  final _productNameController = TextEditingController(text: 'Test Product');
  final _oldPriceController = TextEditingController(text: '100.00');
  final _newPriceController = TextEditingController(text: '80.00');
  final _productIdController = TextEditingController(text: '12345');
  final _titleController = TextEditingController(text: 'Test Notification');
  final _bodyController =
      TextEditingController(text: 'This is a test notification');

  // User info
  String _emailId = '';
  String _deviceId = '';
  String _fcmToken = '';

  // Loading state
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _initializeUserInfo();
  }

  @override
  void dispose() {
    _productNameController.dispose();
    _oldPriceController.dispose();
    _newPriceController.dispose();
    _productIdController.dispose();
    _titleController.dispose();
    _bodyController.dispose();
    super.dispose();
  }

  /// Initialize user information
  Future<void> _initializeUserInfo() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Get email from Firebase Auth
      final user = FirebaseAuth.instance.currentUser;
      if (user != null && user.email != null) {
        _emailId = user.email!;
      }

      // Get device ID
      final deviceInfo = DeviceInfoPlugin();
      if (Platform.isAndroid) {
        final androidInfo = await deviceInfo.androidInfo;
        _deviceId = androidInfo.id;
      } else if (Platform.isIOS) {
        final iosInfo = await deviceInfo.iosInfo;
        _deviceId = iosInfo.identifierForVendor ?? '';
      }

      // Get FCM token
      _fcmToken = await NotificationManager().getCurrentFCMToken() ?? '';

      log('📱 User info initialized - Email: $_emailId, Device: $_deviceId, FCM: $_fcmToken');
    } catch (e) {
      log('❌ Error initializing user info: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  /// Test price drop notification
  Future<void> _testPriceDropNotification() async {
    try {
      log('📤 Testing price drop notification...');

      final success =
          await NotificationApiService().sendPriceDropNotificationToServer(
        emailId: _emailId,
        deviceToken: _deviceId,
        productName: _productNameController.text,
        oldPrice: _oldPriceController.text,
        newPrice: _newPriceController.text,
        productId: int.tryParse(_productIdController.text) ?? 0,
        productImage: 'https://via.placeholder.com/300x300?text=Test+Product',
        savings: (double.parse(_oldPriceController.text) -
                double.parse(_newPriceController.text))
            .toStringAsFixed(2),
        savingsPercentage: (((double.parse(_oldPriceController.text) -
                        double.parse(_newPriceController.text)) /
                    double.parse(_oldPriceController.text)) *
                100)
            .toStringAsFixed(1),
      );

      _showResult('Price Drop Notification', success);
    } catch (e) {
      log('❌ Error testing price drop notification: $e');
      _showResult('Price Drop Notification', false, error: e.toString());
    }
  }

  /// Test welcome notification
  Future<void> _testWelcomeNotification() async {
    try {
      log('📤 Testing welcome notification...');

      final success =
          await NotificationApiService().sendWelcomeNotificationToServer(
        emailId: _emailId,
        deviceToken: _deviceId,
        productName: _productNameController.text,
        productId: int.tryParse(_productIdController.text) ?? 0,
        productImage: 'https://via.placeholder.com/300x300?text=Test+Product',
        currentPrice: _newPriceController.text,
      );

      _showResult('Welcome Notification', success);
    } catch (e) {
      log('❌ Error testing welcome notification: $e');
      _showResult('Welcome Notification', false, error: e.toString());
    }
  }

  /// Test general notification
  Future<void> _testGeneralNotification() async {
    try {
      log('📤 Testing general notification...');

      final success =
          await NotificationApiService().sendGeneralNotificationToServer(
        emailId: _emailId,
        deviceToken: _deviceId,
        title: _titleController.text,
        body: _bodyController.text,
        imageUrl: 'https://via.placeholder.com/300x300?text=Test+Image',
      );

      _showResult('General Notification', success);
    } catch (e) {
      log('❌ Error testing general notification: $e');
      _showResult('General Notification', false, error: e.toString());
    }
  }

  /// Test local notification only
  Future<void> _testLocalNotification() async {
    try {
      log('📤 Testing local notification...');

      final success = await NotificationManager().sendGeneralNotification(
        title: _titleController.text,
        body: _bodyController.text,
        sendLocal: true,
        sendFirebase: false,
      );

      _showResult('Local Notification', success);
    } catch (e) {
      log('❌ Error testing local notification: $e');
      _showResult('Local Notification', false, error: e.toString());
    }
  }

  /// Test Firebase push notification only
  Future<void> _testFirebaseNotification() async {
    try {
      log('📤 Testing Firebase push notification...');

      final success = await NotificationManager().sendGeneralNotification(
        title: _titleController.text,
        body: _bodyController.text,
        firebaseToken: _fcmToken,
        sendLocal: false,
        sendFirebase: true,
      );

      _showResult('Firebase Push Notification', success);
    } catch (e) {
      log('❌ Error testing Firebase push notification: $e');
      _showResult('Firebase Push Notification', false, error: e.toString());
    }
  }

  /// Show test result
  void _showResult(String testName, bool success, {String? error}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success
              ? '$testName sent successfully!'
              : 'Failed to send $testName${error != null ? ': $error' : ''}',
        ),
        backgroundColor: success ? Colors.green : Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 245, 245, 245),
      appBar: AppBar(
        toolbarHeight: h * 0.12,
        backgroundColor: AppColors.primary,
        elevation: 0,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(20),
          ),
        ),
        leading: Container(
          margin: const EdgeInsets.only(left: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(5),
          ),
          child: IconButton(
            icon: const Icon(
              Icons.arrow_back_ios_rounded,
              color: Colors.white,
              size: 20,
            ),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        title: const Text(
          'Notification Test',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            letterSpacing: 0.5,
          ),
        ),
      ),
      body: _isLoading
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(
                    color: AppColors.primary,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Loading user information...',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // User Info Section
                  _buildSectionHeader('User Information'),
                  const SizedBox(height: 16),

                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.1),
                          spreadRadius: 1,
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildInfoRow('Email ID',
                            _emailId.isEmpty ? 'Not logged in' : _emailId),
                        _buildInfoRow('Device ID',
                            _deviceId.isEmpty ? 'Unknown' : _deviceId),
                        _buildInfoRow(
                            'FCM Token',
                            _fcmToken.isEmpty
                                ? 'Not available'
                                : '${_fcmToken.substring(0, 20)}...'),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Product Info Section
                  _buildSectionHeader('Product Information'),
                  const SizedBox(height: 16),

                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.1),
                          spreadRadius: 1,
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        TextField(
                          controller: _productNameController,
                          decoration: const InputDecoration(
                            labelText: 'Product Name',
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _oldPriceController,
                                decoration: const InputDecoration(
                                  labelText: 'Old Price',
                                  border: OutlineInputBorder(),
                                  prefixText: '\$',
                                ),
                                keyboardType: TextInputType.number,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: TextField(
                                controller: _newPriceController,
                                decoration: const InputDecoration(
                                  labelText: 'New Price',
                                  border: OutlineInputBorder(),
                                  prefixText: '\$',
                                ),
                                keyboardType: TextInputType.number,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: _productIdController,
                          decoration: const InputDecoration(
                            labelText: 'Product ID',
                            border: OutlineInputBorder(),
                          ),
                          keyboardType: TextInputType.number,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Notification Content Section
                  _buildSectionHeader('Notification Content'),
                  const SizedBox(height: 16),

                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.1),
                          spreadRadius: 1,
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        TextField(
                          controller: _titleController,
                          decoration: const InputDecoration(
                            labelText: 'Notification Title',
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: _bodyController,
                          decoration: const InputDecoration(
                            labelText: 'Notification Body',
                            border: OutlineInputBorder(),
                          ),
                          maxLines: 3,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Test Buttons Section
                  _buildSectionHeader('Test Notifications'),
                  const SizedBox(height: 16),

                  // Price Drop Test
                  _buildTestButton(
                    title: 'Test Price Drop Notification',
                    subtitle:
                        'Send a price drop notification with product details',
                    icon: Icons.trending_down,
                    color: Colors.red,
                    onPressed: _testPriceDropNotification,
                  ),

                  const SizedBox(height: 12),

                  // Welcome Test
                  _buildTestButton(
                    title: 'Test Welcome Notification',
                    subtitle: 'Send a welcome notification for price alerts',
                    icon: Icons.waving_hand,
                    color: Colors.green,
                    onPressed: _testWelcomeNotification,
                  ),

                  const SizedBox(height: 12),

                  // General Test
                  _buildTestButton(
                    title: 'Test General Notification',
                    subtitle: 'Send a general notification with custom content',
                    icon: Icons.notifications,
                    color: Colors.blue,
                    onPressed: _testGeneralNotification,
                  ),

                  const SizedBox(height: 24),

                  // Individual Service Tests
                  _buildSectionHeader('Individual Service Tests'),
                  const SizedBox(height: 16),

                  Row(
                    children: [
                      Expanded(
                        child: _buildTestButton(
                          title: 'Test Local Only',
                          subtitle: 'Send local notification only',
                          icon: Icons.phone_android,
                          color: Colors.purple,
                          onPressed: _testLocalNotification,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildTestButton(
                          title: 'Test Firebase Only',
                          subtitle: 'Send Firebase push only',
                          icon: Icons.cloud,
                          color: Colors.orange,
                          onPressed: _testFirebaseNotification,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 32),
                ],
              ),
            ),
    );
  }

  /// Build section header
  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: Colors.black87,
      ),
    );
  }

  /// Build info row
  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Build test button
  Widget _buildTestButton({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onPressed,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    icon,
                    color: color,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: Colors.grey[400],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

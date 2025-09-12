import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:minsellprice/core/utils/constants/colors.dart';
import 'package:minsellprice/core/utils/constants/size.dart';
import 'package:minsellprice/services/notification_manager.dart';
import 'package:minsellprice/services/notification_api_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'dart:io';

/// Notification Settings Screen
/// Allows users to manage their notification preferences
class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  State<NotificationSettingsScreen> createState() =>
      _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState
    extends State<NotificationSettingsScreen> {
  // Notification preferences
  bool _priceDropNotifications = true;
  bool _welcomeNotifications = true;
  bool _generalNotifications = true;
  bool _pushNotifications = true;
  bool _localNotifications = true;

  // User info
  String _emailId = '';
  String _deviceId = '';

  // Loading state
  bool _isLoading = false;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _initializeUserInfo();
    _loadNotificationPreferences();
  }

  /// Initialize user information
  Future<void> _initializeUserInfo() async {
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

      log('📱 User info initialized - Email: $_emailId, Device: $_deviceId');
    } catch (e) {
      log('❌ Error initializing user info: $e');
    }
  }

  /// Load notification preferences
  Future<void> _loadNotificationPreferences() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Here you can load preferences from server or local storage
      // For now, we'll use default values
      log('📤 Loading notification preferences...');

      // Simulate loading delay
      await Future.delayed(const Duration(seconds: 1));

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      log('❌ Error loading notification preferences: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  /// Save notification preferences
  Future<void> _saveNotificationPreferences() async {
    setState(() {
      _isSaving = true;
    });

    try {
      log('📤 Saving notification preferences...');

      final preferences = {
        'priceDropNotifications': _priceDropNotifications,
        'welcomeNotifications': _welcomeNotifications,
        'generalNotifications': _generalNotifications,
        'pushNotifications': _pushNotifications,
        'localNotifications': _localNotifications,
      };

      // Save to server
      final success =
          await NotificationApiService().updateNotificationPreferences(
        emailId: _emailId,
        deviceToken: _deviceId,
        preferences: preferences,
      );

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Notification preferences saved successfully'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to save notification preferences'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      log('❌ Error saving notification preferences: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error saving preferences: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isSaving = false;
      });
    }
  }

  /// Test notification
  Future<void> _testNotification() async {
    try {
      log('📤 Testing notification...');

      final success = await NotificationManager().sendGeneralNotification(
        title: 'Test Notification',
        body: 'This is a test notification to verify your settings',
        sendLocal: _localNotifications,
        sendFirebase: _pushNotifications,
      );

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Test notification sent successfully'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to send test notification'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      log('❌ Error testing notification: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error testing notification: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
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
          'Notification Settings',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            letterSpacing: 0.5,
          ),
        ),
        actions: [
          if (!_isLoading)
            Container(
              margin: const EdgeInsets.only(right: 16),
              child: TextButton(
                onPressed: _isSaving ? null : _saveNotificationPreferences,
                child: _isSaving
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Text(
                        'Save',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
        ],
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
                    'Loading notification preferences...',
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
                  // Notification Types Section
                  _buildSectionHeader('Notification Types'),
                  const SizedBox(height: 16),

                  _buildNotificationTile(
                    title: 'Price Drop Alerts',
                    subtitle: 'Get notified when product prices drop',
                    value: _priceDropNotifications,
                    onChanged: (value) {
                      setState(() {
                        _priceDropNotifications = value;
                      });
                    },
                    icon: Icons.trending_down,
                    color: Colors.red,
                  ),

                  _buildNotificationTile(
                    title: 'Welcome Messages',
                    subtitle:
                        'Get welcome notifications when setting price alerts',
                    value: _welcomeNotifications,
                    onChanged: (value) {
                      setState(() {
                        _welcomeNotifications = value;
                      });
                    },
                    icon: Icons.waving_hand,
                    color: Colors.green,
                  ),

                  _buildNotificationTile(
                    title: 'General Notifications',
                    subtitle: 'Get general app notifications and updates',
                    value: _generalNotifications,
                    onChanged: (value) {
                      setState(() {
                        _generalNotifications = value;
                      });
                    },
                    icon: Icons.notifications,
                    color: Colors.blue,
                  ),

                  const SizedBox(height: 24),

                  // Delivery Methods Section
                  _buildSectionHeader('Delivery Methods'),
                  const SizedBox(height: 16),

                  _buildNotificationTile(
                    title: 'Push Notifications',
                    subtitle:
                        'Receive notifications via Firebase Cloud Messaging',
                    value: _pushNotifications,
                    onChanged: (value) {
                      setState(() {
                        _pushNotifications = value;
                      });
                    },
                    icon: Icons.cloud,
                    color: Colors.orange,
                  ),

                  _buildNotificationTile(
                    title: 'Local Notifications',
                    subtitle:
                        'Receive notifications stored locally on your device',
                    value: _localNotifications,
                    onChanged: (value) {
                      setState(() {
                        _localNotifications = value;
                      });
                    },
                    icon: Icons.phone_android,
                    color: Colors.purple,
                  ),

                  const SizedBox(height: 24),

                  // Test Section
                  _buildSectionHeader('Test Notifications'),
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
                        const Text(
                          'Test Your Settings',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Send a test notification to verify your current settings',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: _testNotification,
                            icon: const Icon(Icons.send, size: 16),
                            label: const Text('Send Test Notification'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Info Section
                  _buildSectionHeader('About Notifications'),
                  const SizedBox(height: 16),

                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.blue[50],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.blue[200]!),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.info_outline,
                              color: Colors.blue[700],
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Notification Information',
                              style: TextStyle(
                                color: Colors.blue[700],
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          '• Price drop alerts help you save money by notifying you when products you\'re watching go on sale\n'
                          '• Welcome messages confirm when you\'ve successfully set up price alerts\n'
                          '• General notifications keep you updated with app news and features\n'
                          '• Push notifications work even when the app is closed\n'
                          '• Local notifications are stored on your device and work offline',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.black87,
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
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

  /// Build notification tile
  Widget _buildNotificationTile({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
      child: ListTile(
        leading: Container(
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
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: const TextStyle(
            fontSize: 14,
            color: Colors.grey,
          ),
        ),
        trailing: Switch(
          value: value,
          onChanged: onChanged,
          activeColor: AppColors.primary,
        ),
        onTap: () => onChanged(!value),
      ),
    );
  }
}

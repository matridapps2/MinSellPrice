import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:minsellprice/core/utils/constants/colors.dart';
import 'package:minsellprice/services/notification_manager.dart';
import 'package:minsellprice/services/notification_usage_examples.dart';

/// Notification Test Widget
/// A simple widget to test notifications manually
class NotificationTestWidget extends StatefulWidget {
  const NotificationTestWidget({super.key});

  @override
  State<NotificationTestWidget> createState() => _NotificationTestWidgetState();
}

class _NotificationTestWidgetState extends State<NotificationTestWidget> {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Container(
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
            '🧪 Test Notifications',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Test different types of notifications manually',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 16),

          // Test buttons
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildTestButton(
                'Test Local',
                Icons.phone_android,
                Colors.purple,
                _testLocalNotification,
              ),
              _buildTestButton(
                'Test Firebase',
                Icons.cloud,
                Colors.orange,
                _testFirebaseNotification,
              ),
              _buildTestButton(
                'Test Price Drop',
                Icons.trending_down,
                Colors.red,
                _testPriceDropNotification,
              ),
              _buildTestButton(
                'Test Welcome',
                Icons.waving_hand,
                Colors.green,
                _testWelcomeNotification,
              ),
              _buildTestButton(
                'Check Status',
                Icons.info,
                Colors.blue,
                _checkNotificationStatus,
              ),
            ],
          ),

          if (_isLoading) ...[
            const SizedBox(height: 16),
            const Center(
              child: CircularProgressIndicator(
                color: AppColors.primary,
                strokeWidth: 2,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTestButton(
    String label,
    IconData icon,
    Color color,
    VoidCallback onPressed,
  ) {
    return ElevatedButton.icon(
      onPressed: _isLoading ? null : onPressed,
      icon: Icon(icon, size: 16),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        elevation: 2,
      ),
    );
  }

  Future<void> _testLocalNotification() async {
    setState(() {
      _isLoading = true;
    });

    try {
      await NotificationManager().sendGeneralNotification(
        title: 'Test Local Notification',
        body:
            'This is a test local notification sent at ${DateTime.now().toString()}',
        sendLocal: true,
        sendFirebase: false,
      );

      _showResult('Local notification sent successfully!', true);
    } catch (e) {
      log('❌ Error testing local notification: $e');
      _showResult('Failed to send local notification: $e', false);
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _testFirebaseNotification() async {
    setState(() {
      _isLoading = true;
    });

    try {
      await NotificationManager().sendGeneralNotification(
        title: 'Test Firebase Notification',
        body:
            'This is a test Firebase push notification sent at ${DateTime.now().toString()}',
        sendLocal: false,
        sendFirebase: true,
      );

      _showResult('Firebase notification sent successfully!', true);
    } catch (e) {
      log('❌ Error testing Firebase notification: $e');
      _showResult('Failed to send Firebase notification: $e', false);
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _testPriceDropNotification() async {
    setState(() {
      _isLoading = true;
    });

    try {
      await NotificationUsageExamples.handlePriceDrop(
        productName: 'Test iPhone 15',
        oldPrice: '999.00',
        newPrice: '799.00',
        productId: 12345,
        productImage: 'https://via.placeholder.com/300x300?text=Test+Product',
      );

      _showResult('Price drop notification sent successfully!', true);
    } catch (e) {
      log('❌ Error testing price drop notification: $e');
      _showResult('Failed to send price drop notification: $e', false);
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _testWelcomeNotification() async {
    setState(() {
      _isLoading = true;
    });

    try {
      await NotificationUsageExamples.handlePriceAlertSet(
        productName: 'Test iPhone 15',
        productId: 12345,
        productImage: 'https://via.placeholder.com/300x300?text=Test+Product',
        currentPrice: '999.00',
      );

      _showResult('Welcome notification sent successfully!', true);
    } catch (e) {
      log('❌ Error testing welcome notification: $e');
      _showResult('Failed to send welcome notification: $e', false);
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _checkNotificationStatus() async {
    setState(() {
      _isLoading = true;
    });

    try {
      await NotificationUsageExamples.checkNotificationStatus();

      _showResult(
          'Notification status checked! Check console for details.', true);
    } catch (e) {
      log('❌ Error checking notification status: $e');
      _showResult('Failed to check notification status: $e', false);
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showResult(String message, bool success) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: success ? Colors.green : Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );
  }
}

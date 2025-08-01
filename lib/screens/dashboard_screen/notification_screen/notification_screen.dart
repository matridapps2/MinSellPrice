import 'package:flutter/material.dart';
import 'package:minsellprice/core/utils/constants/colors.dart';
import 'package:minsellprice/core/utils/constants/size.dart';

class NotificationScreen extends StatefulWidget {
  final Map<String, dynamic>? notificationData;

  const NotificationScreen({Key? key, this.notificationData}) : super(key: key);

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  List<Map<String, dynamic>> notifications = [
    {
      'id': '1',
      'title': 'Welcome to MinSellPrice',
      'body': 'Start tracking prices and never miss a deal again!',
      'type': 'welcome',
      'timestamp': DateTime.now(),
      'isRead': false,
    },
    // {
    //   'id': '2',
    //   'title': 'Price Drop Alert! 🎉',
    //   'body':
    //       'Weber Spirit II E-310 Gas Grill price dropped from \$449.99 to \$399.99',
    //   'type': 'price_drop',
    //   'timestamp': DateTime.now().subtract(const Duration(hours: 1)),
    //   'isRead': false,
    // },
    // {
    //   'id': '3',
    //   'title': 'New Feature: Smart Price Alerts 🆕',
    //   'body': 'Get intelligent price drop predictions and early alerts!',
    //   'type': 'feature',
    //   'timestamp': DateTime.now().subtract(const Duration(minutes: 30)),
    //   'isRead': true,
    // },
    // {
    //   'id': '4',
    //   'title': 'Special Offer! 🎁',
    //   'body': 'Limited time: 25% off on all outdoor grills. Hurry up!',
    //   'type': 'offer',
    //   'timestamp': DateTime.now().subtract(const Duration(minutes: 15)),
    //   'isRead': true,
    // },
  ];

  @override
  void initState() {
    super.initState();
    // Add the notification data if provided
    if (widget.notificationData != null) {
      notifications.insert(0, widget.notificationData!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 245, 245, 245),
      appBar: AppBar(
        title: const Text(
          'Notifications',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: AppColors.primary,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.clear_all, color: Colors.white),
            onPressed: () {
              setState(() {
                notifications.clear();
              });
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('All notifications cleared'),
                  backgroundColor: Colors.grey,
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Header with stats
          Container(
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${notifications.where((n) => !n['isRead']).length}',
                        style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const Text(
                        'Unread notifications',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.notifications_active,
                    color: Colors.white,
                    size: 32,
                  ),
                ),
              ],
            ),
          ),

          // Notifications list
          Expanded(
            child: notifications.isEmpty
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.notifications_none,
                          size: 64,
                          color: Colors.grey,
                        ),
                        SizedBox(height: 16),
                        Text(
                          'No notifications yet',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'You\'ll see your notifications here',
                          style: TextStyle(
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: notifications.length,
                    itemBuilder: (context, index) {
                      final notification = notifications[index];
                      return _buildNotificationCard(notification, index);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationCard(Map<String, dynamic> notification, int index) {
    final isUnread = !notification['isRead'];
    final type = notification['type'] as String;
    final timestamp = notification['timestamp'] as DateTime;
    final hasProductDetails = notification.containsKey('productImage');

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
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () {
            setState(() {
              notification['isRead'] = true;
            });
            _handleNotificationTap(notification);
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Notification icon
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: _getNotificationColor(type).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        _getNotificationIcon(type),
                        color: _getNotificationColor(type),
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),

                    // Notification content
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  notification['title'],
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: isUnread
                                        ? FontWeight.bold
                                        : FontWeight.w500,
                                    color: isUnread
                                        ? Colors.black87
                                        : Colors.black54,
                                  ),
                                ),
                              ),
                              if (isUnread)
                                Container(
                                  width: 8,
                                  height: 8,
                                  decoration: BoxDecoration(
                                    color: AppColors.primary,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            notification['body'],
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _formatTimestamp(timestamp),
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[500],
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Action button
                    IconButton(
                      icon: const Icon(Icons.more_vert, color: Colors.grey),
                      onPressed: () {
                        _showNotificationOptions(notification, index);
                      },
                    ),
                  ],
                ),

                // Product details section for price drop notifications
                if (hasProductDetails && type == 'price_drop') ...[
                  const SizedBox(height: 16),
                  _buildProductDetailsSection(notification),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProductDetailsSection(Map<String, dynamic> notification) {
    final productImage = notification['productImage'] as String?;
    final productName = notification['productName'] as String?;
    final oldPrice = notification['oldPrice'] as String?;
    final newPrice = notification['newPrice'] as String?;
    final savings = notification['savings'] as String?;
    final savingsPercentage = notification['savingsPercentage'] as String?;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.blue[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.trending_down,
                color: Colors.green[600],
                size: 16,
              ),
              const SizedBox(width: 8),
              Text(
                'Price Drop Details',
                style: TextStyle(
                  color: Colors.green[700],
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Product image and details row
          Row(
            children: [
              // Product image
              if (productImage != null && productImage.isNotEmpty)
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      productImage,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: Colors.grey[100],
                          child: Icon(
                            Icons.image,
                            color: Colors.grey[400],
                            size: 24,
                          ),
                        );
                      },
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Center(
                          child: CircularProgressIndicator(
                            value: loadingProgress.expectedTotalBytes != null
                                ? loadingProgress.cumulativeBytesLoaded /
                                    loadingProgress.expectedTotalBytes!
                                : null,
                            strokeWidth: 2,
                            color: AppColors.primary,
                          ),
                        );
                      },
                    ),
                  ),
                ),

              const SizedBox(width: 12),

              // Product details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (productName != null)
                      Text(
                        productName,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        if (oldPrice != null) ...[
                          Text(
                            '\$$oldPrice',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                              decoration: TextDecoration.lineThrough,
                            ),
                          ),
                          const SizedBox(width: 8),
                        ],
                        if (newPrice != null)
                          Text(
                            '\$$newPrice',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.green[700],
                            ),
                          ),
                      ],
                    ),
                    if (savings != null && savingsPercentage != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        'Save \$$savings (${savingsPercentage}% off)',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.green[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Action buttons
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    // Navigate to product details
                    _navigateToProductDetails(notification);
                  },
                  icon: const Icon(Icons.visibility, size: 16),
                  label: const Text('View Product'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    // Set price alert
                    _setPriceAlert(notification);
                  },
                  icon: const Icon(Icons.notifications, size: 16),
                  label: const Text('Set Alert'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _getNotificationColor(String type) {
    switch (type) {
      case 'welcome':
        return Colors.green;
      case 'price_drop':
        return Colors.red;
      case 'feature':
        return Colors.blue;
      case 'offer':
        return Colors.orange;
      default:
        return AppColors.primary;
    }
  }

  IconData _getNotificationIcon(String type) {
    switch (type) {
      case 'welcome':
        return Icons.waving_hand;
      case 'price_drop':
        return Icons.trending_down;
      case 'feature':
        return Icons.new_releases;
      case 'offer':
        return Icons.local_offer;
      default:
        return Icons.notifications;
    }
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }

  void _handleNotificationTap(Map<String, dynamic> notification) {
    final type = notification['type'] as String;

    switch (type) {
      case 'price_drop':
        // Show detailed product information
        _showProductDetailsDialog(notification);
        break;
      case 'offer':
        // Navigate to offers
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Navigate to offers section'),
            backgroundColor: Colors.orange,
          ),
        );
        break;
      default:
        // Show notification details
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Notification: ${notification['title']}'),
            backgroundColor: Colors.blue,
          ),
        );
    }
  }

  void _showProductDetailsDialog(Map<String, dynamic> notification) {
    final productName = notification['productName'] as String?;
    final oldPrice = notification['oldPrice'] as String?;
    final newPrice = notification['newPrice'] as String?;
    final productImage = notification['productImage'] as String?;
    final savings = notification['savings'] as String?;
    final savingsPercentage = notification['savingsPercentage'] as String?;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Price Drop Alert!'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (productImage != null && productImage.isNotEmpty)
              Container(
                width: double.infinity,
                height: 150,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    productImage,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: Colors.grey[100],
                        child: const Icon(
                          Icons.image,
                          color: Colors.grey,
                          size: 48,
                        ),
                      );
                    },
                  ),
                ),
              ),
            if (productName != null) ...[
              Text(
                productName,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
            ],
            if (oldPrice != null && newPrice != null) ...[
              Row(
                children: [
                  Text(
                    'Old Price: \$$oldPrice',
                    style: TextStyle(
                      decoration: TextDecoration.lineThrough,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Text(
                    'New Price: \$$newPrice',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
            ],
            if (savings != null && savingsPercentage != null)
              Text(
                'You Save: \$$savings (${savingsPercentage}% off)',
                style: const TextStyle(
                  color: Colors.green,
                  fontWeight: FontWeight.w500,
                ),
              ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _navigateToProductDetails(notification);
            },
            child: const Text('View Product'),
          ),
        ],
      ),
    );
  }

  void _navigateToProductDetails(Map<String, dynamic> notification) {
    final productId = notification['productId'];
    if (productId != null) {
      // Navigate to product details screen
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Navigate to product ID: $productId'),
          backgroundColor: Colors.green,
        ),
      );
      // TODO: Implement actual navigation to product details
    }
  }

  void _setPriceAlert(Map<String, dynamic> notification) {
    final productId = notification['productId'];
    if (productId != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Price alert set for product ID: $productId'),
          backgroundColor: Colors.blue,
        ),
      );
      // TODO: Implement actual price alert setting
    }
  }

  void _showNotificationOptions(Map<String, dynamic> notification, int index) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.mark_email_read),
              title: const Text('Mark as read'),
              onTap: () {
                setState(() {
                  notification['isRead'] = false;
                });
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete),
              title: const Text('Delete notification'),
              onTap: () {
                setState(() {
                  notifications.removeAt(index);
                });
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Notification deleted'),
                    backgroundColor: Colors.red,
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

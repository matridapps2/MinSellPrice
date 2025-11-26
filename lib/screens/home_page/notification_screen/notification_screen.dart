import 'dart:developer';
import 'dart:convert';
import 'dart:async';
import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:minsellprice/core/apis/apis_calls.dart';
import 'package:minsellprice/core/utils/constants/colors.dart';
import 'package:minsellprice/core/utils/constants/size.dart';
import 'package:minsellprice/model/saved_product_model.dart';
import 'package:minsellprice/screens/home_page/home_page.dart';
import 'package:minsellprice/screens/product_details_screen/product_details_screen.dart';
import 'package:minsellprice/core/mixins/notification_mixin.dart';


class NotificationScreen extends StatefulWidget {
  final Map<String, dynamic>? notificationData;

  const NotificationScreen({super.key, this.notificationData});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen>
    with NotificationMixin {
  List<Map<String, dynamic>> notifications = [];
  List<SavedProductModel> savedProducts = [];

  bool isLoading = false;
  bool isLoggedIn = false;

  String _deviceId = '';
  String emailId = '';

  @override
  void initState() {
    super.initState();
    _initCall();

    // // Listen to Firebase Auth state changes
    // _authStateSubscription =
    //     FirebaseAuth.instance.authStateChanges().listen((User? user) {
    //   if (mounted) {
    //     if (user != null && user.email != null) {
    //       setState(() {
    //         isLoggedIn = true;
    //         emailId = user.email!;
    //       });
    //       log('User Logged ?');
    //       _getProductData(emailId);
    //     } else {
    //       setState(() {
    //         isLoggedIn = false;
    //         emailId = '';
    //       });
    //       _getProductData(emailId);
    //     }
    //   }
    // });
  }

  StreamSubscription<User?>? _authStateSubscription;

  @override
  void dispose() {
    _authStateSubscription?.cancel();
    super.dispose();
  }

  void _initCall() async {
    await _getEmail();
    await _getDeviceId();
    await _getProductData();
  }

  Future<void> _getEmail() async {
    try {
      final User? currentUser = FirebaseAuth.instance.currentUser;

      if (currentUser != null && currentUser.email != null) {
        emailId = currentUser.email!;
        isLoggedIn = true;
        log('Email from Firebase Auth: $emailId');
        // await _getProductData(emailId);
      } else {
        // No user logged in
        isLoggedIn = false;
        emailId = '';
        log('No Firebase user found - user not logged in');
        setState(() {});
      }
    } catch (e) {
      log('Error getting email: $e');
      isLoggedIn = false;
      emailId = '';
      setState(() {});
    }
  }

  Future<void> _getDeviceId() async {
    try {
      DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();

      if (Platform.isAndroid) {
        AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
        _deviceId = androidInfo.id;
        log('📱 Notification Screen In Android Unique ID: $_deviceId');
      } else if (Platform.isIOS) {
        IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
        _deviceId = iosInfo.identifierForVendor!;
        log('📱 iOS Unique ID: $_deviceId');
      }
    } catch (e) {
      log('❌ Error getting device ID: $e');
    }
  }

  Future<void> _getProductData() async {
    setState(() {
      isLoading = true;
    });
    log('In Notification Screen');
    log('Device ID: $_deviceId');
    log('EmailId: $emailId');
    try {
      final response = await BrandsApi.fetchPriceAlertProduct(
          emailId: emailId, deviceToken: _deviceId, context: context);

      if (response != 'error') {
        log('API Response: $response');

        final List<dynamic> jsonData = json.decode(response);
        log('Parsed JSON data: $jsonData');

        final List<SavedProductModel> products =
            jsonData.map((item) => SavedProductModel.fromJson(item)).toList();

        savedProducts = [];
        notifications = [];

        setState(() {
          savedProducts = products;
          isLoading = false;
        });

        log('Loaded ${products.length} saved products');

        _convertSavedProductsToNotifications();
      } else {
        log('API returned error');
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      log('Error fetching saved product data: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  void _convertSavedProductsToNotifications() {
    final List<Map<String, dynamic>> priceDropNotifications =
        savedProducts.map((product) {
      return {
        'title': 'Price Drop Alert!',
        'type': 'price_drop',
        'timestamp': _parseDataNTime(product.DataNTime),
        'isRead': product.isRead == 1, // Convert to bool (false or true)
        'isReadInt': product.isRead, // Keep original int for API calls
        'productId': product.productId,
        'productName': product.productName,
        'productImage': product.productImage,
        'oldPrice': product.oldPrice,
        'newPrice': product.newPrice,
        'savings': product.formattedSavings,
        'savingsPercentage': product.formattedSavingsPercentage,
        'brand_key': product.brandKey,
        'product_mpn': product.productMPN,
        'emailId': product.email,
        'dataNTime': product.DataNTime,
      };
    }).toList();

    priceDropNotifications.sort((a, b) {
      final dateA = _parseDataNTime(a['dataNTime'] as String);
      final dateB = _parseDataNTime(b['dataNTime'] as String);
      return dateB.compareTo(dateA);
    });

    setState(() {
      notifications.addAll(priceDropNotifications);
    });

    log('Added ${priceDropNotifications.length} price drop notifications');
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
            //color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(5),
          ),
          child: IconButton(
              icon: const Icon(
                Icons.arrow_back_ios_rounded,
                color: Colors.white,
                size: 20,
              ),
              onPressed: () => Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const HomePage(),
                  ))),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Notifications',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: 0.5,
              ),
            ),
            if (!isLoading && isLoggedIn)
              Text(
                '${notifications.where((n) => !n['isRead']).length} unread',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.white.withOpacity(0.8),
                  fontWeight: FontWeight.w400,
                ),
              ),
          ],
        ),
        actions: [
          Visibility(
            visible: !isLoading,
            child: Container(
              margin: const EdgeInsets.only(right: 16),
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.white.withOpacity(0.2),
                  width: 1,
                ),
              ),
              child: Stack(
                children: [
                  const Icon(
                    Icons.notifications_rounded,
                    color: Colors.white,
                    size: 24,
                  ),
                  if (notifications.where((n) => !n['isRead']).isNotEmpty)
                    Positioned(
                      right: 0,
                      top: 0,
                      child: Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppColors.primary,
                            width: 1.5,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Header with stats
          // Container(
          //   padding: const EdgeInsets.all(20),
          //   decoration: const BoxDecoration(
          //     color: AppColors.primary,
          //     borderRadius: BorderRadius.only(
          //       bottomLeft: Radius.circular(20),
          //       bottomRight: Radius.circular(20),
          //     ),
          //   ),
          //   child: Row(
          //     children: [
          //       // Visibility(
          //       //   visible: !isLoading,
          //       //   child: Expanded(
          //       //     child: Column(
          //       //       crossAxisAlignment: CrossAxisAlignment.start,
          //       //       children: [
          //       //         Text(
          //       //           '${notifications.where((n) => !n['isRead']).length}',
          //       //           style: const TextStyle(
          //       //             fontSize: 32,
          //       //             fontWeight: FontWeight.bold,
          //       //             color: Colors.white,
          //       //           ),
          //       //         ),
          //       //         const Text(
          //       //           'Unread notifications',
          //       //           style: TextStyle(
          //       //             color: Colors.white70,
          //       //             fontSize: 16,
          //       //           ),
          //       //         ),
          //       //       ],
          //       //     ),
          //       //   ),
          //       // ),
          //       Spacer(),
          //       Container(
          //         padding: const EdgeInsets.all(12),
          //         decoration: BoxDecoration(
          //           color: Colors.white.withOpacity(0.2),
          //           borderRadius: BorderRadius.circular(12),
          //         ),
          //         child: const Icon(
          //           Icons.notifications_active,
          //           color: Colors.white,
          //           size: 32,
          //         ),
          //       ),
          //     ],
          //   ),
          // ),

          // Notifications list
          Expanded(
            child: isLoading
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(
                          color: AppColors.primary,
                        ),
                        SizedBox(height: 16),
                        Text(
                          'Loading your saved products...',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  )
                : notifications.isEmpty
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

  // !isLoggedIn
  // ? Constants.noLoginDesign(context, 'notification')

  Widget _buildNotificationCard(Map<String, dynamic> notification, int index) {
    final isUnread = !(notification['isRead'] as bool);
    final type = notification['type'] as String;
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
            // setState(() {
            //   notification['isRead'] = true;
            // });
            // // _handleNotificationTap(notification);
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
                                  decoration: const BoxDecoration(
                                    color: AppColors.primary,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            notification['productName'],
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Icon(
                                Icons.access_time,
                                size: 12,
                                color: Colors.grey[500],
                              ),
                              const SizedBox(width: 4),
                              // Text(
                              //   _formatTimestamp(timestamp),
                              //   style: TextStyle(
                              //     fontSize: 12,
                              //     color: Colors.grey[500],
                              //   ),
                              // ),
                              if (notification.containsKey('dataNTime') &&
                                  notification['dataNTime'] != null)
                                Text(
                                  ' ${notification['dataNTime']}',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Colors.grey[400],
                                  ),
                                  textAlign: TextAlign.end,
                                ),
                            ],
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
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Action button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () async {
                if (notification['isReadInt'] == 1) {
                  log('isRead: ${notification['isReadInt']}');
                  _handleNotificationTap(notification);
                } else {
                  setState(() {
                    notification['isRead'] = true;
                    notification['isReadInt'] = 1;
                  });
                  await _isReadStatusUpdate(emailId, notification['productId']);
                  _handleNotificationTap(notification);
                }
              },
              icon: const Icon(Icons.visibility, size: 16),
              label: const Text('View Product'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                elevation: 2,
              ),
            ),
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

  DateTime _parseDataNTime(String dataNTime) {
    try {
      // Try to parse the DataNTime string to DateTime
      // Assuming the format is something like "2024-01-15 10:30:00" or similar
      return DateTime.parse(dataNTime);
    } catch (e) {
      log('Error parsing DataNTime: $dataNTime, Error: $e');
      // Return current time if parsing fails
      return DateTime.now();
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
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
          ),
          const Spacer(),
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
    final productImage = notification['productImage'] as String?;
    final newPrice = notification['newPrice'] as String?;
    final mpn = notification['product_mpn'].toString();
    final brandKey = notification['brand_key'].toString();
    log('mpn $mpn');
    log('brandKey $brandKey');

    if (productId != null) {
      // Navigate to product details screen
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ProductDetailsScreen(
            productId: productId,
            brandName: brandKey,
            productMPN: mpn,
            productImage: productImage ?? '',
            productPrice: newPrice ?? '0.00',
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Product details not available'),
          backgroundColor: Colors.red,
        ),
      );
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
              leading: const Icon(Icons.delete),
              title: const Text('Delete notification'),
              onTap: () async {
                setState(() {
                  Navigator.pop(context);
                });

                await _deleteNotifications(
                    productId: notification['productId']);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _deleteNotifications({required int productId}) async {
    setState(() {
      isLoading = true;
    });
    log('EmailId $emailId');
    log('productId $productId');

    await BrandsApi.deleteSavedPriceAlertProduct(
            emailId: emailId,
            deviceToken: _deviceId,
            productId: productId,
            context: context)
        .then((response) async {
      if (response != 'error') {
        log('Product $productId deleted successfully');
        await _getProductData();
      } else {
        log('Error deleting product $productId');
      }
    });
  }

  Future<void> _isReadStatusUpdate(String emailId, int productId) async {
    setState(() {
      isLoading = true;
    });
    log('EmailId $emailId');
    log('productId $productId');
    await BrandsApi.updateReadStatus(
            emailId: emailId,
            deviceToken: _deviceId,
            productId: productId,
            isRead: 1)
        .then((response) async {
      if (response != 'error') {
        log('Product $productId count update successfully');
      } else {
        log('Error deleting product $productId');
      }
    });

    setState(() {
      isLoading = false;
    });
  }
}

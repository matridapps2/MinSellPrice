import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:minsellprice/core/apis/apis_calls.dart';

class AlertProduct extends StatefulWidget {
  const AlertProduct({super.key});

  @override
  State<AlertProduct> createState() => _AlertProductState();
}

class _AlertProductState extends State<AlertProduct> {
  List<Map<String, dynamic>> _alertProducts = [];
  bool _isLoading = true;
  String _userEmail = '';
  String _deviceId = '';
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  /// Initialize user data and fetch alerts
  Future<void> _initializeData() async {
    await _getCurrentEmailId();
    await _getDeviceId();
    await _fetchAlertProducts();
  }

  /// Get current user email
  Future<void> _getCurrentEmailId() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        setState(() {
          _userEmail = user.email!;
        });
        log('✅ User email: $_userEmail');
      } else {
        log('❌ No user logged in');
      }
    } catch (e) {
      log('❌ Error getting user email: $e');
    }
  }

  /// Get device ID
  Future<void> _getDeviceId() async {
    try {
      final deviceInfo = DeviceInfoPlugin();
      final androidInfo = await deviceInfo.androidInfo;
      final deviceId = androidInfo.id;

      setState(() {
        _deviceId = deviceId;
      });
      log('✅ Device ID: $_deviceId');
    } catch (e) {
      log('❌ Error getting device ID: $e');
    }
  }

  /// Fetch all alert products using unified API
  Future<void> _fetchAlertProducts() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      log('🔄 Fetching alert products...');
      final response = await BrandsApi.fetchPriceAlertProduct(
        emailId: _userEmail,
        deviceToken: _deviceId,
        context: context,
      );

      if (response == 'error') {
        setState(() {
          _errorMessage = 'Failed to fetch alert products';
          _isLoading = false;
        });
        return;
      }

      log('📥 API Response: $response');

      // Parse the response
      final data = json.decode(response);
      List<Map<String, dynamic>> products = [];

      if (data is List) {
        products = List<Map<String, dynamic>>.from(data);
      } else if (data is Map<String, dynamic>) {
        if (data.containsKey('data') && data['data'] is List) {
          products = List<Map<String, dynamic>>.from(data['data']);
        } else {
          products = [data];
        }
      }

      setState(() {
        _alertProducts = products;
        _isLoading = false;
      });

      log('✅ Loaded ${products.length} alert products');
    } catch (e) {
      log('❌ Error fetching alert products: $e');
      setState(() {
        _errorMessage = 'Error loading alert products: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  /// Delete a specific alert
  Future<void> _deleteAlert(Map<String, dynamic> product) async {
    try {
      final productId = product['product_id'];
      final productName = product['product_name'] ?? 'Product';

      // Show confirmation dialog
      final shouldDelete = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Icon(
                Icons.warning,
                color: Colors.orange.shade600,
                size: 24,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Delete Alert',
                  style: TextStyle(
                    color: Colors.red.shade800,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              GestureDetector(
                onTap: () => Navigator.of(context).pop(false),
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Icon(
                    Icons.close,
                    color: Colors.grey.shade600,
                    size: 20,
                  ),
                ),
              ),
            ],
          ),
          content: Text(
            'Are you sure you want to delete the price alert for "$productName"?',
            style: TextStyle(
              color: Colors.grey.shade700,
              fontSize: 14,
            ),
          ),
          actions: [
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade600,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Delete',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      );

      if (shouldDelete == true) {
        // Call delete API
        final result = await BrandsApi.deleteSavedPriceAlertProduct(
          emailId: _userEmail,
          productId: productId,
          deviceToken: _deviceId,
          context: context,
        );

        if (result == 'error') {
          _showSnackBar('Failed to delete alert', isError: true);
        } else {
          _showSnackBar('Alert deleted successfully');
          // Refresh the list
          await _fetchAlertProducts();
        }
      }
    } catch (e) {
      log('❌ Error deleting alert: $e');
      _showSnackBar('Error deleting alert', isError: true);
    }
  }

  /// Show snackbar message
  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red.shade600 : Colors.green.shade600,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  /// Build product card with consistent design
  Widget _buildProductCard(Map<String, dynamic> product, int index) {
    final productName = product['product_name'] ?? 'Unknown Product';
    final productImage = product['product_image'] ?? '';

    // Safely convert string prices to double
    final oldPriceString = product['OldPrice']?.toString() ?? '0.0';
    final newPriceString = product['NewPrice']?.toString() ?? '0.0';
    final oldPrice = double.tryParse(oldPriceString) ?? 0.0;
    final newPrice = double.tryParse(newPriceString) ?? 0.0;

    final brandKey = product['brand_key'] ?? '';
    final isNotificationSent = product['isNotificationSent'] ?? 0;
    final dateTime = product['DataNTime'] ?? '';

    // Calculate price difference
    final priceDifference = oldPrice - newPrice;
    final hasPriceDrop = priceDifference > 0;

    // Use consistent design for all products
    return _buildConsistentCard(
        product,
        productName,
        productImage,
        oldPrice,
        newPrice,
        brandKey,
        isNotificationSent,
        dateTime,
        hasPriceDrop,
        priceDifference);
  }

  /// Consistent card design for all products
  Widget _buildConsistentCard(
      Map<String, dynamic> product,
      String productName,
      String productImage,
      double oldPrice,
      double newPrice,
      String brandKey,
      int isNotificationSent,
      String dateTime,
      bool hasPriceDrop,
      double priceDifference) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
            color: hasPriceDrop ? Colors.green.shade300 : Colors.blue.shade300,
            width: 1),
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
          // Status row
          // Row(
          //   children: [
          //     Icon(
          //       hasPriceDrop ? Icons.trending_down : Icons.monitor,
          //       color:
          //           hasPriceDrop ? Colors.green.shade600 : Colors.blue.shade600,
          //       size: 20,
          //     ),
          //     const SizedBox(width: 8),
          //     Text(
          //       hasPriceDrop ? 'Price Drop!' : 'Watching',
          //       style: TextStyle(
          //         fontSize: 14,
          //         fontWeight: FontWeight.w600,
          //         color: hasPriceDrop
          //             ? Colors.green.shade700
          //             : Colors.blue.shade700,
          //       ),
          //     ),
          //     const Spacer(),
          //     if (isNotificationSent == 1)
          //       Icon(Icons.notifications_active,
          //           size: 25, color: Colors.orange.shade600),
          //   ],
          // ),
          const SizedBox(height: 12),
          // Product info
          Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: Colors.grey.shade100,
                ),
                child: productImage.isNotEmpty
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          productImage,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => Icon(
                            Icons.image_not_supported,
                            color: Colors.grey.shade400,
                            size: 24,
                          ),
                        ),
                      )
                    : Icon(
                        Icons.image_not_supported,
                        color: Colors.grey.shade400,
                        size: 24,
                      ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      productName,
                      style: const TextStyle(
                          fontSize: 14, fontWeight: FontWeight.w600),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    if (brandKey.isNotEmpty)
                      Text(
                        brandKey.toUpperCase(),
                        style: TextStyle(
                            fontSize: 10, color: Colors.grey.shade600),
                      ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Price row
          Row(
            children: [
              Text(
                '\$${oldPrice.toStringAsFixed(2)}',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey.shade600,
                  decoration: hasPriceDrop ? TextDecoration.lineThrough : null,
                ),
              ),
              if (hasPriceDrop) ...[
                const SizedBox(width: 8),
                Text(
                  '\$${newPrice.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.green.shade700,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '-\$${priceDifference.toStringAsFixed(2)}',
                  style: TextStyle(fontSize: 12, color: Colors.green.shade600),
                ),
              ],
              const Spacer(),
              // Improved delete button
              GestureDetector(
                onTap: () => _deleteAlert(product),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: Colors.red.shade200,
                      width: 1,
                    ),
                  ),
                  child: Icon(
                    Icons.delete_outline,
                    color: Colors.red.shade600,
                    size: 20,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Build empty state
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(60),
            ),
            child: Icon(
              Icons.notifications_off,
              size: 48,
              color: Colors.grey.shade400,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'No Price Alerts',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'You haven\'t set any price alerts yet.\nStart by adding alerts to products you\'re interested in.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade500,
            ),
          ),
       /*   const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.add),
            label: const Text('Add Alert'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue.shade600,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),*/
        ],
      ),
    );
  }

  /// Build error state
  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.red.shade50,
              borderRadius: BorderRadius.circular(60),
            ),
            child: Icon(
              Icons.error_outline,
              size: 48,
              color: Colors.red.shade400,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Something went wrong',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.red.shade600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _errorMessage,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: _fetchAlertProducts,
            icon: const Icon(Icons.refresh),
            label: const Text('Try Again'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade600,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text(
          'Price Alerts',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.blue.shade600,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _fetchAlertProducts,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : _errorMessage.isNotEmpty
              ? _buildErrorState()
              : _alertProducts.isEmpty
                  ? _buildEmptyState()
                  : RefreshIndicator(
                      onRefresh: _fetchAlertProducts,
                      child: ListView.builder(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        itemCount: _alertProducts.length,
                        itemBuilder: (context, index) {
                          return _buildProductCard(
                              _alertProducts[index], index);
                        },
                      ),
                    ),
    );
  }
}

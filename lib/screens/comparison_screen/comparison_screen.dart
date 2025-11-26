import 'package:flutter/material.dart';
import 'package:minsellprice/core/utils/constants/colors.dart';
import 'package:minsellprice/screens/product_details_screen/product_details_screen.dart';
import 'package:minsellprice/service_new/comparison_db.dart';

/// ComparisonScreen - Displays products side-by-side for comparison
/// 
/// Features:
/// - Shows up to 4 products in a comparison table
/// - Displays product images, names, prices, and specs
/// - Allows removing products from comparison
/// - Shows "No products to compare" message when empty
class ComparisonScreen extends StatefulWidget {
  const ComparisonScreen({super.key});

  @override
  State<ComparisonScreen> createState() => _ComparisonScreenState();
}

class _ComparisonScreenState extends State<ComparisonScreen> {
  List<Map<String, dynamic>> comparisonProducts = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadComparisonProducts();
  }

  /// Load all products in comparison from database
  Future<void> _loadComparisonProducts() async {
    try {
      final products = await ComparisonDB.getAllComparisonProducts();
      if (mounted) {
        setState(() {
          comparisonProducts = products;
          isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
      print('Error loading comparison products: $e');
    }
  }

  /// Remove a product from comparison
  Future<void> _removeFromComparison(int vendorProductId) async {
    try {
      await ComparisonDB.removeFromComparison(vendorProductId: vendorProductId);
      await _loadComparisonProducts(); // Refresh the list

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Product removed from comparison'),
          backgroundColor: Colors.orange,
          duration: Duration(seconds: 2),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error removing product from comparison'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  /// Clear all products from comparison
  Future<void> _clearAllComparisons() async {
    try {
      await ComparisonDB.clearAllComparisons();
      await _loadComparisonProducts(); // Refresh the list

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('All products cleared from comparison'),
          backgroundColor: Colors.orange,
          duration: Duration(seconds: 2),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error clearing comparison'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Compare Products (${comparisonProducts.length})'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        actions: [
          if (comparisonProducts.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.clear_all, color: Colors.red),
              onPressed: () {
                _showClearAllDialog();
              },
              tooltip: 'Clear All',
            ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : comparisonProducts.isEmpty
              ? _buildEmptyState()
              : _buildComparisonView(),
    );
  }

  /// Show empty state when no products to compare
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.compare_arrows,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No Products to Compare',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Add products to comparison from product details',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[500],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: const Text('Browse Products'),
          ),
        ],
      ),
    );
  }

  /// Build the main comparison view with products side-by-side
  Widget _buildComparisonView() {
    return SingleChildScrollView(
      child: Column(
        children: [
          // Product Cards Row
          Container(
           height: 400,
            padding: const EdgeInsets.all(16),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: comparisonProducts.length,
              itemBuilder: (context, index) {
                final product = comparisonProducts[index];
                return _buildProductCard(product, index);
              },
            ),
          ),

          // Comparison Table
          _buildComparisonTable(),

          const SizedBox(height: 20),
        ],
      ),
    );
  }

  /// Build individual product card
  Widget _buildProductCard(Map<String, dynamic> product, int index) {
    return Container(
      width: 300,
      margin: const EdgeInsets.only(right: 16),
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Column(
          children: [
            // Product Image
            Expanded(
              flex: 2,
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(12),
                    topRight: Radius.circular(12),
                  ),
                  color: Colors.grey[100],
                ),
                child: ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(12),
                    topRight: Radius.circular(12),
                  ),
                  child: (product['product_image'] != null &&
                          product['product_image'].toString().isNotEmpty)
                      ? Image.network(
                          product['product_image'],
                          fit: BoxFit.fill,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              alignment: Alignment.center,
                              child: const Icon(Icons.image_not_supported,
                                  size: 40, color: Colors.grey),
                            );
                          },
                        )
                      : Container(
                          alignment: Alignment.center,
                          child: const Icon(Icons.image_not_supported,
                              size: 40, color: Colors.grey),
                        ),
                ),
              ),
            ),

            // Product Details
            Expanded(
              flex: 1,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product['product_name'] ?? 'Unknown Product',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      product['brand_name'] ?? 'Unknown Brand',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                    Flexible(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '\$${product['product_price'] ?? '0'}',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.green,
                              ),
                              maxLines: 3,
                            ),
                            IconButton(
                              icon: const Icon(Icons.close, color: Colors.red, size: 20),
                              onPressed: () {
                                _removeFromComparison(product['vendor_product_id']);
                              },
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Build comparison table with features
  Widget _buildComparisonTable() {
    final features = [
      {'label': 'Brand', 'key': 'brand_name'},
      {'label': 'Model', 'key': 'product_mpn'},
      {'label': 'Price', 'key': 'product_price', 'prefix': '\$'},
    ];

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 2,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: const Row(
              children: [
                Icon(Icons.compare_arrows, color: AppColors.primary),
                SizedBox(width: 8),
                Text(
                  'Feature Comparison',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ),

          // Feature Rows
          ...features.map((feature) => _buildFeatureRow(feature)),

          // Action Buttons Row
          Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: comparisonProducts.map((product) {
                return Expanded(
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ProductDetailsScreen(
                              productId: product['product_id'],
                              brandName: product['brand_name'],
                              productMPN: product['product_mpn'],
                              productImage: product['product_image'],
                              productPrice: product['product_price'],
                            ),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 8),
                      ),
                      child: const Text(
                        'View Details',
                        style: TextStyle(fontSize: 12),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  /// Build a single feature comparison row
  Widget _buildFeatureRow(Map<String, dynamic> feature) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.grey[200]!, width: 1),
        ),
      ),
      child: Row(
        children: [
          // Feature Label
          Expanded(
            flex: 2,
            child: Text(
              feature['label'],
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
                color: Colors.black87,
              ),
            ),
          ),

          // Feature Values for each product
          ...comparisonProducts.map((product) {
            String value = product[feature['key']]?.toString() ?? '--';
            if (feature['prefix'] != null) {
              value = '${feature['prefix']}$value';
            }

            return Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Text(
                  value,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.black54,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  /// Show dialog to confirm clearing all comparisons
  void _showClearAllDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Clear All Comparisons'),
          content: const Text(
              'Are you sure you want to remove all products from comparison?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _clearAllComparisons();
              },
              child: const Text('Clear All', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }
}

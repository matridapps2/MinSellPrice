import 'package:flutter/material.dart';
import 'package:minsellprice/screens/unified_product_list_screen.dart';

/// Example usage of the Unified Product List Screen
class UnifiedProductListExample extends StatelessWidget {
  const UnifiedProductListExample({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Unified Product List Examples'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Unified Product List Screen Examples',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),

            // Brand Products Example
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const UnifiedProductListScreen(
                      type: ProductListType.brand,
                      identifier: 'Samsung',
                      displayName: 'Samsung Products',
                    ),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.all(16),
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
              ),
              child: const Column(
                children: [
                  Icon(Icons.branding_watermark, size: 32),
                  SizedBox(height: 8),
                  Text('Brand Products', style: TextStyle(fontSize: 18)),
                  Text('Samsung products using brand API',
                      style: TextStyle(fontSize: 14)),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Category Products Example
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const UnifiedProductListScreen(
                      type: ProductListType.category,
                      identifier: 'electronics/smartphones',
                      displayName: 'Smartphones',
                    ),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.all(16),
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
              ),
              child: const Column(
                children: [
                  Icon(Icons.category, size: 32),
                  SizedBox(height: 8),
                  Text('Category Products', style: TextStyle(fontSize: 18)),
                  Text('Smartphones using category API',
                      style: TextStyle(fontSize: 14)),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Search Results Example
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const UnifiedProductListScreen(
                      type: ProductListType.search,
                      identifier: 'iPhone 15',
                      displayName: 'Search Results',
                    ),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.all(16),
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
              ),
              child: const Column(
                children: [
                  Icon(Icons.search, size: 32),
                  SizedBox(height: 8),
                  Text('Search Results', style: TextStyle(fontSize: 18)),
                  Text('iPhone 15 search results',
                      style: TextStyle(fontSize: 14)),
                ],
              ),
            ),

            const SizedBox(height: 20),

            const Text(
              'Features:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),

            const Text(
              '• Unified UI for all product list types\n'
              '• Flexible API strategy pattern\n'
              '• Advanced filtering and sorting\n'
              '• Search functionality\n'
              '• Pagination support\n'
              '• Vendor price comparison\n'
              '• Responsive design',
              style: TextStyle(fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}

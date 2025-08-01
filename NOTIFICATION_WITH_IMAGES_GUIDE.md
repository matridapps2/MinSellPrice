# Notification System with Product Images - Implementation Guide

## Overview

This guide explains how the MinSellPrice app implements rich notifications with product images for price drop alerts. The system supports both asset images and network images, with automatic conversion and caching for optimal performance. **NEW**: When users tap on notifications, they see a detailed dialog with the same rich content and product image.

## Features

- **Rich Notifications**: Display product images in notifications
- **API Image Support**: Handle product images from API responses (network URLs)
- **Asset Image Support**: Convert Flutter asset paths to file paths for notifications
- **Network Image Handling**: Download and cache network images for notifications
- **Cross-Platform**: Works on both Android and iOS
- **Error Handling**: Graceful fallback when images fail to load
- **Performance Optimized**: Efficient image conversion and caching
- **🎯 NEW: Interactive Notifications**: Tap notifications to see detailed dialogs with product images
- **🎯 NEW: Rich Dialog Content**: Same text and images as notifications in beautiful dialogs

## Implementation Details

### 1. Notification Service (`lib/services/notification_service.dart`)

The core notification service has been enhanced with the following features:

#### Notification Data Storage

```dart
// Store notification data for detailed view
final Map<String, Map<String, dynamic>> _notificationData = {};

// Store notification data for detailed view
_notificationData[productId.toString()] = {
  'productName': productName,
  'oldPrice': oldPrice,
  'newPrice': newPrice.toStringAsFixed(2),
  'productImage': productImage,
  'savings': savings.toStringAsFixed(2),
  'savingsPercentage': savingsPercentage,
};
```

#### Network Image Download

```dart
Future<String?> _downloadNetworkImage(String imageUrl) async {
  try {
    log('Downloading network image: $imageUrl');
    
    // Download the image
    final response = await http.get(Uri.parse(imageUrl));
    
    if (response.statusCode == 200) {
      // Get temporary directory
      final Directory tempDir = await getTemporaryDirectory();
      final String fileName = 'notification_${DateTime.now().millisecondsSinceEpoch}.jpg';
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
```

#### Universal Image Handler

```dart
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
```

#### Enhanced Price Drop Notification

```dart
Future<void> showPriceDropNotification({
  required String productName,
  required String oldPrice,
  required double newPrice,
  required int productId,
  String? productImage,
}) async {
  // Calculate savings
  final savings = double.parse(oldPrice) - newPrice;
  final savingsPercentage = (savings / double.parse(oldPrice) * 100).toStringAsFixed(1);

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
  final AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
    'price_drop_notifications',
    'Price Drop Alerts',
    channelDescription: 'Get notified when product prices drop',
    importance: Importance.high,
    priority: Priority.high,
    showWhen: true,
    enableVibration: true,
    playSound: true,
    styleInformation: BigPictureStyleInformation(
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
    color: const Color(0xFF2196F3),
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

  // Show the notification
  await _localNotifications.show(
    DateTime.now().millisecondsSinceEpoch.remainder(100000),
    title,
    richBody,
    NotificationDetails(android: androidDetails, iOS: iOSDetails),
    payload: 'product:$productId|price_drop|${newPrice.toStringAsFixed(2)}',
  );
}
```

### 2. Notification Tap Handler

#### Enhanced Tap Navigation

```dart
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
    
    // Show detailed notification dialog
    _showNotificationDetailDialog(productId, notificationType, newPrice);
  } else {
    // Use global navigation service to open notification screen
    final navigationService = NavigationService();
    navigationService.navigateToNotifications();
  }
}
```

#### Detailed Notification Dialog

```dart
// Show detailed notification dialog with product image and information
void _showNotificationDetailDialog(String productId, String notificationType, String newPrice) {
  // Get the global navigator key or context
  final context = NavigationService().navigatorKey.currentContext;
  if (context == null) {
    log('No context available for showing notification dialog');
    return;
  }

  // Get stored notification data
  final notificationData = _notificationData[productId];
  final productName = notificationData?['productName'] ?? 'Unknown Product';
  final oldPrice = notificationData?['oldPrice'] ?? '0.00';
  final productImage = notificationData?['productImage'];
  final savings = notificationData?['savings'] ?? '0.00';
  final savingsPercentage = notificationData?['savingsPercentage'] ?? '0.0';

  // Show the detailed dialog
  showDialog(
    context: context,
    barrierDismissible: true,
    builder: (BuildContext context) {
      return _buildNotificationDetailDialog(
        context, 
        productId, 
        notificationType, 
        newPrice,
        productName,
        oldPrice,
        productImage,
        savings,
        savingsPercentage,
      );
    },
  );
}
```

#### Rich Dialog Content

```dart
// Build the detailed notification dialog
Widget _buildNotificationDetailDialog(
  BuildContext context, 
  String productId, 
  String notificationType, 
  String newPrice,
  String productName,
  String oldPrice,
  String? productImage,
  String savings,
  String savingsPercentage,
) {
  return Dialog(
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(20),
    ),
    child: Container(
      width: MediaQuery.of(context).size.width * 0.9,
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.8,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header with app icon and title
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFF2196F3),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.local_offer,
                    color: Color(0xFF2196F3),
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Price Drop Alert!',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'MinSellPrice',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(
                    Icons.close,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          
          // Content area with product image and details
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Product image (actual or placeholder)
                  Container(
                    width: double.infinity,
                    height: 200,
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey[300]!),
                    ),
                    child: productImage != null && productImage.isNotEmpty
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.network(
                              productImage,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return _buildImagePlaceholder();
                              },
                              loadingBuilder: (context, child, loadingProgress) {
                                if (loadingProgress == null) return child;
                                return Center(
                                  child: CircularProgressIndicator(
                                    value: loadingProgress.expectedTotalBytes != null
                                        ? loadingProgress.cumulativeBytesLoaded /
                                            loadingProgress.expectedTotalBytes!
                                        : null,
                                    color: const Color(0xFF2196F3),
                                  ),
                                );
                              },
                            ),
                          )
                        : _buildImagePlaceholder(),
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // Product name
                  Text(
                    productName,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Notification content with price details
                  Container(
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
                              Icons.trending_down,
                              color: Colors.green[600],
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Price Drop Detected!',
                              style: TextStyle(
                                color: Colors.green[700],
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        _buildInfoRow('Product ID', productId),
                        _buildInfoRow('Old Price', '\$$oldPrice'),
                        _buildInfoRow('New Price', '\$$newPrice'),
                        _buildInfoRow('You Save', '\$$savings'),
                        _buildInfoRow('Discount', '${savingsPercentage}%'),
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.green[100],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.savings,
                                color: Colors.green[700],
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Great savings opportunity! Don\'t miss this deal.',
                                  style: TextStyle(
                                    color: Colors.green[800],
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // Action buttons
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            Navigator.of(context).pop();
                            // Navigate to product details
                            _navigateToProductDetails(productId);
                          },
                          icon: const Icon(Icons.visibility),
                          label: const Text('View Product'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF2196F3),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => Navigator.of(context).pop(),
                          icon: const Icon(Icons.close),
                          label: const Text('Dismiss'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.grey[600],
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ),
                    ],
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
```

### 3. Product Details Screen Integration

The product details screen has been updated to pass API product images to notifications:

```dart
Future<void> _subscribeToPriceAlert(BuildContext context) async {
  try {
    // Show loading indicator
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const Center(
          child: CircularProgressIndicator(),
        );
      },
    );

    final notificationService = NotificationService();
    
    // Ensure notification service is initialized
    if (!notificationService.isInitialized) {
      await notificationService.initialize();
    }

    // Get product image path - pass directly from API
    String productImagePath = '';
    if (widget.productImage != null) {
      // Pass the product image directly - the notification service will handle all types
      productImagePath = widget.productImage.toString();
      log('Product image path: $productImagePath');
    }

    // Calculate a realistic new price (20% discount for demo)
    final currentPrice = double.tryParse(widget.productPrice.toString()) ?? 100.0;
    final newPrice = currentPrice * 0.8; // 20% discount

    await notificationService.showPriceDropNotification(
      productName: productDetails?.data?.productName ?? 'Unknown Product',
      oldPrice: widget.productPrice.toString(),
      newPrice: newPrice,
      productId: widget.productId,
      productImage: productImagePath,
    );

    // Close loading dialog and show success message
    Navigator.of(context).pop();
    CommonToasts.centeredMobile(
      context: context, 
      msg: 'Price Alert Set Successfully! You\'ll be notified when the price drops.'
    );

  } catch (e) {
    // Handle errors gracefully
    Navigator.of(context).pop();
    CommonToasts.centeredMobile(
      context: context, 
      msg: 'Failed to set price alert. Please try again.'
    );
    log('Error setting price alert: $e');
  }
}
```

### 4. API Integration Example

Here's how to use the API product image in your current screen:

```dart
// In your brand_product_list_screen.dart or similar file
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => ProductDetailsScreen(
      productId: finalList[index].productId,
      brandName: widget.brandName ?? 'Unknown Brand',
      productMPN: finalList[index].productMpn,
      productImage: finalList[index].productImage, // API product image
      productPrice: finalList[index].vendorpricePrice,
    ),
  ),
);
```

### 5. Test Functions

#### Test Notification with Image

```dart
Future<void> _testNotificationWithImage(BuildContext context) async {
  try {
    final notificationService = NotificationService();
    
    if (!notificationService.isInitialized) {
      await notificationService.initialize();
    }

    // Test with different image types including API images
    final testImages = [
      'assets/images/no_image.png',
      'assets/minsellprice_logo.png',
      'assets/app_logo/logo.png',
      widget.productImage?.toString() ?? 'assets/images/no_image.png', // API image
      // Add some sample network images for testing
      'https://via.placeholder.com/300x300/2196F3/FFFFFF?text=Test+Product+1',
      'https://via.placeholder.com/300x300/4CAF50/FFFFFF?text=Test+Product+2',
    ];

    for (int i = 0; i < testImages.length; i++) {
      final testPrice = 100.0 - (i * 10.0);
      final newPrice = testPrice * 0.8;

      await notificationService.showPriceDropNotification(
        productName: 'Test Product ${i + 1}',
        oldPrice: testPrice.toString(),
        newPrice: newPrice,
        productId: widget.productId + i,
        productImage: testImages[i],
      );

      // Wait between notifications
      await Future.delayed(const Duration(seconds: 2));
    }

    CommonToasts.centeredMobile(
      context: context, 
      msg: 'Test notifications sent! Check your notification panel.'
    );

  } catch (e) {
    CommonToasts.centeredMobile(
      context: context, 
      msg: 'Error sending test notifications: $e'
    );
    log('Error in test notification: $e');
  }
}
```

#### Test Notification Tap Functionality

```dart
Future<void> _testNotificationTap(BuildContext context) async {
  try {
    final notificationService = NotificationService();
    
    if (!notificationService.isInitialized) {
      await notificationService.initialize();
    }

    // Send a test notification
    await notificationService.showPriceDropNotification(
      productName: productDetails?.data?.productName ?? 'Test Product',
      oldPrice: widget.productPrice.toString(),
      newPrice: 79.99,
      productId: widget.productId,
      productImage: widget.productImage?.toString() ?? '',
    );

    CommonToasts.centeredMobile(
      context: context, 
      msg: 'Notification sent! Now tap on it to see the detailed dialog with image.'
    );

  } catch (e) {
    CommonToasts.centeredMobile(
      context: context, 
      msg: 'Error testing notification tap: $e'
    );
    log('Error in notification tap test: $e');
  }
}
```

## Usage Instructions

### 1. Setting Up Price Alerts with API Images

1. Navigate to a product details screen (the image comes from `finalList[index].productImage`)
2. Tap the "Set Alert" button
3. The system will automatically:
   - Download the API product image to a temporary file
   - Convert it to a notification-compatible format
   - Calculate savings and percentage discount
   - Display a rich notification with the actual product image
   - Show success/error messages

### 2. Testing Notifications

1. On the product details screen, tap "Set Alert"
2. In the dialog, tap the orange "Test Notification" button
3. The system will send multiple test notifications with different images including API images
4. Check your device's notification panel to see the results

### 3. Testing Notification Tap Functionality

1. On the product details screen, tap "Set Alert"
2. In the dialog, tap the green "Test Tap" button
3. A notification will be sent with your actual product data
4. **Tap on the notification** to see the detailed dialog with:
   - Same product image as the notification
   - Same text content with price details
   - Rich formatting and styling
   - Action buttons to view product or dismiss

### 4. Supported Image Types

- **API Network Images**: `https://example.com/product-image.jpg` (from `finalList[index].productImage`)
- **Asset Images**: `assets/images/product.jpg`
- **File Paths**: `/path/to/local/image.jpg`
- **Null/Empty**: Falls back to app icon

## Technical Requirements

### Dependencies

The following packages are required:

```yaml
dependencies:
  flutter_local_notifications: ^latest_version
  path_provider: ^2.1.5
  http: ^1.4.0  # For downloading network images
```

### API Image Handling

The system automatically handles different image URL formats:

```dart
// Example API responses and how they're handled:
"product_image": "https://example.com/image.jpg"     // Direct HTTPS URL
"product_image": "http://example.com/image.jpg"      // Direct HTTP URL  
"product_image": "//example.com/image.jpg"           // Protocol-relative URL
"product_image": "example.com/image.jpg"             // Relative URL
"product_image": null                                // No image
```

## Best Practices

### 1. API Image Optimization

- Ensure API returns optimized image URLs
- Use HTTPS URLs when possible
- Provide fallback images in API responses
- Implement proper error handling for failed image downloads

### 2. Error Handling

- Always wrap notification calls in try-catch blocks
- Provide user feedback for success/failure
- Log errors for debugging
- Gracefully handle network image download failures

### 3. Performance

- Download images asynchronously
- Use temporary directories for file storage
- Clean up temporary files periodically
- Implement image caching for frequently used images

### 4. User Experience

- Show loading indicators during image processing
- Provide clear success/error messages
- Test on multiple devices and platforms
- Handle slow network connections gracefully

## Troubleshooting

### Common Issues

1. **API images not showing**: Check if the API URL is accessible and returns valid images
2. **Network timeout**: Increase timeout duration for slow connections
3. **Permission errors**: Ensure notification permissions are granted
4. **Memory issues**: Use smaller images or implement compression
5. **Platform differences**: Test on both Android and iOS
6. **Dialog not showing**: Check if NavigationService has a valid context

### Debug Tips

- Enable verbose logging in the notification service
- Check temporary directory contents
- Verify API image URLs are accessible
- Test with different image formats (PNG, JPG, etc.)
- Monitor network requests in debug console
- Check notification payload format

## Future Enhancements

1. **Image Caching**: Implement persistent caching for API images
2. **Image Compression**: Add automatic image compression for better performance
3. **Multiple Images**: Support for carousel-style notifications with multiple product images
4. **Custom Styles**: Allow customization of notification appearance
5. **Analytics**: Track notification engagement and effectiveness
6. **Offline Support**: Cache images for offline notification display
7. **Deep Linking**: Direct navigation to specific product pages from notifications
8. **Rich Actions**: Add quick action buttons in notifications

## Conclusion

This implementation provides a robust, user-friendly notification system that enhances the price alert experience by including actual product images from your API. The system automatically handles network image downloads, asset conversions, and provides graceful fallbacks when images are unavailable. The integration with your existing `finalList[index].productImage` API data ensures that users see the actual product images in their price drop notifications.

**NEW**: The notification tap functionality now provides an enhanced user experience by showing detailed dialogs with the same rich content and product images, making the notifications truly interactive and informative. 
import 'dart:convert';
import 'dart:developer';
import 'dart:async';
import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:minsellprice/InAppBrowser.dart';
import 'package:minsellprice/core/apis/apis_calls.dart';
import 'package:minsellprice/core/utils/constants/app.dart';
import 'package:minsellprice/core/utils/constants/colors.dart';
import 'package:minsellprice/core/utils/constants/constants.dart';
import 'package:minsellprice/core/utils/toast_messages/common_toasts.dart';
import 'package:minsellprice/core/utils/toast_messages/toast_utils.dart';
import 'package:minsellprice/model/product_details_model.dart';
import 'package:minsellprice/model/product_list_model_new.dart';
import 'package:minsellprice/screens/comparison_screen/comparison_screen.dart';
import 'package:minsellprice/screens/dashboard_screen/dashboard_screen.dart';
import 'package:minsellprice/core/utils/constants/size.dart';
import 'package:minsellprice/service_new/comparison_db.dart';
import 'package:minsellprice/service_new/liked_preference_db.dart';
import 'package:minsellprice/services/notification_service.dart';
// Commented out - WorkManager no longer needed for auto-notifications
// import 'package:minsellprice/services/work_manager_service.dart';
import 'package:minsellprice/services/app_notification_service.dart';
import 'package:minsellprice/widgets/stylish_loader.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../widgets/brand_image.dart';
import '../loging_page/loging_page.dart';
import 'all_alert_product.dart';

class ProductDetailsScreen extends StatefulWidget {
  final int productId;
  final String brandName;
  final String productMPN;
  final productImage;
  final productPrice;

  const ProductDetailsScreen({
    super.key,
    required this.productId,
    required this.brandName,
    required this.productMPN,
    required this.productImage,
    required this.productPrice,
  });

  @override
  State<ProductDetailsScreen> createState() => _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends State<ProductDetailsScreen> {
  ProductDetailsModel? productDetails;

  final ScrollController _scrollController = ScrollController();

  TextEditingController _emailController = TextEditingController();

  bool isLoading = true;
  bool isLiked = false;
  bool isInComparison = false;
  bool _isSubscribedToPriceAlert = false;
  bool _isLoadingPriceAlert = false;
  bool isLoggedIn = false;
  bool isAlertAlreadySet = false;
  bool _canScrollLeft = false;
  bool _canScrollRight = true; // Initially true, will be updated after layout
  bool _isLoadingBrandProducts =
      true; // Separate loading state for brand products

  List<String> filterVendor = [];
  List<String> uniqueVendors = [];
  List<VendorProduct> brandProducts = [];
  List<VendorProduct> tempProductList = [];
  List<VendorProduct> finalList = [];
  List<ProductListModelNew> brandDetails = [];
  List<VendorProductData> vendorProductData = [];

  String loadingMessage = '';
  String wProductName = '';
  String? errorMessage;
  String? emailId;
  String deviceId = '';

  int comparisonCount = 0;
  int vendorId = AppInfo.kVendorId;

  StreamSubscription<User?>? _authStateSubscription;

  // App notification service for handling automatic notifications
  AppNotificationService? _appNotificationService;

  @override
  void initState() {
    super.initState();
    _initCall();
    _setupAuthStateListener();
    _setupScrollListener();

    // Start background WorkManager for price monitoring
    //_startBackgroundWorkManager();

    // Initialize app notification service
    //_initializeAppNotificationService();

    // Commented out - auto-notification logic now handled by AppNotificationService
    // // Check for auto-triggered notifications when screen loads
    // _checkForAutoNotifications();

    // // Set up periodic notification check every 10 seconds while screen is active
    // _notificationCheckTimer =
    //     Timer.periodic(const Duration(seconds: 10), (timer) {
    //   if (mounted) {
    //     _checkForAutoNotifications();
    //   }
    // });
  }

  Future<void> _startBackgroundWorkManager() async {
    try {
      // Commented out WorkManager usage - using AppNotificationService instead
      // // Initialize WorkManager if not already done
      // await WorkManagerService.initialize();

      // // Start the periodic task
      // await WorkManagerService.startPeriodicTask();

      // log('Background WorkManager started successfully');

      // // Check if task is running
      // final isRunning = await WorkManagerService.isTaskRunning();
      // log('WorkManager task running: $isRunning');

      // // Get last execution time
      // final lastExecution = await WorkManagerService.getLastExecutionTime();
      // log('Last WorkManager execution: $lastExecution');

      log('Background WorkManager functionality commented out - using AppNotificationService instead');
    } catch (e) {
      log('Error in background notification service: $e');
    }
  }

  /// Initialize app notification service
  Future<void> _initializeAppNotificationService() async {
    try {
      _appNotificationService = AppNotificationService();
      await _appNotificationService?.initialize(context);

      log('✅ App notification service initialized in ProductDetailsScreen');
    } catch (e) {
      log('❌ Error initializing app notification service: $e');
    }
  }

  @override
  void dispose() {
    _authStateSubscription?.cancel();
    _scrollController.removeListener(_updateScrollButtons);
    _scrollController.dispose();
    // Commented out - auto-notification timer no longer needed
    // _notificationCheckTimer?.cancel();

    // Dispose the app notification service if initialized
    _appNotificationService?.dispose();

    super.dispose();
  }

  /// Setup scroll listener to update button visibility
  void _setupScrollListener() {
    _scrollController.addListener(_updateScrollButtons);
  }

  /// Update scroll button visibility based on scroll position
  void _updateScrollButtons() {
    if (!mounted) return;

    // If no vendor data, hide both buttons
    if (vendorProductData.length <= 1) {
      setState(() {
        _canScrollLeft = false;
        _canScrollRight = false;
      });
      return;
    }

    if (!_scrollController.hasClients) {
      log('Scroll controller has no clients yet');
      // If no clients but we have multiple items, assume we can scroll right initially
      setState(() {
        _canScrollLeft = false; // Hide left icon initially
        _canScrollRight = true; // Show right icon initially
      });
      return;
    }

    try {
      final position = _scrollController.position;
      final maxScrollExtent = position.maxScrollExtent;
      final currentPixels = position.pixels;

      log('Updating scroll buttons: pixels=$currentPixels, max=$maxScrollExtent, items=${vendorProductData.length}');

      // Check if content is scrollable
      if (maxScrollExtent <= 0) {
        log('Content is not scrollable (maxScrollExtent: $maxScrollExtent)');
        setState(() {
          _canScrollLeft = false;
          _canScrollRight = false;
        });
        return;
      }

      // Left icon should only show when scrolled away from the start (position > 0)
      // Right icon should show when not at the end
      final canScrollLeft =
          currentPixels > 5.0; // Threshold to show left icon when scrolled
      final canScrollRight = currentPixels < (maxScrollExtent - 5.0);

      log('Scroll state: canLeft=$canScrollLeft, canRight=$canScrollRight, pixels=$currentPixels');

      setState(() {
        _canScrollLeft = canScrollLeft;
        _canScrollRight = canScrollRight;
      });
      log('Updated scroll state: _canScrollLeft=$_canScrollLeft, _canScrollRight=$_canScrollRight');
    } catch (e) {
      log('Error updating scroll buttons: $e');
    }
  }

  /// Scroll to the next item
  void _scrollToNext() {
    if (!_scrollController.hasClients) {
      log('Scroll controller has no clients');
      return;
    }

    try {
      final position = _scrollController.position;
      const scrollAmount =
          176.0; // Card width (160) + left margin (8) + right margin (8)
      final newPosition = _scrollController.offset + scrollAmount;
      final maxScroll = position.maxScrollExtent;

      log('Scrolling next: current=${_scrollController.offset}, new=$newPosition, max=$maxScroll');

      _scrollController
          .animateTo(
        newPosition > maxScroll ? maxScroll : newPosition,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      )
          .then((_) {
        // Update button visibility after scroll animation completes
        if (mounted) {
          _updateScrollButtons();
        }
      });
    } catch (e) {
      log('Error scrolling next: $e');
    }
  }

  /// Scroll to the previous item
  void _scrollToPrevious() {
    if (!_scrollController.hasClients) {
      log('Scroll controller has no clients');
      return;
    }

    try {
      const scrollAmount =
          176.0; // Card width (160) + left margin (8) + right margin (8)
      final newPosition = _scrollController.offset - scrollAmount;

      log('Scrolling previous: current=${_scrollController.offset}, new=$newPosition');

      _scrollController
          .animateTo(
        newPosition < 0 ? 0 : newPosition,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      )
          .then((_) {
        // Update button visibility after scroll animation completes
        if (mounted) {
          _updateScrollButtons();
        }
      });
    } catch (e) {
      log('Error scrolling previous: $e');
    }
  }

  Future<void> _getDeviceId() async {
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();

    if (Platform.isAndroid) {
      AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
      deviceId = androidInfo.id;
      log('Android Unique ID: $deviceId');
    } else if (Platform.isIOS) {
      IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
      deviceId = iosInfo.identifierForVendor!;
      log('IOS Unique ID: $deviceId');
    }
  }

  // Commented out - auto-notification logic now handled by AppNotificationService
  // Future<void> _checkForAutoNotifications() async {
  //   log('🔍 Checking for auto-notifications...');

  //   final notificationData =
  //       await WorkManagerService.checkAutoTriggeredNotification();

  //   if (notificationData != null && mounted) {
  //     log('✅ Auto-notification found: $notificationData');
  //     await _showAutoNotification(notificationData);
  //     await WorkManagerService.clearAutoTriggeredNotification();
  //   } else {
  //     log('❌ No auto-notifications found');
  //   }
  // }

  // Commented out - auto-notification logic now handled by AppNotificationService
  // Future<void> _showAutoNotification(
  //     Map<String, dynamic> notificationData) async {
  //   log('api load start');
  //   try {
  //     final notificationService = NotificationService();
  //   if (!notificationService.isInitialized) {
  //     await notificationService.initialize();
  //     }

  //     await notificationService.showPriceDropNotification(
  //       productName: notificationData['product_name'] ?? '---',
  //       oldPrice: notificationData['OldPrice'] ??
  //           '0.00', // Fixed: OldPrice not old_price
  //       newPrice: double.tryParse(notificationData['NewPrice'] ?? '0.00') ??
  //           0.00, // Fixed: NewPrice not new_price
  //       productId: int.tryParse(notificationData['product_id'] ?? '0') ?? 0,
  //       productImage: notificationData['product_image'] ?? '',
  //     );

  //     CommonToasts.centeredMobile(
  //       context: context,
  //       msg: '🚨 Price drop detected! Notification sent automatically!',
  //       );
  //   } catch (e) {
  //     CommonToasts.centeredMobile(
  //         context: context, msg: 'Error showing auto-notification: $e');
  //     log('Error showing auto-notification: $e');
  //       );
  //   }
  // }

  /// Setup Firebase Auth state listener to handle login/logout events
  void _setupAuthStateListener() {
    _authStateSubscription =
        FirebaseAuth.instance.authStateChanges().listen((User? user) async {
      if (mounted) {
        setState(() {
          // Update UI based on authentication state
          // This will trigger a rebuild when user logs in/out
        });
        log('Firebase Auth state changed: ${user?.email ?? 'No user'}');

        // If user logged in, refresh liked status
        if (user != null && user.email != null && user.email!.isNotEmpty) {
          log('User logged in, refreshing liked status');
          setState(() {
            isLoggedIn = true;
          });
          await _checkIfLiked();
        } else if (user == null) {
          log('User logged out, clearing liked status');
          // Clear liked status when user logs out
          if (mounted) {
            setState(() {
              isLoggedIn = false;
              isLiked = false;
            });
          }
        }
      }
    });
  }

  void _initCall() async {
    const Duration(seconds: 10).inSeconds;
    await _fetchProductDetails();
    await _isAlreadySetAlert();
    await _fetchBrandProducts();
    await _checkIfLiked();
    await _checkIfInComparison();
  }

  Future<void> _isAlreadySetAlert() async {
    try {
      log('🔍 Checking if price alert is already set for product ID: ${widget.productId}');

      // Get current user credentials
      await _getCurrentEmailId();
      await _getDeviceId();

      // Call the unified API method
      final responseBody = await BrandsApi.fetchPriceAlertProduct(
        emailId: emailId,
        deviceToken: deviceId,
        context: context,
      );

      if (responseBody != 'error' && responseBody.isNotEmpty) {
        log('✅ API call successful for checking existing alerts');

        try {
          final data = json.decode(responseBody);
          log('📊 API Response type: ${data.runtimeType}');
          log('🔍 API Response data: $data');

          if (data is List) {
            log('📋 Response is a List with ${data.length} items');
            for (int i = 0; i < data.length; i++) {
              final item = data[i];
              if (item is Map<String, dynamic>) {
                final productId = item['product_id'];
                log('🔍 Checking item $i - Product ID: $productId');

                if (productId == widget.productId) {
                  isAlertAlreadySet = true;
                  log('✅ FOUND: Current product ID ${widget.productId} exists in saved alerts');
                  log('📊 Alert details: ${item.toString()}');
                  break;
                }
              }
            }
          } else if (data is Map<String, dynamic>) {
            log('📋 Response is a Map with keys: ${data.keys.toList()}');
            final productId = data['product_id'];
            log('🔍 Checking single item - Product ID: $productId');

            if (productId == widget.productId) {
              isAlertAlreadySet = true;
              log('✅ FOUND: Current product ID ${widget.productId} exists in saved alerts');
              log('📊 Alert details: ${data.toString()}');
            }
          }

          // Update UI state
          if (mounted) {
            setState(() {
              _isSubscribedToPriceAlert = isAlertAlreadySet;
            });

            if (isAlertAlreadySet) {
              log('🎯 Price alert is already set for product ID: ${widget.productId}');
            } else {
              log('❌ No price alert found for product ID: ${widget.productId}');
            }
          }
        } catch (jsonError) {
          log('❌ Error parsing JSON response: $jsonError');
          log('📄 Raw response: $responseBody');
        }
      } else {
        log('❌ API call failed or returned error');
        log('📄 Response: $responseBody');

        // Set to false if API call fails
        if (mounted) {
          setState(() {
            _isSubscribedToPriceAlert = false;
          });
        }
      }
    } catch (e) {
      log('❌ Error checking if alert is already set: $e');

      // Set to false on error
      if (mounted) {
        setState(() {
          _isSubscribedToPriceAlert = false;
        });
      }
    }
  }

  /// Get user email from Firebase Auth
  Future<void> _getCurrentEmailId() async {
    log('Product Details Screen');
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null && user.email != null && user.email!.isNotEmpty) {
        emailId = user.email;
        log('✅ User email: $emailId');
      } else {
        emailId = null;
        log('❌ No authenticated user found');
      }
    } catch (e) {
      log('❌ Error getting user email: $e');
      emailId = null;
    }
  }

  Future<void> _checkIfLiked() async {
    try {
      int? actualVendorProductId;
      if (vendorProductData.isNotEmpty) {
        final currentProduct = vendorProductData.firstWhere(
          (product) => product.productId == widget.productId,
          orElse: () => vendorProductData.first,
        );
        actualVendorProductId = currentProduct.vendorProductId;
      }

      actualVendorProductId ??= int.parse('$vendorId${widget.productId}');

      // First check local database for quick UI response
      final localIsLiked = await LikedPreferencesDB.isProductLiked(
        vendorProductId: actualVendorProductId,
      );

      log('Local DB liked status: $localIsLiked for vendor_product_id: $actualVendorProductId');

      // Update UI immediately with local status
      if (mounted) {
        setState(() {
          isLiked = localIsLiked;
        });
        log('UI updated with local liked status: $localIsLiked');
      }

      // Then check server-side status if user is authenticated
      final userEmail = await _getUserEmail();
      if (userEmail != null && userEmail.isNotEmpty) {
        try {
          // Get liked products from server to check current product status
          final serverResponse = await BrandsApi.getLikedProduct(
            emailId: userEmail,
            context: context,
          );

          if (serverResponse != 'error' && serverResponse.isNotEmpty) {
            final serverLikedProducts = json.decode(serverResponse);
            log('Server response structure: ${serverLikedProducts.keys.toList()}');

            // Check both possible response structures
            List<dynamic> likedProducts = [];
            if (serverLikedProducts.containsKey('liked_products')) {
              likedProducts = serverLikedProducts['liked_products'] ?? [];
              log('Using liked_products array: ${likedProducts.length} items');
            } else if (serverLikedProducts.containsKey('brand_product')) {
              likedProducts = serverLikedProducts['brand_product'] ?? [];
              log('Using brand_product array: ${likedProducts.length} items');
            }

            // Check if current product is in server liked list
            bool serverIsLiked = false;
            if (likedProducts.isNotEmpty) {
              // Log first few products for debugging
              log('First 3 products from server: ${likedProducts.take(3).map((p) => {
                    'product_id': p['product_id'],
                    'product_name': p['product_name'] ?? 'Unknown'
                  }).toList()}');

              serverIsLiked = likedProducts.any((product) {
                final productId = product['product_id'];
                final isMatch = productId == widget.productId;
                log('Checking product $productId against current ${widget.productId}: $isMatch');
                return isMatch;
              });
            }

            log('Server liked status: $serverIsLiked for product ${widget.productId}');

            // If server status differs from local, handle the conflict
            if (serverIsLiked != localIsLiked) {
              log('Status conflict detected: Local=$localIsLiked, Server=$serverIsLiked');
              await _handleLikedStatusConflict(
                  localIsLiked, serverIsLiked, actualVendorProductId);
            }
          }
        } catch (e) {
          log('Error checking server-side liked status: $e');
          // Keep local status if server check fails
        }
      }

      log('Final product liked status: $isLiked for vendor_product_id: $actualVendorProductId');
    } catch (e) {
      log('Error checking if product is liked: $e');
    }
  }

  Future<void> _priceAlertDialog() async {
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          elevation: 8,
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white,
                  Colors.grey.shade50,
                ],
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header with icon
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.notifications_active,
                    size: 32,
                    color: AppColors.primary,
                  ),
                ),

                const SizedBox(height: 20),

                // Title
                const Text(
                  'Set Price Alert',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 12),

                // Subtitle
                Text(
                  'Get notified when ${widget.brandName} drops below your target price',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                    height: 1.4,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 24),

                // Email input field
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.1),
                        spreadRadius: 1,
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: TextField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      labelText: 'Enter your email address',
                      prefixIcon: const Icon(
                        Icons.email_outlined,
                        color: AppColors.primary,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide:
                            BorderSide(color: AppColors.primary, width: 2),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 16,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 32),

                // Action buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.of(context).pop(),
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: Colors.grey.shade400),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          'Cancel',
                          style: TextStyle(
                            color: Colors.grey[700],
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () async {
                          Navigator.of(context).pop();
                          await saveAlertedProductData();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Set Alert',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> saveAlertedProductData() async {
    setState(() {
      isLoading = true;
    });
    // await _testNotificationTap(context)
    await _showWelcomeNotification(
            context, widget.productId, widget.productPrice)
        .whenComplete(() async {
      await saveProductData(context, _emailController.text, widget.productPrice,
          widget.productId, deviceId ?? '');
    });
  }

  Future<void> saveProductData(BuildContext context, String emailId,
      String price, int productId, String deviceToken) async {
    log('saveProductData method running');
    log('emailId $emailId');
    log('price $price');
    log('productId $productId');
    log('deviceId $deviceToken');

    String finalDeviceID = deviceToken;

    if (isLoggedIn) {
      finalDeviceID = '';
      log('User is logged in, setting device ID to empty string');
    } else {
      log('User is not logged in, using device ID: ${deviceToken}...');
    }

    log('Final DeviceID to send to API: $finalDeviceID');

    await BrandsApi.savePriceAlert(
            context: context,
            emailId: emailId,
            price: price,
            productId: productId,
            deviceToken: finalDeviceID)
        .then((response) async {
      SharedPreferences preferences = await SharedPreferences.getInstance();
      if (response != 'error') {
        log('Data Successfully Saved');
        preferences.setString('email_id', emailId);
        preferences.setString('brand_name', widget.brandName);
        _initCall();
      } else {
        log('Error');
      }
    });
  }

  // Show welcome notification when price alert is set
  Future<void> _showWelcomeNotification(
      BuildContext context, int productId, String price) async {
    try {
      final notificationService = NotificationService();

      if (!notificationService.isInitialized) {
        await notificationService.initialize();
      }

      // Show welcome notification with product details
      await notificationService.showWelcomeDropNotification(
        productName: productDetails?.data?.productName ?? 'Product',
        productImage: widget.productImage?.toString(),
        productId: productId,
        currentPrice: price,
      );

      log('Welcome notification sent successfully for product: $productId');
    } catch (e) {
      log('Error showing welcome notification: $e');
      // Don't show error to user as this is just a welcome notification
    }
  }

  Future<void> _testNotificationTap(BuildContext context) async {
    try {
      final notificationService = NotificationService();

      if (!notificationService.isInitialized) {
        await notificationService.initialize();
      }

      await notificationService.showPriceDropNotification(
        productName: productDetails?.data?.productName ?? '---',
        oldPrice: widget.productPrice.toString(),
        newPrice: 00.00,
        productId: widget.productId,
        productImage: widget.productImage?.toString() ?? '',
      );

      CommonToasts.centeredMobile(
          context: context,
          msg:
              'Notification sent! Now tap on it to navigate to notification screen with product details.');
    } catch (e) {
      CommonToasts.centeredMobile(
          context: context, msg: 'Error testing notification tap: $e');
      log('Error in notification tap test: $e');
    }
  }

  Future<void> _checkIfInComparison() async {
    try {
      int? actualVendorProductId;
      if (vendorProductData.isNotEmpty) {
        final currentProduct = vendorProductData.firstWhere(
          (product) => product.productId == widget.productId,
          orElse: () => vendorProductData.first,
        );
        actualVendorProductId = currentProduct.vendorProductId;
      }

      actualVendorProductId ??= int.parse('$vendorId${widget.productId}');

      final isProductInComparison = await ComparisonDB.isInComparison(
        vendorProductId: actualVendorProductId,
      );

      final currentComparisonCount = await ComparisonDB.getComparisonCount();

      if (mounted) {
        setState(() {
          isInComparison = isProductInComparison;
          comparisonCount = currentComparisonCount;
        });
      }

      log('Product comparison status: $isInComparison for vendor_product_id: $actualVendorProductId');
      log('Total products in comparison: $comparisonCount');
    } catch (e) {
      log('Error checking if product is in comparison: $e');
    }
  }

  Future<void> _toggleComparison() async {
    try {
      int? actualVendorProductId;
      if (vendorProductData.isNotEmpty) {
        final currentProduct = vendorProductData.firstWhere(
          (product) => product.productId == widget.productId,
          orElse: () => vendorProductData.first,
        );
        actualVendorProductId = currentProduct.vendorProductId;
      }

      actualVendorProductId ??= int.parse('$vendorId${widget.productId}');

      final nowInComparison = await ComparisonDB.toggleComparison(
        productId: widget.productId,
        vendorProductId: actualVendorProductId,
        productName: productDetails?.data?.productName ?? 'Unknown Product',
        productImage: widget.productImage?.toString() ?? '',
        brandName: widget.brandName,
        productMpn: widget.productMPN,
        productPrice: widget.productPrice?.toString() ?? '0',
      );

      if (mounted) {
        setState(() {
          isInComparison = nowInComparison;
        });
      }

      await _checkIfInComparison();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(
                isInComparison
                    ? Icons.compare_arrows
                    : Icons.compare_arrows_outlined,
                color: Colors.white,
              ),
              SizedBox(width: 8),
              Text(isInComparison
                  ? 'Added to comparison!'
                  : 'Removed from comparison!'),
            ],
          ),
          backgroundColor: isInComparison ? Colors.orange : Colors.grey,
          duration: Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
        ),
      );

      log('Product ${isInComparison ? 'added to' : 'removed from'} comparison with vendor_product_id: $actualVendorProductId');
    } catch (e) {
      log('Error toggling comparison state: $e');

      // Show appropriate error message
      String errorMessage = 'Error updating comparison status';
      if (e.toString().contains('Maximum')) {
        errorMessage = 'Maximum 4 products can be compared at once';
      } else if (e.toString().contains('already in comparison')) {
        errorMessage = 'Product is already in comparison';
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 3),
        ),
      );
    }
  }

  /// Get user email from Firebase Auth
  Future<String?> _getUserEmail() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null && user.email != null && user.email!.isNotEmpty) {
        return user.email;
      }
      log('No authenticated user found or user email is empty');
      return null;
    } catch (e) {
      log('Error getting user email from Firebase Auth: $e');
      return null;
    }
  }

  /// Check if user is authenticated with Firebase
  bool _isUserAuthenticated() {
    try {
      final user = FirebaseAuth.instance.currentUser;
      return user != null && user.email != null && user.email!.isNotEmpty;
    } catch (e) {
      log('Error checking Firebase authentication: $e');
      return false;
    }
  }

  /// Get current Firebase user info for debugging
  Map<String, dynamic> _getCurrentUserInfo() {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        return {
          'uid': user.uid,
          'email': user.email,
          'displayName': user.displayName,
          'providerData': user.providerData.map((p) => p.providerId).toList(),
        };
      }
      return {};
    } catch (e) {
      log('Error getting current user info: $e');
      return {};
    }
  }

  /// Show authentication error message with helpful guidance
  void _showAuthErrorSnackBar() {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Authentication Required',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(
              'Please login with Firebase to save favorites',
              style: TextStyle(fontSize: 12),
            ),
          ],
        ),
        backgroundColor: Colors.orange,
        duration: Duration(seconds: 4),
        behavior: SnackBarBehavior.floating,
        action: SnackBarAction(
          label: 'Login',
          textColor: Colors.white,
          onPressed: () {
            // Navigate to login screen
            log('User requested to go to login screen');
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => LoginPage(
                  onLoginSuccess: () {
                    // Refresh liked status after successful login
                    _checkIfLiked();
                  },
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  /// Check if a product is liked on the server
  Future<bool?> _checkServerLikedStatus(
      String userEmail, int vendorProductId) async {
    try {
      final serverResponse = await BrandsApi.getLikedProduct(
        emailId: userEmail,
        context: context,
      );

      if (serverResponse != 'error' && serverResponse.isNotEmpty) {
        final serverLikedProducts = json.decode(serverResponse);
        log('Server response structure in _checkServerLikedStatus: ${serverLikedProducts.keys.toList()}');

        // Check both possible response structures
        List<dynamic> likedProducts = [];
        if (serverLikedProducts.containsKey('liked_products')) {
          likedProducts = serverLikedProducts['liked_products'] ?? [];
          log('Using liked_products array: ${likedProducts.length} items');
        } else if (serverLikedProducts.containsKey('brand_product')) {
          likedProducts = serverLikedProducts['brand_product'] ?? [];
          log('Using brand_product array: ${likedProducts.length} items');
        }

        // Check if current product is in server liked list
        bool serverIsLiked = false;
        if (likedProducts.isNotEmpty) {
          serverIsLiked = likedProducts.any((product) {
            final productId = product['product_id'];
            final isMatch = productId == widget.productId;
            log('Checking product $productId against current ${widget.productId}: $isMatch');
            return isMatch;
          });
        }

        log('Server liked status check: $serverIsLiked for product ${widget.productId}');
        return serverIsLiked;
      }

      log('Server response error or empty, cannot determine liked status');
      return null;
    } catch (e) {
      log('Error checking server liked status: $e');
      return null;
    }
  }

  /// Handle conflicts between local and server liked status
  Future<void> _handleLikedStatusConflict(
      bool localStatus, bool serverStatus, int vendorProductId) async {
    try {
      log('Handling liked status conflict: Local=$localStatus, Server=$serverStatus');

      // Show user notification about the conflict
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.sync, color: Colors.white),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Syncing favorites with server...',
                    style: TextStyle(fontSize: 12),
                  ),
                ),
              ],
            ),
            backgroundColor: Colors.blue,
            duration: Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }

      // Sync local DB with server status
      await _updateLocalDatabase(serverStatus, vendorProductId);

      // Update UI
      if (mounted) {
        setState(() {
          isLiked = serverStatus;
        });
        log('UI updated in conflict handler with server status: $serverStatus');
      }

      log('Successfully synced liked status conflict. Now using server status: $serverStatus');
    } catch (e) {
      log('Error handling liked status conflict: $e');
    }
  }

  /// Show appropriate message when user tries to like/unlike with current status
  void _showStatusMessage(bool currentStatus) {
    if (!mounted) return;

    final message = currentStatus
        ? 'Product is already in your favorites!'
        : 'Product is not in your favorites';

    final icon = currentStatus ? Icons.favorite : Icons.favorite_border;

    final color = currentStatus ? Colors.red : Colors.grey;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(icon, color: Colors.white),
            SizedBox(width: 8),
            Text(message),
          ],
        ),
        backgroundColor: color,
        duration: Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  /// Parse API response to check if it was successful
  bool _isApiResponseSuccessful(String response) {
    try {
      if (response.isEmpty || response == 'error') return false;

      // Try to parse JSON response
      final jsonResponse = json.decode(response);
      return jsonResponse['success'] == 1;
    } catch (e) {
      log('Error parsing API response: $e');
      return false;
    }
  }

  /// Update local database based on like status
  Future<void> _updateLocalDatabase(bool isLiked, int vendorProductId) async {
    try {
      if (isLiked) {
        await LikedPreferencesDB.addLikedProduct(
          productId: widget.productId,
          vendorProductId: vendorProductId,
          productName: productDetails?.data?.productName ?? 'Unknown Product',
          productImage: widget.productImage?.toString() ?? '',
          brandName: widget.brandName,
          productMpn: widget.productMPN,
          productPrice: widget.productPrice?.toString() ?? '0',
        );
        log('Product added to local favorites: $vendorProductId');
      } else {
        await LikedPreferencesDB.removeLikedProduct(
          vendorProductId: vendorProductId,
        );
        log('Product removed from local favorites: $vendorProductId');
      }
    } catch (e) {
      log('Error updating local database: $e');
      // Don't throw here as the API call was successful
    }
  }

  /// Show success snack bar for like/unlike action
  void _showSuccessSnackBar(bool isLiked) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              isLiked ? Icons.favorite : Icons.favorite_border,
              color: Colors.white,
            ),
            SizedBox(width: 8),
            Text(isLiked ? 'Added to favorites!' : 'Removed from favorites!'),
          ],
        ),
        backgroundColor: isLiked ? Colors.red : Colors.grey,
        duration: Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _toggleLiked() async {
    try {
      int? actualVendorProductId;
      if (vendorProductData.isNotEmpty) {
        final currentProduct = vendorProductData.firstWhere(
          (product) => product.productId == widget.productId,
          orElse: () => vendorProductData.first,
        );
        actualVendorProductId = currentProduct.vendorProductId;
      }

      actualVendorProductId ??= int.parse('$vendorId${widget.productId}');

      // Get user email from Firebase Auth
      final String? userEmail = await _getUserEmail();

      if (userEmail == null || userEmail.isEmpty) {
        // Log current user info for debugging
        final userInfo = _getCurrentUserInfo();
        log('No user email found. Current user info: $userInfo');

        _showAuthErrorSnackBar();
        return;
      }

      log('Using Firebase user email: $userEmail');

      // Check current like status from both local and server
      final localIsLiked = await LikedPreferencesDB.isProductLiked(
        vendorProductId: actualVendorProductId,
      );

      // Double-check server status to ensure consistency
      final serverIsLiked =
          await _checkServerLikedStatus(userEmail, actualVendorProductId);

      // Use server status as source of truth, fallback to local if server check fails
      final isCurrentlyLiked = serverIsLiked ?? localIsLiked;

      // If there's a mismatch, sync local DB with server
      if (serverIsLiked != null && serverIsLiked != localIsLiked) {
        await _updateLocalDatabase(serverIsLiked, actualVendorProductId);
        log('Synced local DB with server status: $serverIsLiked');
      }

      // Determine the action to take
      final action = isCurrentlyLiked ? 'unlike' : 'like';
      final status = isCurrentlyLiked ? 0 : 1; // 0 = unlike, 1 = like

      log('Attempting to $action product. Current status: $isCurrentlyLiked, Action: $action');

      // Show current status message for user awareness
      _showStatusMessage(isCurrentlyLiked);

      // Call API to save/remove liked product
      final apiResponse = await BrandsApi.saveLikedProduct(
        emailId: userEmail,
        productId: widget.productId,
        status: status,
      );

      if (_isApiResponseSuccessful(apiResponse)) {
        // API call successful, update local state
        final nowLiked = !isCurrentlyLiked;

        if (mounted) {
          setState(() {
            isLiked = nowLiked;
          });
        }

        // Update local DB for offline functionality
        await _updateLocalDatabase(nowLiked, actualVendorProductId);

        // Show success message
        _showSuccessSnackBar(nowLiked);

        log('Product successfully ${nowLiked ? 'added to' : 'removed from'} favorites via API with vendor_product_id: $actualVendorProductId');
      } else {
        // API call failed, show error
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content:
                Text('Failed to update favorite status. Please try again.'),
            backgroundColor: Colors.red,
          ),
        );
        log('API call failed for product: ${widget.productId}');
      }
    } catch (e) {
      log('Error toggling liked state: $e');

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error updating favorite status'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _fetchProductDetails() async {
    try {
      setState(() {
        isLoading = true;
        errorMessage = null;
      });

      final details = await BrandsApi.getProductDetails(
          brandName: widget.brandName,
          productMPN: widget.productMPN,
          productId: widget.productId,
          context: context);

      if (mounted) {
        setState(() {
          productDetails = details;
          vendorProductData = details.vendorProductData ?? [];
          isLoading = false; // Set loading to false after successful API call
          // Reset scroll button states when new data loads
          _canScrollLeft = false;
          _canScrollRight = vendorProductData.length > 1;
        });
        // Reset scroll position and update buttons after data is loaded
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            // Reset scroll position to start
            if (_scrollController.hasClients) {
              _scrollController.jumpTo(0);
            }
            // Update scroll buttons after layout
            Future.delayed(const Duration(milliseconds: 150), () {
              if (mounted) {
                _updateScrollButtons();
              }
            });
            Future.delayed(const Duration(milliseconds: 400), () {
              if (mounted) {
                _updateScrollButtons();
              }
            });
          }
        });
        log('Single API Data is');
        log('${productDetails?.toJson()}');
        log('Vendor Product Data count: ${vendorProductData.length}');
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          errorMessage = e.toString();
          isLoading = false;
        });
      }
    }
  }

  Future<void> _fetchBrandProducts() async {
    log('_fetchBrandProducts method is running');
    try {
      // Set loading state to true at the start
      if (mounted) {
        setState(() {
          _isLoadingBrandProducts = true;
          loadingMessage = 'Loading products... ';
        });
      }

      List<VendorProduct> allFetchedProducts = [];
      int pageNumber = 1;
      int maxPages = 5;
      int targetProducts = 20;

      while (pageNumber <= maxPages &&
          allFetchedProducts.length < targetProducts) {
        log('Fetching page $pageNumber');

        if (mounted) {
          setState(() {
            loadingMessage = 'Loading products... ';
          });
        }

        final allProductsResponse = await BrandsApi.getProductListByBrandName(
            widget.brandName.toString(), pageNumber, context);
        final Map<String, dynamic> decoded =
            jsonDecode(allProductsResponse ?? '{}');

        final List<dynamic> jsonList = decoded['brand_product'] ?? [];

        if (jsonList.isEmpty) {
          log('No more products found on page $pageNumber');
          break;
        }

        final List<VendorProduct> fetchedProducts = jsonList.map((e) {
          // Transform the product data to ensure proper price handling
          final productData = Map<String, dynamic>.from(e);

          // Get the first vendor price - check multiple possible fields
          String firstVendorPrice = '';
          if (productData['firstVendorPrice'] != null) {
            firstVendorPrice = productData['firstVendorPrice'].toString();
          } else if (productData['vendorprice_price'] != null) {
            firstVendorPrice = productData['vendorprice_price'].toString();
          } else if (productData['lowest_vendor'] != null &&
              (productData['lowest_vendor'] as List).isNotEmpty) {
            // Get price from lowest_vendor array
            final lowestVendor = (productData['lowest_vendor'] as List).first;
            if (lowestVendor['vendorprice_price'] != null) {
              firstVendorPrice = lowestVendor['vendorprice_price'].toString();
            }
          }

          // If still empty or "--", try to parse from vendorpricePrice
          if (firstVendorPrice.isEmpty ||
              firstVendorPrice == '--' ||
              firstVendorPrice == 'null') {
            firstVendorPrice =
                productData['vendorprice_price']?.toString() ?? '0.00';
          }

          // Calculate discount percentage if we have both prices
          double discountPercent = 0.0;
          final msrpValue = double.tryParse(productData['msrp']
                      ?.toString()
                      .replaceAll(RegExp(r'[^\d.]'), '') ??
                  '0') ??
              0.0;
          final priceValue = double.tryParse(
                  firstVendorPrice.replaceAll(RegExp(r'[^\d.]'), '')) ??
              0.0;

          if (msrpValue > 0 && priceValue > 0 && priceValue < msrpValue) {
            discountPercent = ((msrpValue - priceValue) / msrpValue) * 100;
          }

          // Update product data with calculated values - use firstVendorPrice for vendorprice_price if it's valid
          if (firstVendorPrice.isNotEmpty &&
              firstVendorPrice != '--' &&
              firstVendorPrice != 'null') {
            productData['vendorprice_price'] = firstVendorPrice;
          }
          productData['firstVendorPrice'] = firstVendorPrice;
          productData['discount_percent'] = discountPercent.toStringAsFixed(0);

          log('Product ${productData['product_id']}: firstVendorPrice=$firstVendorPrice, vendorprice_price=${productData['vendorprice_price']}, msrp=${productData['msrp']}, discount=$discountPercent%');

          return VendorProduct.fromJson(productData);
        }).toList();

        allFetchedProducts.addAll(fetchedProducts);
        log('Page $pageNumber: ${fetchedProducts.length} products, Total: ${allFetchedProducts.length}');
        if (pageNumber < maxPages &&
            allFetchedProducts.length < targetProducts) {
          await Future.delayed(const Duration(milliseconds: 100));
        }

        pageNumber++;
      }
      final List<VendorProduct> filteredProducts = allFetchedProducts
          .where((product) => product.productId != widget.productId)
          .toList();

      final List<VendorProduct> limitedProducts = filteredProducts.length > 20
          ? filteredProducts.take(20).toList()
          : filteredProducts;

      // List<String> uniqueVendorsLocal = getUniqueBrands(limitedProducts);
      // uniqueVendorsLocal =
      //     uniqueVendorsLocal.where((element1) => element1 != '--').toList();
      // List<String> tempList = [];
      // for (final vendor in uniqueVendorsLocal) {
      //   tempList.add(
      //       '$vendor Total Product(s): ${limitedProducts.where((element) => element.vendorName == vendor).toList().length} ');
      // }

      if (mounted) {
        setState(() {
          brandProducts = limitedProducts;
          // uniqueVendors = tempList;
          tempProductList = limitedProducts;
          finalList = limitedProducts;
          filterVendor = [];
          loadingMessage = 'Loading complete!';
          _isLoadingBrandProducts =
              false; // Set brand products loading to false
        });
      }

      log('Total Products fetched from all pages: ${allFetchedProducts.length}');
      log('Products after filtering current product: ${filteredProducts.length}');
      log('Final products to show: ${limitedProducts.length}');
      log('FinalList length: ${finalList.length}');
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingBrandProducts =
              false; // Set brand products loading to false on error
        });
      }
      log('Error in fetching Brand Product list: $e');
    }
  }

  Future<void> _refreshProductDetails() async {
    await _fetchProductDetails();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.brandName),
        backgroundColor: Colors.white,
        //  foregroundColor: Colors.black,
        elevation: 0,
        actionsPadding: EdgeInsets.only(right: 15),
        actions: const [
          Icon(
            Icons.shopping_cart,
            size: 35,
            color: AppColors.primary,
          )
        ],
      ),
      // bottomNavigationBar: MediaQuery.of(context).viewInsets.bottom != 0.0
      //     ? const SizedBox()
      //     : Container(
      //         height: 60,
      //         decoration: BoxDecoration(
      //           color: Colors.white,
      //           boxShadow: [
      //             BoxShadow(
      //               color: Colors.grey.withValues(alpha: 2),
      //               spreadRadius: 1,
      //               blurRadius: 5,
      //               offset: const Offset(0, -2),
      //             ),
      //           ],
      //         ),
      //       ),
      body: Stack(
        children: [
          RefreshIndicator(
            onRefresh: _refreshProductDetails,
            child: _buildBody(),
          ),
          if (comparisonCount > 0) _buildFloatingComparisonBar(),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (isLoading) {
      return const Center(
          child: Center(
        child: StylishLoader(
          type: LoaderType.wave,
          size: 80.0,
          primaryColor: AppColors.primary,
          text: "Loading Products..",
          textStyle: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: AppColors.primary,
          ),
        ),
      )
          // Column(
          //   mainAxisAlignment: MainAxisAlignment.center,
          //   children: [
          //     const CircularProgressIndicator(),
          //     const SizedBox(height: 16),
          //     Text(
          //       loadingMessage,
          //       style: Theme.of(context).textTheme.bodyMedium,
          //       textAlign: TextAlign.center,
          //     ),
          //   ],
          // ),
          );
    }

    if (errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red,
            ),
            const SizedBox(height: 16),
            Text(
              'Error loading product details',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              errorMessage!,
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _fetchProductDetails,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (productDetails?.data == null) {
      return const Center(
        child: Text('No product details available'),
      );
    }

    return Stack(children: [
      SafeArea(
        bottom: true,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildProductImages(),
              const SizedBox(height: 16),
              _buildProductHeader(),
              const SizedBox(height: 16),
              _buyAtName(),
              const SizedBox(height: 16),
              _buyAtDesign(),
              const SizedBox(height: 16),
              isAlertAlreadySet
                  ? _buildAlreadySubscribe()
                  : _buildSubscribeButton(),
              const SizedBox(height: 24),
              _buildProductActionsBar(),
              _buildMoreName(),
              const SizedBox(height: 16),
              _buildMoreDesign(),

              // Debug section
              const SizedBox(height: 24),
              //_buildDebugSection(),
            ],
          ),
        ),
      ),
      Positioned(
        left: 0,
        right: 0,
        bottom: 0,
        child: Builder(
          builder: (BuildContext context) {
            final MediaQueryData mediaQuery = MediaQuery.of(context);
            final double bottomPadding = mediaQuery.padding.bottom;
            if (bottomPadding > 0) {
              return Container(
                height: bottomPadding,
                color: Colors.blueGrey,
              );
            } else {
              return const SizedBox.shrink();
            }
          },
        ),
      ),
    ]);
  }

  Widget _buildProductHeader() {
    final data = productDetails!.data!;
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Text(data.productName ?? 'Product Name Not Available',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 0),
        Container(
          padding: const EdgeInsets.only(left: 12, right: 12),
          child: Row(children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      'Brand: ${data.brandName ?? widget.brandName}',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey[700],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      'ID: #${data.productSku ?? widget.productMPN}',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey[700],
                      ),
                    ),
                  ],
                ),
              ],
            ),
            Spacer(),
            Column(
              children: [
                _buildProductDetails(),
              ],
            )
          ]),
        ),
      ],
    );
  }

  Widget _buildProductImages() {
    final apiImages = productDetails!.data!.images;
    final fallbackImage = widget.productImage;

    if (apiImages != null && apiImages.isNotEmpty) {
      return Column(
        children: [
          Container(
            height: 280,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  spreadRadius: 2,
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: PageView.builder(
              itemCount: apiImages.length,
              itemBuilder: (context, index) {
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 8),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Stack(
                      children: [
                        // Main product image
                        Image.network(
                          apiImages[index],
                          width: double.infinity,
                          height: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              width: double.infinity,
                              height: double.infinity,
                              decoration: BoxDecoration(
                                color: Colors.grey[100],
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.broken_image,
                                    size: 48,
                                    color: Colors.grey[400],
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Image not available',
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                        // Zoom button overlay
                        Positioned(
                          top: 12,
                          right: 12,
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.6),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: IconButton(
                              icon: const Icon(
                                Icons.zoom_in,
                                color: Colors.white,
                                size: 20,
                              ),
                              onPressed: () {
                                _showImageFullScreen(apiImages[index]);
                              },
                            ),
                          ),
                        ),
                        // Image counter overlay
                        Positioned(
                          bottom: 12,
                          right: 12,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.7),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              '${index + 1}/${apiImages.length}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 16),
          // Image indicators
          if (apiImages.length > 1)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                apiImages.length,
                (index) => Container(
                  width: 8,
                  height: 8,
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: index == 0 ? AppColors.primary : Colors.grey[300],
                  ),
                ),
              ),
            ),
          const SizedBox(height: 8),
          // Thumbnail strip
          if (apiImages.length > 1)
            SizedBox(
              height: 80,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: apiImages.length,
                itemBuilder: (context, index) {
                  return Container(
                    margin: const EdgeInsets.only(right: 12),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: index == 0
                                ? AppColors.primary
                                : Colors.grey[300]!,
                            width: index == 0 ? 2 : 1,
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Image.network(
                          apiImages[index],
                          width: 80,
                          height: 80,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              width: 80,
                              height: 80,
                              color: Colors.grey[200],
                              child: Icon(
                                Icons.broken_image,
                                color: Colors.grey[400],
                                size: 24,
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
        ],
      );
    }

    if (fallbackImage != null && fallbackImage.toString().isNotEmpty) {
      return Container(
        height: 280,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 2,
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Stack(
            children: [
              Image.network(
                fallbackImage,
                width: double.infinity,
                height: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    width: double.infinity,
                    height: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.broken_image,
                          size: 48,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Image not available',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
              Positioned(
                right: 12,
                bottom: 12,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.6),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: IconButton(
                    icon: const Icon(
                      Icons.zoom_in,
                      color: Colors.white,
                      size: 18,
                    ),
                    onPressed: () {
                      _showImageFullScreen(fallbackImage);
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Container(
      height: 280,
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.grey[300]!,
          width: 1,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.image_not_supported,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No image available',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Product image will appear here',
            style: TextStyle(
              color: Colors.grey[500],
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  void _showImageFullScreen(String imageUrl) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            backgroundColor: Colors.white,
            iconTheme: const IconThemeData(color: Colors.black),
            elevation: 0,
            leading: IconButton(
              onPressed: () => Navigator.of(context).pop(),
              icon: const Icon(Icons.arrow_back_ios_new),
            ),
          ),
          body: Container(
            width: double.infinity,
            height: double.infinity,
            color: Colors.white,
            child: InteractiveViewer(
              maxScale: 5.0,
              minScale: 0.5,
              child: Center(
                child: Image.network(
                  imageUrl,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      width: double.infinity,
                      height: double.infinity,
                      color: Colors.grey[100],
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.broken_image,
                            size: 64,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Image not available',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProductDetails() {
    final data = productDetails!.data!;
    final brandData = {
      'brand_name': data.brandName ?? widget.brandName,
      'brand_key': (data.brandName ?? widget.brandName)
          .toString()
          .replaceAll(' ', '-')
          .toLowerCase(),
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        BrandImageWidget(brand: brandData, width: w * 0.3)
        // CachedNetworkImage(
        //   imageUrl:
        //       'https://www.minsellprice.com/Brand-logo-images/${data.brandName.toString().replaceAll(' ', '-').toLowerCase()}.png',
        //   width: 150,
        //   placeholder: (context, url) =>
        //       const Center(child: CircularProgressIndicator()),
        //   errorWidget: (context, url, error) => Image.asset(
        //     'assets/images/no_image.png',
        //     width: 150,
        //   ),
        // ),
      ],
    );
  }

  Widget _buildAlreadySubscribe() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.green.shade50,
            Colors.green.shade100,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.green.shade200,
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.green.shade100,
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Success Icon
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.green.shade500,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.green.shade300,
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Icon(
              Icons.notifications_active,
              color: Colors.white,
              size: 28,
            ),
          ),

          const SizedBox(height: 16),

          // Main Title
          Text(
            'Price Alert Active!',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.green.shade800,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 8),

          // Subtitle
          Text(
            'You\'ll be notified when the price drops',
            style: TextStyle(
              fontSize: 14,
              color: Colors.green.shade600,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 16),

          // Action Buttons Row
          Row(
            children: [
              // View Alerts Button
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    // TODO: Navigate to alerts screen
                    log('Navigate to alerts screen');
                    Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const AlertProduct()));
                  },
                  icon: Icon(
                    Icons.list_alt,
                    size: 18,
                    color: Colors.green.shade700,
                  ),
                  label: Text(
                    'View All Alerts',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.green.shade700,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.green.shade700,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                      side: BorderSide(
                        color: Colors.green.shade300,
                        width: 1.5,
                      ),
                    ),
                    elevation: 0,
                  ),
                ),
              ),

              const SizedBox(width: 12),

              // Manage Alert Button
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    // TODO: Show alert management options
                    log('Show alert management options');
                    _showDeleteConfirmationDialog();
                    //_showAlertManagementDialog();
                  },
                  icon: const Icon(
                    Icons.settings,
                    size: 18,
                    color: Colors.white,
                  ),
                  label: const Text(
                    'Manage Alert',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green.shade600,
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
        ],
      ),
    );
  }

  /// Show alert management dialog
  void _showAlertManagementDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Icon(
                Icons.settings,
                color: Colors.green.shade600,
                size: 24,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Manage Alert',
                  style: TextStyle(
                    color: Colors.green.shade800,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              // Close icon in top right
              GestureDetector(
                onTap: () {
                  Navigator.of(context).pop();
                },
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
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'What would you like to do with this price alert?',
                style: TextStyle(
                  color: Colors.grey.shade700,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 20),

              // Delete Alert Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.of(context).pop();
                    _showDeleteConfirmationDialog();
                  },
                  icon: Icon(
                    Icons.delete,
                    size: 18,
                    color: Colors.red.shade700,
                  ),
                  label: Text(
                    'Delete Alert',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.red.shade700,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red.shade50,
                    foregroundColor: Colors.red.shade700,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                      side: BorderSide(
                        color: Colors.red.shade200,
                        width: 1,
                      ),
                    ),
                    elevation: 0,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  /// Show delete confirmation dialog
  void _showDeleteConfirmationDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
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
              // Close icon in top right
              GestureDetector(
                onTap: () {
                  Navigator.of(context).pop();
                },
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
            'Are you sure you want to delete this price alert? You will no longer receive notifications for price drops on this product.',
            style: TextStyle(
              color: Colors.grey.shade700,
              fontSize: 14,
            ),
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();

                _deletePriceAlert();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade600,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                'Delete',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  /// Delete price alert
  Future<void> _deletePriceAlert() async {
    setState(() {
      isLoading = true;
    });
    try {
      log('🗑️ Deleting price alert for product ID: ${widget.productId}');

      // TODO: Implement delete API call
      await BrandsApi.deleteSavedPriceAlertProduct(
        emailId: emailId ?? '',
        deviceToken: deviceId,
        productId: widget.productId,
        context: context,
      );

      // Update UI state
      if (mounted) {
        setState(() {
          isAlertAlreadySet = false;
          _isSubscribedToPriceAlert = false;
        });
      }

      _initCall();

      CommonToasts.centeredMobile(
          msg: 'Price alert deleted successfully', context: context);

      log('✅ Price alert deleted successfully');
    } catch (e) {
      log('❌ Error deleting price alert: $e');

      CommonToasts.centeredMobile(
          msg: 'Failed to delete price alert', context: context);
    }
    setState(() {
      isLoading = false;
    });
  }

  Widget _buildSubscribeButton() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.grey.shade300,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title
          Text(
            'Wish to have a better price?',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade800,
            ),
          ),
          const SizedBox(height: 12),
          // Description
          Text(
            'We will bargain with the vendors and get you a special discount on this product.',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade700,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 20),
          // Email input field
          TextField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            decoration: InputDecoration(
              hintText: 'Enter your email',
              hintStyle: TextStyle(
                color: Colors.grey.shade400,
              ),
              filled: true,
              fillColor: Colors.grey.shade50,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(
                  color: Colors.grey.shade300,
                  width: 1,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(
                  color: Colors.grey.shade300,
                  width: 1,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(
                  color: AppColors.primary,
                  width: 2,
                ),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Submit button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isLoadingPriceAlert
                  ? null
                  : () {
                      if (_emailController.text.trim().isEmpty) {
                        CommonToasts.centeredMobile(
                          context: context,
                          msg: 'Please enter your email address',
                        );
                        return;
                      }
                      // Validate email format
                      final emailRegex = RegExp(
                          r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
                      if (!emailRegex.hasMatch(_emailController.text.trim())) {
                        CommonToasts.centeredMobile(
                          context: context,
                          msg: 'Please enter a valid email address',
                        );
                        return;
                      }
                      saveAlertedProductData();
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                elevation: 0,
              ),
              child: _isLoadingPriceAlert
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : const Text(
                      'Submit',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
            ),
          ),
          const SizedBox(height: 16),
          // Privacy statement
          Text(
            'We respect your privacy and will never share your email with third parties.',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
              height: 1.4,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildProductActionsBar() {
    // Debug logging for like button state
    log('Building product actions bar - isLiked: $isLiked');

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // _buildActionButton(
          //   icon: Icons.share,
          //   label: 'Share',
          //   color: Colors.blue,
          //   onTap: () {
          //     ScaffoldMessenger.of(context).showSnackBar(
          //       SnackBar(
          //         content: Row(
          //           children: [
          //             Icon(Icons.share, color: Colors.white),
          //             SizedBox(width: 8),
          //             Text('Product shared successfully!'),
          //           ],
          //         ),
          //         backgroundColor: Colors.blue,
          //         duration: Duration(seconds: 1),
          //         behavior: SnackBarBehavior.floating,
          //       ),
          //     );
          //   },
          // ),
          _buildActionButton(
            icon: isLiked ? Icons.favorite : Icons.favorite_border,
            label: 'Favorite',
            color: Colors.red,
            onTap: _toggleLiked,
          ),
          // Compare Button
          _buildActionButton(
            icon: isInComparison
                ? Icons.compare_arrows
                : Icons.compare_arrows_outlined,
            label: 'Compare',
            color: Colors.orange,
            onTap: _toggleComparison,
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: color.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: Colors.white,
                size: 20,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMoreName() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'More From ${widget.brandName}',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildMoreDesign() {
    log('_buildMoreDesign method is running');
    log('finalList length: ${finalList.length}, _isLoadingBrandProducts: $_isLoadingBrandProducts');

    // Show loader when brand products data is being fetched
    if (_isLoadingBrandProducts) {
      return Container(
        padding: const EdgeInsets.all(32),
        child: const Center(
          child: StylishLoader(
            type: LoaderType.wave,
            size: 60.0,
            primaryColor: AppColors.primary,
            text: "Loading products...",
            textStyle: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppColors.primary,
            ),
          ),
        ),
      );
    }

    // Show empty state only when loading is complete and list is empty
    if (finalList.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'No products available',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'More products will appear here when available.',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      );
    }

    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(), // because parent scrolls
      shrinkWrap: true,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      itemCount: finalList.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio:
            0.65, // Adjusted to accommodate larger bottom price section
      ),
      itemBuilder: (context, index) {
        final product = finalList[index];

        // Parse prices - handle "--" and invalid values
        String msrpStr = product.msrp;
        String vendorPriceStr = product.vendorpricePrice;

        // Clean and validate price strings
        if (msrpStr == '--' || msrpStr.isEmpty || msrpStr == 'null') {
          msrpStr = '0';
        }
        if (vendorPriceStr == '--' ||
            vendorPriceStr.isEmpty ||
            vendorPriceStr == 'null') {
          vendorPriceStr = '0';
        }

        final msrp =
            double.tryParse(msrpStr.replaceAll(RegExp(r'[^\d.]'), '')) ?? 0.0;
        final vendorPrice =
            double.tryParse(vendorPriceStr.replaceAll(RegExp(r'[^\d.]'), '')) ??
                0.0;

        // Calculate discount percentage
        double discountPercent = 0.0;
        if (msrp > 0 && vendorPrice > 0 && vendorPrice < msrp) {
          discountPercent = ((msrp - vendorPrice) / msrp) * 100;
        }

        // Hide MSRP and discount when discount is 0% (or effectively 0%)
        // Use epsilon for floating point comparison
        const double discountEpsilon = 0.1; // 0.1% discount threshold - hide if discount is less than 0.1%
        
        final discountIsZero = discountPercent.abs() < discountEpsilon;
        
        // Hide if discount is 0% or effectively 0%
        final shouldShowMsrpAndDiscount = !discountIsZero;

        // Log for debugging
        log('Product ${product.productId}: vendorPrice=$vendorPriceStr (parsed: $vendorPrice), msrp=$msrpStr (parsed: $msrp), discount=$discountPercent%');

        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ProductDetailsScreen(
                  productId: product.productId,
                  brandName: product.brandName.isNotEmpty
                      ? product.brandName
                      : widget.brandName,
                  productMPN: product.productMpn,
                  productImage: product.productImage,
                  productPrice: product.vendorpricePrice,
                ),
              ),
            );
          },
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey[200]!, width: 1),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  spreadRadius: 1,
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Product Image
                Container(
                  height: 90,
                  width: double.infinity,
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(16),
                      topRight: Radius.circular(16),
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: product.productImage.isEmpty ||
                            product.productImage.contains('no_image')
                        ? Container(
                            color: Colors.grey[100],
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.image_not_supported_outlined,
                                  size: 40,
                                  color: Colors.grey[400],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'No image',
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 10,
                                  ),
                                ),
                              ],
                            ),
                          )
                        : Image.network(
                            product.productImage,
                            fit: BoxFit.contain,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                color: Colors.grey[100],
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.image_not_supported_outlined,
                                      size: 40,
                                      color: Colors.grey[400],
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'No image',
                                      style: TextStyle(
                                        color: Colors.grey[600],
                                        fontSize: 10,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                  ),
                ),

                // Brand Logo
                Padding(
                  padding: const EdgeInsets.only(left: 8, top: 2, bottom: 2),
                  child: SizedBox(
                    height: 30,
                    width: 70,
                    child: BrandImageWidget(
                      brand: {
                        'brand_name': product.brandName.isNotEmpty
                            ? product.brandName
                            : widget.brandName,
                        'brand_key': product.brandName.isNotEmpty
                            ? product.brandName
                                .replaceAll(' ', '-')
                                .toLowerCase()
                            : widget.brandName
                                .replaceAll(' ', '-')
                                .toLowerCase(),
                        'brand_id': 0,
                      },
                      width: 70,
                      height: 30,
                    ),
                  ),
                ),

                // Product Details
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        // Model Number
                        if (product.productMpn.isNotEmpty &&
                            product.productMpn != '--')
                          Text(
                            product.productMpn,
                            style: TextStyle(
                              color: Colors.grey[700],
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        if (product.productMpn.isNotEmpty &&
                            product.productMpn != '--')
                          const SizedBox(height: 2),

                        // Product Name - Constrained to show 2 lines completely
                        Expanded(
                          child: Align(
                            alignment: Alignment.topLeft,
                            child: Text(
                              product.productName,
                              style: const TextStyle(
                                color: Colors.black87,
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                height: 1.2,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),

                        // Spacer to push price section to bottom
                        const SizedBox(height: 8),

                        // Price Section Container - Fixed at bottom with increased size
                        Container(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // Price Section - Fixed at bottom
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  // Current Price (discounted) - on the left
                                  Flexible(
                                    child: Text(
                                      vendorPrice > 0
                                          ? '\$${_formatPrice(vendorPriceStr)}'
                                          : '--',
                                      style: const TextStyle(
                                        color: Colors.black87,
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  // Original Price (strikethrough) - on the right, only show if discounted and not same as current price
                                  if (discountPercent > 0 &&
                                      msrp > 0 &&
                                      shouldShowMsrpAndDiscount)
                                    Flexible(
                                      child: Text(
                                        '\$${_formatPrice(product.msrp)}',
                                        style: TextStyle(
                                          color: Colors.grey[600],
                                          fontSize: 16,
                                          decoration:
                                              TextDecoration.lineThrough,
                                          decorationColor: Colors.grey[600],
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        textAlign: TextAlign.right,
                                      ),
                                    ),
                                ],
                              ),
                              // Discount Badge - only show if there's a discount and not same as MSRP
                              if (discountPercent > 0 &&
                                  shouldShowMsrpAndDiscount) ...[
                                const SizedBox(height: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: Colors.green[50],
                                    borderRadius: BorderRadius.circular(4),
                                    border: Border.all(
                                        color: Colors.green[200]!, width: 1),
                                  ),
                                  child: Text(
                                    '${discountPercent.toStringAsFixed(0)}% OFF',
                                    style: TextStyle(
                                      color: Colors.green[700],
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ],
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
      },
    );
  }

  /// Format price string to remove non-numeric characters and format
  String _formatPrice(String price) {
    try {
      final double? priceValue =
          double.tryParse(price.replaceAll(RegExp(r'[^\d.]'), ''));

      if (priceValue == null) {
        return price;
      }

      final formatter = NumberFormat('#,###.##');
      return formatter.format(priceValue);
    } catch (e) {
      return price;
    }
  }

  Widget _buyAtName() {
    return Row(
      children: [
        Text(
          'Buy At:',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buyAtDesign() {
    log('_buyAtDesign called with ${vendorProductData.length} vendor products');

    if (vendorProductData.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'No vendor data available',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.grey[600],
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Vendor pricing information will appear here when available.',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Builder(
          builder: (context) {
            // Initialize scroll state after layout
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) {
                // Reset initial state
                setState(() {
                  _canScrollLeft = false;
                  _canScrollRight = vendorProductData.length > 1;
                });
                // Multiple attempts to ensure scroll controller is ready
                Future.delayed(const Duration(milliseconds: 50), () {
                  if (mounted) {
                    _updateScrollButtons();
                  }
                });
                Future.delayed(const Duration(milliseconds: 200), () {
                  if (mounted) {
                    _updateScrollButtons();
                  }
                });
                Future.delayed(const Duration(milliseconds: 500), () {
                  if (mounted) {
                    _updateScrollButtons();
                  }
                });
              }
            });

            return Stack(
              children: [
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  controller: _scrollController,
                  physics: const BouncingScrollPhysics(),
                  child: Row(
                    children: vendorProductData.map((product) {
                      log('Rendering vendor: ${product.vendorName} with price: ${product.vendorpricePrice}');
                      return Container(
                        width: 160,
                        margin: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 8),
                        child: Card(
                          elevation: 3,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: InkWell(
                            onTap: () async {
                              log('Selected vendor: ${product.vendorName}');
                              await MyInAppBrowser().openUrlRequest(
                                urlRequest: URLRequest(
                                  url: WebUri(
                                    '${product.vendorUrl}',
                                  ),
                                ),
                              );
                              log('vendor URL: ${product.vendorUrl}');
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: Container(
                                      height: 80,
                                      width: double.infinity,
                                      color: Colors.white,
                                      child: _buildVendorLogo(
                                          product.vendorName ?? ''),
                                    ),
                                  ),
                                  Divider(
                                    color: Colors.grey,
                                  ),
                                  const SizedBox(height: 4),
                                  const Padding(
                                    padding: EdgeInsets.only(right: 10.0),
                                    child: Column(
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Text(
                                              '\$122',
                                              //'\$${_formatPrice(product.msrp)}',
                                              style: TextStyle(
                                                color: Colors.black,
                                                fontFamily: 'Segoe UI',
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold,
                                                decoration:
                                                    TextDecoration.lineThrough,
                                                decorationThickness: 2,
                                              ),
                                            ),
                                          ],
                                        ),
                                        Padding(
                                          padding: EdgeInsets.only(
                                              right: 0.0, top: 5),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.end,
                                            children: [
                                              Text(
                                                'Add to Cart Price:',
                                                style: TextStyle(
                                                  color: Colors.black,
                                                  fontFamily: 'Segoe UI',
                                                  fontSize: 16,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 3.0),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          '\$${product.vendorpricePrice ?? '--'} ',
                                          style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 20),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${product.vendorpriceDate ?? '--'}',
                                    style: const TextStyle(
                                        color: Colors.grey, fontSize: 16),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
                // Previous button on the left
                if (vendorProductData.length > 1)
                  Positioned(
                    left: 0,
                    top: 0,
                    bottom: 0,
                    child: AnimatedOpacity(
                      opacity: _canScrollLeft ? 1.0 : 0.0,
                      duration: const Duration(milliseconds: 200),
                      child: IgnorePointer(
                        ignoring: !_canScrollLeft,
                        child: GestureDetector(
                          onTap: _canScrollLeft ? _scrollToPrevious : null,
                          child: Container(
                            width: 50,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.centerRight,
                                end: Alignment.centerLeft,
                                colors: [
                                  Colors.white.withOpacity(0.0),
                                  Colors.white.withOpacity(0.9),
                                  Colors.white,
                                ],
                              ),
                            ),
                            child: Center(
                              child: Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  onTap: _scrollToPrevious,
                                  borderRadius: BorderRadius.circular(25),
                                  child: Container(
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color:
                                          AppColors.primary.withOpacity(0.15),
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color:
                                            AppColors.primary.withOpacity(0.4),
                                        width: 1.5,
                                      ),
                                    ),
                                    child: const Icon(
                                      Icons.arrow_back_ios,
                                      size: 18,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                // Next button on the right
                if (vendorProductData.length > 1)
                  Positioned(
                    right: 0,
                    top: 0,
                    bottom: 0,
                    child: AnimatedOpacity(
                      opacity: _canScrollRight ? 1.0 : 0.0,
                      duration: const Duration(milliseconds: 200),
                      child: IgnorePointer(
                        ignoring: !_canScrollRight,
                        child: GestureDetector(
                          onTap: _canScrollRight ? _scrollToNext : null,
                          child: Container(
                            width: 50,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.centerLeft,
                                end: Alignment.centerRight,
                                colors: [
                                  Colors.white.withOpacity(0.0),
                                  Colors.white.withOpacity(0.9),
                                  Colors.white,
                                ],
                              ),
                            ),
                            child: Center(
                              child: Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  onTap: _scrollToNext,
                                  borderRadius: BorderRadius.circular(25),
                                  child: Container(
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color:
                                          AppColors.primary.withOpacity(0.15),
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color:
                                            AppColors.primary.withOpacity(0.4),
                                        width: 1.5,
                                      ),
                                    ),
                                    child: Icon(
                                      Icons.arrow_forward_ios,
                                      size: 18,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      ],
    );
  }

  Widget _buildVendorLogo(String vendorName) {
    String logoPath =
        'https://growth.matridtech.net/vendor-logo/$vendorName.jpg';

    return Image.network(
      logoPath,
      fit: BoxFit.contain,
      errorBuilder: (context, error, stackTrace) {
        return Container(
          padding: const EdgeInsets.all(8),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            vendorName,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
        );
      },
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return Container(
          padding: const EdgeInsets.all(8),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(8),
          ),
          child: CircularProgressIndicator(
            value: loadingProgress.expectedTotalBytes != null
                ? loadingProgress.cumulativeBytesLoaded /
                    loadingProgress.expectedTotalBytes!
                : null,
            strokeWidth: 2,
          ),
        );
      },
    );
  }

  Future<void> _processApiDataForNotifications(
      dynamic data, String email, String deviceToken) async {
    log('🔧 Processing API data for notifications...');

    try {
      // Process API response based on authentication status
      if (data is List) {
        log('🔍 Processing List response with ${data.length} items');

        // Process each item in the list
        for (int i = 0; i < data.length; i++) {
          final item = data[i];
          log('📦 Processing item $i: $item');

          if (item is Map<String, dynamic>) {
            await _processNotificationItem(item, deviceToken, email);
          } else {
            log('⚠️ Item $i is not a Map: ${item.runtimeType}');
          }
        }
      } else if (data is Map<String, dynamic>) {
        log('🔍 Processing single Map response: ${data.keys.toList()}');
        await _processNotificationItem(data, deviceToken, email);
      } else {
        log('⚠️ Response is neither List nor Map, cannot process: ${data.runtimeType}');
      }

      log('✅ Data processing completed');
    } catch (e) {
      log('❌ Error processing API data: $e');
    }
  }

  bool _validateNotificationData(Map<String, dynamic> data) {
    try {
      log('🔍 Validating notification data completeness...');

      // Check required fields exist and are not empty
      final requiredFields = [
        'product_name',
        'OldPrice',
        'NewPrice',
        'product_id',
        'product_image'
      ];

      for (String field in requiredFields) {
        final value = data[field];
        if (value == null ||
            value.toString().isEmpty ||
            value.toString() == '---') {
          log('❌ Validation failed: $field is empty or null ($value)');
          return false;
        }
      }

      // Check if prices are valid numbers
      final oldPrice = double.tryParse(data['OldPrice']?.toString() ?? '');
      final newPrice = double.tryParse(data['NewPrice']?.toString() ?? '');

      if (oldPrice == null || newPrice == null) {
        log('❌ Validation failed: Invalid price format');
        log('   Old Price: ${data['OldPrice']} (parsed: $oldPrice)');
        log('   New Price: ${data['NewPrice']} (parsed: $newPrice)');
        return false;
      }

      // Check if prices are valid (but don't require price drop)
      log('✅ Prices are valid: Old Price: $oldPrice, New Price: $newPrice');
      log('📊 Price difference: ${newPrice - oldPrice}');

      // Check if product ID is valid
      final productId = int.tryParse(data['product_id']?.toString() ?? '');
      if (productId == null || productId <= 0) {
        log('❌ Validation failed: Invalid product ID: ${data['product_id']}');
        return false;
      }

      // Check if image URL is valid
      final imageUrl = data['product_image']?.toString() ?? '';
      if (imageUrl.isEmpty || !imageUrl.startsWith('http')) {
        log('❌ Validation failed: Invalid image URL: $imageUrl');
        return false;
      }

      log('✅ All data completeness checks passed:');
      log('   Product Name: ${data['product_name']}');
      log('   Old Price: $oldPrice');
      log('   New Price: $newPrice');
      log('   Product ID: $productId');
      log('   Image URL: $imageUrl');
      log('   📊 Data is complete and ready for notification');

      return true;
    } catch (e) {
      log('❌ Error during data validation: $e');
      return false;
    }
  }

  Future<void> _autoTriggerNotification(Map<String, dynamic> data) async {
    try {
      log('Auto-triggering notification for product: ${data['product_name']}');

      // Store notification data for immediate UI consumption
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('auto_notification_triggered', true);
      await prefs.setString(
          'auto_notification_product_name', data['product_name'] ?? '---');
      await prefs.setString('auto_notification_old_price',
          data['OldPrice']?.toString() ?? '0.00');
      await prefs.setString('auto_notification_new_price',
          data['NewPrice']?.toString() ?? '0.00');
      await prefs.setString('auto_notification_product_id',
          data['product_id']?.toString() ?? '0');
      await prefs.setString(
          'auto_notification_product_image', data['product_image'] ?? '');
      await prefs.setString('auto_notification_timestamp',
          data['DataNTime'] ?? DateTime.now().toIso8601String());

      log('Auto-notification data stored successfully');
    } catch (e) {
      log('Error in auto-trigger notification: $e');
    }
  }

  Future<void> _processNotificationItem(
      Map<String, dynamic> item, String deviceToken, String email) async {
    log('🔍 Processing notification item: ${item.keys.toList()}');

    try {
      // Check if this is a price drop notification
      if (item.containsKey('device_token') && item.containsKey('product_id')) {
        final responseDeviceToken = item['device_token'];
        final responseEmail = item['email'];

        log('🔍 Processing notification data:');
        log('   Response device token: $responseDeviceToken');
        log('   Response email: $responseEmail');
        log('   Current device token: $deviceToken');
        log('   Current user email: $email');
        log('   User login status: ${email.isNotEmpty ? "LOGGED IN" : "NOT LOGGED IN"}');

        bool shouldShowNotification = false;

        if (email.isNotEmpty) {
          // User is logged in - check email matches (device token can be anything)
          if (responseEmail == email) {
            shouldShowNotification = true;
            log('✅ User logged in - email matches (showing notification)');
          } else {
            log('❌ User logged in - notification conditions not met:');
            log('   Response email: $responseEmail, Current email: $email');
          }
        } else {
          // User is not logged in - check device token matches
          if (responseDeviceToken == deviceToken) {
            shouldShowNotification = true;
            log('✅ User not logged in - device token matches (showing notification)');
          } else {
            log('❌ User not logged in - device token does not match:');
            log('   Response device token: $responseDeviceToken');
            log('   Current device token: $deviceToken');
          }
        }

        if (shouldShowNotification) {
          log('🎉 NOTIFICATION APPROVED! Auto-triggering for product: ${item['product_name']}');
          log('📊 Notification details:');
          log('   Product: ${item['product_name']}');
          log('   Old Price: ${item['OldPrice']}');
          log('   New Price: ${item['NewPrice']}');
          log('   Product ID: ${item['product_id']}');

          // Check if data is not empty before showing notification
          bool isDataValid = _validateNotificationData(item);

          if (isDataValid) {
            log('✅ Data validation passed - showing notification on device');

            // Auto-trigger notification when conditions are met
            await _autoTriggerNotification(item);

            log('✅ Notification triggered successfully!');
          } else {
            log('❌ Data validation failed - notification data is empty or invalid');
            log('⚠️ Skipping notification due to invalid data');
          }
        } else {
          log('❌ Notification conditions not met, skipping');
        }
      } else {
        log('❌ Invalid item format - missing required fields');
      }
    } catch (e) {
      log('❌ Error processing notification item: $e');
    }
  }

  Future<void> _testApiCall() async {
    log('🧪 Starting manual API test...');

    try {
      // Get device token
      DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
      String deviceToken = '';

      if (Platform.isAndroid) {
        AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
        deviceToken = androidInfo.id;
        log('📱 Android Unique ID: $deviceToken');
      }

      // Get user email
      String email = '';
      final user = FirebaseAuth.instance.currentUser;
      if (user != null && user.email != null && user.email!.isNotEmpty) {
        email = user.email!;
        log('✅ User email: $email');
      }

      // Construct API URL
      String apiUrl;
      if (email.isNotEmpty) {
        apiUrl =
            'https://growth.matridtech.net/api/fetch-product-data?email=$email';
        log('✅ Calling API with email: $email');
      } else {
        apiUrl =
            'https://growth.matridtech.net/api/fetch-product-data?device_token=$deviceToken';
        log('✅ Calling API with device token: $deviceToken');
      }

      log('🌐 Making API call to: $apiUrl');

      // Make the API call
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ).timeout(const Duration(seconds: 30));

      log('📥 API Response received');
      log('📊 Status: ${response.statusCode}');
      log('📏 Body length: ${response.body.length}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        log('✅ API call successful!');
        log('📊 Response type: ${data.runtimeType}');
        log('🔍 Response data: $data');

        // Process the data for notifications (same logic as WorkManager)
        log('🔧 Processing data for notifications...');
        await _processApiDataForNotifications(data, email, deviceToken);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                  '✅ API call successful! Data length: ${data is List ? data.length : 1}'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        log('❌ API call failed with status: ${response.statusCode}');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('❌ API call failed: HTTP ${response.statusCode}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      log('❌ Manual API test failed: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ API test failed: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Widget _buildFloatingComparisonBar() {
    return Positioned(
      bottom: 20,
      left: 16,
      right: 16,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.orange,
              Colors.orange.withOpacity(0.8),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(25),
          boxShadow: [
            BoxShadow(
              color: Colors.orange.withOpacity(0.3),
              spreadRadius: 2,
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(25),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ComparisonScreen(),
                ),
              );
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.compare_arrows,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Compare Products',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '$comparisonCount product${comparisonCount > 1 ? 's' : ''} ready to compare',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Text(
                    comparisonCount.toString(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

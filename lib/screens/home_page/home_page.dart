import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:minsellprice/core/apis/apis_calls.dart';
import 'package:minsellprice/core/utils/constants/colors.dart';
import 'package:minsellprice/core/utils/constants/size.dart';
import 'package:minsellprice/model/saved_product_model.dart';
import 'package:minsellprice/reposotory_services/database/database_functions.dart';
import 'package:minsellprice/screens/account_screen/account_screen.dart';
import 'package:minsellprice/screens/categories_provider/categories_provider_file.dart';
import 'package:minsellprice/screens/categories_screen/categories_screen.dart';
import 'package:minsellprice/screens/dashboard_screen/dashboard_screen.dart';
import 'package:minsellprice/screens/liked_product_screen/liked_product_api.dart';
import 'package:minsellprice/screens/liked_product_screen/liked_product_screen.dart';
import 'package:minsellprice/services/notification_service.dart';
import 'package:provider/provider.dart';
import 'package:salomon_bottom_bar/salomon_bottom_bar.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';

import 'notification_screen/notification_screen.dart';
import 'package:minsellprice/services/work_manager_service.dart';

class HomePage extends StatefulWidget {
  const HomePage({
    super.key,
  });

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with TickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  int vendorId = 0;
  int _activeIndex = 0;

  List<Widget> _screens = [];

  Map<String, dynamic> userData = {};

  String vendorName = '';
  String emailId = '';

  bool hasUnreadNotifications = false;
  bool isWorkManagerRunning = false;
  DateTime? lastApiExecution;
  DateTime? nextApiExecution;

  late Database database;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  StreamSubscription<User?>? _authStateSubscription;

  bool isLoggedIn = false;

  @override
  void initState() {
    // TODO: implement initState
    _screens = [
      const Center(
        child: CircularProgressIndicator(),
      )
    ];

    super.initState();
    _initCall();
  }

  void _initCall() async {
    await _initializeDatabase();

    // Initialize WorkManager for background API calls
    await _initializeWorkManager();

    _authStateSubscription =
        FirebaseAuth.instance.authStateChanges().listen((User? user) {
      if (mounted) {
        if (user != null && user.email != null) {
          setState(() {
            isLoggedIn = true;
            emailId = user.email!;
          });
          log('Home Screen');
          log('User Logged ?');
          _checkNotificationStatus(emailId);

          // Start WorkManager task when user is logged in
       //   _startWorkManagerTask();
        } else {
          setState(() {
            isLoggedIn = false;
            emailId = '';
          });
          log('User Not Login');

          // Stop WorkManager task when user logs out
          _stopWorkManagerTask();
        }
      }
    });
  }

  Future<void> _checkNotificationStatus(String emailId) async {
    try {
      final response = await BrandsApi.fetchSavedProductData(
        emailId: emailId,
        context: context,
      );

      if (response != 'error') {
        final List<dynamic> jsonData = json.decode(response);
        final List<SavedProductModel> products =
            jsonData.map((item) => SavedProductModel.fromJson(item)).toList();

        final hasUnread = products.any((product) => product.isRead == 0);

        if (mounted) {
          setState(() {
            hasUnreadNotifications = hasUnread;
          });
        }

        log('Notification status: ${hasUnread ? 'Has unread' : 'All read'}');
      }
    } catch (e) {
      log('Error checking notification status: $e');
    }
  }

  // Initialize WorkManager service
  Future<void> _initializeWorkManager() async {
    try {
      await WorkManagerService.initialize();
      log('WorkManager initialized in HomePage');
    } catch (e) {
      log('Error initializing WorkManager in HomePage: $e');
    }
  }

  // Start WorkManager periodic task
  Future<void> _startWorkManagerTask() async {
    try {
      await WorkManagerService.startPeriodicTask();
      log('WorkManager task started in HomePage');

      // Check status after starting
      await Future.delayed(const Duration(seconds: 2));
      await _checkWorkManagerStatus();
      _showWelcomeNotification(context, 22, '454');
    } catch (e) {
      log('Error starting WorkManager task in HomePage: $e');
    }
  }

  // Stop WorkManager periodic task
  Future<void> _stopWorkManagerTask() async {
    try {
      await WorkManagerService.stopPeriodicTask();
      log('WorkManager task stopped in HomePage');
    } catch (e) {
      log('Error stopping WorkManager task in HomePage: $e');
    }
  }

  // Check WorkManager status and update UI
  Future<void> _checkWorkManagerStatus() async {
    try {
      final isRunning = await WorkManagerService.isTaskRunning();
      final lastExecution = await WorkManagerService.getLastExecutionTime();
      final nextExecution = await WorkManagerService.getNextExecutionTime();

      if (mounted) {
        setState(() {
          isWorkManagerRunning = isRunning;
          lastApiExecution = lastExecution;
          nextApiExecution = nextExecution;
        });
      }
    } catch (e) {
      log('Error checking WorkManager status: $e');
    }
  }

  // Refresh WorkManager status
  Future<void> _refreshWorkManagerStatus() async {
    await _checkWorkManagerStatus();
  }

  // Manual test API call for debugging
  Future<void> _manualTestApiCall() async {
    try {
      log('Manual API test triggered');

      // Show a simple toast or snackbar to indicate the test
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Manual API test triggered - check logs for details'),
            duration: Duration(seconds: 2),
          ),
        );
      }

      // You can add actual API call logic here if needed
      // For now, just log the action
      log('Manual API test completed');
    } catch (e) {
      log('Error in manual API test: $e');
    }
  }

  Future<void> _showWelcomeNotification(
      BuildContext context, int productId, String price) async {
    log('test notification');
    try {
      final notificationService = NotificationService();

      if (!notificationService.isInitialized) {
        await notificationService.initialize();
      }

      // Show welcome notification with product details
      await notificationService.showWelcomeDropNotification(
        productName: 'Product',
        productImage: '',
        productId: productId,
        currentPrice: price,
      );

      log('Welcome notification sent successfully for product: $productId');
    } catch (e) {
      log('Error showing welcome notification: $e');
      // Don't show error to user as this is just a welcome notification
    }
  }

  Future<void> _initializeDatabase() async {
    try {
      final db = await DatabaseHelper().database ??
          await DatabaseHelper().initDatabase();
      if (mounted) {
        setState(() {
          database = db;
          _screens = [
            ChangeNotifierProvider(
              create: (context) {
                final provider = BrandsProvider();
                // Start fetching brands immediately for faster loading
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  provider.fetchBrands();
                });
                return provider;
              },
              child: DashboardScreenWidget(),
            ),
            //   LikedProduct(database: db),
            LikedProductScreen(),
            ChangeNotifierProvider(
              create: (context) {
                final provider = BrandsProvider();
                // Start fetching brands immediately for faster loading
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  provider.fetchBrands();
                });
                return provider;
              },
              child: CategoriesScreen(database: db),
            ),
            AccountScreen(),
          ];
        });
      }
    } catch (e) {
      log('Dashboard database initialization error: $e');
      if (mounted) {
        setState(() {
          _screens = [
            ChangeNotifierProvider(
              create: (context) {
                final provider = BrandsProvider();
                provider.fetchBrands();
                return provider;
              },
              child: DashboardScreenWidget(),
            ),
            //LikedProduct(database: database),
            LikedProductScreen(),
            ChangeNotifierProvider(
              create: (context) {
                final provider = BrandsProvider();
                provider.fetchBrands();
                return provider;
              },
              child: CategoriesScreen(database: database),
            ),
            AccountScreen(),
          ];
        });
      }
    }
  }

  // Future<void> _showExampleNotifications() async {
  //   final notificationService = NotificationService();
  //   await notificationService.showPriceDropNotification(
  //     productName: 'Example Product',
  //     oldPrice: 99.99,
  //     newPrice: 79.99,
  //     productId: 'example_product_123',
  //   );
  // }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    if (_screens.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Stack(
        children: [
          Scaffold(
            key: scaffoldKey,
            extendBody: true,
            resizeToAvoidBottomInset: false,
            // appBar: AppBar(
            //   backgroundColor: Colors.white,
            //   surfaceTintColor: Colors.transparent,
            //   elevation: 0,
            //   toolbarHeight: 80,
            //   centerTitle: true,
            //   automaticallyImplyLeading: false,
            //   title:
            //   Row(
            //     mainAxisSize: MainAxisSize.min,
            //     children: [
            //       Icon(
            //         Icons.show_chart,
            //         color: AppColors.primary,
            //         size: 24,
            //       ),
            //       const SizedBox(width: 8),
            //       Text(
            //         'MinSellPrice',
            //         style: TextStyle(
            //           color: AppColors.primary,
            //           fontSize: 20,
            //           fontWeight: FontWeight.bold,
            //           fontFamily: 'Segoe UI',
            //         ),
            //       ),
            //     ],
            //   ),
            //   actionsPadding: const EdgeInsets.only(right: 15),
            //   actions: const [
            //     Icon(Icons.shopping_cart, size: 35, color: AppColors.primary),
            //   ],
            // ),
            appBar: AppBar(
              backgroundColor: Colors.white,
              surfaceTintColor: Colors.transparent,
              elevation: 0,
              toolbarHeight: 80,
              centerTitle: true,
              automaticallyImplyLeading: false,
              title: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.white,
                      Colors.grey[50]!,
                    ],
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
                  children: [
                    // Header Section
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 20),
                      child: Row(
                        children: [
                          // App Logo
                          Expanded(
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: AppColors.primary,
                                    borderRadius: BorderRadius.circular(12),
                                    boxShadow: [
                                      BoxShadow(
                                        color:
                                            AppColors.primary.withOpacity(0.3),
                                        spreadRadius: 1,
                                        blurRadius: 4,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: Icon(
                                    Icons.shopping_bag,
                                    color: Colors.white,
                                    size: w * .06,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'MinSellPrice',
                                        style: TextStyle(
                                          color: AppColors.primary,
                                          fontSize: w * .05,
                                          fontWeight: FontWeight.bold,
                                          fontFamily: 'Segoe UI',
                                        ),
                                      ),
                                      Text(
                                        'Find the best prices',
                                        style: TextStyle(
                                          color: Colors.grey[600],
                                          fontSize: w * .025,
                                          fontWeight: FontWeight.w500,
                                          fontFamily: 'Segoe UI',
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // Action Buttons
                          Row(
                            children: [
                              // WorkManager Status Indicator
                              // if (isLoggedIn) ...[
                              //   Container(
                              //     margin: const EdgeInsets.only(right: 12),
                              //     decoration: BoxDecoration(
                              //       color: isWorkManagerRunning
                              //           ? Colors.green
                              //           : Colors.orange,
                              //       borderRadius: BorderRadius.circular(8),
                              //       boxShadow: [
                              //         BoxShadow(
                              //           color: Colors.grey.withOpacity(0.1),
                              //           spreadRadius: 1,
                              //           blurRadius: 3,
                              //           offset: const Offset(0, 1),
                              //         ),
                              //       ],
                              //     ),
                              //     child: Material(
                              //       color: Colors.transparent,
                              //       child: InkWell(
                              //         borderRadius: BorderRadius.circular(8),
                              //         onTap: _refreshWorkManagerStatus,
                              //         child: Container(
                              //           padding: const EdgeInsets.symmetric(
                              //               horizontal: 8, vertical: 4),
                              //           child: Row(
                              //             mainAxisSize: MainAxisSize.min,
                              //             children: [
                              //               Icon(
                              //                 isWorkManagerRunning
                              //                     ? Icons.sync
                              //                     : Icons.sync_disabled,
                              //                 color: Colors.white,
                              //                 size: 16,
                              //               ),
                              //               const SizedBox(width: 4),
                              //               Text(
                              //                 isWorkManagerRunning
                              //                     ? 'API Active'
                              //                     : 'API Inactive',
                              //                 style: const TextStyle(
                              //                   color: Colors.white,
                              //                   fontSize: 10,
                              //                   fontWeight: FontWeight.w600,
                              //                 ),
                              //               ),
                              //             ],
                              //           ),
                              //         ),
                              //       ),
                              //     ),
                              //   ),
                              //
                              //   // Manual Test Button
                              //   Container(
                              //     margin: const EdgeInsets.only(right: 12),
                              //     decoration: BoxDecoration(
                              //       color: Colors.blue,
                              //       borderRadius: BorderRadius.circular(8),
                              //       boxShadow: [
                              //         BoxShadow(
                              //           color: Colors.grey.withOpacity(0.1),
                              //           spreadRadius: 1,
                              //           blurRadius: 3,
                              //           offset: const Offset(0, 1),
                              //         ),
                              //       ],
                              //     ),
                              //     child: Material(
                              //       color: Colors.transparent,
                              //       child: InkWell(
                              //         borderRadius: BorderRadius.circular(8),
                              //         onTap: () async {
                              //           // Manually trigger API call for testing
                              //           await _manualTestApiCall();
                              //         },
                              //         child: Container(
                              //           padding: const EdgeInsets.symmetric(
                              //               horizontal: 8, vertical: 4),
                              //           child: Row(
                              //             mainAxisSize: MainAxisSize.min,
                              //             children: [
                              //               Icon(
                              //                 Icons.play_arrow,
                              //                 color: Colors.white,
                              //                 size: 16,
                              //               ),
                              //               const SizedBox(width: 4),
                              //               Text(
                              //                 'Test API',
                              //                 style: const TextStyle(
                              //                   color: Colors.white,
                              //                   fontSize: 10,
                              //                   fontWeight: FontWeight.w600,
                              //                 ),
                              //               ),
                              //             ],
                              //           ),
                              //         ),
                              //       ),
                              //     ),
                              //   ),
                              // ],

                              // Notifications
                              Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.grey.withOpacity(0.1),
                                      spreadRadius: 1,
                                      blurRadius: 3,
                                      offset: const Offset(0, 1),
                                    ),
                                  ],
                                ),
                                child: Material(
                                  color: Colors.transparent,
                                  child: InkWell(
                                    borderRadius: BorderRadius.circular(12),
                                    onTap: () async {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              const NotificationScreen(),
                                        ),
                                      );
                                      await _checkNotificationStatus(emailId);
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.all(10),
                                      child: Stack(
                                        children: [
                                          Icon(
                                            Icons.notifications_outlined,
                                            color: Colors.grey[700],
                                            size: w * .07,
                                          ),
                                          if (hasUnreadNotifications)
                                            Positioned(
                                              right: 0,
                                              top: 0,
                                              child: Container(
                                                width: 8,
                                                height: 8,
                                                decoration: BoxDecoration(
                                                  color: Colors.red,
                                                  shape: BoxShape.circle,
                                                ),
                                              ),
                                            ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            bottomNavigationBar: MediaQuery.of(context).viewInsets.bottom != 0.0
                ? const SizedBox()
                : SalomonBottomBar(
                    backgroundColor: Colors.white,
                    currentIndex: _activeIndex,
                    onTap: (i) => setState(() => _activeIndex = i),
                    items: [
                      SalomonBottomBarItem(
                        icon: const Icon(Icons.space_dashboard),
                        title: const Text("Dashboard"),
                        selectedColor: AppColors.primary,
                      ),
                      SalomonBottomBarItem(
                        icon: const Icon(Icons.favorite_border),
                        title: const Text("Likes"),
                        selectedColor: AppColors.primary,
                      ),
                      SalomonBottomBarItem(
                        icon: const Icon(Icons.category),
                        title: const Text("Categories"),
                        selectedColor: AppColors.primary,
                      ),
                      SalomonBottomBarItem(
                        icon: const Icon(Icons.account_circle_rounded),
                        title: const Text("Account"),
                        selectedColor: AppColors.primary,
                      ),
                    ],
                  ),
            body: _screens[_activeIndex],
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
        ],
      ),
    );
  }

  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;
}

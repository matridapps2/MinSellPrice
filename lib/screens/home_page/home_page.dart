import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
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
import 'package:minsellprice/widgets/category_shimmer.dart';
import 'package:provider/provider.dart';
import 'package:salomon_bottom_bar/salomon_bottom_bar.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';

import '../categories_menu_screen.dart';
import 'notification_screen/notification_screen.dart';
import 'package:minsellprice/services/work_manager_service.dart';
import 'package:minsellprice/services/app_notification_service.dart';
import 'package:minsellprice/core/mixins/notification_mixin.dart';

class HomePage extends StatefulWidget {
  const HomePage({
    super.key,
  });

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with
        TickerProviderStateMixin,
        AutomaticKeepAliveClientMixin,
        NotificationMixin {
  int vendorId = 0;
  int _activeIndex = 0;

  List<Widget> _screens = [];

  Map<String, dynamic> userData = {};

  String vendorName = '';
  String emailId = '';
  String? _deviceId;

  bool hasUnreadNotifications = false;
  bool isWorkManagerRunning = false;
  DateTime? lastApiExecution;
  DateTime? nextApiExecution;

  late Database database;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  StreamSubscription<User?>? _authStateSubscription;

  bool isLoggedIn = false;

  // App notification service for handling automatic notifications
  AppNotificationService? _appNotificationService;

  @override
  void initState() {
    // TODO: implement initState
    _screens = [
      const SingleChildScrollView(
          child: Column(children: [
        Center(child: ShimmerDesign(isDone: true)),
      ]))
    ];

    super.initState();
    _initCall();
  }

  void _initCall() async {
    await _getDeviceId();
    await _getEmail();
    await _checkNotificationStatus();
    await _initializeDatabase();

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
    if (_deviceId != null) return;

    try {
      DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();

      if (Platform.isAndroid) {
        AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
        _deviceId = androidInfo.id;
        log('📱 Android Unique ID: $_deviceId');
      } else if (Platform.isIOS) {
        IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
        _deviceId = iosInfo.identifierForVendor;
        log('📱 iOS Unique ID: $_deviceId');
      }
    } catch (e) {
      log('❌ Error getting device ID: $e');
    }
  }

  Future<void> _checkNotificationStatus() async {
    log('Home Page DeviceID: $_deviceId');
    log('Home Page EmailID: $emailId');
    try {
      final response = await BrandsApi.fetchPriceAlertProduct(
        emailId: emailId,
        deviceToken: _deviceId,
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
        log('Home Screen');
        log('Notification status: ${hasUnread ? 'Has unread' : 'All read'}');
      }
    } catch (e) {
      log('Error checking notification status: $e');
    }
  }

  // Initialize WorkManager service
  Future<void> _initializeWorkManager() async {
    try {
      // Commented out WorkManager usage - using AppNotificationService instead
      // await WorkManagerService.initialize();
      // log('WorkManager initialized in HomePage');
      log('WorkManager functionality commented out - using AppNotificationService instead');
    } catch (e) {
      log('Error initializing WorkManager in HomePage: $e');
    }
  }

  /// Initialize app notification service
  Future<void> _initializeAppNotificationService() async {
    try {
      _appNotificationService = AppNotificationService();
      await _appNotificationService?.initialize(context);

      // Start automatic notification checking
      await _appNotificationService?.startAutoNotificationChecking();

      log('✅ App notification service initialized successfully');
    } catch (e) {
      log('❌ Error initializing app notification service: $e');
    }
  }

  /// Check for notifications when app comes to foreground
  Future<void> _checkForNotificationsOnAppResume() async {
    try {
      log('🔍 Checking for notifications on app resume...');

      // Check for new notifications from API when app comes to foreground
      if (_appNotificationService != null) {
        await _appNotificationService!.checkForNotificationsOnAppOpen();
      }

      log('✅ App resume notification check completed');
    } catch (e) {
      log('❌ Error checking notifications on app resume: $e');
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
              child: const DashboardScreenWidget(),
            ),
            const LikedProductScreen(),
            ChangeNotifierProvider(
              create: (context) {
                final provider = BrandsProvider();
                // Start fetching brands immediately for faster loading
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  provider.fetchBrands();
                });
                return provider;
              },
              child: const CategoriesMenuScreen(),
            ),
            const AccountScreen(),
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
              child: CategoriesMenuScreen(),
            ),
            AccountScreen(),
          ];
        });
      }
    }
  }

  @override
  void dispose() {
    _authStateSubscription?.cancel();

    // Dispose the app notification service if initialized
    _appNotificationService?.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    if (_screens.isEmpty) {
      return const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ShimmerDesign(isDone: true),
          SizedBox(height: 25),
          ShimmerDesign(isDone: true),
        ],
      );
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
                                      await _checkNotificationStatus();
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

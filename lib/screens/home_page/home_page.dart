import 'dart:developer';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:minsellprice/core/utils/constants/colors.dart';
import 'package:minsellprice/reposotory_services/database/database_functions.dart';
import 'package:minsellprice/screens/account_screen/account_screen.dart';
import 'package:minsellprice/screens/categories_provider/categories_provider_file.dart';
import 'package:minsellprice/screens/categories_screen/categories_screen.dart';
import 'package:minsellprice/screens/dashboard_screen/dashboard_screen.dart';
import 'package:minsellprice/screens/liked_product_screen/liked_product_screen.dart';
import 'package:provider/provider.dart';
import 'package:salomon_bottom_bar/salomon_bottom_bar.dart';
import 'package:sqflite/sqflite.dart';

GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

class HomePage extends StatefulWidget {
  const HomePage({
    super.key,
  });

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  int vendorId = 0;
  int _activeIndex = 0;

  List<Widget> _screens = [];

  Map<String, dynamic> userData = {};

  String vendorName = '';

  late Database database;

  final scaffoldKey = GlobalKey<ScaffoldState>();

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
              child: DashboardScreenWidget(
                database: db,
              ),
            ),
            LikedProduct(database: db),
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
              child: DashboardScreenWidget(
                database: database,
              ),
            ),
            LikedProduct(database: database),
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
            appBar: AppBar(
              backgroundColor: Colors.white,
              surfaceTintColor: Colors.transparent,
              elevation: 0,
              toolbarHeight: 80,
              centerTitle: true,
              automaticallyImplyLeading: false,
              title: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.show_chart,
                    color: AppColors.primary,
                    size: 24,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'MinSellPrice',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Segoe UI',
                    ),
                  ),
                ],
              ),
              actionsPadding: const EdgeInsets.only(right: 15),
              actions: const [
                Icon(Icons.shopping_cart, size: 35, color: AppColors.primary),
              ],
            ),
            bottomNavigationBar: MediaQuery.of(context).viewInsets.bottom != 0.0
                ? const SizedBox()
                : SalomonBottomBar(
                    backgroundColor: Colors.white,
                    currentIndex: _activeIndex,
                    onTap: (i) => setState(() => _activeIndex = i),
                    items: [
                      SalomonBottomBarItem(
                        icon: const Icon(Icons.home),
                        title: const Text("Home"),
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

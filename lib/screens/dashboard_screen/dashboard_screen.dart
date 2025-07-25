import 'dart:async';
import 'dart:developer';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:minsellprice/core/apis/apis_calls.dart';
import 'package:minsellprice/core/utils/constants/app.dart';
import 'package:minsellprice/core/utils/constants/colors.dart';
import 'package:minsellprice/screens/account_screen/account_screen.dart';
import 'package:minsellprice/screens/categories_provider/categories_provider_file.dart';
import 'package:minsellprice/screens/categories_screen/categories_screen.dart';
import 'package:minsellprice/screens/liked_product_screen/liked_product_screen.dart';
import 'package:minsellprice/screens/search_screen/search_screen.dart';
import 'package:minsellprice/widgets/category_shimmer.dart';
import 'package:provider/provider.dart';
import 'package:salomon_bottom_bar/salomon_bottom_bar.dart';
import 'package:minsellprice/screens/product_list_screen/brand_product_list_screen.dart';
import 'package:sqflite/sqflite.dart';
import '../../../reposotory_services/database/database_functions.dart';
import '../../core/utils/constants/size.dart';

GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({
    super.key,
  });

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen>
    with TickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  int vendorId = 0;

  DateTime date = DateTime.now().subtract(
    const Duration(days: 1),
  );
  GlobalKey widgetKey = GlobalKey();
  late Offset widgetOffset;

  double opacity = 1;

  final ScrollController _otherCompetitorController = ScrollController();
  final ScrollController _priceHealthController = ScrollController();

  bool shouldScrollMain = true;

  int _activeIndex = 0;

  List<Widget> _screens = [];

  @override
  void initState() {
    // TODO: implement initState
    _screens = [
      const Center(
        child: CircularProgressIndicator(),
      )
    ];
    super.initState();
    _initializeDatabase();
  }

  void _initializeDatabase() async {
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
                provider.fetchBrands();
                return provider;
              },
              child: DashboardScreenWidget(
                database: db,
                vendorId: '${AppInfo.kVendorId}',
              ),
            ),
            LikedProduct(database: db),
            CategoriesScreen(database: db, vendorId: vendorId),
            AccountScreen(),
          ];
        });
      }
    } catch (e) {
      log('Dashboard database initialization error: $e');
    }
  }

  @override
  void dispose() {
    super.dispose();
    _priceHealthController.dispose();
    _otherCompetitorController.dispose();
  }

  final List<Widget> bottomBarPages = [const DashboardScreen()];

  Map<String, dynamic> userData = {};
  String vendorName = '';
  late Database database;
  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    if (database == null || _screens.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
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
    );
  }

  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;
}

class CustomBottomNavBar extends StatefulWidget {
  final ValueChanged<int> onTap;
  int activeIndex;

  CustomBottomNavBar(
      {super.key, required this.onTap, required this.activeIndex});

  @override
  State<CustomBottomNavBar> createState() => _CustomBottomNavBarState();
}

class _CustomBottomNavBarState extends State<CustomBottomNavBar> {
  int activeIndex = 0;

  @override
  void initState() {
    activeIndex = widget.activeIndex;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned(
          bottom: 0,
          child: ClipPath(
            //  clipper: NavBarClipper(),
            child: Container(
              height: 50,
              width: w,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.blue,
                    Colors.blue.withOpacity(0.2),
                    Colors.blue.withOpacity(0.3),
                  ],
                ),
              ),
            ),
          ),
        ),
        Positioned(
          bottom: 30,
          child: SizedBox(
            width: w,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                GestureDetector(
                  onTap: () {
                    widget.onTap(0);
                  },
                  child: AnimatedCrossFade(
                    duration: const Duration(seconds: 2),
                    alignment: Alignment.bottomCenter,
                    firstChild: const CircleAvatar(
                      backgroundColor: Colors.blue,
                      radius: 28,
                      child: CircleAvatar(
                        backgroundColor: Colors.white,
                        radius: 23,
                        child: Icon(Icons.home),
                      ),
                    ),
                    secondChild: const CircleAvatar(
                      backgroundColor: Colors.blue,
                      radius: 30,
                      child: CircleAvatar(
                        backgroundColor: Colors.blue,
                        radius: 25,
                        child: Icon(
                          Icons.home,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    crossFadeState: widget.activeIndex == 0
                        ? CrossFadeState.showSecond
                        : CrossFadeState.showFirst,
                  ),
                ),
                const SizedBox(width: 10),
                GestureDetector(
                  onTap: () {
                    widget.onTap(1);
                  },
                  child: AnimatedCrossFade(
                    alignment: Alignment.bottomCenter,
                    duration: const Duration(seconds: 2),
                    firstChild: const CircleAvatar(
                      backgroundColor: Colors.blue,
                      radius: 28,
                      child: CircleAvatar(
                        backgroundColor: Colors.white,
                        radius: 23,
                        child: Icon(Icons.star),
                      ),
                    ),
                    secondChild: const CircleAvatar(
                      backgroundColor: Colors.blue,
                      radius: 32,
                      child: CircleAvatar(
                        backgroundColor: Colors.blue,
                        radius: 25,
                        child: Icon(
                          Icons.star,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    crossFadeState: widget.activeIndex == 1
                        ? CrossFadeState.showSecond
                        : CrossFadeState.showFirst,
                  ),
                ),
                const SizedBox(width: 10),
                GestureDetector(
                  onTap: () {
                    widget.onTap(2);
                  },
                  child: AnimatedCrossFade(
                    alignment: Alignment.bottomCenter,
                    duration: const Duration(seconds: 2),
                    firstChild: const CircleAvatar(
                      backgroundColor: Colors.blue,
                      radius: 28,
                      child: CircleAvatar(
                        backgroundColor: Colors.white,
                        radius: 23,
                        child: Icon(Icons.search),
                      ),
                    ),
                    secondChild: const CircleAvatar(
                      backgroundColor: Colors.blue,
                      radius: 32,
                      child: CircleAvatar(
                        backgroundColor: Colors.blue,
                        radius: 25,
                        child: Icon(
                          Icons.search,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    crossFadeState: widget.activeIndex == 2
                        ? CrossFadeState.showSecond
                        : CrossFadeState.showFirst,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class DashboardScreenWidget extends StatefulWidget {
  const DashboardScreenWidget({
    super.key,
    required this.database,
    required this.vendorId,
  });

  final Database database;
  final String vendorId;

  @override
  State<DashboardScreenWidget> createState() => _DashboardScreenWidgetState();
}

class _DashboardScreenWidgetState extends State<DashboardScreenWidget>
    with KeepAliveParentDataMixin {
  List<Map<String, dynamic>> databaseData = [];
  final _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();

  final _scrollController = ScrollController();
  Future<Map<String, List<dynamic>>>? _brandsFuture;
  List<Map<String, dynamic>> _homeGardenBrands = [];
  List<Map<String, dynamic>> _shoesApparels = [];
  List<Map<String, dynamic>> _allBrands = [];

  @override
  void initState() {
    super.initState();
    _initCall();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _searchFocusNode.unfocus();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _initCall() async {
    await _getBrands().timeout(Duration(seconds: 10));
  }

  Future<void> _getBrands() async {
    _brandsFuture = BrandsApi.fetchBrands(context);
    final brandsData = await _brandsFuture!;

    setState(() {
      _homeGardenBrands = (brandsData["Home & Garden Brands"] ?? [])
          .whereType<Map<String, dynamic>>()
          .toList();

      _shoesApparels = (brandsData["Shoes & Apparels"] ?? [])
          .whereType<Map<String, dynamic>>()
          .toList();

      _allBrands = [..._homeGardenBrands, ..._shoesApparels];
    });
  }

  IconData? selectedIcon;
  List<IconData> iconsList = [
    Icons.favorite_border,
    Icons.compare_arrows_outlined,
    Icons.visibility_outlined,
    Icons.shopping_bag_outlined
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 5, top: 15),
      child: Container(
        color: const Color.fromARGB(255, 245, 245, 245),
        width: w,
        child: Column(
          children: [
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Center(
                  child: SizedBox(
                    height: 45,
                    width: w * .9,
                    child: TextFormField(
                      //enabled: true,
                      controller: _searchController,
                      focusNode: _searchFocusNode,
                      textInputAction: TextInputAction.search,
                      onFieldSubmitted: (value) {
                        if (value.trim().isNotEmpty) {
                          //  _searchBrand(value);
                        }
                      },
                      cursorColor: AppColors.primary,
                      onTap: () {
                        _searchFocusNode.unfocus();
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => SearchScreen()));
                      },
                      decoration: InputDecoration(
                        hintText: 'Search brands by name...',
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 10.0,
                        ),
                        suffixIconColor: AppColors.primary,
                        border: OutlineInputBorder(
                          borderSide: BorderSide(color: AppColors.primary),
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(5),
                            topRight: Radius.circular(5),
                            bottomRight: Radius.circular(5),
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: AppColors.primary),
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(5),
                            topRight: Radius.circular(5),
                            bottomRight: Radius.circular(5),
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: AppColors.primary),
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(5),
                            topRight: Radius.circular(5),
                            bottomRight: Radius.circular(5),
                          ),
                        ),
                        disabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: AppColors.primary),
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(5),
                            topRight: Radius.circular(5),
                            bottomRight: Radius.circular(5),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: Scrollbar(
                controller: _scrollController,
                thickness: 4,
                thumbVisibility: true,
                trackVisibility: true,
                interactive: true,
                child: SingleChildScrollView(
                  controller: _scrollController,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      const SizedBox(height: 15),
                      Consumer<BrandsProvider>(
                        builder: (context, brandsProvider, child) {
                          return _buildBrandsSections(brandsProvider);
                        },
                      ),
                      const SizedBox(height: 45),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBrandsSections(BrandsProvider brandsProvider) {
    log('_buildBrandsSections called with state: ${brandsProvider.state}');
    log('Home & Garden count: ${brandsProvider.homeGardenBrands.length}');
    log('Shoes & Apparels count: ${brandsProvider.shoesApparels.length}');

    if (brandsProvider.state == BrandsState.loading ||
        brandsProvider.state == BrandsState.initial) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          BrandsSectionShimmer(title: ''),
          SizedBox(height: 25),
          BrandsSectionShimmer(title: ''),
        ],
      );
    } else if (brandsProvider.state == BrandsState.error) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            const Text(
              'Failed to load brands',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              brandsProvider.errorMessage,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[600]),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => brandsProvider.retry(),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    } else {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 20.0),
            child: Text(
              'Home & Garden',
              style: const TextStyle(
                fontSize: 27,
                fontWeight: FontWeight.bold,
                fontFamily: 'Segoe UI',
              ),
            ),
          ),
          const SizedBox(height: 25),
          _brandsGrid(brandsProvider.homeGardenBrands),
          const SizedBox(height: 5),
          Padding(
            padding: const EdgeInsets.only(left: 20.0),
            child: Text(
              'Shoes & Apparels',
              style: const TextStyle(
                fontSize: 27,
                fontWeight: FontWeight.bold,
                fontFamily: 'Segoe UI',
              ),
            ),
          ),
          const SizedBox(height: 25),
          _brandsGrid(brandsProvider.shoesApparels),
        ],
      );
    }
  }

  Widget _brandsGrid(List<Map<String, dynamic>> brands) {
    if (brands.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.image,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'No brands available',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Brands will appear here once loaded',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          childAspectRatio: 0.85, // Slightly taller for better logo display
        ),
        itemCount: brands.length,
        itemBuilder: (context, index) {
          final brand = brands[index];
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => BrandProductListScreen(
                    brandId: brand['brand_id'],
                    brandName: brand['brand_name'],
                    dataList: const [],
                  ),
                ),
              );
            },
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    spreadRadius: 2,
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.05),
                    spreadRadius: 1,
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Colors.white,
                        Colors.grey[50]!,
                      ],
                    ),
                    border: Border.all(
                      color: Colors.grey[200]!,
                      width: 1,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(
                        flex: 3,
                        child: Container(
                          margin: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            color: Colors.white,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.08),
                                spreadRadius: 1,
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: BrandImageWidget(
                              brand: brand,
                              width: double.infinity,
                              height: double.infinity,
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16.0,
                            vertical: 12.0,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: const BorderRadius.only(
                              bottomLeft: Radius.circular(16),
                              bottomRight: Radius.circular(16),
                            ),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Flexible(
                                child: Text(
                                  brand['brand_name'].toString().trim(),
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    color: Colors.black87,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 16,
                                    fontFamily: 'Segoe UI',
                                    letterSpacing: 0.3,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              // const SizedBox(height: 4),
                              // Container(
                              //   width: 24,
                              //   height: 2,
                              //   decoration: BoxDecoration(
                              //     color: AppColors.primary.withOpacity(0.6),
                              //     borderRadius: BorderRadius.circular(1),
                              //   ),
                              // ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  void detach() {
    // TODO: implement detach
  }

  @override
  // TODO: implement keptAlive
  bool get keptAlive => true;
}

class BrandImageWidget extends StatefulWidget {
  final Map<String, dynamic> brand;
  final double? width;
  final double? height;

  const BrandImageWidget(
      {super.key, required this.brand, this.width, this.height});

  @override
  State<BrandImageWidget> createState() => _BrandImageWidgetState();
}

class _BrandImageWidgetState extends State<BrandImageWidget> {
  late String _imageUrl1;
  late String _imageUrl2;
  late String _currentUrl;
  int _attempt = 0;

  @override
  void initState() {
    super.initState();
    _initCall();
  }

  Future<void> _initCall() async {
    await _initializeImageUrls();
  }

  Future<void> _initializeImageUrls() async {
    try {
      String brandName = widget.brand['brand_name']?.toString() ?? '';
      String brandKey = widget.brand['brand_key']?.toString() ?? '';
      int brandId = widget.brand['brand_id'] ?? 0;

      String processedBrandName = brandName.replaceAll(' ', '-').toLowerCase();
      String processedBrandKey = brandKey.replaceAll(' ', '-').toLowerCase();

      _imageUrl1 =
          'https://growth.matridtech.net/brand-logo/brands/$processedBrandKey.png';
      _imageUrl2 =
          'https://www.minsellprice.com/Brand-logo-images/$processedBrandName.png';

      _currentUrl = _imageUrl1;

      log('BrandImageWidget [ID:$brandId] - Brand: "$brandName", Key: "$brandKey"');
      log('BrandImageWidget [ID:$brandId] - Processed Brand Name: "$processedBrandName"');
      log('BrandImageWidget [ID:$brandId] - URL 1: $_imageUrl1');
      log('BrandImageWidget [ID:$brandId] - URL 2: $_imageUrl2');
      log('BrandImageWidget [ID:$brandId] - Full brand data: ${widget.brand}');
    } catch (e) {
      log('Error initializing image URLs: $e');
      _currentUrl = '';
    }
  }

  void _onImageError() {
    setState(() {
      if (_attempt == 0) {
        _currentUrl = _imageUrl2;
        log('Trying alternative URL: $_imageUrl2');
      } else if (_attempt == 1) {
        _currentUrl = _imageUrl1;
        log('Trying original URL again: $_imageUrl1');
      } else {
        _currentUrl = '';
        log('All image URLs failed, showing placeholder');
      }
      _attempt++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: widget.width ?? double.infinity,
      height: widget.height ?? 115,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.white,
      ),
      child: _currentUrl.isEmpty
          ? _buildPlaceholderWidget()
          : CachedNetworkImage(
              imageUrl: _currentUrl,
              fit: BoxFit.contain,
              placeholder: (context, url) => _buildLoadingWidget(),
              errorWidget: (context, url, error) {
                log('Image load error for URL: $url, Error: $error');
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (mounted) {
                    _onImageError();
                  }
                });
                return _buildErrorWidget();
              },
            ),
    );
  }

  Widget _buildPlaceholderWidget() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.grey[100]!,
            Colors.grey[200]!,
          ],
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.2),
                  spreadRadius: 1,
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Icon(
              Icons.image,
              color: Colors.grey[400],
              size: 28,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingWidget() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.grey[50]!,
            Colors.grey[100]!,
          ],
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  spreadRadius: 1,
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(
                  AppColors.primary.withOpacity(0.7),
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Loading...',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorWidget() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.red[50]!,
            Colors.red[100]!,
          ],
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.red.withOpacity(0.2),
                  spreadRadius: 1,
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Icon(
              Icons.broken_image_outlined,
              color: Colors.red[400],
              size: 24,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Image Error',
            style: TextStyle(
              color: Colors.red[600],
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

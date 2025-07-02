// ignore_for_file: library_private_types_in_public_api, must_be_immutable

import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'package:firebase_database/firebase_database.dart';
import 'package:http/http.dart' as http;
import 'package:auto_size_text/auto_size_text.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_carousel_slider/carousel_slider.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:salomon_bottom_bar/salomon_bottom_bar.dart';
import 'package:shared_preferences/shared_preferences.dart';

// import 'package:msp/model/competitor_model.dart';
// import 'package:msp/model/price_change_model.dart';

import 'package:shimmer/shimmer.dart';
import 'package:minsellprice/app.dart';
import 'package:minsellprice/bloc/database_bloc/database_setup/database_bloc.dart';
import 'package:minsellprice/bloc/feature_brand_bloc/feature_brands_bloc.dart';
import 'package:minsellprice/bloc/feature_brand_bloc/model/feature_brands_model.dart';
import 'package:minsellprice/bloc/feature_category/feature_category_bloc.dart';
import 'package:minsellprice/bloc/product_list_by_id_bloc/product_list_by_id_bloc.dart';
import 'package:minsellprice/bloc/vendor_analysis_bloc/vendor_price_analysis_bloc.dart';
import 'package:minsellprice/bloc/vendor_details_bloc/vendor_details_bloc.dart';
import 'package:minsellprice/res/icon_file.dart';
import 'package:minsellprice/screens/brand_screen.dart';
import 'package:minsellprice/screens/navigation_drawer.dart';
import 'package:minsellprice/screens/product_list_screen/brand_product_list_screen.dart';
import 'package:minsellprice/screens/product_list_screen/product_list_screen.dart';
import 'package:minsellprice/screens/widgets/bridge_class/bridge_class.dart';
import 'package:minsellprice/utils/common_methods.dart';
import 'package:minsellprice/utils/custom_dropdown.dart';
import 'package:minsellprice/utils/toast_messages/common_toasts.dart';
import 'package:sqflite/sqflite.dart';

import 'animation/custom_loader.dart';
import 'colors.dart';
import 'loging_page/loging_page.dart';
import 'model/brands_items.dart';
import 'model/vendor_dashboard_model.dart';
import 'reposotory_services/database/database_constants.dart';
import 'reposotory_services/database/database_functions.dart';
import 'screens/ai_price_engine/ai_pricie_engine_screen.dart';
import 'screens/liked_product_screen.dart';
import 'screens/search_screen/search_screen.dart';
import 'screens/widgets/custom_tooltip.dart';
import 'screens/widgets/extra_widgets.dart';
import 'screens/widgets/inheriated_widget.dart';
import 'screens/widgets/price_proposition_chart.dart';
import 'screens/widgets/sample_product_screen.dart';
import 'services/extra_functions.dart';
import 'size.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:minsellprice/screens/all_brands_screen.dart';

GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

// Add this at the top of the file, outside any class
Future<List<Map<String, dynamic>>>? _brandsFutureSingleton;

// final dateFormat = DateFormat("yyyy/MM/dd");
final List<ChartData> chartData = [
  ChartData(
    x: 'Home Perfect',
    y: 384,
  ),
  ChartData(
    x: 'Zoro',
    y: 139,
  ),
  ChartData(
    x: 'eBay',
    y: 182,
  ),
  ChartData(
    x: 'Others',
    y: 152,
  )
];

// EXCLUDE_FROM_GALLERY_DOCS_END
// import 'package:community_charts_flutter/community_charts_flutter.dart'
//     as charts;

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({
    super.key,
  });

  // final String vendorName, vendorId;

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen>
    with TickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  final _healthHighlightController = ScrollController();

  int vendorId = 0;

  VendorPriceAnalysisBloc bloc1 = VendorPriceAnalysisBloc();

  DateTime date = DateTime.now().subtract(
    const Duration(days: 1),
  );
  GlobalKey widgetKey = GlobalKey();
  late Offset widgetOffset;

  double opacity = 1;

  final ScrollController _otherCompetitorController = ScrollController();
  final ScrollController _priceHealthController = ScrollController();

  bool shouldScrollMain = true;

  /*  int _activeDrawerIndex = 1;*/

  int _activeIndex = 0;

  List<Widget> _screens = [];

  // Future<void> subscribeToFCMTopic() async {
  //   if (vendorId == AppInfo.kVendorId) {
  //     await FirebaseMessaging.instance.subscribeToTopic('af-supply');
  //   } else {
  //     await FirebaseMessaging.instance.subscribeToTopic('home-perfect');
  //   }
  // }

  @override
  void initState() {
    // TODO: implement initState
    context.read<DatabaseBloc>().add(DatabaseInitEvent());
    _screens = [
      const Center(
        child: CustomLoader(),
      )
    ];
    // subscribeToFCMTopic();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    _priceHealthController.dispose();
    _otherCompetitorController.dispose();
  }

  final List<Widget> bottomBarPages = [const DashboardScreen()];

  List<PricePropositionModel> chartData = [];
  List<PricePropositionModel> donutData = [];

  Map<String, dynamic> userData = {};
  String vendorName = '';
  late Database database;
  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return SafeArea(
      top: true,
      child: WillPopScope(
        onWillPop: () async {
          if (_activeIndex != 0) {
            setState(() {
              _activeIndex = 0;
            });
            Fluttertoast.showToast(
              msg: 'Press back again to exit',
              toastLength: Toast.LENGTH_LONG,
              gravity: ToastGravity.CENTER,
            );
            return false;
          } else {
            return true;
          }
        },
        child: BlocListener<DatabaseBloc, DatabaseState>(
          listener: (context, state) async {
            // TODO: implement listener

            if (state is DatabaseLoadedState) {
              setState(() {
                database = state.database;
              });
              final Map<String, dynamic> userData =
                  await DatabaseHelper().getUserInformation(db: database);

              setState(() {
                vendorName = userData[vendor_nameKey];
                vendorId = userData[vendor_idKey];
              });
              Future.delayed(const Duration(seconds: 1)).whenComplete(
                () => setState(
                  () => _screens = [
                    DashboardScreenWidget(
                      database: database,
                      vendorId: '${AppInfo.kVendorId}',
                    ),
                    LikedProduct(
                      database: database,
                      vendorId: vendorId,
                    ),
                    SearchScreen(
                      database: database,
                      vendorId: vendorId,
                    ),
                  ],
                ),
              );
              Future.delayed(const Duration(seconds: 1));

              await DatabaseHelper().showAllProducts(db: database);
            } else {
              Fluttertoast.showToast(msg: 'Database not init');
            }
          },
          child: GestureDetector(
            onTap: () {
              FocusScopeNode currentFocus = FocusScope.of(context);
              currentFocus.unfocus();
            },
            child: BlocListener<VendorDetailsBloc, VendorDetailsState>(
              listener: (context, state) {
                // if(state != VendorDetailsLoadedState || state != VendorDetailsErrorState){
                // }
              },
              child: MyInheritedWidget(
                // null,
                vendorName: '',
                vendorId: '',
                childWidget: SafeArea(
                  child: Scaffold(
                    key: scaffoldKey,
                    extendBody: true,
                    resizeToAvoidBottomInset: false,
                    drawer: CustomNavigationDrawer(),
                    //_buildDrawer(context),

                    //     CustomNavigationDrawer(
                    //   onLogout: () {
                    //     Navigator.of(context).push(
                    //       MaterialPageRoute(
                    //         builder: (context) => const
                    //       ),
                    //     );
                    //   },
                    // ),
                    // Enable the custom drawer
                    appBar: AppBar(
                      surfaceTintColor: Colors.white,
                      toolbarHeight: .18 * w,
                      leading: InkWell(
                        onTap: () {
                          scaffoldKey.currentState?.openDrawer();
                        },
                        child: const Icon(
                          Icons.menu,
                          // color: primary,
                          color: AppColors.primary,
                          size: 40,
                        ),
                      ),
                      // backgroundColor: Colors.white,
                      centerTitle: true,
                      title: Image.asset(
                        // 'assets/logo.png',
                        'assets/minsellprice_logo.png',
                        height: .2 * w,
                      ),
                      actionsPadding: EdgeInsets.only(right: 15),
                      actions: const [
                        Icon(
                          Icons.shopping_cart,
                          size: 35,
                          color: AppColors.primary,
                        )
                      ],
                      shape: Border.all(
                        color: AppColors.primary,
                        width: 0
                      ),
                    ),
                    bottomNavigationBar:
                        MediaQuery.of(context).viewInsets.bottom != 0.0
                            ? const SizedBox()
                            : SalomonBottomBar(
                                backgroundColor: Colors.white,
                                currentIndex: _activeIndex,
                                onTap: (i) => setState(() => _activeIndex = i),
                                items: [
                                  /// Home
                                  SalomonBottomBarItem(
                                    icon: const Icon(Icons.home),
                                    title: const Text("Home"),
                                    selectedColor: AppColors.primary,
                                  ),

                                  /// Likes
                                  SalomonBottomBarItem(
                                    icon: const Icon(Icons.favorite_border),
                                    title: const Text("Likes"),
                                    selectedColor: AppColors.primary,
                                  ),

                                  /// Search
                                  SalomonBottomBarItem(
                                    icon: const Icon(Icons.search),
                                    title: const Text("Search"),
                                    selectedColor: AppColors.primary,
                                  ),
                                ],
                              ),
                    // CustomBottomNavBar(
                    //         onTap: (index) =>
                    //             setState(() => _activeIndex = index),
                    //         activeIndex: _activeIndex,
                    //       ),
                    body: _screens[_activeIndex],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget loadingWidget1() => Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4.0),
            child: Shimmer.fromColors(
              baseColor: Colors.grey[300]!,
              highlightColor: Colors.grey[100]!,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 4,
                  vertical: 3,
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Card(
                          color: Colors.white,
                          elevation: 4,
                          child: Container(
                            width: .42 * w,
                            height: .15 * w,
                            decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(8)),
                            child: Center(
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: AutoSizeText(
                                  'Total Products\n${00}',
                                  // maxLines: 1,
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.montserrat(
                                    fontSize: w * 0.04,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        Card(
                          color: Colors.white,
                          elevation: 4,
                          child: Container(
                            width: .42 * w,
                            height: .15 * w,
                            decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(8)),
                            child: Center(
                              child: AutoSizeText(
                                'Scrap Data\n${00}',
                                textAlign: TextAlign.center,
                                style: GoogleFonts.montserrat(
                                  fontSize: w * 0.04,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    Card(
                      color: Colors.white,
                      elevation: 4,
                      child: Container(
                        width: .88 * w,
                        height: .15 * w,
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8)),
                        child: Center(
                          child: AutoSizeText(
                            'Price Automation: ${00}',
                            style: GoogleFonts.montserrat(
                              fontSize: w * 0.045,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Card(
                          color: Colors.white,
                          elevation: 4,
                          child: Container(
                            width: .42 * w,
                            height: .15 * w,
                            decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(8)),
                            child: Center(
                              child: AutoSizeText(
                                'In Stock \n${00}',
                                textAlign: TextAlign.center,
                                style: GoogleFonts.montserrat(
                                  fontSize: w * 0.04,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                        Card(
                          color: Colors.white,
                          elevation: 4,
                          child: Container(
                            width: .42 * w,
                            height: .15 * w,
                            decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(8)),
                            child: Center(
                              child: AutoSizeText(
                                'Out of Stock: \n${00}',
                                textAlign: TextAlign.center,
                                style: GoogleFonts.montserrat(
                                  fontSize: w * 0.04,
                                  fontWeight: FontWeight.bold,
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
            ),
          ),
          _competitorLoading(),
          _vendorLoading()
        ],
      );

  AspectRatio _competitiveHealthWidget(VendorDetailsLoadedState state, BuildContext context) {
    return AspectRatio(
      aspectRatio: .67,
      child: SizedBox(
        width: w,
        // height: .51 * h,
        child: Padding(
          padding: const EdgeInsets.only(bottom: 12.0),
          child: Card(
            color: Colors.white,
            surfaceTintColor: Colors.white,
            child: Container(
              decoration: BoxDecoration(
                  color: Colors.white, borderRadius: BorderRadius.circular(8)),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8.0, vertical: 4),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          height: .1 * w,
                          width: .6 * w,
                          // fit: BoxFit.fill,

                          child: CachedNetworkImage(
                              imageUrl:
                                  '${AppInfo.kBaseUrl(stagingSelector: 1)}vendor-logo/$vendorName.jpg'),
                        ),
                        Center(
                          child: Text(
                            'Count: ${totalProductCount(
                              l15: int.parse(
                                state.dashboardModel.competitiveHealth
                                    .lowestBy15,
                              ),
                              l515: int.parse(
                                state.dashboardModel.competitiveHealth
                                    .lowestBy515,
                              ),
                              l5: int.parse(
                                state
                                    .dashboardModel.competitiveHealth.lowestBy5,
                              ),
                              h15: int.parse(
                                state.dashboardModel.competitiveHealth
                                    .highestBy15,
                              ),
                              h515: int.parse(
                                state.dashboardModel.competitiveHealth
                                    .highestBy15,
                              ),
                              h5: int.parse(
                                state.dashboardModel.competitiveHealth
                                    .highestBy5,
                              ),
                            )}',
                            style: GoogleFonts.montserrat(
                              fontSize: w * 0.055,
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8.0, vertical: 4),
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ContentScreen(
                              loadingString: 'Very Low 15%',
                              loadingData: '$vendorName\nVery Lowest 15%',
                              vendorName: 'Lowest by 15%',
                              vendorImage:
                                  '${AppInfo.kBaseUrl(stagingSelector: 1)}vendor-logo/$vendorName.jpg',
                              vendorId: vendorId.toString(),
                              id: state
                                  .dashboardModel.competitiveHealth.idLowestBy15
                                  .toString(),
                              date: dateFormat
                                  .format(
                                    DateTime.now().subtract(
                                      const Duration(days: 1),
                                    ),
                                  )
                                  .replaceAll('/', '-'),
                              isVendorPriceAnalysis: true,
                              isVendorTable: false,
                              database: database,
                            ),
                          ),
                        );
                      },
                      child: SizedBox(
                        width: .9 * w,
                        child: Row(
                          // mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            SizedBox(
                              width: .58 * w,
                              height: .13 * w,
                              child: Stack(
                                children: [
                                  Container(
                                    width: .5 * w,
                                    height: .2 * w,
                                    constraints: BoxConstraints(
                                      minHeight: .1 * w,
                                      // maxHeight: .3 * w,
                                    ),
                                    decoration: const BoxDecoration(
                                      color: Colors.redAccent,
                                    ),
                                    child: Center(
                                      child: RichText(
                                        textAlign: TextAlign.center,
                                        text: TextSpan(
                                            text: 'Very Low\n'.toUpperCase(),
                                            style: GoogleFonts.montserrat(
                                              fontSize: w * 0.045,
                                              color: Colors.white,
                                              decoration:
                                                  TextDecoration.underline,
                                              fontWeight: FontWeight.bold,
                                            ),
                                            children: [
                                              TextSpan(
                                                text: '15%',
                                                style: GoogleFonts.montserrat(
                                                  fontSize: w * 0.04,
                                                  color: Colors.white,
                                                  decoration:
                                                      TextDecoration.none,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              )
                                            ]),
                                      ),
                                    ),
                                  ),
                                  const Align(
                                      alignment: Alignment.centerRight,
                                      child: Icon(
                                        Icons.arrow_right,
                                        size: 50,
                                        color: Colors.redAccent,
                                      ))
                                ],
                              ),
                            ),
                            Flexible(
                              child: SizedBox(
                                height: .12 * w,
                                child: Center(
                                  child: AutoSizeText(
                                    state.dashboardModel.competitiveHealth
                                        .lowestBy15,
                                    maxLines: 1,
                                    style: GoogleFonts.montserrat(
                                      color: Colors.redAccent,
                                      fontSize: w * .05,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8.0, vertical: 4),
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ContentScreen(
                              loadingString: 'Lowest\n5% - 15%',
                              loadingData: '$vendorName\nLow 5%-15%',
                              isVendorTable: false,
                              vendorName: 'Lowest by 5% - 15%',
                              vendorImage:
                                  '${AppInfo.kBaseUrl(stagingSelector: 1)}vendor-logo/$vendorName.jpg',
                              vendorId: vendorId.toString(),
                              id: state.dashboardModel.competitiveHealth
                                  .idLowestBy515
                                  .toString(),
                              date: dateFormat
                                  .format(
                                    DateTime.now().subtract(
                                      const Duration(days: 1),
                                    ),
                                  )
                                  .replaceAll('/', '-'),
                              isVendorPriceAnalysis: true,
                              database: database,
                            ),
                          ),
                        );
                      },
                      child: SizedBox(
                        width: .9 * w,
                        child: Row(
                          // mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            SizedBox(
                              width: .58 * w,
                              height: .12 * w,
                              child: Stack(
                                children: [
                                  Container(
                                    width: .5 * w,
                                    height: .12 * w,
                                    constraints: BoxConstraints(
                                      minHeight: .1 * w,
                                      // maxHeight: .3 * w,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.redAccent.withOpacity(.7),
                                    ),
                                    child: Center(
                                      child: RichText(
                                        textAlign: TextAlign.center,
                                        text: TextSpan(
                                            text: 'Low\n'.toUpperCase(),
                                            style: GoogleFonts.montserrat(
                                              fontSize: w * 0.045,
                                              color: Colors.white,
                                              decoration:
                                                  TextDecoration.underline,
                                              fontWeight: FontWeight.bold,
                                            ),
                                            children: [
                                              TextSpan(
                                                text: '5% - 15%',
                                                style: GoogleFonts.montserrat(
                                                  fontSize: w * 0.04,
                                                  color: Colors.white,
                                                  decoration:
                                                      TextDecoration.none,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              )
                                            ]),
                                      ),
                                    ),
                                  ),
                                  Align(
                                    alignment: Alignment.centerRight,
                                    child: Icon(
                                      Icons.arrow_right,
                                      size: 50,
                                      color: Colors.redAccent.withOpacity(.7),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Flexible(
                              child: SizedBox(
                                height: .12 * w,
                                child: Center(
                                  child: AutoSizeText(
                                    state.dashboardModel.competitiveHealth
                                        .lowestBy515,
                                    maxLines: 1,
                                    style: GoogleFonts.montserrat(
                                      color: Colors.redAccent.withOpacity(.7),
                                      fontSize: w * .05,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8.0, vertical: 4),
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ContentScreen(
                              loadingString: 'Lowest By5%',
                              vendorName: 'Lowest by 5%',
                              vendorImage:
                                  '${AppInfo.kBaseUrl(stagingSelector: 1)}vendor-logo/$vendorName.jpg',
                              vendorId: vendorId.toString(),
                              id: state
                                  .dashboardModel.competitiveHealth.idLowestBy5
                                  .toString(),
                              date: dateFormat
                                  .format(
                                    DateTime.now().subtract(
                                      const Duration(days: 1),
                                    ),
                                  )
                                  .replaceAll('/', '-'),
                              isVendorPriceAnalysis: true,
                              isVendorTable: false,
                              loadingData:
                                  '${vendorId == AppInfo.kVendorId ? 'AF Supply\n' : 'HomePerfect\n'}Moderate 5%',
                              database: database,
                            ),
                          ),
                        );
                      },
                      child: SizedBox(
                        width: .9 * w,
                        child: Row(
                          // mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            SizedBox(
                              width: .58 * w,
                              height: .13 * w,
                              child: Stack(
                                children: [
                                  Container(
                                    width: .5 * w,
                                    height: .13 * w,
                                    constraints: BoxConstraints(
                                      minHeight: .1 * w,
                                      // maxHeight: .3 * w,
                                    ),
                                    decoration: const BoxDecoration(
                                      color: Colors.green,
                                    ),
                                    child: Center(
                                      child: AutoSizeText(
                                        'Moderate'.toUpperCase(),
                                        textAlign: TextAlign.center,
                                        // maxFontSize: w * .06,
                                        style: GoogleFonts.montserrat(
                                          fontSize: w * 0.045,
                                          decoration: TextDecoration.underline,
                                          decorationColor: Colors.white,
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const Align(
                                    alignment: Alignment.centerRight,
                                    child: Icon(
                                      Icons.arrow_right,
                                      size: 50,
                                      color: Colors.green,
                                    ),
                                  )
                                ],
                              ),
                            ),
                            Flexible(
                              child: SizedBox(
                                height: .13 * w,
                                child: Center(
                                  child: AutoSizeText(
                                    state.dashboardModel.competitiveHealth
                                        .lowestBy5,
                                    maxLines: 1,
                                    style: GoogleFonts.montserrat(
                                      color: Colors.green,
                                      fontSize: w * .05,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8.0, vertical: 4),
                    child: GestureDetector(
                      onTap: () {
                        // log(list[index]['id_highest_by_5%'].toString());
                      },
                      child: SizedBox(
                        width: .9 * w,
                        child: Row(
                          // mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            SizedBox(
                              width: .58 * w,
                              height: .12 * w,
                              child: Stack(
                                children: [
                                  Container(
                                    width: .5 * w,
                                    height: .13 * w,
                                    constraints: BoxConstraints(
                                      minHeight: .1 * w,
                                      // maxHeight: .3 * w,
                                    ),
                                    decoration: const BoxDecoration(
                                      color: Colors.grey,
                                    ),
                                    child: Center(
                                      child: AutoSizeText(
                                        'Neutral'.toUpperCase(),
                                        maxLines: 1,
                                        // maxFontSize: w * .06,
                                        style: GoogleFonts.montserrat(
                                          fontSize: w * 0.045,
                                          color: Colors.white,
                                          decoration: TextDecoration.underline,
                                          decorationColor: Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const Align(
                                    alignment: Alignment.centerRight,
                                    child: Icon(
                                      Icons.arrow_right,
                                      size: 50,
                                      color: Colors.grey,
                                    ),
                                  )
                                ],
                              ),
                            ),
                            Flexible(
                              child: SizedBox(
                                height: .13 * w,
                                child: Center(
                                  child: AutoSizeText(
                                    state.dashboardModel.competitiveHealth
                                        .lowestBy5,
                                    maxLines: 1,
                                    style: GoogleFonts.montserrat(
                                      color: Colors.grey,
                                      fontSize: w * .05,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8.0, vertical: 4),
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ContentScreen(
                              loadingString: 'Highest by 5%',
                              isVendorTable: false,
                              vendorName: 'Highest by 5%',
                              vendorImage:
                                  '${AppInfo.kBaseUrl(stagingSelector: 1)}vendor-logo/$vendorName.jpg',
                              vendorId: vendorId.toString(),
                              id: state
                                  .dashboardModel.competitiveHealth.idHighestBy5
                                  .toString(),
                              date: dateFormat
                                  .format(
                                    DateTime.now().subtract(
                                      const Duration(days: 1),
                                    ),
                                  )
                                  .replaceAll('/', '-'),
                              isVendorPriceAnalysis: true,
                              loadingData:
                                  '${vendorId == AppInfo.kVendorId ? 'AF Supply\n' : 'HomePerfect\n'}Highest By 5%',
                              database: database,
                            ),
                          ),
                        );
                      },
                      child: SizedBox(
                        width: .9 * w,
                        child: Row(
                          // mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            SizedBox(
                              width: .58 * w,
                              height: .12 * w,
                              child: Stack(
                                children: [
                                  Container(
                                    width: .5 * w,
                                    height: .13 * w,
                                    constraints: BoxConstraints(
                                      minHeight: .1 * w,
                                      // maxHeight: .3 * w,
                                    ),
                                    decoration: const BoxDecoration(
                                      color: Colors.green,
                                    ),
                                    child: Center(
                                      child: AutoSizeText(
                                        'Moderate'.toUpperCase(),
                                        textAlign: TextAlign.center,
                                        // maxFontSize: w * .06,
                                        style: GoogleFonts.montserrat(
                                          fontSize: w * 0.045,
                                          color: Colors.white,
                                          decoration: TextDecoration.underline,
                                          decorationColor: Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const Align(
                                      alignment: Alignment.centerRight,
                                      child: Icon(
                                        Icons.arrow_right,
                                        size: 50,
                                        color: Colors.green,
                                      ))
                                ],
                              ),
                            ),
                            Flexible(
                              child: SizedBox(
                                height: .13 * w,
                                child: Center(
                                  child: AutoSizeText(
                                    state.dashboardModel.competitiveHealth
                                        .highestBy5,
                                    maxLines: 1,
                                    style: GoogleFonts.montserrat(
                                      color: Colors.green,
                                      fontSize: w * .05,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8.0, vertical: 4),
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ContentScreen(
                              loadingString: 'Highest by 5% - 15%',
                              isVendorTable: false,
                              vendorName: 'Highest by 5% - 15%',
                              vendorImage:
                                  '${AppInfo.kBaseUrl(stagingSelector: 1)}vendor-logo/$vendorName.jpg',
                              vendorId: vendorId.toString(),
                              id: state.dashboardModel.competitiveHealth
                                  .idHighestBy515
                                  .toString(),
                              date: dateFormat
                                  .format(
                                    DateTime.now().subtract(
                                      const Duration(days: 1),
                                    ),
                                  )
                                  .replaceAll('/', '-'),
                              isVendorPriceAnalysis: true,
                              loadingData:
                                  '${vendorId == AppInfo.kVendorId ? 'AF Supply\n' : 'HomePerfect\n'}High 5%-15%',
                              database: database,
                            ),
                          ),
                        );
                      },
                      child: SizedBox(
                        width: .9 * w,
                        child: Row(
                          // mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            SizedBox(
                              width: .58 * w,
                              height: .12 * w,
                              child: Stack(
                                children: [
                                  Container(
                                    width: .5 * w,
                                    height: .13 * w,
                                    constraints: BoxConstraints(
                                      minHeight: .1 * w,
                                      // maxHeight: .3 * w,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.redAccent.withOpacity(.7),
                                    ),
                                    child: Center(
                                      child: RichText(
                                        textAlign: TextAlign.center,
                                        text: TextSpan(
                                            text: 'High\n'.toUpperCase(),
                                            style: GoogleFonts.montserrat(
                                              fontSize: w * 0.045,
                                              color: Colors.white,
                                              decoration:
                                                  TextDecoration.underline,
                                              fontWeight: FontWeight.bold,
                                            ),
                                            children: [
                                              TextSpan(
                                                text: '5% - 15%',
                                                style: GoogleFonts.montserrat(
                                                  fontSize: w * 0.04,
                                                  color: Colors.white,
                                                  decoration:
                                                      TextDecoration.none,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              )
                                            ]),
                                      ),
                                    ),
                                  ),
                                  Align(
                                    alignment: Alignment.centerRight,
                                    child: Icon(
                                      Icons.arrow_right,
                                      size: 50,
                                      color: Colors.redAccent.withOpacity(.7),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Flexible(
                              child: SizedBox(
                                height: .13 * w,
                                child: Center(
                                  child: AutoSizeText(
                                    state.dashboardModel.competitiveHealth
                                        .highestBy515,
                                    maxLines: 1,
                                    style: GoogleFonts.montserrat(
                                      color: Colors.redAccent.withOpacity(.7),
                                      fontSize: w * .05,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8.0, vertical: 4),
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ContentScreen(
                              loadingString: 'Very High  >15%',
                              isVendorTable: false,
                              vendorName: 'Highest by 15%',
                              vendorImage:
                                  '${AppInfo.kBaseUrl(stagingSelector: 1)}vendor-logo/$vendorName.jpg',
                              vendorId: vendorId.toString(),
                              id: state.dashboardModel.competitiveHealth
                                  .idHighestBy15
                                  .toString(),
                              date: dateFormat
                                  .format(
                                    DateTime.now().subtract(
                                      const Duration(days: 1),
                                    ),
                                  )
                                  .replaceAll('/', '-'),
                              isVendorPriceAnalysis: true,
                              loadingData:
                                  '${vendorId == AppInfo.kVendorId ? 'AF Supply\n' : 'HomePerfect\n'}Very High 15%',
                              database: database,
                            ),
                          ),
                        );
                      },
                      child: SizedBox(
                        width: .9 * w,
                        child: Row(
                          // mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            SizedBox(
                              width: .58 * w,
                              height: .12 * w,
                              child: Stack(
                                children: [
                                  Container(
                                    width: .5 * w,
                                    height: .13 * w,
                                    constraints: BoxConstraints(
                                      minHeight: .1 * w,
                                      // maxHeight: .3 * w,
                                    ),
                                    decoration: const BoxDecoration(
                                      color: Colors.redAccent,
                                    ),
                                    child: Center(
                                      child: RichText(
                                        textAlign: TextAlign.center,
                                        text: TextSpan(
                                            text: 'Very High\n'.toUpperCase(),
                                            style: GoogleFonts.montserrat(
                                              fontSize: w * 0.045,
                                              color: Colors.white,
                                              decoration:
                                                  TextDecoration.underline,
                                              fontWeight: FontWeight.bold,
                                            ),
                                            children: [
                                              TextSpan(
                                                text: '>15%',
                                                style: GoogleFonts.montserrat(
                                                  fontSize: w * 0.04,
                                                  color: Colors.white,
                                                  decoration:
                                                      TextDecoration.none,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              )
                                            ]),
                                      ),
                                    ),
                                  ),
                                  const Align(
                                      alignment: Alignment.centerRight,
                                      child: Icon(
                                        Icons.arrow_right,
                                        size: 50,
                                        color: Colors.redAccent,
                                      ))
                                ],
                              ),
                            ),
                            Flexible(
                              child: SizedBox(
                                height: .13 * w,
                                child: Center(
                                  child: AutoSizeText(
                                    state.dashboardModel.competitiveHealth
                                        .highestBy15,
                                    maxLines: 1,
                                    style: GoogleFonts.montserrat(
                                      color: Colors.redAccent,
                                      fontSize: w * .05,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void returnListenerStateValues({required VendorDetailsLoadedState state}) {
    chartData.clear();
    donutData.clear();

    /*Donut Entries*/

    // donutData.add(PricePropositionModel(
    //   brandName: vendorId == AppInfo.kVendorId
    //       ? '${AppInfo.kBaseUrl(stagingSelector: 1)}vendor-logo/AF Supply.jpg'
    //       : '${AppInfo.kBaseUrl(stagingSelector: 1)}vendor-logo/Home Perfect.jpg',
    //   color: [
    //
    //
    //     PricePropositionColor(
    //       value: int.parse(state.dashboardModel.competitiveHealth.lowestBy5),
    //       color: '#90EE90'.toColor(),
    //       labelName: 'Moderate(Low) Upto 5%',
    //     ),
    //     PricePropositionColor(
    //       value: int.parse(state.dashboardModel.competitiveHealth.lowestBy515),
    //       color: Colors.orange,
    //       labelName: 'Low 5%-15%',
    //     ),
    //     PricePropositionColor(
    //       value: int.parse(state.dashboardModel.competitiveHealth.highestBy5),
    //       color: '#90EE90'.toColor(),
    //       labelName: 'Moderate(High) Upto 5%',
    //     ),
    //     PricePropositionColor(
    //       value: int.parse(state.dashboardModel.competitiveHealth.lowestBy15),
    //       color: Colors.red,
    //       labelName: 'Very Low <15%',
    //     ),
    //     PricePropositionColor(
    //       value: int.parse(state.dashboardModel.competitiveHealth.highestBy515),
    //       color: Colors.orange,
    //       labelName: 'High 5%-15%',
    //     ),
    //     PricePropositionColor(
    //       value: int.parse(state.dashboardModel.competitiveHealth.highestBy15),
    //       color: Colors.red,
    //       labelName: 'Very High >15%',
    //     ),
    //   ],
    // ));
    /*Chart Entries*/
    chartData.add(PricePropositionModel(
      brandName: vendorName,
      color: [
        PricePropositionColor(
          value: int.parse(state.dashboardModel.competitiveHealth.lowestBy15),
          color: Colors.red,
          labelName: 'Very Low <15%',
        ),
        PricePropositionColor(
          value: int.parse(state.dashboardModel.competitiveHealth.lowestBy515),
          color: Colors.orange,
          labelName: 'Low 5%-15%',
        ),
        PricePropositionColor(
          value: int.parse(state.dashboardModel.competitiveHealth.lowestBy5),
          color: '#90EE90'.toColor(),
          labelName: 'Moderate(Low) Upto 5%',
        ),
        PricePropositionColor(
          value: int.parse(state.dashboardModel.competitiveHealth.highestBy5),
          color: '#90EE90'.toColor(),
          labelName: 'Moderate(High) Upto 5%',
        ),
        PricePropositionColor(
          value: int.parse(state.dashboardModel.competitiveHealth.highestBy515),
          color: Colors.orange,
          labelName: 'High 5%-15%',
        ),
        PricePropositionColor(
          value: int.parse(state.dashboardModel.competitiveHealth.highestBy15),
          color: Colors.red,
          labelName: 'Very High >15%',
        ),
      ],
    ));
    List<Map<String, dynamic>> list = [];
    state.dashboardModel.competitiveHealthAnother.forEach((key, value) {
      Map<String, dynamic> brand = {"brandName": key, ...value};

      chartData.add(PricePropositionModel(
        brandName: key,
        color: [
          PricePropositionColor(
            value: value['lower more than 15%']['map_count'] +
                value['lower more than 15%']['nonmap_count'] +
                value['lower more than 15%']['reviewed_count'],
            color: Colors.red,
            labelName: 'Very Low <15%',
          ),
          PricePropositionColor(
            value: value['lower from 5% - 15%']['map_count'] +
                value['lower from 5% - 15%']['nonmap_count'] +
                value['lower from 5% - 15%']['reviewed_count'],
            color: Colors.orange,
            labelName: 'Low 5%-15%',
          ),
          PricePropositionColor(
              value: value['lower upto 5%']['map_count'] +
                  value['lower upto 5%']['nonmap_count'] +
                  value['lower upto 5%']['reviewed_count'],
              color: '#90EE90'.toColor(),
              labelName: 'Moderate(Low) Upto 5%'),
          PricePropositionColor(
            value: value['higher upto 5%']['map_count'] +
                value['higher upto 5%']['nonmap_count'] +
                value['higher upto 5%']['reviewed_count'],
            color: '#90EE90'.toColor(),
            labelName: 'Moderate(High) Upto 5%',
          ),
          PricePropositionColor(
            value: value['higher from 5% - 15%']['map_count'] +
                value['higher from 5% - 15%']['nonmap_count'] +
                value['higher from 5% - 15%']['reviewed_count'],
            color: Colors.orange,
            labelName: 'High 5%-15%',
          ),
          PricePropositionColor(
            value: value['higher more than 15%']['map_count'] +
                value['higher more than 15%']['nonmap_count'] +
                value['higher more than 15%']['reviewed_count'],
            color: Colors.red,
            labelName: 'Very High >15%',
          ),
        ],
      ));
      // donutData.add(PricePropositionModel(
      //   brandName: key,
      //   color: [
      //
      //
      //     PricePropositionColor(
      //         value: value['lower upto 5%']['map_count'] +
      //             value['lower upto 5%']['nonmap_count'] +
      //             value['lower upto 5%']['reviewed_count'],
      //         color: '#90EE90'.toColor(),
      //         labelName: 'Moderate(Low) Upto 5%'),
      //     PricePropositionColor(
      //       value: value['lower from 5% - 15%']['map_count'] +
      //           value['lower from 5% - 15%']['nonmap_count'] +
      //           value['lower from 5% - 15%']['reviewed_count'],
      //       color: Colors.orange,
      //       labelName: 'Low 5%-15%',
      //     ),
      //     PricePropositionColor(
      //       value: value['higher upto 5%']['map_count'] +
      //           value['higher upto 5%']['nonmap_count'] +
      //           value['higher upto 5%']['reviewed_count'],
      //       color: '#90EE90'.toColor(),
      //       labelName: 'Moderate(High) Upto 5%',
      //     ),
      //     PricePropositionColor(
      //       value: value['lower more than 15%']['map_count'] +
      //           value['lower more than 15%']['nonmap_count'] +
      //           value['lower more than 15%']['reviewed_count'],
      //       color: Colors.red,
      //       labelName: 'Very Low <15%',
      //     ),
      //     PricePropositionColor(
      //       value: value['higher from 5% - 15%']['map_count'] +
      //           value['higher from 5% - 15%']['nonmap_count'] +
      //           value['higher from 5% - 15%']['reviewed_count'],
      //       color: Colors.orange,
      //       labelName: 'High 5%-15%',
      //     ),
      //     PricePropositionColor(
      //       value: value['higher more than 15%']['map_count'] +
      //           value['higher more than 15%']['nonmap_count'] +
      //           value['higher more than 15%']['reviewed_count'],
      //       color: Colors.red,
      //       labelName: 'Very High >15%',
      //     ),
      //   ],
      // ));

      list.add(brand);
    });
    donutData = chartData;
  }

  Widget _buildDrawer(BuildContext context,) {
    return Drawer(
      child: Padding(
        padding: const EdgeInsets.all(6.0),
        child: Card(
          color: Colors.white,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          child: Container(
            decoration: BoxDecoration(
                color: Colors.white, borderRadius: BorderRadius.circular(10)),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  /// Header of the Drawer
                  InkWell(
                    onTap: () {
                      /// Close Navigation drawer before

                      // Navigator.push(context, MaterialPageRoute(builder: (context) => UserProfile()),);
                    },
                    child: Container(
                      padding: const EdgeInsets.only(
                          // top: MediaQuery.of(context).padding.top,
                          top: 10,
                          bottom: 24),
                      child: Card(
                        color: Colors.white,
                        elevation: 2,
                        child: Container(
                          decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8)),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 12.0),
                            child: CachedNetworkImage(
                              imageUrl:
                                  '${AppInfo.kBaseUrl(stagingSelector: 1)}vendor-logo/$vendorName.jpg',
                              fit: BoxFit.fill,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20.0),
                        child: AutoSizeText(
                          'Menu',
                          style: GoogleFonts.montserrat(
                            fontSize: w * 0.06,
                            color: Colors.blue,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      ListTile(
                        leading: const Icon(
                          Icons.home_outlined,
                          color: Colors.black,
                          size: 40,
                        ),
                        title: AutoSizeText(
                          'Dashboard',
                          style: GoogleFonts.montserrat(
                            fontSize: w * 0.045,
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        onTap: () {
                          /// Close Navigation drawer before
                          Navigator.pop(
                              context); // Navigator.push(context, MaterialPageRoute(builder: (context) => HomeScreen()),);
                        },
                      ),
                      ListTile(
                        leading: Padding(
                          padding: const EdgeInsets.only(left: 8.0),
                          child: Image.asset(
                            'assets/capital-a.png',
                            width: 25,
                            height: 25,
                            color: Colors.black,
                          ),
                        ),
                        title: Text(
                          'AI Price Engine',
                          style: GoogleFonts.montserrat(
                            fontSize: w * 0.045,
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        onTap: () {
                          /// Close Navigation drawer before

                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => AiPriceEngineScreen(
                                vendorId: vendorId,
                                date: dateFormat
                                    .format(
                                      date,
                                    )
                                    .replaceAll('/', '-'),
                                database: database,
                                vendorName: vendorName,
                              ),
                            ),
                          );
                          // Navigator.push(context, MaterialPageRoute(builder: (context) => FavouriteScreen()),);
                        },
                      ),
                      ExpansionTile(
                        initiallyExpanded: true,
                        //_activeDrawerIndex == 1,
                        onExpansionChanged: (value) {
                          if (kDebugMode) {}
                          // value == true
                          //     ? setState(() => _activeDrawerIndex = 1)
                          //     : null;
                        },
                        shape: const RoundedRectangleBorder(
                            side: BorderSide(color: Colors.transparent)),
                        collapsedShape: const RoundedRectangleBorder(
                            side: BorderSide(color: Colors.transparent)),
                        leading: Padding(
                          padding: const EdgeInsets.only(left: 8.0),
                          child: Image.asset(
                            'assets/b.png',
                            width: 25,
                            height: 25,
                            color: Colors.black,
                          ),
                        ),
                        title: Text(
                          'Brands',
                          style: GoogleFonts.montserrat(
                            fontSize: w * 0.045,
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        children: List.generate(
                            _brandList.length,
                            (index) => Column(
                                  children: [
                                    ListTile(
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => BrandScreen(
                                              vendorId: vendorId.toString(),
                                              date: dateFormat
                                                  .format(
                                                    date,
                                                  )
                                                  .replaceAll('/', '-'),
                                              database: database,
                                            ),
                                          ),
                                        );
                                      },
                                      dense: true,
                                      leading: Padding(
                                        padding: EdgeInsets.only(left: 8.0),
                                        child: Icon(
                                          O.o,
                                          color: Colors.transparent,
                                        ),
                                      ),
                                      title: Text(
                                        _brandList[index],
                                        style: GoogleFonts.montserrat(
                                          fontSize: w * 0.04,
                                          color: Colors.black,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 30.0),
                                      child: Divider(
                                        color: Colors.black.withOpacity(.6),
                                      ),
                                    )
                                  ],
                                )),
                      ),
                      const SizedBox(
                        height: 3,
                      ),
                      const Divider(
                        color: Colors.black45,
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20.0),
                        child: AutoSizeText(
                          'Apps',
                          style: GoogleFonts.montserrat(
                            fontSize: w * 0.06,
                            color: Colors.blue,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 5,
                      ),
                      // ExpansionTile(
                      //   initiallyExpanded: _activeDrawerIndex == 2,
                      //   onExpansionChanged: (value) {
                      //     if (kDebugMode) {}
                      //     value == true
                      //         ? setState(() => _activeDrawerIndex = 2)
                      //         : null;
                      //   },
                      //   shape: const RoundedRectangleBorder(
                      //       side: BorderSide(color: Colors.transparent)),
                      //   collapsedShape: const RoundedRectangleBorder(
                      //       side: BorderSide(color: Colors.transparent)),
                      //   leading: const Icon(
                      //     O.report,
                      //     color: Colors.black,
                      //     size: 35,
                      //   ),
                      //   title: Text(
                      //     'Rank Reports',
                      //     style: GoogleFonts.montserrat(
                      //       fontSize: w * 0.045,
                      //       color: Colors.black,
                      //       fontWeight: FontWeight.bold,
                      //     ),
                      //   ),
                      //   children: List.generate(
                      //       _rankList.length,
                      //       (index) => Column(
                      //             children: [
                      //               ListTile(
                      //                 dense: true,
                      //                 leading: const Padding(
                      //                   padding: EdgeInsets.only(left: 8.0),
                      //                   child: Icon(
                      //                     O.o,
                      //                     color: Colors.transparent,
                      //                   ),
                      //                 ),
                      //                 title: Text(
                      //                   _rankList[index],
                      //                   style: GoogleFonts.montserrat(
                      //                     fontSize: w * 0.04,
                      //                     color: Colors.black,
                      //                     fontWeight: FontWeight.bold,
                      //                   ),
                      //                 ),
                      //               ),
                      //               Padding(
                      //                 padding: const EdgeInsets.symmetric(
                      //                     horizontal: 30.0),
                      //                 child: Divider(
                      //                   color: Colors.black.withOpacity(.6),
                      //                 ),
                      //               )
                      //             ],
                      //           )),
                      // ),
                      ListTile(
                        leading: const Padding(
                          padding: EdgeInsets.only(left: 8.0),
                          child: Icon(
                            Icons.settings_input_component_outlined,
                            color: Colors.black,
                          ),
                        ),
                        title: Text(
                          'Exclude Competitor',
                          style: GoogleFonts.montserrat(
                            fontSize: w * 0.045,
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        onTap: () {},
                      ),
                      // ExpansionTile(
                      //   initiallyExpanded: _activeDrawerIndex == 3,
                      //   onExpansionChanged: (value) {
                      //     if (kDebugMode) {}
                      //     value == true
                      //         ? setState(() => _activeDrawerIndex = 3)
                      //         : null;
                      //   },
                      //   shape: const RoundedRectangleBorder(
                      //       side: BorderSide(color: Colors.transparent)),
                      //   collapsedShape: const RoundedRectangleBorder(
                      //       side: BorderSide(color: Colors.transparent)),
                      //   leading: const Padding(
                      //     padding: EdgeInsets.only(left: 8.0),
                      //     child: Icon(
                      //       O.o,
                      //       color: Colors.black,
                      //     ),
                      //   ),
                      //   title: AutoSizeText(
                      //     'ON AUTOMATION Rules',
                      //     style: GoogleFonts.montserrat(
                      //       fontSize: w * 0.04,
                      //       color: Colors.black,
                      //       fontWeight: FontWeight.bold,
                      //     ),
                      //   ),
                      //   children: List.generate(
                      //       _gpRuleList.length,
                      //       (index) => Column(
                      //             children: [
                      //               ListTile(
                      //                 dense: true,
                      //                 leading: const Padding(
                      //                   padding: EdgeInsets.only(left: 8.0),
                      //                   child: Icon(
                      //                     O.o,
                      //                     color: Colors.transparent,
                      //                   ),
                      //                 ),
                      //                 title: Text(
                      //                   _gpRuleList[index],
                      //                   style: GoogleFonts.montserrat(
                      //                     fontSize: w * 0.04,
                      //                     color: Colors.black,
                      //                     fontWeight: FontWeight.bold,
                      //                   ),
                      //                 ),
                      //               ),
                      //               Padding(
                      //                 padding: const EdgeInsets.symmetric(
                      //                     horizontal: 30.0),
                      //                 child: Divider(
                      //                   color: Colors.black.withOpacity(.6),
                      //                 ),
                      //               )
                      //             ],
                      //           )),
                      // ),
                      const Divider(
                        color: Colors.black,
                        thickness: .5,
                      ),
                      ListTile(
                        leading: const Icon(
                          Icons.notifications_active_outlined,
                          color: Colors.black,
                          size: 35,
                        ),
                        title: Text(
                          'Product Notifications',
                          style: GoogleFonts.montserrat(
                            fontSize: w * 0.045,
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        onTap: () {},
                      ),
                    ],
                  ),
                  ListTile(
                    leading: const Icon(
                      Icons.login_outlined,
                      color: Colors.black,
                      size: 40,
                    ),
                    title: AutoSizeText(
                      'Log Out',
                      style: GoogleFonts.montserrat(
                        fontSize: w * 0.045,
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    onTap: () async {
                      /// Close Navigation drawer before
                      await DatabaseHelper().logout(db: database).whenComplete(
                            () => Navigator.pushAndRemoveUntil(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const BridgeClass(),
                                ),
                                (route) => false),
                          );
                    },
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  final _gpRuleList = [
    'Group Mapping View',
    'Group Mapping',
    'Create SKU Group',
    'Create Age Group',
    'Create Brand Group',
    'Create Material Group',
    'Create Competitor Group',
    'Create Sale2Atp Ratio Group',
  ];
  final _rankList = [
    'Rank Count',
    'Rank Reduce Report',
    'Rank Improved Report',
  ];
  final _brandList = [
    'All Brands',
    'Common Brands',
    // 'Rank Improved Report',
  ];

  Padding _vendorLoading() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Card(
        color: Colors.white,
        child: Container(
          decoration: BoxDecoration(
              color: Colors.white, borderRadius: BorderRadius.circular(8)),
          child: Padding(
            padding: const EdgeInsets.all(6),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4),
                  child: SizedBox(
                    width: w,
                    child: Row(
                      // mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        SizedBox(
                          width: .7 * w,
                          height: w * .15,
                          child: Stack(
                            children: [
                              Container(
                                width: .63 * w,
                                height: w * .15,
                                constraints: BoxConstraints(
                                  minHeight: .1 * w,
                                  // maxHeight: .3 * w,
                                ),
                                decoration: const BoxDecoration(
                                  color: Colors.redAccent,
                                ),
                                child: Center(
                                  child: RichText(
                                    textAlign: TextAlign.center,
                                    text: TextSpan(
                                        text: 'Very Low\n'.toUpperCase(),
                                        style: GoogleFonts.montserrat(
                                          fontSize: w * 0.055,
                                          color: Colors.white,
                                          decoration: TextDecoration.underline,
                                          fontWeight: FontWeight.bold,
                                        ),
                                        children: [
                                          TextSpan(
                                            text: '<15%',
                                            style: GoogleFonts.montserrat(
                                              fontSize: w * 0.05,
                                              color: Colors.white,
                                              decoration: TextDecoration.none,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          )
                                        ]),
                                  ),
                                ),
                              ),
                              const Align(
                                  alignment: Alignment.centerRight,
                                  child: Icon(
                                    Icons.arrow_right,
                                    size: 50,
                                    color: Colors.redAccent,
                                  ))
                            ],
                          ),
                        ),
                        Shimmer.fromColors(
                          baseColor: Colors.grey[300]!,
                          highlightColor: Colors.grey[100]!,
                          child: Center(
                            child: AutoSizeText(
                              '000'.toString(),
                              maxLines: 1,
                              style: GoogleFonts.montserrat(
                                color: Colors.redAccent,
                                fontSize: w * .06,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4),
                  child: SizedBox(
                    width: w,
                    child: Row(
                      // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        SizedBox(
                          width: .7 * w,
                          height: w * .15,
                          child: Stack(
                            children: [
                              Container(
                                width: .63 * w,
                                height: w * .15,
                                constraints: BoxConstraints(
                                  minHeight: .1 * w,
                                  // maxHeight: .3 * w,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.redAccent.withOpacity(.7),
                                ),
                                child: Center(
                                  child: RichText(
                                    textAlign: TextAlign.center,
                                    text: TextSpan(
                                        text: 'Low\n'.toUpperCase(),
                                        style: GoogleFonts.montserrat(
                                          fontSize: w * 0.055,
                                          color: Colors.white,
                                          decoration: TextDecoration.underline,
                                          fontWeight: FontWeight.bold,
                                        ),
                                        children: [
                                          TextSpan(
                                            text: '5% - 15%',
                                            style: GoogleFonts.montserrat(
                                              fontSize: w * 0.05,
                                              color: Colors.white,
                                              decoration: TextDecoration.none,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          )
                                        ]),
                                  ),
                                ),
                              ),
                              Align(
                                alignment: Alignment.centerRight,
                                child: Icon(
                                  Icons.arrow_right,
                                  size: 50,
                                  color: Colors.redAccent.withOpacity(.7),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Shimmer.fromColors(
                          baseColor: Colors.grey[300]!,
                          highlightColor: Colors.grey[100]!,
                          child: Center(
                            child: AutoSizeText(
                              '000'.toString(),
                              maxLines: 1,
                              style: GoogleFonts.montserrat(
                                color: Colors.redAccent,
                                fontSize: w * .06,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4),
                  child: SizedBox(
                    width: w,
                    child: Row(
                      // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        SizedBox(
                          width: .7 * w,
                          height: w * .15,
                          child: Stack(
                            children: [
                              Container(
                                width: .63 * w,
                                height: w * .15,
                                constraints: BoxConstraints(
                                  minHeight: .1 * w,
                                  // maxHeight: .3 * w,
                                ),
                                decoration: const BoxDecoration(
                                  color: Colors.green,
                                ),
                                child: Center(
                                  child: AutoSizeText(
                                    'Moderate'.toUpperCase(),
                                    textAlign: TextAlign.center,
                                    // maxFontSize: w * .06,
                                    style: GoogleFonts.montserrat(
                                      fontSize: w * 0.055,
                                      decoration: TextDecoration.underline,
                                      decorationColor: Colors.white,
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                              const Align(
                                alignment: Alignment.centerRight,
                                child: Icon(
                                  Icons.arrow_right,
                                  size: 50,
                                  color: Colors.green,
                                ),
                              )
                            ],
                          ),
                        ),
                        Shimmer.fromColors(
                          baseColor: Colors.grey[300]!,
                          highlightColor: Colors.grey[100]!,
                          child: Center(
                            child: AutoSizeText(
                              '000'.toString(),
                              maxLines: 1,
                              style: GoogleFonts.montserrat(
                                color: Colors.redAccent,
                                fontSize: w * .06,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4),
                  child: SizedBox(
                    width: w,
                    child: Row(
                      // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        SizedBox(
                          width: .7 * w,
                          height: w * .15,
                          child: Stack(
                            children: [
                              Container(
                                width: .63 * w,
                                height: w * .15,
                                constraints: BoxConstraints(
                                  minHeight: .1 * w,
                                  // maxHeight: .3 * w,
                                ),
                                decoration: const BoxDecoration(
                                  color: Colors.grey,
                                ),
                                child: Center(
                                  child: AutoSizeText(
                                    'Neutral'.toUpperCase(),
                                    maxLines: 1,
                                    // maxFontSize: w * .06,
                                    style: GoogleFonts.montserrat(
                                      fontSize: w * 0.055,
                                      color: Colors.white,
                                      decoration: TextDecoration.underline,
                                      decorationColor: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                              const Align(
                                alignment: Alignment.centerRight,
                                child: Icon(
                                  Icons.arrow_right,
                                  size: 50,
                                  color: Colors.grey,
                                ),
                              )
                            ],
                          ),
                        ),
                        Shimmer.fromColors(
                          baseColor: Colors.grey[300]!,
                          highlightColor: Colors.grey[100]!,
                          child: Center(
                            child: AutoSizeText(
                              '000'.toString(),
                              maxLines: 1,
                              style: GoogleFonts.montserrat(
                                color: Colors.redAccent,
                                fontSize: w * .06,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4),
                  child: SizedBox(
                    width: w,
                    child: Row(
                      // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        SizedBox(
                          width: .7 * w,
                          height: w * 0.15,
                          child: Stack(
                            children: [
                              Container(
                                width: .63 * w,
                                height: w * 0.15,
                                constraints: BoxConstraints(
                                  minHeight: .1 * w,
                                  // maxHeight: .3 * w,
                                ),
                                decoration: const BoxDecoration(
                                  color: Colors.green,
                                ),
                                child: Center(
                                  child: AutoSizeText(
                                    'Moderate'.toUpperCase(),
                                    textAlign: TextAlign.center,
                                    // maxFontSize: w * .06,
                                    style: GoogleFonts.montserrat(
                                      fontSize: w * 0.055,
                                      color: Colors.white,
                                      decoration: TextDecoration.underline,
                                      decorationColor: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                              const Align(
                                  alignment: Alignment.centerRight,
                                  child: Icon(
                                    Icons.arrow_right,
                                    size: 50,
                                    color: Colors.green,
                                  ))
                            ],
                          ),
                        ),
                        Shimmer.fromColors(
                          baseColor: Colors.grey[300]!,
                          highlightColor: Colors.grey[100]!,
                          child: Center(
                            child: AutoSizeText(
                              '000'.toString(),
                              maxLines: 1,
                              style: GoogleFonts.montserrat(
                                color: Colors.redAccent,
                                fontSize: w * .06,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4),
                  child: SizedBox(
                    width: w,
                    child: Row(
                      // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        SizedBox(
                          width: .7 * w,
                          height: w * 0.15,
                          child: Stack(
                            children: [
                              Container(
                                width: .63 * w,
                                height: w * 0.15,
                                constraints: BoxConstraints(
                                  minHeight: .1 * w,
                                  // maxHeight: .3 * w,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.redAccent.withOpacity(.7),
                                ),
                                child: Center(
                                  child: RichText(
                                    textAlign: TextAlign.center,
                                    text: TextSpan(
                                        text: 'High\n'.toUpperCase(),
                                        style: GoogleFonts.montserrat(
                                          fontSize: w * 0.055,
                                          color: Colors.white,
                                          decoration: TextDecoration.underline,
                                          fontWeight: FontWeight.bold,
                                        ),
                                        children: [
                                          TextSpan(
                                            text: '5% - 15%',
                                            style: GoogleFonts.montserrat(
                                              fontSize: w * 0.05,
                                              color: Colors.white,
                                              decoration: TextDecoration.none,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          )
                                        ]),
                                  ),
                                ),
                              ),
                              Align(
                                alignment: Alignment.centerRight,
                                child: Icon(
                                  Icons.arrow_right,
                                  size: 50,
                                  color: Colors.redAccent.withOpacity(.7),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Shimmer.fromColors(
                          baseColor: Colors.grey[300]!,
                          highlightColor: Colors.grey[100]!,
                          child: Center(
                            child: AutoSizeText(
                              '000'.toString(),
                              maxLines: 1,
                              style: GoogleFonts.montserrat(
                                color: Colors.redAccent,
                                fontSize: w * .06,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4),
                  child: SizedBox(
                    width: w,
                    child: Row(
                      // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        SizedBox(
                          width: .7 * w,
                          height: w * 0.15,
                          child: Stack(
                            children: [
                              Container(
                                width: .63 * w,
                                height: w * 0.15,
                                constraints: BoxConstraints(
                                  minHeight: .1 * w,
                                  // maxHeight: .3 * w,
                                ),
                                decoration: const BoxDecoration(
                                  color: Colors.redAccent,
                                ),
                                child: Center(
                                  child: RichText(
                                    textAlign: TextAlign.center,
                                    text: TextSpan(
                                        text: 'Very High\n'.toUpperCase(),
                                        style: GoogleFonts.montserrat(
                                          fontSize: w * 0.055,
                                          color: Colors.white,
                                          decoration: TextDecoration.underline,
                                          fontWeight: FontWeight.bold,
                                        ),
                                        children: [
                                          TextSpan(
                                            text: '>15%',
                                            style: GoogleFonts.montserrat(
                                              fontSize: w * 0.05,
                                              color: Colors.white,
                                              decoration: TextDecoration.none,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          )
                                        ]),
                                  ),
                                ),
                              ),
                              const Align(
                                  alignment: Alignment.centerRight,
                                  child: Icon(
                                    Icons.arrow_right,
                                    size: 50,
                                    color: Colors.redAccent,
                                  ))
                            ],
                          ),
                        ),
                        Shimmer.fromColors(
                          baseColor: Colors.grey[300]!,
                          highlightColor: Colors.grey[100]!,
                          child: Center(
                            child: AutoSizeText(
                              '000'.toString(),
                              maxLines: 1,
                              style: GoogleFonts.montserrat(
                                color: Colors.redAccent,
                                fontSize: w * .06,
                                fontWeight: FontWeight.bold,
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
          ),
        ),
      ),
    );
  }

  Widget _competitorLoading() => Card(
        color: Colors.white,
        elevation: 5,
        child: Container(
          decoration: BoxDecoration(
              color: Colors.white, borderRadius: BorderRadius.circular(8)),
          width: w,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 5.0, vertical: 25),
                    child: Shimmer.fromColors(
                      baseColor: Colors.grey[300]!,
                      highlightColor: Colors.grey[100]!,
                      child: Center(
                          child: Container(
                        width: w * .4,
                        height: w * .25,
                        color: Colors.black,
                      )),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Row(
                          children: [
                            AutoSizeText(
                              'Total Products: ',
                              style: GoogleFonts.montserrat(
                                fontSize: w * 0.032,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Shimmer.fromColors(
                              baseColor: Colors.grey[300]!,
                              highlightColor: Colors.grey[100]!,
                              child: AutoSizeText(
                                '0000',
                                style: GoogleFonts.montserrat(
                                  fontSize: w * 0.032,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        Container(
                          height: 2,
                          width: w * .4,
                          color: Colors.black,
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        Row(
                          children: [
                            AutoSizeText(
                              'Overlapping Brands:',
                              style: GoogleFonts.montserrat(
                                fontSize: w * 0.032,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Shimmer.fromColors(
                              baseColor: Colors.grey[300]!,
                              highlightColor: Colors.grey[100]!,
                              child: AutoSizeText(
                                '0000',
                                style: GoogleFonts.montserrat(
                                  fontSize: w * 0.032,
                                  fontWeight: FontWeight.bold,
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
              const SizedBox(
                height: 15,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10.0),
                child: AutoSizeText(
                  'Top Brands: ',
                  style: GoogleFonts.montserrat(
                    fontSize: w * 0.04,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(
                height: 15,
              ),
              SizedBox(
                width: w * .9,
                child: Wrap(
                  // mainAxisSize: MainAxisSize.min,
                  // crossAxisAlignment: WrapCrossAlignment.center,
                  alignment: WrapAlignment.center,
                  children: List.generate(
                    12,
                    (index) => GestureDetector(
                      onTap: () {
                        // Navigator.push(
                        //   context,
                        //   MaterialPageRoute(
                        //     builder: (context) => ContentScreen(
                        //       vendorName: brandList[index]['name'].toString(),
                        //       vendorImage: kBaseUrl  +
                        //           brandList[index]['image'].toString(),
                        //       vendorId: vendorId.toString(),
                        //       date: dateFormat
                        //           .format(
                        //             DateTime.now().subtract(
                        //               const Duration(days: 1),
                        //             ),
                        //           )
                        //           .replaceAll('/', '-'),
                        //     ),
                        //   ),
                        // );
                      },
                      child: Card(
                        color: Colors.white,
                        child: Container(
                            width: w * .17,
                            decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(8)),
                            child: Padding(
                              padding: const EdgeInsets.all(2.0),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Shimmer.fromColors(
                                    baseColor: Colors.grey[300]!,
                                    highlightColor: Colors.grey[100]!,
                                    child: Container(
                                      color: Colors.black,
                                      width: w * .2,
                                      height: w * .2 - 20,
                                      // fit: BoxFit.fill,
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 5,
                                  ),
                                  Shimmer.fromColors(
                                    baseColor: Colors.grey[300]!,
                                    highlightColor: Colors.grey[100]!,
                                    child: Text(
                                      '0000',
                                      style: GoogleFonts.montserrat(
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ],
                              ),
                            )),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(
                height: 15,
              ),
            ],
          ),
        ),
      );

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
            clipper: NavBarClipper(),
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
                horizontalSpace(horizontalSpace: 1),
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
                horizontalSpace(horizontalSpace: 1),
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

class CompetitorClass extends StatefulWidget {
  const CompetitorClass({super.key, required this.model});

  final TopBrand model;

  @override
  State<CompetitorClass> createState() => _CompetitorClassState();
}

class _CompetitorClassState extends State<CompetitorClass>
    with AutomaticKeepAliveClientMixin {
  @override
  Widget build(BuildContext context) {
    super.build(context);
    return _competitorWidget(widget.model);
  }

  Widget _competitorWidget(TopBrand model) {
    List<Map<String, dynamic>> brandList = [];

    model.topBrands.forEach((key, value) {
      Map<String, dynamic> brand = {
        "name": key,
        "image": value.image,
        "count": value.count
      };
      brandList.add(brand);
    });

    return GestureDetector(
      onTap: () {},
      child: Card(
        color: Colors.white,
        elevation: 5,
        child: Container(
          width: w * .9,
          decoration: BoxDecoration(
              color: Colors.white, borderRadius: BorderRadius.circular(8)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: w,
                child: FittedBox(
                  child: Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 5.0, vertical: 10),
                        child: Center(
                          child: CachedNetworkImage(
                            imageUrl:
                                '${AppInfo.kBaseUrl(stagingSelector: 1)}vendor-logo/${model.vendorName}.jpg',
                            width: w * .5,
                            height: w * .2,
                            fit: BoxFit.fill,
                            placeholder: (context, url) => Center(
                              child: Lottie.asset(
                                'assets/lottie_animations/loading_bar.json',
                                repeat: true,
                                animate: true,
                                width: 50,
                                height: 50,
                                frameRate: FrameRate(
                                  60,
                                ),
                              ),
                            ),
                            // fit: BoxFit.fill,
                            errorWidget: (_, c, e) => SizedBox(
                              width: w * .2,
                              child: Center(
                                child: Text(
                                  model.vendorName,
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          verticalSpace(
                            verticalSpace: 1,
                          ),
                          Padding(
                            padding: const EdgeInsets.all(2.0),
                            child: RichText(
                              textAlign: TextAlign.center,
                              text: TextSpan(
                                  text: '${model.totalProducts}',
                                  style: GoogleFonts.montserrat(
                                    fontWeight: FontWeight.bold,
                                    fontSize: w * 0.04,
                                    color: Colors.blue,
                                  ),
                                  children: [
                                    TextSpan(
                                        text: '\n Common Products',
                                        style: GoogleFonts.montserrat(
                                          fontWeight: FontWeight.w500,
                                          fontSize: w * 0.03,
                                          color: Colors.black,
                                        )),
                                  ]),
                            ),
                          ),
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 2.0),
                            child: SizedBox(
                                width: w * .3,
                                child: const Divider(
                                  thickness: 1,
                                  color: Colors.black,
                                )),
                          ),
                          // AutoSizeText(
                          //   'No. of Common Products: ${model.totalProducts}',
                          //   style: GoogleFonts.montserrat(
                          //     fontSize: w * 0.032,
                          //     fontWeight: FontWeight.bold,
                          //   ),
                          // ),
                          // const SizedBox(
                          //   height: 10,
                          // ),
                          // Container(
                          //   height: 2,
                          //   width: w * .5,
                          //   color: Colors.black,
                          // ),
                          // const SizedBox(
                          //   height: 10,
                          // ),
                          Padding(
                            padding: const EdgeInsets.all(2.0),
                            child: RichText(
                              textAlign: TextAlign.center,
                              text: TextSpan(
                                  text: '${model.totalBrands}',
                                  style: GoogleFonts.montserrat(
                                    fontWeight: FontWeight.bold,
                                    fontSize: w * 0.04,
                                    color: Colors.blue,
                                  ),
                                  children: [
                                    TextSpan(
                                        text: '\n Common Brands',
                                        style: GoogleFonts.montserrat(
                                          fontWeight: FontWeight.w500,
                                          fontSize: w * 0.033,
                                          color: Colors.black,
                                        )),
                                  ]),
                            ),
                          ),
                        ],
                      ),
                      horizontalSpace(horizontalSpace: 2)
                    ],
                  ),
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              SizedBox(
                width: w * .9,
                child: Wrap(
                  // mainAxisSize: MainAxisSize.min,
                  // crossAxisAlignment: WrapCrossAlignment.center,
                  alignment: WrapAlignment.center,
                  children: List.generate(
                    brandList.length,
                    (index) => Card(
                      color: Colors.white,
                      child: Container(
                          width: w * .17,
                          decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8)),
                          child: Padding(
                            padding: const EdgeInsets.all(2.0),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                CachedNetworkImage(
                                  imageUrl: CommonMethods.removeLastSlash(
                                          AppInfo.kBaseUrl(
                                              stagingSelector: 1)) +
                                      brandList[index]['image'].toString(),
                                  width: w * .2,
                                  height: w * .2 - 20,
                                  placeholder: (context, url) => Center(
                                    child: Lottie.asset(
                                      'assets/lottie_animations/loading_bar.json',
                                      repeat: true,
                                      animate: true,
                                      width: 50,
                                      height: 50,
                                      frameRate: FrameRate(
                                        60,
                                      ),
                                    ),
                                  ),
                                  // fit: BoxFit.fill,
                                  errorWidget: (_, c, e) => SizedBox(
                                    width: w * .2,
                                    child: Center(
                                      child: Text(
                                        brandList[index]['name'],
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(
                                  height: 5,
                                ),
                                Text(
                                  brandList[index]['count'].toString(),
                                  style: GoogleFonts.montserrat(
                                      fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          )),
                    ),
                  ),
                ),
              ),
              const SizedBox(
                height: 10,
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;
}

class BrandSlider extends StatelessWidget {
  BrandSlider(
      {Key? key,
      required this.data,
      required this.vendorId,
      required this.database})
      : super(key: key);
  final String vendorId;
  Map<String, dynamic> data;
  List<Map<String, dynamic>> list = [];
  final Database database;

  @override
  Widget build(BuildContext context) {
    data.forEach((key, value) {
      Map<String, dynamic> brand = {"brandName": key, ...value};
      list.add(brand);
    });

    return Row(
      children: List.generate(
        list.length,
        (index) => buildPadding(index, context, vendorId, list, database),
      ),
    );
  }
}

Widget buildPadding(int index, BuildContext context, String vendorId,
    List<Map<String, dynamic>> list, Database database) {
  // List<int> temp = [];
  // temp.add(list[index]['lower more than 15%']);
  //
  // temp.add(list[index]['lower from 5% - 15%']);
  // temp.add(list[index]['lower upto 5%']);
  // temp.add(list[index]['higher upto 5%']);
  // temp.add(list[index]['higher from 5% - 15%']);
  // temp.add(list[index]['higher more than 15%']);
  //
  // List<int> orderedList = temp;

  return AspectRatio(
    aspectRatio: .66,
    child: SizedBox(
      width: w,
      // height: .52 * h,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 16.0),
        child: Card(
          color: Colors.white,
          elevation: 4,
          child: Container(
            decoration: BoxDecoration(
                color: Colors.white, borderRadius: BorderRadius.circular(8)),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CachedNetworkImage(
                        imageUrl:
                            'http://growth.matridtech.net/${list[index]['Image']}',
                        height: .13 * w,
                        width: .6 * w,
                        placeholder: (context, url) => Center(
                          child: Lottie.asset(
                            'assets/lottie_animations/loading_bar.json',
                            repeat: true,
                            animate: true,
                            width: 50,
                            height: 50,
                            frameRate: FrameRate(
                              60,
                            ),
                          ),
                        ),
                        errorWidget: (context, url, error) =>
                            const Icon(Icons.error),
                        // fit: BoxFit.fill,
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: AutoSizeText(
                          'Total Products: ${list[index]['total_products'].toString().toUpperCase()}',
                          maxLines: 1,
                          style: GoogleFonts.montserrat(
                            fontSize: w * 0.045,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  width: w,
                  child: Row(
                    mainAxisSize: MainAxisSize.max,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SizedBox(
                        width: w * .41,
                      ),
                      Card(
                        color: Colors.white,
                        child: Container(
                          decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8)),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                vertical: 16.0, horizontal: 8),
                            child: AutoSizeText(
                              'Map',
                              textAlign: TextAlign.center,
                              style: GoogleFonts.montserrat(
                                fontSize: w * .035,
                              ),
                            ),
                          ),
                        ),
                      ),
                      Card(
                        color: Colors.white,
                        child: Container(
                          decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8)),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                vertical: 4.0, horizontal: 8),
                            child: AutoSizeText(
                              'Map\nExempt',
                              textAlign: TextAlign.center,
                              style: GoogleFonts.montserrat(
                                fontSize: w * .035,
                              ),
                            ),
                          ),
                        ),
                      ),
                      Card(
                        color: Colors.white,
                        child: Container(
                          decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8)),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                vertical: 16.0, horizontal: 8),
                            child: AutoSizeText(
                              'Other',
                              style: GoogleFonts.montserrat(
                                fontSize: w * .035,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 4.0, vertical: 4),
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ContentScreen(
                            loadingString: 'Very Low 15%',
                            isVendorTable: false,
                            brandKey: list[index]['brandName'],
                            vendorName: 'Lowest by 15%',
                            vendorImage:
                                'http://growth.matridtech.net/${list[index]['Image']}',
                            vendorId: vendorId.toString(),
                            id: list[index]['id_lower more than 15%']
                                .toString(),
                            date: dateFormat
                                .format(
                                  DateTime.now().subtract(
                                    const Duration(days: 1),
                                  ),
                                )
                                .replaceAll('/', '-'),
                            isVendorPriceAnalysis: false,
                            loadingData:
                                list[index]['brandName'] + ' Very Low 15%',
                            database: database,
                          ),
                        ),
                      );

                      // log(list[index]['id_lowest_by_15%'].toString());
                    },
                    child: SizedBox(
                      width: w,
                      child: Row(
                        // mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          SizedBox(
                            width: .48 * w,
                            height: .13 * w,
                            child: Stack(
                              children: [
                                Container(
                                  width: .4 * w,
                                  height: .13 * w,
                                  constraints: BoxConstraints(
                                    minHeight: .1 * w,
                                    // maxHeight: .3 * w,
                                  ),
                                  decoration: const BoxDecoration(
                                    color: Colors.redAccent,
                                  ),
                                  child: Center(
                                    child: RichText(
                                      textAlign: TextAlign.center,
                                      text: TextSpan(
                                          text: 'Very Low\n'.toUpperCase(),
                                          style: GoogleFonts.montserrat(
                                            fontSize: w * 0.045,
                                            color: Colors.white,
                                            decoration:
                                                TextDecoration.underline,
                                            fontWeight: FontWeight.bold,
                                          ),
                                          children: [
                                            TextSpan(
                                              text: '<15%',
                                              style: GoogleFonts.montserrat(
                                                fontSize: w * 0.04,
                                                color: Colors.white,
                                                decoration: TextDecoration.none,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            )
                                          ]),
                                    ),
                                  ),
                                ),
                                const Align(
                                    alignment: Alignment.centerRight,
                                    child: Icon(
                                      Icons.arrow_right,
                                      size: 50,
                                      color: Colors.redAccent,
                                    ))
                              ],
                            ),
                          ),
                          SizedBox(
                            height: .13 * w,
                            child: SizedBox(
                              width: w * .4,
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Center(
                                    child: AutoSizeText(
                                      list[index]['lower more than 15%']
                                              ['map_count']
                                          .toString(),
                                      maxLines: 1,
                                      style: GoogleFonts.montserrat(
                                        color: Colors.redAccent,
                                        fontSize: w * .05,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  Center(
                                    child: AutoSizeText(
                                      list[index]['lower more than 15%']
                                              ['nonmap_count']
                                          .toString(),
                                      maxLines: 1,
                                      style: GoogleFonts.montserrat(
                                        color: Colors.redAccent,
                                        fontSize: w * .05,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  Center(
                                    child: AutoSizeText(
                                      list[index]['lower more than 15%']
                                              ['reviewed_count']
                                          .toString(),
                                      maxLines: 1,
                                      style: GoogleFonts.montserrat(
                                        color: Colors.redAccent,
                                        fontSize: w * .05,
                                        fontWeight: FontWeight.bold,
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
                  ),
                ),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 4.0, vertical: 4),
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ContentScreen(
                            loadingString: 'Low\n5% - 15%',
                            isVendorTable: false,
                            brandKey: list[index]['brandName'],
                            vendorName: 'Lowest by 5% - 15%',
                            vendorImage:
                                'http://growth.matridtech.net/${list[index]['Image']}',
                            vendorId: vendorId.toString(),
                            id: list[index]['id_lowest_by_5% - 15%'].toString(),
                            date: dateFormat
                                .format(
                                  DateTime.now().subtract(
                                    const Duration(days: 1),
                                  ),
                                )
                                .replaceAll('/', '-'),
                            isVendorPriceAnalysis: false,
                            loadingData:
                                list[index]['brandName'] + ' Low 5%-15%',
                            database: database,
                          ),
                        ),
                      );
                    },
                    child: SizedBox(
                      width: w,
                      child: Row(
                        // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          SizedBox(
                            width: .48 * w,
                            height: .13 * w,
                            child: Stack(
                              children: [
                                Container(
                                  width: .4 * w,
                                  height: .13 * w,
                                  constraints: BoxConstraints(
                                    minHeight: .1 * w,
                                    // maxHeight: .3 * w,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.redAccent.withOpacity(.7),
                                  ),
                                  child: Center(
                                    child: RichText(
                                      textAlign: TextAlign.center,
                                      text: TextSpan(
                                          text: 'Low\n'.toUpperCase(),
                                          style: GoogleFonts.montserrat(
                                            fontSize: w * 0.045,
                                            color: Colors.white,
                                            decoration:
                                                TextDecoration.underline,
                                            fontWeight: FontWeight.bold,
                                          ),
                                          children: [
                                            TextSpan(
                                              text: '5% - 15%',
                                              style: GoogleFonts.montserrat(
                                                fontSize: w * 0.04,
                                                color: Colors.white,
                                                decoration: TextDecoration.none,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            )
                                          ]),
                                    ),
                                  ),
                                ),
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: Icon(
                                    Icons.arrow_right,
                                    size: 50,
                                    color: Colors.redAccent.withOpacity(.7),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(
                            height: .13 * w,
                            width: w * .4,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Center(
                                  child: AutoSizeText(
                                    list[index]['lower from 5% - 15%']
                                            ['map_count']
                                        .toString(),
                                    maxLines: 1,
                                    style: GoogleFonts.montserrat(
                                      color: Colors.redAccent.withOpacity(.7),
                                      fontSize: w * .05,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                Center(
                                  child: AutoSizeText(
                                    list[index]['lower from 5% - 15%']
                                            ['nonmap_count']
                                        .toString(),
                                    maxLines: 1,
                                    style: GoogleFonts.montserrat(
                                      color: Colors.redAccent.withOpacity(.7),
                                      fontSize: w * .05,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                Center(
                                  child: AutoSizeText(
                                    list[index]['lower from 5% - 15%']
                                            ['reviewed_count']
                                        .toString(),
                                    maxLines: 1,
                                    style: GoogleFonts.montserrat(
                                      color: Colors.redAccent.withOpacity(.7),
                                      fontSize: w * .05,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 4.0, vertical: 4),
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ContentScreen(
                            loadingString: 'Lower By 5% ',
                            isVendorTable: false,
                            brandKey: list[index]['brandName'],
                            vendorName: 'Lowest by 5%',
                            vendorImage:
                                'http://growth.matridtech.net/${list[index]['Image']}',
                            vendorId: vendorId.toString(),
                            id: list[index]['id_lower upto 5%'].toString(),
                            date: dateFormat
                                .format(
                                  DateTime.now().subtract(
                                    const Duration(days: 1),
                                  ),
                                )
                                .replaceAll('/', '-'),
                            isVendorPriceAnalysis: false,
                            loadingData: list[index]['brandName'] + ' Low 5%',
                            database: database,
                          ),
                        ),
                      );
                    },
                    child: SizedBox(
                      width: w,
                      child: Row(
                        // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          SizedBox(
                            width: .48 * w,
                            height: .13 * w,
                            child: Stack(
                              children: [
                                Container(
                                  width: .4 * w,
                                  height: .13 * w,
                                  constraints: BoxConstraints(
                                    minHeight: .1 * w,
                                    // maxHeight: .3 * w,
                                  ),
                                  decoration: const BoxDecoration(
                                    color: Colors.green,
                                  ),
                                  child: Center(
                                    child: AutoSizeText(
                                      'Moderate'.toUpperCase(),
                                      textAlign: TextAlign.center,
                                      // maxFontSize: w * .06,
                                      style: GoogleFonts.montserrat(
                                        fontSize: w * 0.045,
                                        decoration: TextDecoration.underline,
                                        decorationColor: Colors.white,
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                                const Align(
                                  alignment: Alignment.centerRight,
                                  child: Icon(
                                    Icons.arrow_right,
                                    size: 50,
                                    color: Colors.green,
                                  ),
                                )
                              ],
                            ),
                          ),
                          SizedBox(
                            height: .13 * w,
                            width: w * .4,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Center(
                                  child: AutoSizeText(
                                    list[index]['lower upto 5%']['map_count']
                                        .toString(),
                                    maxLines: 1,
                                    style: GoogleFonts.montserrat(
                                      color: Colors.green,
                                      fontSize: w * .05,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                Center(
                                  child: AutoSizeText(
                                    list[index]['lower upto 5%']['nonmap_count']
                                        .toString(),
                                    maxLines: 1,
                                    style: GoogleFonts.montserrat(
                                      color: Colors.green,
                                      fontSize: w * .05,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                Center(
                                  child: AutoSizeText(
                                    list[index]['lower upto 5%']
                                            ['reviewed_count']
                                        .toString(),
                                    maxLines: 1,
                                    style: GoogleFonts.montserrat(
                                      color: Colors.green,
                                      fontSize: w * .05,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                // Padding(
                //   padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 4),
                //   child: GestureDetector(
                //     onTap: () {
                //       // log(list[index]['id_highest_by_5%'].toString());
                //     },
                //     child: SizedBox(
                //       width: w,
                //       child: Row(
                //         // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                //         children: [
                //           SizedBox(
                //             width: .48 * w,
                //             height: returnHeightAccordingToValues(
                //               value: list[index]['lower upto 5%'],
                //               orderedList: orderedList,
                //             ),
                //             child: Stack(
                //               children: [
                //                 Container(
                //                   width: .4 * w,
                //                   height: returnHeightAccordingToValues(
                //                     value: list[index]['lower upto 5%'],
                //                     orderedList: orderedList,
                //                   ),
                //                   constraints: BoxConstraints(
                //                     minHeight: .1 * w,
                //                     // maxHeight: .3 * w,
                //                   ),
                //                   decoration: const BoxDecoration(
                //                     color: Colors.grey,
                //                   ),
                //                   child: Center(
                //                     child: AutoSizeText(
                //                       'Neutral'.toUpperCase(),
                //                       maxLines: 1,
                //                       // maxFontSize: w * .06,
                //                       style: GoogleFonts.montserrat(
                //                         fontSize: w * 0.055,
                //                         color: Colors.white,
                //                         decoration: TextDecoration.underline,
                //                         decorationColor: Colors.white,
                //                         fontWeight: FontWeight.bold,
                //                       ),
                //                     ),
                //                   ),
                //                 ),
                //                 const Align(
                //                   alignment: Alignment.centerRight,
                //                   child: Icon(
                //                     Icons.arrow_right,
                //                     size: 50,
                //                     color: Colors.grey,
                //                   ),
                //                 )
                //               ],
                //             ),
                //           ),
                //           SizedBox(
                //             height: returnHeightAccordingToValues(
                //               value: list[index]['lower upto 5%'],
                //               orderedList: orderedList,
                //             ),
                //             width: w * .4,
                //             child: Row(
                //               mainAxisAlignment: MainAxisAlignment.spaceBetween,
                //               children: [
                //                 Center(
                //                   child: AutoSizeText(
                //                     list[index]['lower upto 5%'].toString(),
                //                     maxLines: 1,
                //                     style: GoogleFonts.montserrat(
                //                       color: Colors.grey,
                //                       fontSize: w * .06,
                //                       fontWeight: FontWeight.bold,
                //                     ),
                //                   ),
                //                 ),
                //                 Center(
                //                   child: AutoSizeText(
                //                     list[index]['lower upto 5%'].toString(),
                //                     maxLines: 1,
                //                     style: GoogleFonts.montserrat(
                //                       color: Colors.grey,
                //                       fontSize: w * .06,
                //                       fontWeight: FontWeight.bold,
                //                     ),
                //                   ),
                //                 ),
                //                 Center(
                //                   child: AutoSizeText(
                //                     list[index]['lower upto 5%'].toString(),
                //                     maxLines: 1,
                //                     style: GoogleFonts.montserrat(
                //                       color: Colors.grey,
                //                       fontSize: w * .06,
                //                       fontWeight: FontWeight.bold,
                //                     ),
                //                   ),
                //                 ),
                //               ],
                //             ),
                //           ),
                //         ],
                //       ),
                //     ),
                //   ),
                // ),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 4.0, vertical: 4),
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ContentScreen(
                            loadingString: 'Highest By 5%',
                            isVendorTable: false,
                            brandKey: list[index]['brandName'],
                            vendorName: 'Highest by 5%',
                            vendorImage:
                                'http://growth.matridtech.net/${list[index]['Image']}',
                            vendorId: vendorId.toString(),
                            id: list[index]['id_higher upto 5%%'].toString(),
                            date: dateFormat
                                .format(
                                  DateTime.now().subtract(
                                    const Duration(days: 1),
                                  ),
                                )
                                .replaceAll('/', '-'),
                            isVendorPriceAnalysis: false,
                            loadingData: list[index]['brandName'] + ' High 5%',
                            database: database,
                          ),
                        ),
                      );

                      // log(list[index]['id_highest_by_5%'].toString());
                    },
                    child: SizedBox(
                      width: w,
                      child: Row(
                        // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          SizedBox(
                            width: .48 * w,
                            height: .13 * w,
                            child: Stack(
                              children: [
                                Container(
                                  width: .4 * w,
                                  height: .13 * w,
                                  constraints: BoxConstraints(
                                    minHeight: .1 * w,
                                    // maxHeight: .3 * w,
                                  ),
                                  decoration: const BoxDecoration(
                                    color: Colors.green,
                                  ),
                                  child: Center(
                                    child: AutoSizeText(
                                      'Moderate'.toUpperCase(),
                                      textAlign: TextAlign.center,
                                      // maxFontSize: w * .06,
                                      style: GoogleFonts.montserrat(
                                        fontSize: w * 0.045,
                                        color: Colors.white,
                                        decoration: TextDecoration.underline,
                                        decorationColor: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                                const Align(
                                    alignment: Alignment.centerRight,
                                    child: Icon(
                                      Icons.arrow_right,
                                      size: 50,
                                      color: Colors.green,
                                    ))
                              ],
                            ),
                          ),
                          SizedBox(
                            height: .13 * w,
                            width: w * .4,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Center(
                                  child: AutoSizeText(
                                    list[index]['higher upto 5%']['map_count']
                                        .toString(),
                                    maxLines: 1,
                                    style: GoogleFonts.montserrat(
                                      color: Colors.green,
                                      fontSize: w * .05,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                Center(
                                  child: AutoSizeText(
                                    list[index]['higher upto 5%']
                                            ['nonmap_count']
                                        .toString(),
                                    maxLines: 1,
                                    style: GoogleFonts.montserrat(
                                      color: Colors.green,
                                      fontSize: w * .05,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                Center(
                                  child: AutoSizeText(
                                    list[index]['higher upto 5%']
                                            ['reviewed_count']
                                        .toString(),
                                    maxLines: 1,
                                    style: GoogleFonts.montserrat(
                                      color: Colors.green,
                                      fontSize: w * .05,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 4.0, vertical: 4),
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ContentScreen(
                            loadingString: 'High\n5% - 15%',
                            loadingData:
                                list[index]['brandName'] + ' High 5%-15%',
                            isVendorTable: false,
                            brandKey: list[index]['brandName'],
                            vendorName: 'Highest by 5% - 15%',
                            vendorImage:
                                'http://growth.matridtech.net/${list[index]['Image']}',
                            vendorId: vendorId.toString(),
                            id: list[index]['id_higher from 5% - 15%']
                                .toString(),
                            date: dateFormat
                                .format(
                                  DateTime.now().subtract(
                                    const Duration(days: 1),
                                  ),
                                )
                                .replaceAll('/', '-'),
                            isVendorPriceAnalysis: false,
                            database: database,
                          ),
                        ),
                      );

                      // log(list[index]['id_highest_by_5% - 15%'].toString());
                    },
                    child: SizedBox(
                      width: w,
                      child: Row(
                        // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          SizedBox(
                            width: .48 * w,
                            height: .13 * w,
                            child: Stack(
                              children: [
                                Container(
                                  width: .4 * w,
                                  height: .13 * w,
                                  constraints: BoxConstraints(
                                    minHeight: .1 * w,
                                    // maxHeight: .3 * w,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.redAccent.withOpacity(.7),
                                  ),
                                  child: Center(
                                    child: RichText(
                                      textAlign: TextAlign.center,
                                      text: TextSpan(
                                          text: 'High\n'.toUpperCase(),
                                          style: GoogleFonts.montserrat(
                                            fontSize: w * 0.045,
                                            color: Colors.white,
                                            decoration:
                                                TextDecoration.underline,
                                            fontWeight: FontWeight.bold,
                                          ),
                                          children: [
                                            TextSpan(
                                              text: '5% - 15%',
                                              style: GoogleFonts.montserrat(
                                                fontSize: w * 0.04,
                                                color: Colors.white,
                                                decoration: TextDecoration.none,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            )
                                          ]),
                                    ),
                                  ),
                                ),
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: Icon(
                                    Icons.arrow_right,
                                    size: 50,
                                    color: Colors.redAccent.withOpacity(.7),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(
                            height: .13 * w,
                            width: w * .4,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Center(
                                  child: AutoSizeText(
                                    list[index]['higher from 5% - 15%']
                                            ['map_count']
                                        .toString(),
                                    maxLines: 1,
                                    style: GoogleFonts.montserrat(
                                      color: Colors.redAccent.withOpacity(.7),
                                      fontSize: w * .05,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                Center(
                                  child: AutoSizeText(
                                    list[index]['higher from 5% - 15%']
                                            ['nonmap_count']
                                        .toString(),
                                    maxLines: 1,
                                    style: GoogleFonts.montserrat(
                                      color: Colors.redAccent.withOpacity(.7),
                                      fontSize: w * .05,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                Center(
                                  child: AutoSizeText(
                                    list[index]['higher from 5% - 15%']
                                            ['reviewed_count']
                                        .toString(),
                                    maxLines: 1,
                                    style: GoogleFonts.montserrat(
                                      color: Colors.redAccent.withOpacity(.7),
                                      fontSize: w * .05,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 4.0, vertical: 4),
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ContentScreen(
                            loadingString: 'Highest more then15%',
                            isVendorTable: false,
                            brandKey: list[index]['brandName'],
                            vendorName: 'Highest by 15%',
                            vendorImage:
                                'http://growth.matridtech.net/${list[index]['Image']}',
                            vendorId: vendorId.toString(),
                            id: list[index]['id_higher more than 15%']
                                .toString(),
                            date: dateFormat
                                .format(
                                  DateTime.now().subtract(
                                    const Duration(days: 1),
                                  ),
                                )
                                .replaceAll('/', '-'),
                            isVendorPriceAnalysis: false,
                            loadingData:
                                list[index]['brandName'] + ' Very High 15%',
                            database: database,
                          ),
                        ),
                      );
                    },
                    child: SizedBox(
                      width: w,
                      child: Row(
                        // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          SizedBox(
                            width: .48 * w,
                            height: .13 * w,
                            child: Stack(
                              children: [
                                Container(
                                  width: .4 * w,
                                  height: .13 * w,
                                  constraints: BoxConstraints(
                                    minHeight: .1 * w,
                                    // maxHeight: .3 * w,
                                  ),
                                  decoration: const BoxDecoration(
                                    color: Colors.redAccent,
                                  ),
                                  child: Center(
                                    child: RichText(
                                      textAlign: TextAlign.center,
                                      text: TextSpan(
                                          text: 'Very High\n'.toUpperCase(),
                                          style: GoogleFonts.montserrat(
                                            fontSize: w * 0.045,
                                            color: Colors.white,
                                            decoration:
                                                TextDecoration.underline,
                                            fontWeight: FontWeight.bold,
                                          ),
                                          children: [
                                            TextSpan(
                                              text: '>15%',
                                              style: GoogleFonts.montserrat(
                                                fontSize: w * 0.04,
                                                color: Colors.white,
                                                decoration: TextDecoration.none,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            )
                                          ]),
                                    ),
                                  ),
                                ),
                                const Align(
                                    alignment: Alignment.centerRight,
                                    child: Icon(
                                      Icons.arrow_right,
                                      size: 50,
                                      color: Colors.redAccent,
                                    ))
                              ],
                            ),
                          ),
                          SizedBox(
                            height: .13 * w,
                            width: w * .4,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Center(
                                  child: AutoSizeText(
                                    list[index]['higher more than 15%']
                                            ['map_count']
                                        .toString(),
                                    maxLines: 1,
                                    style: GoogleFonts.montserrat(
                                      color: Colors.redAccent,
                                      fontSize: w * .05,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                Center(
                                  child: AutoSizeText(
                                    list[index]['higher more than 15%']
                                            ['nonmap_count']
                                        .toString(),
                                    maxLines: 1,
                                    style: GoogleFonts.montserrat(
                                      color: Colors.redAccent,
                                      fontSize: w * .05,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                Center(
                                  child: AutoSizeText(
                                    list[index]['higher more than 15%']
                                            ['reviewed_count']
                                        .toString(),
                                    maxLines: 1,
                                    style: GoogleFonts.montserrat(
                                      color: Colors.redAccent,
                                      fontSize: w * .05,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}

List<ProductColor> colorList = [
  ProductColor(
    title: 'High Count',
    color: Colors.redAccent.withOpacity(.8),
  ),
  ProductColor(
    title: 'Semi High Count',
    color: Colors.redAccent.withOpacity(.6),
  ),
  ProductColor(
    title: 'Less High Count',
    color: Colors.redAccent.withOpacity(.5),
  ),
  ProductColor(
    title: 'High Lowest Count',
    color: Colors.redAccent.withOpacity(.4),
  ),
  ProductColor(
    title: 'Semi Low Count',
    color: Colors.redAccent.withOpacity(.3),
  ),
  ProductColor(
    title: 'Low Count',
    color: Colors.redAccent.withOpacity(.2),
  ),
  ProductColor(
    title: 'No Count',
    color: Colors.grey.withOpacity(.6),
  ),
];

class ProductColor {
  final String title;
  final Color color;

  ProductColor({required this.title, required this.color});
}

class SimpleBlocObserver extends BlocObserver {
  @override
  void onEvent(Bloc bloc, Object? event) {
    super.onEvent(bloc, event);
    if (kDebugMode) {
      print(event);
    }
  }

  @override
  void onChange(BlocBase bloc, Change change) {
    super.onChange(bloc, change);
    if (kDebugMode) {
      print(change);
    }
  }

  @override
  void onCreate(BlocBase bloc) {
    super.onCreate(bloc);
    if (kDebugMode) {
      print(bloc);
    }
  }

  @override
  void onTransition(Bloc bloc, Transition transition) {
    super.onTransition(bloc, transition);
    if (kDebugMode) {
      print(transition);
    }
  }

  @override
  void onError(BlocBase bloc, Object error, StackTrace stackTrace) {
    if (kDebugMode) {
      print(error);
    }
    super.onError(bloc, error, stackTrace);
  }
}

/*Price Change Widget*/

class PriceChangeWidget extends StatelessWidget {
  final PriceChanges priceChanges;
  final String date;

  const PriceChangeWidget(
      {super.key, required this.priceChanges, required this.date});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Visibility(
          visible: checkUpdateDate(priceChanges.today),
          child: AutoSizeText(
            'Today',
            maxLines: 1,
            style: GoogleFonts.montserrat(
              fontSize: w * 0.055,
              color: Colors.blue,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(
          height: 10,
        ),
        Center(
          child: Wrap(
            children: List.generate(
              priceChanges.today.length,
              (index) => Visibility(
                visible: returnFrequency(
                        history: priceChanges.today[index].history) !=
                    '0',
                child: Card(
                  color: Colors.white,
                  child: Container(
                    width: w * .3,
                    height: w * .33,
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8)),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 8.0, horizontal: 4),
                          child: CachedNetworkImage(
                            imageUrl:
                                'http://growth.matridtech.net/brand-logo/brands/${priceChanges.today[index].brandName.replaceAll(' ', '-').toLowerCase()}.png',
                            width: w * .22,
                            height: w * .102,
                            placeholder: (context, url) => Center(
                              child: Lottie.asset(
                                'assets/lottie_animations/loading_bar.json',
                                repeat: true,
                                animate: true,
                                width: 50,
                                height: 50,
                                frameRate: FrameRate(
                                  60,
                                ),
                              ),
                            ),
                            errorWidget: (context, error, stack) => Center(
                              child: AutoSizeText(
                                priceChanges.today[index].brandName,
                                style: GoogleFonts.montserrat(
                                  fontSize: w * 0.032,
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 4.0, horizontal: 4),
                          child: AutoSizeText(
                            '${returnFrequency(history: priceChanges.today[index].history)} Product${returnFrequency(history: priceChanges.today[index].history) != '1' ? 's' : ''}',
                            maxLines: 2,
                            textAlign: TextAlign.center,
                            style: GoogleFonts.montserrat(
                              fontSize: w * 0.04,
                              color: Colors.blue,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        CustomTooltip(
                          message: 'as',
                          triggerMode: TooltipTriggerMode.tap,
                          waitDuration: const Duration(
                            seconds: 1,
                          ),
                          showDuration: const Duration(
                            seconds: 10,
                          ),
                          padding: const EdgeInsets.all(12),
                          height: 35,
                          preferBelow: true,
                          textStyle: const TextStyle(
                            fontSize: 15,
                            color: Colors.white,
                            fontWeight: FontWeight.normal,
                          ),
                          decoration: const BoxDecoration(
                            borderRadius: BorderRadius.all(
                              Radius.circular(
                                10,
                              ),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey,
                                blurRadius: 10.0,
                                offset: Offset(
                                  6.0,
                                  6.0,
                                ),
                              ), //BoxShadow
                            ],
                            color: Colors.white,
                          ),
                          // BoxDe
                          // message: 'dasdasdasd',
                          // tooltipColor: Colors.blue,
                          history: priceChanges.today[index].history,
                          child: const Padding(
                            padding: EdgeInsets.symmetric(vertical: 8.0),
                            child: Icon(
                              Icons.history,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(
          height: 20,
        ),
        Visibility(
          visible: priceChanges.last7Days.isNotEmpty,
          child: AutoSizeText(
            'Last 7 Days',
            maxLines: 1,
            style: GoogleFonts.montserrat(
              fontSize: w * 0.055,
              color: Colors.blue,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Visibility(
          visible: priceChanges.last7Days.isNotEmpty,
          child: const SizedBox(
            height: 10,
          ),
        ),
        Center(
          child: Wrap(
            children: List.generate(
              priceChanges.last7Days.length,
              (index) => SizedBox(
                child: SizedBox(
                  width: w * .3,
                  child: Card(
                    color: Colors.white,
                    child: Container(
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8)),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                vertical: 8.0, horizontal: 4),
                            child: CachedNetworkImage(
                              imageUrl:
                                  'http://growth.matridtech.net/brand-logo/brands/${priceChanges.last7Days[index].brandName.replaceAll(' ', '-').toLowerCase()}.png',
                              width: w * .22,
                              height: w * .105,
                              placeholder: (context, url) => Center(
                                child: Lottie.asset(
                                  'assets/lottie_animations/loading_bar.json',
                                  repeat: true,
                                  animate: true,
                                  width: 50,
                                  height: 50,
                                  frameRate: FrameRate(
                                    60,
                                  ),
                                ),
                              ),
                              errorWidget: (context, error, stack) => Center(
                                child: AutoSizeText(
                                  priceChanges.last7Days[index].brandName,
                                  style: GoogleFonts.montserrat(
                                    fontSize: w * 0.032,
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                vertical: 8.0, horizontal: 4),
                            child: AutoSizeText(
                              '${priceChanges.last7Days[index].last7DaysCount}\nProduct${priceChanges.last7Days[index].last7DaysCount != 1 ? 's' : ''}',
                              maxLines: 2,
                              textAlign: TextAlign.center,
                              style: GoogleFonts.montserrat(
                                fontSize: w * 0.04,
                                color: Colors.blue,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(
          height: 20,
        ),
      ],
    );
  }

  String returnFrequency({required List<PriceHistory> history}) {
    String returnCurrentDateFrequency = '';

    DateFormat format = DateFormat('MM/dd/yyyy');
    DateTime dateTime = DateTime.parse(date);

    String date1 = format.format(dateTime).split(' ')[0].replaceAll('/', '-');

    for (PriceHistory element in history) {
      if (element.updateDate == date1) {
        returnCurrentDateFrequency = element.frequency.toString();
      }
    }
    if (returnCurrentDateFrequency.isEmpty) {
      returnCurrentDateFrequency = '0';
    }

    return returnCurrentDateFrequency;
  }

  String shiftFirstToLastAndLastToFirst(List<String> myList) {
    String firstElement = myList[0];
    String lastElement = myList[myList.length - 1];

    // Remove the first element
    myList.removeAt(0);

    // Add the first element to the end of the list
    myList.add(firstElement);

    // Remove the last element
    myList.removeLast();

    // Insert the last element at the beginning of the list
    myList.insert(0, lastElement);

    return myList.join('-');
  }
}

class NavBarClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();
    final width = size.width;
    final height = size.height;

    path.cubicTo(width / 12, 0, width / 12, 2 * height / 5, 2 * width / 12,
        2 * height / 5);
    path.cubicTo(
        3 * width / 12, 2 * height / 5, 3 * width / 12, 0, 4 * width / 12, 0);
    path.cubicTo(5 * width / 12, 0, 5 * width / 12, 2 * height / 5,
        6 * width / 12, 2 * height / 5);
    path.cubicTo(
        7 * width / 12, 2 * height / 5, 7 * width / 12, 0, 8 * width / 12, 0);
    path.cubicTo(9 * width / 12, 0, 9 * width / 12, 2 * height / 5,
        10 * width / 12, 2 * height / 5);
    path.cubicTo(11 * width / 12, 2 * height / 5, 11 * width / 12, 0, width, 0);
    path.lineTo(width, height);
    path.lineTo(0, height);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) {
    // TODO: implement shouldReclip
    return false;
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
  String _vendorShortName = '';
  String _sisterVendorShortName = '';

  bool _showMoreProduct = false;

  final _searchController = TextEditingController();

  bool _showMoreCategory = false;

  final _scrollController = ScrollController();
  late Future<List<Map<String, dynamic>>> _brandsFuture;
  late Future<List<Map<String, dynamic>>> _bannersFuture;

  List<List<FeaturedBrandModel>> makeFourElementsRow(
      {required List<FeaturedBrandModel> list}) {
    List<List<FeaturedBrandModel>> result = [];
    for (int i = 0; i < list.length; i += 4) {
      int end = (i + 4 < list.length) ? i + 4 : list.length;
      result.add(list.sublist(i, end));
    }
    return result;
  }

  void getData() async {
    List<Map<String, dynamic>> temp =
        await DatabaseHelper().getData(db: widget.database);

    final loginData =
        await DatabaseHelper().getUserInformation(db: widget.database);
    setState(() {
      databaseData = temp;
      _vendorShortName = loginData[vendor_short_nameKey];
      _sisterVendorShortName = loginData[sister_vendor_short_nameKey];
    });
  }

  @override
  void initState() {
    super.initState();
    getData();
    context.read<ProductListByIdBloc>().add(ProductListByIdLoadingEvent(
        vendorId: '${AppInfo.kVendorId}',
        date: '2024-03-05',
        dataId: '',
        featuredProducts: true,
        fromSearchScreen: false,
        brandProductsEnabled: false,
        isCategory: false));
    context.read<FeatureCategoryBloc>().add(const FeatureCategoryEvent());
    context.read<FeatureBrandsBloc>().add(const FeatureBrandsEvent());
    setupRemoteConfig();
    _bannersFuture = getBanners();
    _brandsFuture = _brandsFutureSingleton ??= fetchBrands();
    _mainContentBigImagesFuture = getMainContentBigImages();
    _mainContentSmallImagesFuture = getMainContentSmallImages();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }

  List<String> categoryList = [];
  List<String> featureCategoryList = [];

  //List<Map<String, dynamic>> _allBrands = [];
  //int _visibleCount = 10;

  List<String> newProductsDropDownCategoryList = [
    'Gas Grills',
    'Kamado Grills'
  ];
  String selProductsDropDCatList = 'Gas Grills';

  List<ProductsDataForTesting> newProducts = [
    ProductsDataForTesting(
      image:
          'https://www.shoppingmegamart.com/media/catalog/product/cache/8b8544c1a181b548add339ab14e1ae1b/f/1/f150ead0d6485821c5a97b5791fcc2eb_8.jpg',
      from: 'RCS',
      prodTitle: 'RCS Cutlass Pro 42-Inch Propane Gas Grill - RON42ALPCK',
      discountPercentage: '15',
      actualPrice: '\$6,848',
      discountedPrice: '\$5,828',
    ),
    ProductsDataForTesting(
      image:
          'https://www.shoppingmegamart.com/media/catalog/product/cache/8b8544c1a181b548add339ab14e1ae1b/e/1/e1060i-9lan.jpg',
      from: 'Fire Magic',
      prodTitle:
          'Fire Magic Echelon Diamond E1060i 48-Inch Built-In Natural Gas Grill w/ Rotisserie Left Side Infrared Burner & Analog Thermometer - E1060I-9LAN',
      discountPercentage: '10',
      actualPrice: '\$11,522',
      discountedPrice: '\$10,396',
    ),
    ProductsDataForTesting(
      image:
          'https://www.shoppingmegamart.com/media/catalog/product/cache/8b8544c1a181b548add339ab14e1ae1b/c/v/cv-mg-36ng.jpg',
      from: 'Crown Verity',
      prodTitle: 'Crown Verity 36-Inch Mobile Natural Gas Griddle - CV-MG-36NG',
      discountPercentage: '5',
      actualPrice: '\$3,488',
      discountedPrice: '\$3,313',
    ),
  ];

  List<String> specOfferProductsDropDownCategoryList = ['Built-In Grills'];
  String selSpecOfferProductsDropDCatList = 'Built-In Grills';

  List<ProductsDataForTesting> specOfferProducts = [
    ProductsDataForTesting(
      image:
          'https://www.shoppingmegamart.com/media/catalog/product/cache/8b8544c1a181b548add339ab14e1ae1b/a/x/axe-30gt-ng-s9003.jpg',
      from: 'Alfresco',
      prodTitle:
          'Alfresco ALXE 56-Inch Built-In Natural Gas Deluxe Grill With Rotisserie And Side Burner in Blue Lilac - ALXE-56-NG-S4005',
      discountPercentage: '0',
      actualPrice: '',
      discountedPrice: '\$9,239',
    ),
    ProductsDataForTesting(
      image:
          'https://www.shoppingmegamart.com/media/catalog/product/cache/8b8544c1a181b548add339ab14e1ae1b/a/x/axe-30gt-ng-s3027.jpg',
      from: 'Alfresco',
      prodTitle:
          'Alfresco ALXE 56-Inch Built-In Natural Gas Deluxe Grill With Rotisserie And Side Burner in Light Green - ALXE-56-NG-S6027',
      discountPercentage: '0',
      actualPrice: '',
      discountedPrice: '\$10,396',
    ),
    ProductsDataForTesting(
      image:
          'https://www.shoppingmegamart.com/media/catalog/product/cache/8b8544c1a181b548add339ab14e1ae1b/a/x/axe-30gt-ng-s9003.jpg',
      from: 'Alfresco',
      prodTitle:
          'Alfresco ALXE 56-Inch Built-In Natural Gas Deluxe Grill With Rotisserie And Side Burner in Raspberry Red - ALXE-56-NG-S3027',
      discountPercentage: '0',
      actualPrice: '',
      discountedPrice: '\$3,313',
    ),
  ];

  IconData? selectedIcon;
  List<IconData> iconsList = [
    Icons.favorite_border,
    Icons.compare_arrows_outlined,
    Icons.visibility_outlined,
    Icons.shopping_bag_outlined
  ];

  late Future<List<Map<String, dynamic>>> _mainContentBigImagesFuture;
  late Future<List<Map<String, dynamic>>> _mainContentSmallImagesFuture;

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
                      enabled: true,
                      controller: _searchController,
                      textInputAction: TextInputAction.search,
                      onFieldSubmitted: (value) {
                        if (value.length > 3) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ProductListScreen(
                                titleValue: value,
                                database: widget.database,
                                searchProduct: true,
                                dataList: const [],
                                isBrands: false,
                                isCategory: false,
                                title: 'Looking for: ${_searchController.text}',
                              ),
                            ),
                          );
                        }
                      },
                      cursorColor: AppColors.primary,
                      decoration: InputDecoration(
                        hintText: 'Search by product name...',
                        suffixIcon: InkWell(
                          splashColor: AppColors.primary.withOpacity(.3),
                          onTap: () {
                            if (_searchController.text.length > 3) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ProductListScreen(
                                    titleValue: _searchController.text,
                                    database: widget.database,
                                    dataList: const [],
                                    isBrands: false,
                                    searchProduct: true,
                                    isCategory: false,
                                    title:
                                        'Looking for: ${_searchController.text}',
                                  ),
                                ),
                              );
                            }
                          },
                          child: Icon(
                            Icons.search,
                            color: AppColors.primary,
                            size: 30,
                          ),
                        ),
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
            verticalSpace(verticalSpace: 15),
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
                    // shrinkWrap: true,
                    children: [
                      SizedBox(
                        height: h * .22,
                        child: FutureBuilder<List<Map<String, dynamic>>>(
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return Center(
                                  child: CustomLoader(width: 50, height: 50));
                            } else if (snapshot.hasError) {
                              return Center(
                                child: RichText(
                                  textAlign: TextAlign.center,
                                  text: TextSpan(
                                      text: 'Unable to load banners.\n',
                                      style: TextStyle(
                                          fontSize: .06 * w,
                                          fontFamily: 'Futura BdCn BT Bold',
                                          fontWeight: FontWeight.w300,
                                          color: Colors.black),
                                      children: [
                                        TextSpan(
                                          text: 'Try Again',
                                          recognizer: TapGestureRecognizer()
                                            ..onTap = () => setState(() {}),
                                          style: TextStyle(
                                              fontSize: .06 * w,
                                              fontFamily: 'Futura BdCn BT Bold',
                                              fontWeight: FontWeight.w300,
                                              color: Colors.red),
                                        )
                                      ]),
                                ),
                              );
                            } else {
                              // This is your dominant color
                              // Color dominantColor = snapshot.data!.dominantColor!.color;
                              return CarouselSlider(
                                enableAutoSlider: true,
                                unlimitedMode: true,
                                autoSliderTransitionTime:
                                    const Duration(seconds: 1),
                                autoSliderDelay: const Duration(seconds: 3),
                                slideIndicator: CircularSlideIndicator(
                                    padding: const EdgeInsets.only(top: 30),
                                    itemSpacing: 15,
                                    indicatorRadius: 5),
                                children: List.generate(
                                  snapshot.data!.length,
                                  (index) => Padding(
                                    padding:
                                        const EdgeInsets.only(bottom: 20.0),
                                    child: CachedNetworkImage(
                                      imageUrl: snapshot.data![index]
                                          ['imageLink'],
                                      fit: BoxFit.fill,
                                    ),
                                  ),
                                ),
                              );
                            }
                          },
                          future: _bannersFuture,
                        ),
                      ),
                      verticalSpace(verticalSpace: 15),
                      _mainContentBigImages(),
                      _mainContentSmallImages(),
                      verticalSpace(verticalSpace: 15),
                      //  _grillsMenu(),
                      //    verticalSpace(verticalSpace: 25),
                      // _newProductsTitleRow(),
                      // verticalSpace(verticalSpace: 15),
                      // _newProductsRow(),
                      // verticalSpace(verticalSpace: 25),
                      // _specialOfferProductsTitleRow(),
                      // verticalSpace(verticalSpace: 15),
                      // _specialOfferProductsRow(),
                      // verticalSpace(verticalSpace: 25),
                      // _shopByBrandTitleRow(),

                      Padding(
                        padding: const EdgeInsets.only(left: 20.0),
                        child: Text(
                          'Grills & Outdoor Cooking',
                          style: TextStyle(
                            fontSize: 27, fontWeight: FontWeight.bold,
                            //fontFamily: 'Futura BdCn BT Bold',
                            fontFamily: 'Segoe UI',
                          ),
                        ),
                      ),

                      verticalSpace(verticalSpace: 25),
                      grillsOutdoor(),

                      verticalSpace(verticalSpace: 15),
                      Padding(
                        padding: const EdgeInsets.only(left: 20.0),
                        child: Text(
                          'Shop by Grill Size',
                          style: TextStyle(
                            fontSize: 27, fontWeight: FontWeight.bold,
                            //fontFamily: 'Futura BdCn BT Bold',
                            fontFamily: 'Segoe UI',
                          ),
                        ),
                      ),
                      verticalSpace(verticalSpace: 25),
                      _shopByGrills(),

                      verticalSpace(verticalSpace: 5),
                      Padding(
                        padding: const EdgeInsets.only(left: 20.0),
                        child: Text(
                          'Shop by Brand',
                          style: TextStyle(
                            fontSize: 27,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Segoe UI',
                          ),
                        ),
                      ),
                      verticalSpace(verticalSpace: 25),
                      _allBrandsScreen(),
                      verticalSpace(verticalSpace: 45),

                      // /*Padding(
                      //   padding: const EdgeInsets.symmetric(
                      //       horizontal: 18.0, vertical: 5),
                      //   child: AutoSizeText(
                      //     'Shop By Category',
                      //     textAlign: TextAlign.start,
                      //     style: TextStyle(
                      //       fontSize: .06 * w,
                      //       fontFamily: 'Futura BdCn BT Bold',
                      //       fontWeight: FontWeight.w300,
                      //     ),
                      //   ),
                      // ),
                      // Padding(
                      //   padding: const EdgeInsets.only(left: 12.0),
                      //   child: SingleChildScrollView(
                      //     scrollDirection: Axis.horizontal,
                      //     child: Row(
                      //       children: List.generate(
                      //         4,
                      //         (index) => Padding(
                      //           padding: const EdgeInsets.all(8.0),
                      //           child: Container(
                      //             height: .35 * w,
                      //             width: .32 * w,
                      //             decoration: BoxDecoration(
                      //                 border: Border.all(color: Colors.grey),
                      //                 borderRadius: const BorderRadius.all(
                      //                     Radius.circular(5))),
                      //             child: Column(
                      //               children: [
                      //                 Padding(
                      //                   padding: const EdgeInsets.all(2.0),
                      //                   child: Image.asset(
                      //                     'assets/home_screen_assets/category/image-one.jpg',
                      //                   ),
                      //                 ),
                      //                 Text(
                      //                   'Power Tools',
                      //                   style: TextStyle(
                      //                     fontSize: .04 * w,
                      //                     fontWeight: FontWeight.bold,
                      //                   ),
                      //                 )
                      //               ],
                      //             ),
                      //           ),
                      //         ),
                      //       ),
                      //     ),
                      //   ),
                      // ),*/
                      // /*
                      // verticalSpace(verticalSpace: 15),
                      // BlocBuilder<FeatureBrandsBloc, FeatureBrandsState>(
                      //   builder: (context, state) {
                      //     return state is FeatureBrandsLoaded
                      //         ? Column(
                      //             crossAxisAlignment: CrossAxisAlignment.start,
                      //             children: makeFourElementsRow(
                      //                     list: state.data)
                      //                 .map(
                      //                   (row) => Padding(
                      //                     padding: const EdgeInsets.only(
                      //                       left: 16.0,
                      //                     ),
                      //                     child: SingleChildScrollView(
                      //                       scrollDirection: Axis.horizontal,
                      //                       child: Row(
                      //                         children: row
                      //                             .map(
                      //                               (item) => Padding(
                      //                                 padding:
                      //                                     const EdgeInsets.all(
                      //                                         4.0),
                      //                                 child: InkWell(
                      //                                   onTap: () {
                      //                                     Navigator.push(
                      //                                       context,
                      //                                       MaterialPageRoute(
                      //                                         builder: (context) =>
                      //                                             ProductListScreen(
                      //                                           titleValue: item
                      //                                               .brandKey
                      //                                               .toUpperCase(),
                      //                                           database: widget
                      //                                               .database,
                      //                                           dataList: const [],
                      //                                           isBrands: true,
                      //                                           imageUrl:
                      //                                               'http://growth.matridtech.net/brand-logo/brands/${item.brandKey}.png',
                      //                                           isCategory:
                      //                                               false,
                      //                                           title: '',
                      //                                         ),
                      //                                       ),
                      //                                     ).whenComplete(() => context
                      //                                         .read<
                      //                                             ProductListByIdBloc>()
                      //                                         .add(const ProductListByIdLoadingEvent(
                      //                                             vendorId:
                      //                                                 '${AppInfo.kVendorId}',
                      //                                             date:
                      //                                                 '2024-03-05',
                      //                                             dataId:
                      //                                                 '14371',
                      //                                             featuredProducts:
                      //                                                 false,
                      //                                             fromSearchScreen:
                      //                                                 false,
                      //                                             brandProductsEnabled:
                      //                                                 false,
                      //                                             isCategory:
                      //                                                 false)));
                      //                                   },
                      //                                   child: Card(
                      //                                     shape:
                      //                                         RoundedRectangleBorder(
                      //                                       borderRadius:
                      //                                           BorderRadius
                      //                                               .circular(
                      //                                         20,
                      //                                       ),
                      //                                     ),
                      //                                     shadowColor:
                      //                                         Colors.grey,
                      //                                     elevation: 4,
                      //                                     color: Colors.white,
                      //                                     surfaceTintColor:
                      //                                         Colors.white,
                      //                                     child: Padding(
                      //                                       padding:
                      //                                           const EdgeInsets
                      //                                               .symmetric(
                      //                                               horizontal:
                      //                                                   6.0,
                      //                                               vertical:
                      //                                                   4),
                      //                                       child:
                      //                                           CachedNetworkImage(
                      //                                         imageUrl:
                      //                                             'http://growth.matridtech.net/brand-logo/brands/${item.brandKey}.png',
                      //                                         width: w * .35,
                      //                                         height: w * .2,
                      //                                         errorWidget:
                      //                                             (context, _,
                      //                                                     c) =>
                      //                                                 Card(
                      //                                           color: Colors
                      //                                               .white,
                      //                                           surfaceTintColor:
                      //                                               Colors
                      //                                                   .white,
                      //                                           child: Padding(
                      //                                             padding:
                      //                                                 const EdgeInsets
                      //                                                     .all(
                      //                                                     6.0),
                      //                                             child:
                      //                                                 CachedNetworkImage(
                      //                                               imageUrl:
                      //                                                   'https://upload.wikimedia.org/wikipedia/commons/thumb/d/d1/Image_not_available.png/800px-Image_not_available.png?20210219185637',
                      //                                             ),
                      //                                           ),
                      //                                         ),
                      //                                       ),
                      //                                     ),
                      //                                   ),
                      //                                 )
                      //                                 */
                      // /*FutureBuilder(
                      //                                       future: updatePaletteGenerator(imageUrl: 'http://growth.matridtech.net/brand-logo/brands/${item.brandKey}.png'),
                      //                                     builder: (context, snapshot) {
                      //                                       if (snapshot.connectionState == ConnectionState.waiting) {
                      //                                         return const CircularProgressIndicator();
                      //                                       } else if (snapshot.hasError) {
                      //                                         return Card(
                      //                                           color: Colors.white,
                      //                                           surfaceTintColor: Colors.white,
                      //                                           child: Padding(
                      //                                             padding: const EdgeInsets.all(4.0),
                      //                                             child: CachedNetworkImage(
                      //                                               imageUrl:
                      //                                               'http://growth.matridtech.net/brand-logo/brands/${item.brandKey}.png',
                      //                                               width: w * .4,
                      //                                               height: w * .25,
                      //                                               errorWidget: (context, _,
                      //                                                   c) =>
                      //                                                   Card(
                      //                                                     color: Colors.white,
                      //                                                     surfaceTintColor: Colors.white,
                      //                                                     child: Padding(
                      //                                                       padding: const EdgeInsets.all(4.0),
                      //                                                       child: CachedNetworkImage(
                      //                                                         imageUrl:
                      //                                                         'https://upload.wikimedia.org/wikipedia/commons/thumb/d/d1/Image_not_available.png/800px-Image_not_available.png?20210219185637',
                      //                                                       ),
                      //                                                     ),
                      //                                                   ),
                      //                                             ),
                      //                                           ),
                      //                                         );
                      //                                       } else {
                      //                                         // This is your dominant color
                      //                                         Color dominantColor = snapshot.data!.dominantColor!.color;
                      //                                         return Card(
                      //                                           color: dominantColor.withOpacity(.5),
                      //                                           surfaceTintColor: dominantColor.withOpacity(.5),
                      //                                           child: Padding(
                      //                                             padding: const EdgeInsets.all(4.0),
                      //                                             child: CachedNetworkImage(
                      //                                               imageUrl:
                      //                                               'http://growth.matridtech.net/brand-logo/brands/${item.brandKey}.png',
                      //                                               width: w * .4,
                      //                                               height: w * .25,
                      //                                               errorWidget: (context, _,
                      //                                                   c) =>
                      //                                                   CachedNetworkImage(
                      //                                                     imageUrl:
                      //                                                     'https://upload.wikimedia.org/wikipedia/commons/thumb/d/d1/Image_not_available.png/800px-Image_not_available.png?20210219185637',
                      //                                                   ),
                      //                                             ),
                      //                                           ),
                      //                                         );
                      //                                       }
                      //                                     }
                      //                                   )*/
                      // /*
                      //                                 ,
                      //                               ),
                      //                             )
                      //                             .toList(),
                      //                       ),
                      //                     ),
                      //                   ),
                      //                 )
                      //                 .toList(),
                      //           )
                      //         : const Center(
                      //             child: CustomLoader(),
                      //           );
                      //   },
                      // ),*/
                      // // verticalSpace(verticalSpace: 15),
                      // // Padding(
                      // //   padding: const EdgeInsets.symmetric(
                      // //       horizontal: 18.0, vertical: 5),
                      // //   child: AutoSizeText(
                      // //     'Feature Products',
                      // //     textAlign: TextAlign.start,
                      // //     style: TextStyle(
                      // //       fontSize: .06 * w,
                      // //       fontFamily: 'Futura BdCn BT Bold',
                      // //       fontWeight: FontWeight.w300,
                      // //     ),
                      // //   ),
                      // // ),
                      // // BlocBuilder<ProductListByIdBloc, ProductListByIdState>(
                      // //   builder: (context, state) {
                      // //     return state is ProductListByIdLoading
                      // //         ? const Align(
                      // //             alignment: Alignment.topCenter,
                      // //             child: CustomLoader(),
                      // //           )
                      // //         : state is ProductListByIdLoadedState
                      // //             ? Column(
                      // //                 children: [
                      // //                   Center(
                      // //                     child: Wrap(
                      // //                       runSpacing: 10,
                      // //                       children: List.generate(
                      // //                         state.productList
                      // //                                     .where((element) =>
                      // //                                         !element
                      // //                                             .firstVendorPrice
                      // //                                             .contains(
                      // //                                                 '--'))
                      // //                                     .toList()
                      // //                                     .length <=
                      // //                                 6
                      // //                             ? state.productList
                      // //                                 .where((element) =>
                      // //                                     !element
                      // //                                         .firstVendorPrice
                      // //                                         .contains('--'))
                      // //                                 .toList()
                      // //                                 .length
                      // //                             : _showMoreProduct == true
                      // //                                 ? state.productList
                      // //                                     .where((element) =>
                      // //                                         !element
                      // //                                             .firstVendorPrice
                      // //                                             .contains(
                      // //                                                 '--'))
                      // //                                     .toList()
                      // //                                     .length
                      // //                                 : 6,
                      // //                         (index) => state.productList
                      // //                                 .where((element) =>
                      // //                                     !element
                      // //                                         .firstVendorPrice
                      // //                                         .contains('--'))
                      // //                                 .toList()[index]
                      // //                                 .firstVendorPrice
                      // //                                 .contains('--')
                      // //                             ? const SizedBox()
                      // //                             : Padding(
                      // //                                 padding: const EdgeInsets
                      // //                                     .symmetric(
                      // //                                     horizontal: 4.0),
                      // //                                 child: GestureDetector(
                      // //                                   onTap: () {
                      // //                                     Navigator.push(
                      // //                                       context,
                      // //                                       MaterialPageRoute(
                      // //                                         builder:
                      // //                                             (context) =>
                      // //                                                 SafeArea(
                      // //                                           child: Scaffold(
                      // //                                             body:
                      // //                                                 CurrentProductScreen(
                      // //                                               data: state
                      // //                                                   .productList
                      // //                                                   .where((element) => !element
                      // //                                                       .firstVendorPrice
                      // //                                                       .contains('--'))
                      // //                                                   .toList()[index],
                      // //                                               vendorId:
                      // //                                                   AppInfo.kVendorId,
                      // //                                               database: widget
                      // //                                                   .database,
                      // //                                               likedValue:
                      // //                                                   0,
                      // //                                               notifiedValue:
                      // //                                                   0,
                      // //                                               databaseData:
                      // //                                                   databaseData,
                      // //                                               vendorShortname:
                      // //                                                   '',
                      // //                                               sisterVendorShortName:
                      // //                                                   '',
                      // //                                             ),
                      // //                                           ),
                      // //                                         ),
                      // //                                       ),
                      // //                                     );
                      // //                                   },
                      // //                                   child: Card(
                      // //                                     shape:
                      // //                                         const RoundedRectangleBorder(
                      // //                                       side: BorderSide(
                      // //                                         color:
                      // //                                             Colors.grey,
                      // //                                       ),
                      // //                                     ),
                      // //                                     child: Container(
                      // //                                       width: w * .44,
                      // //                                       color: Colors.white,
                      // //                                       child: Column(
                      // //                                         crossAxisAlignment:
                      // //                                             CrossAxisAlignment
                      // //                                                 .start,
                      // //                                         children: [
                      // //                                           verticalSpace(
                      // //                                               verticalSpace:
                      // //                                                   5),
                      // //                                           Center(
                      // //                                             child:
                      // //                                                 CachedNetworkImage(
                      // //                                               imageUrl: state
                      // //                                                   .productList
                      // //                                                   .where((element) => !element
                      // //                                                       .firstVendorPrice
                      // //                                                       .contains(
                      // //                                                           '--'))
                      // //                                                   .toList()[
                      // //                                                       index]
                      // //                                                   .productImage,
                      // //                                               height:
                      // //                                                   w * .3,
                      // //                                               errorWidget:
                      // //                                                   (context,
                      // //                                                       _,
                      // //                                                       c) {
                      // //                                                 return CachedNetworkImage(
                      // //                                                     imageUrl:
                      // //                                                         'https://t3.ftcdn.net/jpg/04/34/72/82/360_F_434728286_OWQQvAFoXZLdGHlObozsolNeuSxhpr84.jpg');
                      // //                                               },
                      // //                                             ),
                      // //                                           ),
                      // //                                           verticalSpace(
                      // //                                               verticalSpace:
                      // //                                                   2),
                      // //                                           Container(
                      // //                                             constraints: BoxConstraints(
                      // //                                                 minHeight:
                      // //                                                     w *
                      // //                                                         .2,
                      // //                                                 maxHeight:
                      // //                                                     w * .21),
                      // //                                             child:
                      // //                                                 Padding(
                      // //                                               padding: const EdgeInsets
                      // //                                                   .only(
                      // //                                                   left: 8,
                      // //                                                   right:
                      // //                                                       10.0,
                      // //                                                   top: 8),
                      // //                                               child: Text(
                      // //                                                 state
                      // //                                                     .productList
                      // //                                                     .where((element) => !element
                      // //                                                         .firstVendorPrice
                      // //                                                         .contains('--'))
                      // //                                                     .toList()[index]
                      // //                                                     .productName,
                      // //                                                 maxLines:
                      // //                                                     3,
                      // //                                                 overflow:
                      // //                                                     TextOverflow
                      // //                                                         .ellipsis,
                      // //                                                 style: TextStyle(
                      // //                                                     color: '#222223'
                      // //                                                         .toColor(),
                      // //                                                     fontFamily:
                      // //                                                         'Myriad Arabic',
                      // //                                                     fontSize: w *
                      // //                                                         .06,
                      // //                                                     height:
                      // //                                                         1,
                      // //                                                     wordSpacing:
                      // //                                                         0,
                      // //                                                     letterSpacing:
                      // //                                                         0,
                      // //                                                     fontWeight:
                      // //                                                         FontWeight.w900),
                      // //                                               ),
                      // //                                             ),
                      // //                                           ),
                      // //                                           Padding(
                      // //                                             padding: const EdgeInsets
                      // //                                                 .symmetric(
                      // //                                                 horizontal:
                      // //                                                     8.0,
                      // //                                                 vertical:
                      // //                                                     3),
                      // //                                             child:
                      // //                                                 AutoSizeText(
                      // //                                               'MPN# ${state.productList.where((element) => !element.firstVendorPrice.contains('--')).toList()[index].productMpn}',
                      // //                                               maxLines: 1,
                      // //                                               overflow:
                      // //                                                   TextOverflow
                      // //                                                       .ellipsis,
                      // //                                               style: TextStyle(
                      // //                                                   color: Colors
                      // //                                                       .black,
                      // //                                                   fontFamily:
                      // //                                                       'Segoe UI',
                      // //                                                   fontSize: w *
                      // //                                                       .04,
                      // //                                                   wordSpacing:
                      // //                                                       0,
                      // //                                                   letterSpacing:
                      // //                                                       0,
                      // //                                                   fontWeight:
                      // //                                                       FontWeight.w500
                      // //
                      // //                                                   // fontWeight: FontWeight.w900
                      // //                                                   ),
                      // //                                             ),
                      // //                                           ),
                      // //                                           Padding(
                      // //                                             padding: const EdgeInsets
                      // //                                                 .symmetric(
                      // //                                                 horizontal:
                      // //                                                     8.0,
                      // //                                                 vertical:
                      // //                                                     5),
                      // //                                             child: Row(
                      // //                                               children: [
                      // //                                                 Icon(
                      // //                                                   Icons
                      // //                                                       .check,
                      // //                                                   color: '#3b8039'
                      // //                                                       .toColor(),
                      // //                                                   size:
                      // //                                                       23,
                      // //                                                 ),
                      // //                                                 horizontalSpace(
                      // //                                                     horizontalSpace:
                      // //                                                         8),
                      // //                                                 Text(
                      // //                                                   'In Stock',
                      // //                                                   maxLines:
                      // //                                                       3,
                      // //                                                   overflow:
                      // //                                                       TextOverflow.ellipsis,
                      // //                                                   style: TextStyle(
                      // //                                                       color: '#3b8039'
                      // //                                                           .toColor(),
                      // //                                                       fontFamily:
                      // //                                                           'Segoe UI Bold',
                      // //                                                       fontSize: w *
                      // //                                                           .043,
                      // //                                                       wordSpacing:
                      // //                                                           2,
                      // //                                                       letterSpacing:
                      // //                                                           0,
                      // //                                                       fontWeight:
                      // //                                                           FontWeight.normal
                      // //
                      // //                                                       // fontWeight: FontWeight.w900
                      // //                                                       ),
                      // //                                                 ),
                      // //                                               ],
                      // //                                             ),
                      // //                                           ),
                      // //                                           Padding(
                      // //                                             padding: const EdgeInsets
                      // //                                                 .symmetric(
                      // //                                                 horizontal:
                      // //                                                     8.0,
                      // //                                                 vertical:
                      // //                                                     5),
                      // //                                             child:
                      // //                                                 RichText(
                      // //                                               text:
                      // //                                                   TextSpan(
                      // //                                                 text: state
                      // //                                                     .productList
                      // //                                                     .where((element) => !element
                      // //                                                         .firstVendorPrice
                      // //                                                         .contains('--'))
                      // //                                                     .toList()[index]
                      // //                                                     .firstVendorPrice,
                      // //                                                 style:
                      // //                                                     TextStyle(
                      // //                                                   color: '#e3121b'
                      // //                                                       .toColor(),
                      // //                                                   fontFamily:
                      // //                                                       'MyriadPro-BoldCond',
                      // //                                                   fontSize:
                      // //                                                       w * .08,
                      // //                                                   wordSpacing:
                      // //                                                       .1,
                      // //                                                   letterSpacing:
                      // //                                                       0,
                      // //                                                   fontWeight:
                      // //                                                       FontWeight.bold,
                      // //                                                 ),
                      // //                                               ),
                      // //                                             ),
                      // //                                           ),
                      // //                                           Padding(
                      // //                                             padding:
                      // //                                                 const EdgeInsets
                      // //                                                     .symmetric(
                      // //                                               horizontal:
                      // //                                                   8.0,
                      // //                                             ),
                      // //                                             child:
                      // //                                                 SizedBox(
                      // //                                               width:
                      // //                                                   w * .46,
                      // //                                               child:
                      // //                                                   FittedBox(
                      // //                                                 child:
                      // //                                                     Row(
                      // //                                                   children: [
                      // //                                                     Icon(
                      // //                                                       Icons.local_shipping,
                      // //                                                       color:
                      // //                                                           '#0678cb'.toColor(),
                      // //                                                     ),
                      // //                                                     horizontalSpace(
                      // //                                                         horizontalSpace: 3),
                      // //                                                     AutoSizeText(
                      // //                                                       state.productList.where((element) => !element.firstVendorPrice.contains('--')).toList()[index].firstVendorPriceShipping == '--' || state.productList.where((element) => !element.firstVendorPrice.contains('--')).toList()[index].firstVendorPriceShipping == '\$0.00'
                      // //                                                           ? ' Free Shipping'
                      // //                                                           : 'Shipping(${state.productList.where((element) => !element.firstVendorPrice.contains('--')).toList()[index].firstVendorPriceShipping})',
                      // //                                                       maxLines:
                      // //                                                           3,
                      // //                                                       overflow:
                      // //                                                           TextOverflow.ellipsis,
                      // //                                                       style: TextStyle(
                      // //                                                           color: state.productList.where((element) => !element.firstVendorPrice.contains('--')).toList()[index].firstVendorPriceShipping == '--' || state.productList.where((element) => !element.firstVendorPrice.contains('--')).toList()[index].firstVendorPriceShipping == '\$0.00' ? '#3b8039'.toColor() : '#0678cb'.toColor(),
                      // //                                                           fontFamily: 'Segoe UI Bold',
                      // //                                                           fontSize: w * .042,
                      // //                                                           wordSpacing: 2,
                      // //                                                           letterSpacing: .4,
                      // //                                                           fontWeight: FontWeight.normal
                      // //
                      // //                                                           // fontWeight: FontWeight.w900
                      // //                                                           ),
                      // //                                                     )
                      // //                                                   ],
                      // //                                                 ),
                      // //                                               ),
                      // //                                             ),
                      // //                                           ),
                      // //                                           verticalSpace(
                      // //                                               verticalSpace:
                      // //                                                   11),
                      // //                                           /*                  Center(
                      // //                                             child:
                      // //                                                 CachedNetworkImage(
                      // //                                               imageUrl:
                      // //                                                   '${AppInfo.kBaseUrl(stagingSelector: 0)}vendor-logo/${finalList[index].firstVendorName}.jpg',
                      // //                                               height:
                      // //                                                   h * 0.045,
                      // //                                               fit: BoxFit
                      // //                                                   .fill,
                      // //                                               errorWidget: (_,
                      // //                                                       c,
                      // //                                                       e) =>
                      // //                                                   SizedBox(
                      // //                                                 child:
                      // //                                                     Container(
                      // //                                                   width: w *
                      // //                                                       .42,
                      // //                                                   padding:
                      // //                                                       const EdgeInsets
                      // //                                                           .all(
                      // //                                                           2),
                      // //                                                   color: Colors
                      // //                                                       .black,
                      // //                                                   child:
                      // //                                                       Center(
                      // //                                                     child:
                      // //                                                         AutoSizeText(
                      // //                                                       finalList[index]
                      // //                                                           .firstVendorName,
                      // //                                                       maxLines:
                      // //                                                           1,
                      // //                                                       textAlign:
                      // //                                                           TextAlign.center,
                      // //                                                       style:
                      // //                                                           GoogleFonts.albertSans(
                      // //                                                         color:
                      // //                                                             Colors.white,
                      // //                                                         fontSize:
                      // //                                                             w * .055,
                      // //                                                         letterSpacing:
                      // //                                                             0,
                      // //                                                         fontWeight:
                      // //                                                             FontWeight.bold,
                      // //                                                         // fontFamily: 'JT Marnie Light',
                      // //                                                       ),
                      // //                                                     ),
                      // //                                                   ),
                      // //                                                 ),
                      // //                                               ),
                      // //                                             ),
                      // //                                           ),
                      // //                                           verticalSpace(
                      // //                                               verticalSpace:
                      // //                                                   5),*/
                      // //                                           Center(
                      // //                                             child:
                      // //                                                 InkWell(
                      // //                                               onTap: () async =>
                      // //                                                   await MyInAppBrowser()
                      // //                                                       .openUrlRequest(
                      // //                                                 urlRequest:
                      // //                                                     URLRequest(
                      // //                                                   url: Uri
                      // //                                                       .parse(
                      // //                                                     state
                      // //                                                         .productList
                      // //                                                         .where((element) => !element.firstVendorPrice.contains('--'))
                      // //                                                         .toList()[index]
                      // //                                                         .firstVendorUrl,
                      // //                                                   ),
                      // //                                                 ),
                      // //                                                 options:
                      // //                                                     InAppBrowserClassOptions(
                      // //                                                   crossPlatform:
                      // //                                                       InAppBrowserOptions(
                      // //                                                     toolbarTopBackgroundColor:
                      // //                                                         Colors.blue,
                      // //                                                   ),
                      // //                                                 ),
                      // //                                               ),
                      // //                                               child: BuyAtButton(
                      // //                                                   imageUrl: state
                      // //                                                       .productList
                      // //                                                       .where((element) =>
                      // //                                                           !element.firstVendorPrice.contains('--'))
                      // //                                                       .toList()[index]
                      // //                                                       .firstVendorName)
                      // //                                               /*Container(
                      // //                                                 width:
                      // //                                                     w * .42,
                      // //                                                 decoration:
                      // //                                                     BoxDecoration(
                      // //                                                   border:
                      // //                                                       Border
                      // //                                                           .all(
                      // //                                                     color: Colors
                      // //                                                         .blue,
                      // //                                                     width:
                      // //                                                         3,
                      // //                                                   ),
                      // //                                                   borderRadius:
                      // //                                                       BorderRadius
                      // //                                                           .circular(
                      // //                                                     3,
                      // //                                                   ),
                      // //                                                 ),
                      // //                                                 child:
                      // //                                                     Padding(
                      // //                                                   padding: const EdgeInsets
                      // //                                                       .symmetric(
                      // //                                                       vertical:
                      // //                                                           10.0),
                      // //                                                   child:
                      // //                                                       Row(
                      // //                                                     mainAxisAlignment:
                      // //                                                         MainAxisAlignment.center,
                      // //                                                     crossAxisAlignment:
                      // //                                                         CrossAxisAlignment.center,
                      // //                                                     children: [
                      // //                                                       Image
                      // //                                                           .asset(
                      // //                                                         'assets/images/world-wide-web.png',
                      // //                                                         color:
                      // //                                                             '#0678cb'.toColor(),
                      // //                                                         height:
                      // //                                                             20,
                      // //                                                         width:
                      // //                                                             20,
                      // //                                                         // weight: 10,
                      // //                                                       ),
                      // //                                                       horizontalSpace(
                      // //                                                           horizontalSpace: 15),
                      // //                                                       AutoSizeText(
                      // //                                                         'Visit'.toUpperCase(),
                      // //                                                         style:
                      // //                                                             TextStyle(
                      // //                                                           color: '#0678cb'.toColor(),
                      // //                                                           fontFamily: 'MyriadPro-BoldCond',
                      // //                                                           fontSize: w * .043,
                      // //                                                           wordSpacing: .1,
                      // //                                                           letterSpacing: 0,
                      // //                                                           fontWeight: FontWeight.bold,
                      // //                                                         ),
                      // //                                                       )
                      // //                                                     ],
                      // //                                                   ),
                      // //                                                 ),
                      // //                                               )*/
                      // //                                               ,
                      // //                                             ),
                      // //                                           ),
                      // //                                           verticalSpace(
                      // //                                               verticalSpace:
                      // //                                                   15)
                      // //                                         ],
                      // //                                       ),
                      // //                                     ),
                      // //                                   ),
                      // //                                 ),
                      // //                               )
                      // //                         /*Padding(
                      // //                                 padding: const EdgeInsets
                      // //                                     .symmetric(
                      // //                                     horizontal: 4.0),
                      // //                                 child: GestureDetector(
                      // //                                   onTap: () {
                      // //                                     Navigator.push(
                      // //                                       context,
                      // //                                       MaterialPageRoute(
                      // //                                         builder:
                      // //                                             (context) =>
                      // //                                                 SafeArea(
                      // //                                           child: Scaffold(
                      // //                                             body:
                      // //                                                 CurrentProductScreen(
                      // //                                               data: state
                      // //                                                   .productList
                      // //                                                   .where((element) => !element
                      // //                                                       .firstVendorPrice
                      // //                                                       .contains(
                      // //                                                           '--'))
                      // //                                                   .toList()[index],
                      // //                                               vendorId:
                      // //                                                   AppInfo.kVendorId,
                      // //                                               database: widget
                      // //                                                   .database,
                      // //                                               likedValue: 0,
                      // //                                               notifiedValue:
                      // //                                                   0,
                      // //                                               databaseData:
                      // //                                                   databaseData,
                      // //                                               vendorShortname:
                      // //                                                   _vendorShortName,
                      // //                                               sisterVendorShortName:
                      // //                                                   _sisterVendorShortName,
                      // //                                             ),
                      // //                                           ),
                      // //                                         ),
                      // //                                       ),
                      // //                                     );
                      // //                                   },
                      // //                                   child: Card(
                      // //                                     shape:
                      // //                                         const RoundedRectangleBorder(
                      // //                                       side: BorderSide(
                      // //                                         color: Colors.grey,
                      // //                                       ),
                      // //                                     ),
                      // //                                     child: Container(
                      // //                                       width: w * .44,
                      // //                                       // height: h * .56,
                      // //                                       color: Colors.white,
                      // //                                       child: Column(
                      // //                                         crossAxisAlignment:
                      // //                                             CrossAxisAlignment
                      // //                                                 .start,
                      // //                                         children: [
                      // //                                           verticalSpace(
                      // //                                               verticalSpace:
                      // //                                                   5),
                      // //                                           Center(
                      // //                                             child:
                      // //                                                 CachedNetworkImage(
                      // //                                               imageUrl: state
                      // //                                                   .productList
                      // //                                                   .where((element) => !element
                      // //                                                       .firstVendorPrice
                      // //                                                       .contains(
                      // //                                                           '--'))
                      // //                                                   .toList()[
                      // //                                                       index]
                      // //                                                   .productImage,
                      // //                                               height:
                      // //                                                   w * .3,
                      // //                                               errorWidget:
                      // //                                                   (context,
                      // //                                                       _,
                      // //                                                       c) {
                      // //                                                 return CachedNetworkImage(
                      // //                                                     imageUrl:
                      // //                                                         'https://t3.ftcdn.net/jpg/04/34/72/82/360_F_434728286_OWQQvAFoXZLdGHlObozsolNeuSxhpr84.jpg');
                      // //                                               },
                      // //                                             ),
                      // //                                           ),
                      // //                                           verticalSpace(
                      // //                                               verticalSpace:
                      // //                                                   2),
                      // //                                           Container(
                      // //                                             constraints: BoxConstraints(
                      // //                                                 minHeight:
                      // //                                                     w * .2,
                      // //                                                 maxHeight:
                      // //                                                     w * .21),
                      // //                                             child: Padding(
                      // //                                               padding:
                      // //                                                   const EdgeInsets
                      // //                                                       .only(
                      // //                                                       left:
                      // //                                                           8,
                      // //                                                       right:
                      // //                                                           10.0,
                      // //                                                       top:
                      // //                                                           8),
                      // //                                               child: Text(
                      // //                                                 state
                      // //                                                     .productList
                      // //                                                     .where((element) => !element
                      // //                                                         .firstVendorPrice
                      // //                                                         .contains(
                      // //                                                             '--'))
                      // //                                                     .toList()[
                      // //                                                         index]
                      // //                                                     .productName,
                      // //                                                 maxLines: 3,
                      // //                                                 overflow:
                      // //                                                     TextOverflow
                      // //                                                         .ellipsis,
                      // //                                                 style: TextStyle(
                      // //                                                     color: '#222223'
                      // //                                                         .toColor(),
                      // //                                                     fontFamily:
                      // //                                                         'Myriad Arabic',
                      // //                                                     fontSize: w *
                      // //                                                         .06,
                      // //                                                     height:
                      // //                                                         1,
                      // //                                                     wordSpacing:
                      // //                                                         0,
                      // //                                                     letterSpacing:
                      // //                                                         0,
                      // //                                                     fontWeight:
                      // //                                                         FontWeight.w900),
                      // //                                               ),
                      // //                                             ),
                      // //                                           ),
                      // //                                           Padding(
                      // //                                             padding: const EdgeInsets
                      // //                                                 .symmetric(
                      // //                                                 horizontal:
                      // //                                                     8.0,
                      // //                                                 vertical:
                      // //                                                     3),
                      // //                                             child: Text(
                      // //                                               'SKU# ${state.productList.where((element) => !element.firstVendorPrice.contains('--')).toList()[index].secondarySku.contains('--') ? state.productList.where((element) => !element.firstVendorPrice.contains('--')).toList()[index].productMpn : state.productList.where((element) => !element.firstVendorPrice.contains('--')).toList()[index].secondarySku}',
                      // //                                               maxLines: 3,
                      // //                                               overflow:
                      // //                                                   TextOverflow
                      // //                                                       .ellipsis,
                      // //                                               style: TextStyle(
                      // //                                                   color: Colors
                      // //                                                       .black,
                      // //                                                   fontFamily:
                      // //                                                       'Segoe UI',
                      // //                                                   fontSize:
                      // //                                                       w *
                      // //                                                           .04,
                      // //                                                   wordSpacing:
                      // //                                                       0,
                      // //                                                   letterSpacing:
                      // //                                                       0,
                      // //                                                   fontWeight:
                      // //                                                       FontWeight
                      // //                                                           .w500
                      // //
                      // //                                                   // fontWeight: FontWeight.w900
                      // //                                                   ),
                      // //                                             ),
                      // //                                           ),
                      // //                                           Padding(
                      // //                                             padding: const EdgeInsets
                      // //                                                 .symmetric(
                      // //                                                 horizontal:
                      // //                                                     8.0,
                      // //                                                 vertical:
                      // //                                                     5),
                      // //                                             child: Row(
                      // //                                               children: [
                      // //                                                 Icon(
                      // //                                                   Icons
                      // //                                                       .check,
                      // //                                                   color: '#3b8039'
                      // //                                                       .toColor(),
                      // //                                                   size: 23,
                      // //                                                 ),
                      // //                                                 horizontalSpace(
                      // //                                                     horizontalSpace:
                      // //                                                         8),
                      // //                                                 Text(
                      // //                                                   'In Stock',
                      // //                                                   maxLines:
                      // //                                                       3,
                      // //                                                   overflow:
                      // //                                                       TextOverflow
                      // //                                                           .ellipsis,
                      // //                                                   style: TextStyle(
                      // //                                                       color: '#3b8039'
                      // //                                                           .toColor(),
                      // //                                                       fontFamily:
                      // //                                                           'Segoe UI Bold',
                      // //                                                       fontSize: w *
                      // //                                                           .043,
                      // //                                                       wordSpacing:
                      // //                                                           2,
                      // //                                                       letterSpacing:
                      // //                                                           0,
                      // //                                                       fontWeight:
                      // //                                                           FontWeight.normal
                      // //
                      // //                                                       // fontWeight: FontWeight.w900
                      // //                                                       ),
                      // //                                                 ),
                      // //                                               ],
                      // //                                             ),
                      // //                                           ),
                      // //                                           Padding(
                      // //                                             padding: const EdgeInsets
                      // //                                                 .symmetric(
                      // //                                                 horizontal:
                      // //                                                     8.0,
                      // //                                                 vertical:
                      // //                                                     5),
                      // //                                             child: RichText(
                      // //                                               text:
                      // //                                                   TextSpan(
                      // //                                                 text: state
                      // //                                                     .productList
                      // //                                                     .where((element) => !element
                      // //                                                         .firstVendorPrice
                      // //                                                         .contains(
                      // //                                                             '--'))
                      // //                                                     .toList()[
                      // //                                                         index]
                      // //                                                     .vendorpriceFinalprice,
                      // //                                                 style:
                      // //                                                     TextStyle(
                      // //                                                   color: '#e3121b'
                      // //                                                       .toColor(),
                      // //                                                   fontFamily:
                      // //                                                       'MyriadPro-BoldCond',
                      // //                                                   fontSize:
                      // //                                                       w * .08,
                      // //                                                   wordSpacing:
                      // //                                                       .1,
                      // //                                                   letterSpacing:
                      // //                                                       0,
                      // //                                                   fontWeight:
                      // //                                                       FontWeight
                      // //                                                           .bold,
                      // //                                                 ),
                      // //                                               ),
                      // //                                             ),
                      // //                                           ),
                      // //                                           Padding(
                      // //                                             padding:
                      // //                                                 const EdgeInsets
                      // //                                                     .symmetric(
                      // //                                               horizontal:
                      // //                                                   8.0,
                      // //                                             ),
                      // //                                             child: SizedBox(
                      // //                                               width:
                      // //                                                   w * .46,
                      // //                                               child:
                      // //                                                   FittedBox(
                      // //                                                 child: Row(
                      // //                                                   children: [
                      // //                                                     Icon(
                      // //                                                       Icons
                      // //                                                           .local_shipping,
                      // //                                                       color:
                      // //                                                           '#0678cb'.toColor(),
                      // //                                                     ),
                      // //                                                     horizontalSpace(
                      // //                                                         horizontalSpace:
                      // //                                                             3),
                      // //                                                     AutoSizeText(
                      // //                                                       state.productList.where((element) => !element.firstVendorPrice.contains('--')).toList()[index].vendorpriceShipping == '--' || state.productList.where((element) => !element.firstVendorPrice.contains('--')).toList()[index].vendorpriceShipping == '\$0.00'
                      // //                                                           ? ' Free Shipping'
                      // //                                                           : 'Shipping(${state.productList.where((element) => !element.firstVendorPrice.contains('--')).toList()[index].vendorpriceShipping})',
                      // //                                                       maxLines:
                      // //                                                           3,
                      // //                                                       overflow:
                      // //                                                           TextOverflow.ellipsis,
                      // //                                                       style: TextStyle(
                      // //                                                           color: '#0678cb'.toColor(),
                      // //                                                           fontFamily: 'Segoe UI Bold',
                      // //                                                           fontSize: w * .042,
                      // //                                                           wordSpacing: 2,
                      // //                                                           letterSpacing: .4,
                      // //                                                           fontWeight: FontWeight.normal
                      // //
                      // //                                                           // fontWeight: FontWeight.w900
                      // //                                                           ),
                      // //                                                     )
                      // //                                                   ],
                      // //                                                 ),
                      // //                                               ),
                      // //                                             ),
                      // //                                           ),
                      // //                                           verticalSpace(
                      // //                                               verticalSpace:
                      // //                                                   11),
                      // //                                           Center(
                      // //                                             child:
                      // //                                                 CachedNetworkImage(
                      // //                                               imageUrl:
                      // //                                                   '${AppInfo.kBaseUrl(stagingSelector: 0)}vendor-logo/${state.productList.where((element) => !element.firstVendorPrice.contains('--')).toList()[index].firstVendorName}.jpg',
                      // //                                               height:
                      // //                                                   h * 0.045,
                      // //                                               fit: BoxFit
                      // //                                                   .fill,
                      // //                                               errorWidget: (_,
                      // //                                                       c,
                      // //                                                       e) =>
                      // //                                                   SizedBox(
                      // //                                                 child:
                      // //                                                     Container(
                      // //                                                   width: w *
                      // //                                                       .42,
                      // //                                                   padding:
                      // //                                                       const EdgeInsets
                      // //                                                           .all(
                      // //                                                           2),
                      // //                                                   color: Colors
                      // //                                                       .black,
                      // //                                                   child:
                      // //                                                       Center(
                      // //                                                     child:
                      // //                                                         AutoSizeText(
                      // //                                                       state
                      // //                                                           .productList[index]
                      // //                                                           .firstVendorName,
                      // //                                                       maxLines:
                      // //                                                           1,
                      // //                                                       textAlign:
                      // //                                                           TextAlign.center,
                      // //                                                       style:
                      // //                                                           GoogleFonts.albertSans(
                      // //                                                         color:
                      // //                                                             Colors.white,
                      // //                                                         fontSize:
                      // //                                                             w * .055,
                      // //                                                         letterSpacing:
                      // //                                                             0,
                      // //                                                         fontWeight:
                      // //                                                             FontWeight.bold,
                      // //                                                         // fontFamily: 'JT Marnie Light',
                      // //                                                       ),
                      // //                                                     ),
                      // //                                                   ),
                      // //                                                 ),
                      // //                                               ),
                      // //                                             ),
                      // //                                           ),
                      // //                                           verticalSpace(
                      // //                                               verticalSpace:
                      // //                                                   5),
                      // //                                           Center(
                      // //                                             child: InkWell(
                      // //                                               onTap: () async =>
                      // //                                                   await MyInAppBrowser()
                      // //                                                       .openUrlRequest(
                      // //                                                 urlRequest:
                      // //                                                     URLRequest(
                      // //                                                   url: Uri
                      // //                                                       .parse(
                      // //                                                     state
                      // //                                                         .productList[index]
                      // //                                                         .firstVendorUrl,
                      // //                                                   ),
                      // //                                                 ),
                      // //                                                 options:
                      // //                                                     InAppBrowserClassOptions(
                      // //                                                   crossPlatform:
                      // //                                                       InAppBrowserOptions(
                      // //                                                     toolbarTopBackgroundColor:
                      // //                                                         Colors.blue,
                      // //                                                   ),
                      // //                                                 ),
                      // //                                               ),
                      // //                                               child:
                      // //                                                   Container(
                      // //                                                 width:
                      // //                                                     w * .42,
                      // //                                                 decoration:
                      // //                                                     BoxDecoration(
                      // //                                                   border:
                      // //                                                       Border
                      // //                                                           .all(
                      // //                                                     color: Colors
                      // //                                                         .blue,
                      // //                                                     width:
                      // //                                                         3,
                      // //                                                   ),
                      // //                                                   borderRadius:
                      // //                                                       BorderRadius
                      // //                                                           .circular(
                      // //                                                     3,
                      // //                                                   ),
                      // //                                                 ),
                      // //                                                 child:
                      // //                                                     Padding(
                      // //                                                   padding: const EdgeInsets
                      // //                                                       .symmetric(
                      // //                                                       vertical:
                      // //                                                           10.0),
                      // //                                                   child:
                      // //                                                       Row(
                      // //                                                     mainAxisAlignment:
                      // //                                                         MainAxisAlignment.center,
                      // //                                                     crossAxisAlignment:
                      // //                                                         CrossAxisAlignment.center,
                      // //                                                     children: [
                      // //                                                       Image
                      // //                                                           .asset(
                      // //                                                         'assets/images/world-wide-web.png',
                      // //                                                         color:
                      // //                                                             '#0678cb'.toColor(),
                      // //                                                         height:
                      // //                                                             20,
                      // //                                                         width:
                      // //                                                             20,
                      // //                                                         // weight: 10,
                      // //                                                       ),
                      // //                                                       horizontalSpace(
                      // //                                                           horizontalSpace: 15),
                      // //                                                       AutoSizeText(
                      // //                                                         'Visit'.toUpperCase(),
                      // //                                                         style:
                      // //                                                             TextStyle(
                      // //                                                           color: '#0678cb'.toColor(),
                      // //                                                           fontFamily: 'MyriadPro-BoldCond',
                      // //                                                           fontSize: w * .043,
                      // //                                                           wordSpacing: .1,
                      // //                                                           letterSpacing: 0,
                      // //                                                           fontWeight: FontWeight.bold,
                      // //                                                         ),
                      // //                                                       )
                      // //                                                     ],
                      // //                                                   ),
                      // //                                                 ),
                      // //                                               ),
                      // //                                             ),
                      // //                                           ),
                      // //                                           verticalSpace(
                      // //                                               verticalSpace:
                      // //                                                   15)
                      // //                                         ],
                      // //                                       ),
                      // //                                     ),
                      // //                                   ),
                      // //                                 ),
                      // //                               )*/
                      // //                         ,
                      // //                       ),
                      // //                     ),
                      // //                   ),
                      // //                   verticalSpace(verticalSpace: 15),
                      // //                   ElevatedButton(
                      // //                     style: ButtonStyle(
                      // //                       backgroundColor:
                      // //                           MaterialStateProperty
                      // //                               .resolveWith<Color>(
                      // //                         (Set<MaterialState> states) {
                      // //                           return '#d90310'.toColor();
                      // //                         },
                      // //                       ),
                      // //                       shape: MaterialStateProperty
                      // //                           .resolveWith<OutlinedBorder>(
                      // //                         (states) =>
                      // //                             RoundedRectangleBorder(
                      // //                           borderRadius:
                      // //                               BorderRadius.circular(
                      // //                             10,
                      // //                           ),
                      // //                         ),
                      // //                       ),
                      // //                     ),
                      // //                     onPressed: () {
                      // //                       setState(() {
                      // //                         _showMoreProduct =
                      // //                             !_showMoreProduct;
                      // //                       });
                      // //                     },
                      // //                     child: Padding(
                      // //                       padding: const EdgeInsets.symmetric(
                      // //                           horizontal: 8.0),
                      // //                       child: Text(
                      // //                         (_showMoreProduct == true
                      // //                                 ? 'Show Less'
                      // //                                 : 'Show More')
                      // //                             .toUpperCase(),
                      // //                         style: TextStyle(
                      // //                             color: Colors.white,
                      // //                             fontFamily:
                      // //                                 'Futura BdCn BT Bold',
                      // //                             wordSpacing: 1,
                      // //                             letterSpacing: 1,
                      // //                             fontSize: w * .045),
                      // //                       ),
                      // //                     ),
                      // //                   )
                      // //                 ],
                      // //               )
                      // //             : const SizedBox();
                      // //   },
                      // // ),
                      // // verticalSpace(verticalSpace: 10),
                      // // Container(
                      // //   color: '#fb8f95'.toColor(),
                      // //   // padding: const EdgeInsets.all(10),
                      // //   child: BlocBuilder<FeatureCategoryBloc,
                      // //       FeatureCategoryState>(
                      // //     builder: (context, state) {
                      // //       return state is FeatureCategoryLoaded
                      // //           ? Center(
                      // //               child: Column(
                      // //                 crossAxisAlignment:
                      // //                     CrossAxisAlignment.start,
                      // //                 children: [
                      // //                   Padding(
                      // //                     padding: const EdgeInsets.symmetric(
                      // //                         horizontal: 16.0, vertical: 5),
                      // //                     child: AutoSizeText(
                      // //                       'Feature Categories',
                      // //                       textAlign: TextAlign.start,
                      // //                       style: TextStyle(
                      // //                         fontSize: .06 * w,
                      // //                         fontFamily: 'Futura BdCn BT Bold',
                      // //                         fontWeight: FontWeight.w300,
                      // //                       ),
                      // //                     ),
                      // //                   ),
                      // //                   verticalSpace(verticalSpace: 10),
                      // //                   Padding(
                      // //                     padding: const EdgeInsets.symmetric(
                      // //                         horizontal: 8.0),
                      // //                     child: Align(
                      // //                       alignment: Alignment.topCenter,
                      // //                       child: Wrap(
                      // //                         spacing: 15,
                      // //                         runSpacing: 10,
                      // //                         children: List.generate(
                      // //                           state.data.length <= 6
                      // //                               ? state.data.length
                      // //                               : _showMoreCategory == true
                      // //                                   ? state.data.length
                      // //                                   : 6,
                      // //                           (index) => InkWell(
                      // //                             onTap: () {
                      // //                               Navigator.push(
                      // //                                 context,
                      // //                                 MaterialPageRoute(
                      // //                                   builder: (context) =>
                      // //                                       ProductListScreen(
                      // //                                     titleValue: state
                      // //                                         .data[index]
                      // //                                         .categoryName,
                      // //                                     categoryId: state
                      // //                                         .data[index]
                      // //                                         .categoryId
                      // //                                         .toString(),
                      // //                                     database:
                      // //                                         widget.database,
                      // //                                     dataList: const [],
                      // //                                     isBrands: false,
                      // //                                     isCategory: false,
                      // //                                     title: state
                      // //                                         .data[index]
                      // //                                         .categoryName,
                      // //                                   ),
                      // //                                 ),
                      // //                               ).whenComplete(() => context
                      // //                                   .read<
                      // //                                       ProductListByIdBloc>()
                      // //                                   .add(const ProductListByIdLoadingEvent(
                      // //                                       vendorId: '${AppInfo.kVendorId}',
                      // //                                       date: '2024-03-05',
                      // //                                       dataId: '14371',
                      // //                                       featuredProducts:
                      // //                                           false,
                      // //                                       fromSearchScreen:
                      // //                                           false,
                      // //                                       brandProductsEnabled:
                      // //                                           false,
                      // //                                       isCategory:
                      // //                                           false)));
                      // //                             },
                      // //                             child: Card(
                      // //                               child: Padding(
                      // //                                 padding:
                      // //                                     const EdgeInsets.all(
                      // //                                         4.0),
                      // //                                 child: Column(
                      // //                                   children: [
                      // //                                     Container(
                      // //                                       width: w * .41,
                      // //                                       height: w * .4,
                      // //                                       decoration:
                      // //                                           const BoxDecoration(
                      // //                                         image:
                      // //                                             DecorationImage(
                      // //                                           image:
                      // //                                               AssetImage(
                      // //                                             'assets/home_screen_assets/feature_category/image-1.jpg',
                      // //                                           ),
                      // //                                           fit:
                      // //                                               BoxFit.fill,
                      // //                                         ),
                      // //                                       ),
                      // //                                     ),
                      // //                                     verticalSpace(
                      // //                                         verticalSpace: 5),
                      // //                                     SizedBox(
                      // //                                       width: w * .41,
                      // //                                       child: RichText(
                      // //                                         maxLines: 1,
                      // //                                         overflow:
                      // //                                             TextOverflow
                      // //                                                 .ellipsis,
                      // //                                         textAlign:
                      // //                                             TextAlign
                      // //                                                 .center,
                      // //                                         text: TextSpan(
                      // //                                           text: state
                      // //                                               .data[index]
                      // //                                               .categoryName,
                      // //                                           style:
                      // //                                               TextStyle(
                      // //                                             fontSize:
                      // //                                                 .045 * w,
                      // //                                             fontFamily:
                      // //                                                 'Futura BdCn BT Bold',
                      // //                                             fontWeight:
                      // //                                                 FontWeight
                      // //                                                     .w300,
                      // //                                             color: Colors
                      // //                                                 .black,
                      // //                                           ),
                      // //                                           /*        children: [
                      // //                                         // TextSpan(
                      // //                                         //   text: '75% OFF',
                      // //                                         //   style: TextStyle(
                      // //                                         //     fontSize: .05 * w,
                      // //                                         //     fontFamily:
                      // //                                         //         'Futura BdCn BT Bold',
                      // //                                         //     fontWeight: FontWeight.w300,
                      // //                                         //     color: Colors.green,
                      // //                                         //   ),
                      // //                                         // ),
                      // //                                       ],*/
                      // //                                         ),
                      // //                                       ),
                      // //                                     ),
                      // //                                     verticalSpace(
                      // //                                         verticalSpace: 15)
                      // //                                   ],
                      // //                                 ),
                      // //                               ),
                      // //                             ),
                      // //                           ),
                      // //                         ),
                      // //                       ),
                      // //                     ),
                      // //                   ),
                      // //                   verticalSpace(verticalSpace: 20),
                      // //                   state.data.length > 4
                      // //                       ? Center(
                      // //                           child: ElevatedButton(
                      // //                             style: ButtonStyle(
                      // //                               backgroundColor:
                      // //                                   MaterialStateProperty
                      // //                                       .resolveWith<Color>(
                      // //                                 (Set<MaterialState>
                      // //                                     states) {
                      // //                                   return '#d90310'
                      // //                                       .toColor();
                      // //                                 },
                      // //                               ),
                      // //                               shape: MaterialStateProperty
                      // //                                   .resolveWith<
                      // //                                       OutlinedBorder>(
                      // //                                 (states) =>
                      // //                                     RoundedRectangleBorder(
                      // //                                   borderRadius:
                      // //                                       BorderRadius
                      // //                                           .circular(
                      // //                                     10,
                      // //                                   ),
                      // //                                 ),
                      // //                               ),
                      // //                             ),
                      // //                             onPressed: () {
                      // //                               setState(() {
                      // //                                 _showMoreCategory =
                      // //                                     !_showMoreCategory;
                      // //                               });
                      // //                             },
                      // //                             child: Padding(
                      // //                               padding: const EdgeInsets
                      // //                                   .symmetric(
                      // //                                   horizontal: 8.0),
                      // //                               child: Text(
                      // //                                 (_showMoreCategory ==
                      // //                                             false
                      // //                                         ? 'Show More'
                      // //                                         : 'Show Less')
                      // //                                     .toUpperCase(),
                      // //                                 style: TextStyle(
                      // //                                     color: Colors.white,
                      // //                                     fontFamily:
                      // //                                         'Futura BdCn BT Bold',
                      // //                                     wordSpacing: 1,
                      // //                                     letterSpacing: 1,
                      // //                                     fontSize: w * .045),
                      // //                               ),
                      // //                             ),
                      // //                           ),
                      // //                         )
                      // //                       : const SizedBox.shrink(),
                      // //                   state.data.length > 4
                      // //                       ? verticalSpace(verticalSpace: 20)
                      // //                       : const SizedBox.shrink()
                      // //                 ],
                      // //               ),
                      // //             )
                      // //           : const Center(
                      // //               child: Padding(
                      // //                 padding: EdgeInsets.all(50.0),
                      // //                 child: CustomLoader(),
                      // //               ),
                      // //             );
                      // //     },
                      // //   ),
                      // // ),
                      // // SizedBox(
                      // //   height: .08 * h,
                      // // )
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

// try {
//   final response = await http.get(
//     Uri.parse(
//         'https://growth.matridtech.net/api/shopping-mega-mart-brand-api-data'),
//   );
//   if (response.statusCode == 200) {
//     final List<dynamic> jsonData = json.decode(response.body);
//     final brandsResponse = BrandsResponse.fromJson(jsonData);
//     return brandsResponse.toJson();
//   } else {
//     throw Exception('Failed to load brands: ${response.statusCode}');
//   }
// } catch (e) {
//   throw Exception('Error fetching brands: $e');
// }

  Future<List<Map<String, dynamic>>> fetchBrands() async {
    try {
      log('method running');
      final response = await http
          .get(
            Uri.parse(
                'https://growth.matridtech.net/api/shopping-mega-mart-brand-api-data'),
          )
          .timeout(const Duration(seconds: 30));
      log('Brand API: https://growth.matridtech.net/api/shopping-mega-mart-brand-api-data');

      if (response.statusCode == 200) {
        log('status code \\${response.statusCode}');
        final List<dynamic> jsonData = json.decode(response.body);
        return jsonData.cast<Map<String, dynamic>>();
      } else {
        log('Error Brand API: \\${response.statusCode}');
        throw Exception('Failed to load brands: \\${response.statusCode}');
      }
    } catch (e) {
      log("Exception In Brand API: \\${e.toString()}");
      throw Exception('Error fetching brands: $e');
    }
  }

  Widget _allBrandsScreen() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: FutureBuilder<List<Map<String, dynamic>>>(
          future: _brandsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(
                  child: Text('Failed to load brands: ${snapshot.error}'));
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(child: Text('No brands available.'));
            }
            final allBrands = snapshot.data!;
            final initialBrands = allBrands.take(10).toList();
            final hasMoreBrands = allBrands.length > 10;

            return Column(
              // mainAxisSize: MainAxisSize.min,
              // crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 5,
                    crossAxisSpacing: 5,
                    childAspectRatio: 1,
                  ),
                  itemCount: initialBrands.length,
                  itemBuilder: (context, index) {
                    final brand = initialBrands[index];
                    return GestureDetector(
                      onTap: () {
                        log('Brand object: $brand');
                        log('brandID ${brand['brand_id']}');
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => BrandProductListScreen(
                              brandId: brand['brand_id'],
                              brandName: brand['brand_name'],
                              database: widget.database,
                              dataList: const [],
                            ),
                          ),
                        );
                      },
                      child: Card(
                        elevation: 0.5,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                          side: const BorderSide(color: Colors.black),
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Flexible(
                              flex: 1,
                              child: Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 5.0),
                                child: SizedBox(
                                  width: double.infinity,
                                  height: 115,
                                  child: CachedNetworkImage(
                                    imageUrl: brand['brand_logo'],
                                    fit: BoxFit.contain,
                                    placeholder: (context, url) => const Center(
                                        child: CircularProgressIndicator()),
                                    errorWidget: (context, url, error) =>
                                        Image.asset(
                                      'assets/images/no_image.png',
                                      fit: BoxFit.contain,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(
                                  top: 10.0, left: 8.0, right: 8.0),
                              child: Text(
                                brand['brand_name'].toString().trim(),
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20,
                                  fontFamily: 'Segoe UI',
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(
                                  bottom: 4.0, left: 8.0, right: 8.0, top: 4.0),
                              child: Text(
                                'Products: ${brand['product_count']}',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Colors.grey[700],
                                  fontSize: 18,
                                  fontFamily: 'Segoe UI',
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
                if (hasMoreBrands)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 20.0, top: 0),
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => AllBrandsScreen(
                              brands: allBrands,
                              database: widget.database,
                            ),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromARGB(255, 237, 63, 69),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 32, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'See More Brands',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _shopByGrills() {
    final List<Map<String, String>> gridData = [
      {
        'title': 'Large Grills',
        'image': 'assets/shop_by_grills/large_grills.jpg'
      },
      {
        'title': 'Medium Grills',
        'image': 'assets/shop_by_grills/medium_grills2.jpg'
      },
      {
        'title': 'Small Grills',
        'image': 'assets/shop_by_grills/small_grills.jpg'
      },
      {
        'title': 'Large Size Grills',
        'image': 'assets/shop_by_grills/large_size_grills.jpg'
      },
      {
        'title': 'Medium Size Grills',
        'image': 'assets/shop_by_grills/medium_size_grills.jpg'
      },
      {'title': '49+ inches', 'image': 'assets/shop_by_grills/49+ inches.jpg'},
      {
        'title': 'Small Size Grills',
        'image': 'assets/shop_by_grills/small_size_grills.jpg'
      },
      {
        'title': 'x-Large Size Grills',
        'image': 'assets/shop_by_grills/x-large_size_grills.jpg'
      },
      {
        'title': 'x-Large Grills',
        'image': 'assets/shop_by_grills/x-large_grills.jpg',
      },
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 5,
          crossAxisSpacing: 5,
          childAspectRatio: 1.0,
        ),
        itemCount: gridData.length,
        itemBuilder: (context, index) {
          final item = gridData[index];
          return Column(
            children: [
              Expanded(
                child: Card(
                  elevation: 0.5,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Image.asset(
                    item['image']!,
                    fit: BoxFit.contain,
                    width: w * .5,
                    height: w * .5,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 8.0, bottom: 4.0),
                child: Text(
                  item['title']!,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: w * .035,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget grillsOutdoor() {
    final List<Map<String, String>> gridData = [
      {
        'title': 'Outdoor Pizza Ovens',
        'image': 'assets/grills_outdoor_cooking/outdoor_pizza_ovens.jpg'
      },
      {
        'title': 'Gas Grills',
        'image': 'assets/grills_outdoor_cooking/gas_grills.jpg'
      },
      {
        'title': 'Charcoal Grills',
        'image': 'assets/grills_outdoor_cooking/charcoal_grills.jpg'
      },
      {
        'title': 'Flat Top Griddles',
        'image': 'assets/grills_outdoor_cooking/flat_top_graddles.jpg'
      },
      {
        'title': 'Pellet Grills',
        'image': 'assets/grills_outdoor_cooking/pellet_grills.jpg'
      },
      {
        'title': 'Electric Grills',
        'image': 'assets/grills_outdoor_cooking/electric_grills.jpg'
      },
      {
        'title': 'Kamado Grills',
        'image': 'assets/grills_outdoor_cooking/kamado_grills.jpg'
      },
      {
        'title': 'Beyond the Backyard',
        'image': 'assets/grills_outdoor_cooking/bayond.jpg'
      },
      {
        'title': 'Santa Maria Gaucho Grills',
        'image': 'assets/grills_outdoor_cooking/santa_maria.jpg',
      },
      {
        'title': 'BBQ Smokers',
        'image': 'assets/grills_outdoor_cooking/bbq_smoker.jpg'
      },
      {
        'title': 'Outdoor Fryers & Stoves',
        'image': 'assets/grills_outdoor_cooking/outdoor_Gas Fryer.jpg'
      },
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 5,
          crossAxisSpacing: 5,
          childAspectRatio: 1.0,
        ),
        itemCount: gridData.length,
        itemBuilder: (context, index) {
          final item = gridData[index];
          return Column(
            children: [
              Expanded(
                child: Card(
                  elevation: 0.5,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Image.asset(
                    item['image']!,
                    fit: BoxFit.contain,
                    width: w * .5,
                    height: w * .5,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 8.0, bottom: 4.0),
                child: Text(
                  item['title']!,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: w * .035,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _mainContentBigImages() {
    return SizedBox(
      height: h * .28,
      child: FutureBuilder(
        future: _mainContentBigImagesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: const CustomLoader(width: 50, height: 50));
          } else if (snapshot.hasError) {
            return const SizedBox();
          } else {
            return Column(
              children: List.generate(
                  snapshot.data!.length,
                  (index) => Column(
                        children: [
                          Stack(
                            children: [
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 5),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(10.0),
                                  child: Image.network(
                                    snapshot.data![index]['image_link'],
                                    fit: BoxFit.fitWidth,
                                  ),
                                ),
                              ),
                              Column(
                                children: [
                                  const SizedBox(height: 10),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        snapshot.data![index]['large_text'],
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 1,
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontFamily: 'Futura BdCn BT Bold',
                                          wordSpacing: 1,
                                          letterSpacing: 1,
                                          fontSize: w * .07,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        snapshot.data![index]['small_text'],
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 1,
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontFamily: 'Futura BdCn BT Bold',
                                          wordSpacing: 1,
                                          letterSpacing: 1,
                                          fontSize: w * .045,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      ElevatedButton(
                                        onPressed: () {},
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: AppColors.primary,
                                        ),
                                        child: Center(
                                          child: Text(
                                            snapshot.data![index]
                                                ['button_name'],
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontFamily: 'Futura BdCn BT Bold',
                                              wordSpacing: 1,
                                              letterSpacing: 1,
                                              fontSize: w * .045,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  )
                                ],
                              )
                            ],
                          ),
                          const SizedBox(height: 10),
                        ],
                      )),
            );
          }
        },
      ),
    );
  }

  Widget _mainContentSmallImages() {
    return SizedBox(
      height: h * .28,
      child: FutureBuilder(
        future: _mainContentSmallImagesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: const CustomLoader(width: 50, height: 50));
          } else if (snapshot.hasError) {
            return const SizedBox();
          } else {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 5),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      children: List.generate(
                        snapshot.data!.length,
                        // Up to half the length for left column
                        (index) => index < (snapshot.data!.length / 2)
                            ? GestureDetector(
                                onTap: () {
                                  log('index1 - $index');
                                },
                                child: SizedBox(
                                  width:
                                      double.infinity, // Fill available width
                                  child: Column(
                                    children: [
                                      ClipRRect(
                                        borderRadius:
                                            BorderRadius.circular(10.0),
                                        child: Image.network(
                                          snapshot.data![index]['image_link'],
                                          fit: BoxFit.cover, // Adjust as needed
                                        ),
                                      ),
                                      const SizedBox(height: 10),
                                    ],
                                  ),
                                ),
                              )
                            : Container(), // Placeholder for unused space
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      children: List.generate(
                        snapshot.data!.length,
                        // Up to half the length for right column
                        (index) => index >= (snapshot.data!.length / 2)
                            ? GestureDetector(
                                onTap: () {
                                  log('index2 - $index');
                                },
                                child: SizedBox(
                                  width:
                                      double.infinity, // Fill available width
                                  child: Column(
                                    children: [
                                      ClipRRect(
                                        borderRadius:
                                            BorderRadius.circular(10.0),
                                        child: Image.network(
                                          snapshot.data![index]['image_link'],
                                          fit: BoxFit.cover, // Adjust as needed
                                        ),
                                      ),
                                      const SizedBox(height: 10),
                                    ],
                                  ),
                                ),
                              )
                            : Container(),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }
        },
      ),
    );
  }

  Widget _grillsMenu() {
    return FutureBuilder(
      future: getGrillsMenu(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CustomLoader();
        } else if (snapshot.hasError) {
          return const SizedBox();
        } else {
          return SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: List.generate(
                    snapshot.data!.length,
                    (index) => Column(
                          children: [
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 8.0),
                              child: Card(
                                elevation: .5,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                clipBehavior: Clip.antiAlias,
                                child: Image.network(
                                  snapshot.data![index]['image_link'],
                                  height: h * .2,
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(top: 5),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    snapshot.data![index]['text'],
                                    maxLines: 2,
                                    overflow: TextOverflow.visible,
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontFamily: 'Futura BdCn BT Bold',
                                      wordSpacing: 1,
                                      letterSpacing: 1,
                                      fontSize: w * .035,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        )),
              ));
        }
      },
    );
  }

  Widget _newProductsTitleRow() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Column(
        children: [
          Container(
            height: 45,
            width: w,
            decoration: BoxDecoration(
              border: Border(top: BorderSide(color: AppColors.primary, width: 2)),
              color: Colors.white,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  color: AppColors.primary,
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        'NEW PRODUCTS',
                        style: TextStyle(
                          color: Colors.white,
                          fontFamily: 'Futura BdCn BT Bold',
                          wordSpacing: 1,
                          letterSpacing: 1,
                          fontSize: w * .04,
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      CustomDropdown2(
                        width: w * .45,
                        selectedValue: selProductsDropDCatList,
                        itemsList: newProductsDropDownCategoryList,
                        onChanged: (value) {
                          setState(() => selProductsDropDCatList = value!);
                        },
                      )
                    ],
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }

  // Widget _newProductsRow() {
  //   return Padding(
  //       padding: const EdgeInsets.symmetric(horizontal: 8.0),
  //       child: SingleChildScrollView(
  //         scrollDirection: Axis.horizontal,
  //         child: Row(
  //           children: List.generate(
  //               newProducts.length,
  //               (index) => Padding(
  //                     padding: index != newProducts.length
  //                         ? const EdgeInsets.only(right: 15)
  //                         : EdgeInsets.zero,
  //                     child: Container(
  //                       width: w * .44,
  //                       decoration: BoxDecoration(
  //                         border:
  //                             Border.all(color: Colors.grey.shade300, width: 1),
  //                         color: Colors.white,
  //                       ),
  //                       child: Column(
  //                         crossAxisAlignment: CrossAxisAlignment.start,
  //                         children: [
  //                           Stack(
  //                             children: [
  //                               Image.network(newProducts[index].image),
  //                               Positioned(
  //                                 top: 0,
  //                                 right: 0,
  //                                 child: PopupMenuButton<IconData>(
  //                                   offset: const Offset(0, 40),
  //                                   padding: EdgeInsets.zero,
  //                                   initialValue: selectedIcon,
  //                                   onSelected: (value) {
  //                                     setState(() => selectedIcon = value);
  //                                   },
  //                                   itemBuilder: (BuildContext context) =>
  //                                       List.generate(
  //                                           4,
  //                                           (index) => PopupMenuItem<IconData>(
  //                                                 value: iconsList[index],
  //                                                 padding: EdgeInsets.zero,
  //                                                 child: Center(
  //                                                     child: Icon(
  //                                                         iconsList[index])),
  //                                               )),
  //                                   constraints:
  //                                       const BoxConstraints(maxWidth: 48),
  //                                 ),
  //                               )
  //                             ],
  //                           ),
  //                           verticalSpace(verticalSpace: 2),
  //                           Padding(
  //                             padding:
  //                                 const EdgeInsets.symmetric(horizontal: 8.0),
  //                             child: Row(
  //                               mainAxisAlignment: MainAxisAlignment.start,
  //                               children: [
  //                                 Text(
  //                                   'From: ${newProducts[index].from}',
  //                                   style: TextStyle(
  //                                     color: Colors.black,
  //                                     fontFamily: 'Segoe UI',
  //                                     fontSize: w * .03,
  //                                     fontWeight: FontWeight.w500,
  //                                   ),
  //                                 ),
  //                               ],
  //                             ),
  //                           ),
  //                           verticalSpace(verticalSpace: 2),
  //                           Padding(
  //                             padding:
  //                                 const EdgeInsets.symmetric(horizontal: 8.0),
  //                             child: Row(
  //                               mainAxisAlignment: MainAxisAlignment.start,
  //                               children: [
  //                                 Flexible(
  //                                   child: Text(
  //                                     newProducts[index].prodTitle,
  //                                     style: TextStyle(
  //                                       color: Colors.black,
  //                                       fontFamily: 'Futura BdCn BT Bold',
  //                                       wordSpacing: 1,
  //                                       letterSpacing: 1,
  //                                       fontSize: w * .04,
  //                                     ),
  //                                     maxLines: 3,
  //                                     overflow: TextOverflow.ellipsis,
  //                                   ),
  //                                 )
  //                               ],
  //                             ),
  //                           ),
  //                           verticalSpace(verticalSpace: 5),
  //                           const Padding(
  //                             padding: EdgeInsets.symmetric(horizontal: 8.0),
  //                             child: Divider(),
  //                           ),
  //                           verticalSpace(verticalSpace: 5),
  //                           Row(
  //                             mainAxisAlignment: MainAxisAlignment.start,
  //                             crossAxisAlignment: CrossAxisAlignment.end,
  //                             children: [
  //                               Column(
  //                                 crossAxisAlignment: CrossAxisAlignment.start,
  //                                 children: [
  //                                   Padding(
  //                                     padding: const EdgeInsets.symmetric(
  //                                         horizontal: 8.0),
  //                                     child: Row(
  //                                       mainAxisAlignment:
  //                                           MainAxisAlignment.start,
  //                                       children: [
  //                                         Text(
  //                                           newProducts[index].actualPrice,
  //                                           style: TextStyle(
  //                                             decoration:
  //                                                 TextDecoration.lineThrough,
  //                                             decorationColor: Colors.grey,
  //                                             color: Colors.grey,
  //                                             fontFamily: 'Futura BdCn BT Bold',
  //                                             wordSpacing: 1,
  //                                             letterSpacing: 1,
  //                                             fontSize: w * .04,
  //                                           ),
  //                                         )
  //                                       ],
  //                                     ),
  //                                   ),
  //                                   verticalSpace(verticalSpace: 2),
  //                                   Padding(
  //                                     padding: const EdgeInsets.symmetric(
  //                                         horizontal: 8.0),
  //                                     child: Row(
  //                                       mainAxisAlignment:
  //                                           MainAxisAlignment.start,
  //                                       children: [
  //                                         Text(
  //                                           newProducts[index].discountedPrice,
  //                                           style: TextStyle(
  //                                             color: primary,
  //                                             fontFamily: 'Futura BdCn BT Bold',
  //                                             wordSpacing: 1,
  //                                             letterSpacing: 1,
  //                                             fontSize: w * .07,
  //                                           ),
  //                                         )
  //                                       ],
  //                                     ),
  //                                   ),
  //                                 ],
  //                               ),
  //                               Expanded(
  //                                 child: Row(
  //                                   mainAxisAlignment: MainAxisAlignment.end,
  //                                   crossAxisAlignment: CrossAxisAlignment.end,
  //                                   children: [
  //                                     Padding(
  //                                       padding: const EdgeInsets.only(
  //                                           bottom: 5, right: 5),
  //                                       child: Container(
  //                                         decoration: BoxDecoration(
  //                                           color: primary,
  //                                           borderRadius:
  //                                               BorderRadius.circular(5),
  //                                         ),
  //                                         child: Column(
  //                                           mainAxisAlignment:
  //                                               MainAxisAlignment.end,
  //                                           children: [
  //                                             Padding(
  //                                               padding:
  //                                                   const EdgeInsets.symmetric(
  //                                                       horizontal: 5),
  //                                               child: Row(
  //                                                 mainAxisAlignment:
  //                                                     MainAxisAlignment.start,
  //                                                 children: [
  //                                                   Text(
  //                                                     '${newProducts[index].discountPercentage}%',
  //                                                     style: TextStyle(
  //                                                       color: Colors.white,
  //                                                       fontFamily:
  //                                                           'Futura BdCn BT Bold',
  //                                                       wordSpacing: 1,
  //                                                       letterSpacing: 1,
  //                                                       fontSize: w * .04,
  //                                                     ),
  //                                                   )
  //                                                 ],
  //                                               ),
  //                                             ),
  //                                             verticalSpace(verticalSpace: 2),
  //                                             Padding(
  //                                               padding:
  //                                                   const EdgeInsets.symmetric(
  //                                                       horizontal: 5),
  //                                               child: Row(
  //                                                 mainAxisAlignment:
  //                                                     MainAxisAlignment.start,
  //                                                 children: [
  //                                                   Text(
  //                                                     'OFF',
  //                                                     style: TextStyle(
  //                                                       color: Colors.white,
  //                                                       fontFamily:
  //                                                           'Futura BdCn BT Bold',
  //                                                       wordSpacing: 1,
  //                                                       letterSpacing: 1,
  //                                                       fontSize: w * .04,
  //                                                     ),
  //                                                   )
  //                                                 ],
  //                                               ),
  //                                             ),
  //                                           ],
  //                                         ),
  //                                       ),
  //                                     )
  //                                   ],
  //                                 ),
  //                               )
  //                             ],
  //                           ),
  //                         ],
  //                       ),
  //                     ),
  //                   )),
  //         ),
  //       ));
  // }

  Widget _specialOfferProductsTitleRow() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Column(
        children: [
          Container(
            height: 45,
            width: w,
            decoration: BoxDecoration(
              border: Border(top: BorderSide(color: AppColors.primary, width: 2)),
              color: Colors.white,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  color: AppColors.primary,
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        'SPECIAL OFFER IN THIS WEEK',
                        style: TextStyle(
                          color: Colors.white,
                          fontFamily: 'Futura BdCn BT Bold',
                          wordSpacing: 1,
                          letterSpacing: 1,
                          fontSize: w * .04,
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      CustomDropdown2(
                        width: w * .4,
                        selectedValue: selSpecOfferProductsDropDCatList,
                        itemsList: specOfferProductsDropDownCategoryList,
                        onChanged: (value) {
                          setState(
                              () => selSpecOfferProductsDropDCatList = value!);
                        },
                      )
                    ],
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _specialOfferProductsRow() {
    return SizedBox(
      height: h * .4,
      child: CarouselSlider(
        enableAutoSlider: true,
        unlimitedMode: true,
        autoSliderTransitionTime: const Duration(seconds: 2),
        viewportFraction: .44,
        autoSliderDelay: const Duration(seconds: 4),
        children: List.generate(
            specOfferProducts.length,
            (index) => Padding(
                  padding: index != specOfferProducts.length
                      ? const EdgeInsets.only(right: 15)
                      : EdgeInsets.zero,
                  child: Container(
                    width: w * .44,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300, width: 1),
                      color: Colors.white,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Stack(
                          children: [
                            Image.network(specOfferProducts[index].image),
                            Positioned(
                              top: 0,
                              right: 0,
                              child: PopupMenuButton<IconData>(
                                offset: const Offset(0, 40),
                                padding: EdgeInsets.zero,
                                initialValue: selectedIcon,
                                onSelected: (value) {
                                  setState(() => selectedIcon = value);
                                },
                                itemBuilder: (BuildContext context) =>
                                    List.generate(
                                        4,
                                        (index) => PopupMenuItem<IconData>(
                                              value: iconsList[index],
                                              padding: EdgeInsets.zero,
                                              child: Center(
                                                  child:
                                                      Icon(iconsList[index])),
                                            )),
                                constraints: const BoxConstraints(maxWidth: 48),
                              ),
                            )
                          ],
                        ),
                        verticalSpace(verticalSpace: 2),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Text(
                                'From: ${specOfferProducts[index].from}',
                                style: TextStyle(
                                  color: Colors.black,
                                  fontFamily: 'Segoe UI',
                                  fontSize: w * .03,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                        verticalSpace(verticalSpace: 2),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Flexible(
                                child: Text(
                                  specOfferProducts[index].prodTitle,
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontFamily: 'Futura BdCn BT Bold',
                                    wordSpacing: 1,
                                    letterSpacing: 1,
                                    fontSize: w * .04,
                                  ),
                                  maxLines: 3,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              )
                            ],
                          ),
                        ),
                        verticalSpace(verticalSpace: 5),
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 8.0),
                          child: Divider(),
                        ),
                        verticalSpace(verticalSpace: 5),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                /*Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Text(
                                      specOfferProducts[index].actualPrice,
                                      style: TextStyle(
                                        decoration: TextDecoration.lineThrough,
                                        decorationColor: Colors.grey,
                                        color: Colors.grey,
                                        fontFamily: 'Futura BdCn BT Bold',
                                        wordSpacing: 1,
                                        letterSpacing: 1,
                                        fontSize: w * .04,
                                      ),
                                    )
                                  ],
                                ),
                              ),
                              verticalSpace(verticalSpace: 2),*/
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8.0),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Text(
                                        specOfferProducts[index]
                                            .discountedPrice,
                                        style: TextStyle(
                                          color: AppColors.primary,
                                          fontFamily: 'Futura BdCn BT Bold',
                                          wordSpacing: 1,
                                          letterSpacing: 1,
                                          fontSize: w * .07,
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            /*Expanded(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 5, right: 5),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: primary,
                                      borderRadius: BorderRadius.circular(5),
                                    ),
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.symmetric(horizontal: 5),
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.start,
                                            children: [
                                              Text(
                                                '${specOfferProducts[index].discountPercentage}%',
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontFamily: 'Futura BdCn BT Bold',
                                                  wordSpacing: 1,
                                                  letterSpacing: 1,
                                                  fontSize: w * .04,
                                                ),
                                              )
                                            ],
                                          ),
                                        ),
                                        verticalSpace(verticalSpace: 2),
                                        Padding(
                                          padding: const EdgeInsets.symmetric(horizontal: 5),
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.start,
                                            children: [
                                              Text(
                                                'OFF',
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontFamily: 'Futura BdCn BT Bold',
                                                  wordSpacing: 1,
                                                  letterSpacing: 1,
                                                  fontSize: w * .04,
                                                ),
                                              )
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                )
                              ],
                            ),
                          )*/
                          ],
                        ),
                      ],
                    ),
                  ),
                )),
      ),
    );
  }

  Widget _shopByBrandTitleRow() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 5),
      child: AutoSizeText(
        'Shop By Brands',
        textAlign: TextAlign.start,
        style: TextStyle(
          fontSize: .06 * w,
          fontFamily: 'Futura BdCn BT Bold',
          fontWeight: FontWeight.w300,
        ),
      ),
    );
  }

  Future<Map<String, dynamic>> getDataFromRemoteConfig() async {
    final data = await remoteConfig.getString('msp_app_config');

    return jsonDecode(data);
  }

  Future<List<Map<String, dynamic>>> getBanners() async {
    final data = await getDataFromRemoteConfig();
    List<Map<String, dynamic>> list =
        List.from((data['banners'] as List<dynamic>).map((e) => e));
    return list;
  }

  Future<List<Map<String, dynamic>>> getMainContentBigImages() async {
    final data = await getDataFromRemoteConfig();
    List<Map<String, dynamic>> list = List.from(
        (data['main_content_big_images'] as List<dynamic>).map((e) => e));
    list.sort((a, b) => a['id'].compareTo(b['id']));
    return list;
  }

  Future<List<Map<String, dynamic>>> getMainContentSmallImages() async {
    final data = await getDataFromRemoteConfig();
    List<Map<String, dynamic>> list = List.from(
        (data['main_content_small_images'] as List<dynamic>).map((e) => e));
    list.sort((a, b) => a['id'].compareTo(b['id']));
    return list;
  }

  Future<List<Map<String, dynamic>>> getGrillsMenu() async {
    final data = await getDataFromRemoteConfig();
    List<Map<String, dynamic>> list =
        List.from((data['grills_menu'] as List<dynamic>).map((e) => e));
    list.sort((a, b) => int.parse(a['id']).compareTo(int.parse(b['id'])));
    return list;
  }

  @override
  void detach() {
    // TODO: implement detach
  }

  @override
  // TODO: implement keptAlive
  bool get keptAlive => true;

/*
  Widget _item({required Map<String, String> data}) {
    return Card(
      surfaceTintColor: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(2.0),
        child: Container(
          width: w * .3,
          height: w * .4,
          decoration: BoxDecoration(
              color: Colors.white, borderRadius: BorderRadius.circular(10)),
          child: Column(
            children: [
              CachedNetworkImage(
                imageUrl: data['image']!,
                height: w * .3,
              ),
              Container(
                width: w * .29,
                height: .1 * w,
                color: Colors.white,
                child: Center(
                  child: AutoSizeText(
                    data['title']!,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: '#535252'.toColor(),
                      fontFamily: 'MyriadPro-Regular',
                      fontSize: w * .035,
                      wordSpacing: .1,
                      letterSpacing: 0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    ).animate().fade().scale();
  }*/
}

class ProductsDataForTesting {
  final String image;
  final String from;
  final String prodTitle;
  final String actualPrice;
  final String discountedPrice;
  final String discountPercentage;

  ProductsDataForTesting({
    required this.image,
    required this.from,
    required this.prodTitle,
    required this.discountPercentage,
    required this.actualPrice,
    required this.discountedPrice,
  });
}

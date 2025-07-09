// ignore_for_file: library_private_types_in_public_api, must_be_immutable

import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart' as http;
import 'package:auto_size_text/auto_size_text.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_carousel_slider/carousel_slider.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:minsellprice/screens/tushar_screen/account_screen/account_screen.dart';
import 'package:salomon_bottom_bar/salomon_bottom_bar.dart';
import 'package:minsellprice/app.dart';
import 'package:minsellprice/screens/product_list_screen/brand_product_list_screen.dart';
import 'package:minsellprice/utils/common_methods.dart';
import 'package:sqflite/sqflite.dart';
import 'colors.dart';
import 'model/vendor_dashboard_model.dart';
import 'reposotory_services/database/database_functions.dart';
import 'screens/liked_product_screen.dart';
import 'screens/search_screen/search_screen.dart';
import 'screens/widgets/inheriated_widget.dart';
import 'screens/widgets/price_proposition_chart.dart';
import 'services/extra_functions.dart';
import 'size.dart';
import 'package:minsellprice/screens/all_brands_screen.dart';

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
        child: FutureBuilder<Database>(
          future: DatabaseHelper().initDatabase(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else if (snapshot.hasData) {
              database = snapshot.data!;
              _screens = [
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
                AccountScreen(
                  database: database,
                  vendorId: vendorId,
                )
              ];
              return GestureDetector(
                onTap: () {
                  FocusScopeNode currentFocus = FocusScope.of(context);
                  currentFocus.unfocus();
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
                      appBar: AppBar(
                        surfaceTintColor: Colors.white,
                        toolbarHeight: .18 * w,
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
                        shape: Border.all(color: AppColors.primary, width: 0),
                      ),
                      bottomNavigationBar: MediaQuery.of(context)
                                  .viewInsets
                                  .bottom !=
                              0.0
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

                                // /// Search
                                // SalomonBottomBarItem(
                                //   icon: const Icon(Icons.search),
                                //   title: const Text("Search"),
                                //   selectedColor: AppColors.primary,
                                // ),

                                /// account
                                SalomonBottomBarItem(
                                  icon:
                                      const Icon(Icons.account_circle_rounded),
                                  title: const Text("Account"),
                                  selectedColor: AppColors.primary,
                                ),
                              ],
                            ),
                      body: _screens[_activeIndex],
                    ),
                  ),
                ),
              );
            } else {
              Fluttertoast.showToast(msg: 'Database not init');
              return const Center(child: Text('Database not initialized'));
            }
          },
        ),
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
                          const SizedBox(height: 10),
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
                      const SizedBox(width: 20)
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
                      // Navigator.push(
                      //   context,
                      //   MaterialPageRoute(
                      //     builder: (context) => ContentScreen(
                      //       loadingString: 'Very Low 15%',
                      //       isVendorTable: false,
                      //       brandKey: list[index]['brandName'],
                      //       vendorName: 'Lowest by 15%',
                      //       vendorImage:
                      //           'http://growth.matridtech.net/${list[index]['Image']}',
                      //       vendorId: vendorId.toString(),
                      //       id: list[index]['id_lower more than 15%']
                      //           .toString(),
                      //       date: dateFormat
                      //           .format(
                      //             DateTime.now().subtract(
                      //               const Duration(days: 1),
                      //             ),
                      //           )
                      //           .replaceAll('/', '-'),
                      //       isVendorPriceAnalysis: false,
                      //       loadingData:
                      //           list[index]['brandName'] + ' Very Low 15%',
                      //       database: database,
                      //     ),
                      //   ),
                      // );

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
                    onTap: () {},
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
                    onTap: () {},
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
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 4.0, vertical: 4),
                  child: GestureDetector(
                    onTap: () {},
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
                    onTap: () {},
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
                    onTap: () {},
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
  final _searchController = TextEditingController();

  final _scrollController = ScrollController();
  late Future<Map<String, List<dynamic>>> _brandsFuture;
  late Future<List<Map<String, dynamic>>> _bannersFuture;
  late List<Map<String, dynamic>> _homeGardenBrands = [];
  late List<Map<String, dynamic>> _shoesApparels = [];
  late List<Map<String, dynamic>> _allBrands = [];

  List<List<dynamic>> makeFourElementsRow({required List<dynamic> list}) {
    List<List<dynamic>> result = [];
    for (int i = 0; i < list.length; i += 4) {
      int end = (i + 4 < list.length) ? i + 4 : list.length;
      result.add(list.sublist(i, end));
    }
    return result;
  }

  @override
  void initState() {
    super.initState();
    setupRemoteConfig();
    _bannersFuture = getBanners();
    _mainContentBigImagesFuture = getMainContentBigImages();
    _mainContentSmallImagesFuture = getMainContentSmallImages();
    _initCall();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _initCall() async {
    _brandsFuture = fetchBrands();
    final brandsData = await _brandsFuture;

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

  void _searchBrand(String value) async {
    if (_allBrands.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'No Brand',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          backgroundColor: Colors.orange,
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BrandSearchScreen(
          brands: _allBrands,
          database: widget.database,
          initialSearchQuery: value.trim(),
        ),
      ),
    );
  }

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
                        if (value.trim().isNotEmpty) {
                          _searchBrand(value);
                        }
                      },
                      cursorColor: AppColors.primary,
                      decoration: InputDecoration(
                        hintText: 'Search brands by name...',
                        suffixIcon: ValueListenableBuilder<TextEditingValue>(
                          valueListenable: _searchController,
                          builder: (context, value, child) {
                            return InkWell(
                              splashColor: AppColors.primary.withOpacity(.3),
                              onTap: () {
                                if (_searchController.text.isNotEmpty) {
                                  if (value.text.trim().isNotEmpty) {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => BrandSearchScreen(
                                          brands: _allBrands,
                                          database: widget.database,
                                          initialSearchQuery: value.text.trim(),
                                        ),
                                      ),
                                    );
                                  } else {
                                    _searchController.clear();
                                  }
                                } else {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => BrandSearchScreen(
                                        brands: _allBrands,
                                        database: widget.database,
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
                            );
                          },
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
                    // shrinkWrap: true,
                    children: [
                      SizedBox(
                        height: h * .22,
                        child: FutureBuilder<List<Map<String, dynamic>>>(
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return Center(child: CircularProgressIndicator());
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
                      const SizedBox(height: 15),
                      _mainContentBigImages(),
                      _mainContentSmallImages(),
                      const SizedBox(height: 15),
                      const SizedBox(height: 5),
                      Padding(
                        padding: const EdgeInsets.only(left: 20.0),
                        child: Text(
                          'Home & Garden',
                          style: TextStyle(
                            fontSize: 27,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Segoe UI',
                          ),
                        ),
                      ),
                      const SizedBox(height: 25),
                      _homeGardenBrandsDesign(),
                      const SizedBox(height: 5),
                      Padding(
                        padding: const EdgeInsets.only(left: 20.0),
                        child: Text(
                          'Shoes & Apparels',
                          style: TextStyle(
                            fontSize: 27,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Segoe UI',
                          ),
                        ),
                      ),
                      const SizedBox(height: 25),
                      _shoesApparelsDesign(),
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

  Future<Map<String, List<dynamic>>> fetchBrands() async {
    try {
      log('method running');
      final response = await http
          .get(
            Uri.parse('https://www.minsellprice.com/api/minsell-brand'),
          )
          .timeout(const Duration(seconds: 30));
      log('Brand API: https://www.minsellprice.com/api/minsell-brand');

      if (response.statusCode == 200) {
        log('status code ${response.statusCode}');
        final Map<String, dynamic> jsonData = json.decode(response.body);

        final homeGardenBrands =
            jsonData["Home & Garden Brands"] as List<dynamic>;
        final shoesApparels = jsonData["Shoes & Apparels"] as List<dynamic>;

        return {
          "Home & Garden Brands": homeGardenBrands,
          "Shoes & Apparels": shoesApparels,
        };
      } else {
        log('Error Brand API: ${response.statusCode}');
        throw Exception('Failed to load brands: ${response.statusCode}');
      }
    } catch (e) {
      log("Exception In Brand API: ${e.toString()}");
      throw Exception('Error fetching brands: $e');
    }
  }

  Widget _homeGardenBrandsDesign() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: FutureBuilder<Map<String, List<dynamic>>>(
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

            final allBrands = _homeGardenBrands;
            log('Home & Garden Brands count: ${allBrands.length}');

            return Column(
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
                  itemCount: allBrands.length,
                  itemBuilder: (context, index) {
                    final brand = allBrands[index];
                    return GestureDetector(
                      onTap: () {
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
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 5.0),
                                  child: BrandImageWidget(brand: brand)
                                  // SizedBox(
                                  //   width: double.infinity,
                                  //   height: 115,
                                  //   child: CachedNetworkImage(
                                  //     imageUrl:
                                  //         'https://growth.matridtech.net/brand-logo/brands/${brand['brand_key'].toString().replaceAll(' ', '-').toLowerCase()}.png',
                                  //         //'https://www.minsellprice.com/Brand-logo-images/${brand['brand_name'].toString().replaceAll(' ', '-').toLowerCase()}.png',
                                  //     fit: BoxFit.contain,
                                  //     placeholder: (context, url) => const Center(
                                  //         child: CircularProgressIndicator()),
                                  //     errorWidget: (context, url, error) =>
                                  //         Image.asset(
                                  //       'assets/images/no_image.png',
                                  //       fit: BoxFit.contain,
                                  //     ),
                                  //   ),
                                  // ),
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
                          ],
                        ),
                      ),
                    );
                  },
                ),
                // if (hasMoreBrands)
                //   Padding(
                //       padding: const EdgeInsets.only(bottom: 20.0, top: 0),
                //       child: Container(
                //         decoration: BoxDecoration(
                //           borderRadius: BorderRadius.circular(12.0),
                //           gradient: LinearGradient(
                //             colors: [
                //               Colors.blue.shade700,
                //               Colors.blue.shade900
                //             ], // Darker blue gradient
                //             begin: Alignment.centerLeft,
                //             end: Alignment.centerRight,
                //           ),
                //           boxShadow: [
                //             BoxShadow(
                //               color: Colors.blue.withOpacity(0.3),
                //               spreadRadius: 2,
                //               blurRadius: 8,
                //               offset: Offset(0, 4),
                //             ),
                //           ],
                //         ),
                //         child: MaterialButton(
                //           onPressed: () {
                //             Navigator.push(
                //               context,
                //               MaterialPageRoute(
                //                 builder: (context) => BrandSearchScreen(
                //                   brands: List<Map<String, dynamic>>.from(
                //                       allBrands),
                //                   database: widget.database,
                //                 ),
                //               ),
                //             );
                //           },
                //           padding: EdgeInsets.symmetric(
                //               horizontal: 40, vertical: 15),
                //           shape: RoundedRectangleBorder(
                //             borderRadius: BorderRadius.circular(12.0),
                //           ),
                //           elevation: 0,
                //           color: Colors.transparent,
                //           child: const Text(
                //             'See More Brands',
                //             style: TextStyle(
                //               fontSize: 16,
                //               fontWeight: FontWeight.w600,
                //               color: Colors.white,
                //             ),
                //           ),
                //         ),
                //       )),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _shoesApparelsDesign() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: FutureBuilder<Map<String, List<dynamic>>>(
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

            final allBrands = _shoesApparels;
            log('Shoes & Apparels count: ${allBrands.length}');

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
                  itemCount: allBrands.length,
                  itemBuilder: (context, index) {
                    final brand = allBrands[index];
                    return GestureDetector(
                      onTap: () {
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
                                    imageUrl:
                                        'https://www.minsellprice.com/Brand-logo-images/${brand['brand_name'].toString().replaceAll(' ', '-').toLowerCase()}.png',
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
                          ],
                        ),
                      ),
                    );
                  },
                ),
                // if (hasMoreBrands)
                //   Padding(
                //       padding: const EdgeInsets.only(bottom: 20.0, top: 0),
                //       child: Container(
                //         decoration: BoxDecoration(
                //           borderRadius: BorderRadius.circular(12.0),
                //           gradient: LinearGradient(
                //             colors: [
                //               Colors.blue.shade700,
                //               Colors.blue.shade900
                //             ], // Darker blue gradient
                //             begin: Alignment.centerLeft,
                //             end: Alignment.centerRight,
                //           ),
                //           boxShadow: [
                //             BoxShadow(
                //               color: Colors.blue.withOpacity(0.3),
                //               spreadRadius: 2,
                //               blurRadius: 8,
                //               offset: Offset(0, 4),
                //             ),
                //           ],
                //         ),
                //         child: MaterialButton(
                //           onPressed: () {
                //             Navigator.push(
                //               context,
                //               MaterialPageRoute(
                //                 builder: (context) => BrandSearchScreen(
                //                   brands: List<Map<String, dynamic>>.from(
                //                       allBrands),
                //                   database: widget.database,
                //                 ),
                //               ),
                //             );
                //           },
                //           padding: EdgeInsets.symmetric(
                //               horizontal: 40, vertical: 15),
                //           shape: RoundedRectangleBorder(
                //             borderRadius: BorderRadius.circular(12.0),
                //           ),
                //           elevation: 0,
                //           color: Colors.transparent,
                //           child: const Text(
                //             'See More Brands',
                //             style: TextStyle(
                //               fontSize: 16,
                //               fontWeight: FontWeight.w600,
                //               color: Colors.white,
                //             ),
                //           ),
                //         ),
                //       )),
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
            return Center(child: const CircularProgressIndicator());
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
            return Center(child: const CircularProgressIndicator());
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
}

class BrandImageWidget extends StatefulWidget {
  final Map<String, dynamic> brand;

  const BrandImageWidget({super.key, required this.brand});

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

    String brandKey =
        widget.brand['brand_key'].toString().replaceAll(' ', '-').toLowerCase();
    String brandName = widget.brand['brand_name']
        .toString()
        .replaceAll(' ', '-')
        .toLowerCase();

    _imageUrl1 =
        'https://growth.matridtech.net/brand-logo/brands/$brandKey.png';
    _imageUrl2 =
        'https://www.minsellprice.com/Brand-logo-images/$brandName.png';

    _currentUrl = _imageUrl1;

    log('Brand name: ${widget.brand['brand_name']}');
    log('Brand key: ${widget.brand['brand_key']}');
    log('Using brand name for image URL: $brandName');
    log('Image URL 1: $_imageUrl1');
    log('Image URL 2: $_imageUrl2');
  }

  void _onImageError() {
    setState(() {
      if (_attempt == 0) {
        _currentUrl = _imageUrl2;
      } else if (_attempt == 1) {
        _currentUrl = _imageUrl1;
      } else {
        _currentUrl = ''; // fallback to asset
      }
      _attempt++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 5.0),
      child: SizedBox(
        width: double.infinity,
        height: 115,
        child: _currentUrl.isEmpty
            ? Image.asset(
                'assets/images/no_image.png',
                fit: BoxFit.contain,
              )
            : CachedNetworkImage(
                imageUrl: _currentUrl,
                fit: BoxFit.contain,
                placeholder: (context, url) =>
                    const Center(child: CircularProgressIndicator()),
                errorWidget: (context, url, error) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (mounted) {
                      _onImageError();
                    }
                  });
                  return const SizedBox(); // avoid calling setState during build
                },
              ),
      ),
    );
  }
}

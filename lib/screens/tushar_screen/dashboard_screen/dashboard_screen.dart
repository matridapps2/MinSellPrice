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
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:minsellprice/screens/tushar_screen/account_screen/account_screen.dart';
import 'package:minsellprice/screens/tushar_screen/categories_provider/categories_provider_file.dart';

import 'package:minsellprice/screens/tushar_screen/categories_screen/categories_screen.dart';
import 'package:minsellprice/screens/widgets/category_shimmer.dart';
import 'package:provider/provider.dart';
import 'package:salomon_bottom_bar/salomon_bottom_bar.dart';
import 'package:minsellprice/app.dart';
import 'package:minsellprice/screens/product_list_screen/brand_product_list_screen.dart';
import 'package:sqflite/sqflite.dart';
import '../../../colors.dart';
import '../../../reposotory_services/database/database_functions.dart';
import '../liked_product_screen/liked_product_screen.dart';
import '../search_screen/search_screen.dart';
import '../../../size.dart';

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
                ChangeNotifierProvider(
                  create: (context) {
                    final provider = BrandsProvider();
                    provider.fetchBrands();
                    return provider;
                  },
                  child: DashboardScreenWidget(
                    database: database,
                    vendorId: '${AppInfo.kVendorId}',
                  ),
                ),
                LikedProduct(
                  database: database,
                ),
                CategoriesScreen(
                  database: database,
                  vendorId: vendorId,
                ),
                AccountScreen(
                  database: database,
                )
              ];
              return GestureDetector(
                onTap: () {
                  FocusScopeNode currentFocus = FocusScope.of(context);
                  currentFocus.unfocus();
                },
                child: SafeArea(
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
                              SalomonBottomBarItem(
                                icon: const Icon(Icons.category),
                                title: const Text("Categories"),
                                selectedColor: AppColors.primary,
                              ),

                              /// account
                              SalomonBottomBarItem(
                                icon: const Icon(Icons.account_circle_rounded),
                                title: const Text("Account"),
                                selectedColor: AppColors.primary,
                              ),
                            ],
                          ),
                    body: _screens[_activeIndex],
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

@override
// TODO: implement wantKeepAlive
bool get wantKeepAlive => true;

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

  Future<void> _initCall() async {
    _brandsFuture = fetchBrands();
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

  Future<Map<String, List<dynamic>>> fetchBrands() async {
    try {
      log('Fetching brands from API');
      final response = await http
          .get(
            Uri.parse('https://www.minsellprice.com/api/minsell-brand'),
          ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        log('Brand API status code: ${response.statusCode}');
        final Map<String, dynamic> jsonData = json.decode(response.body);

        final homeGardenBrands =
            jsonData["Home & Garden Brands"] as List<dynamic>;
        final shoesApparels = jsonData["Shoes & Apparels"] as List<dynamic>;

        log('Home & Garden Brands count: ${homeGardenBrands.length}');
        log('Shoes & Apparels count: ${shoesApparels.length}');

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

  Widget _buildBrandsSections(BrandsProvider brandsProvider) {
    log('_buildBrandsSections called with state: ${brandsProvider.state}');
    log('Home & Garden count: ${brandsProvider.homeGardenBrands.length}');
    log('Shoes & Apparels count: ${brandsProvider.shoesApparels.length}');

    if (brandsProvider.state == BrandsState.loading || brandsProvider.state == BrandsState.initial) {
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
      return const Center(child: Text('No brands available.'));
    }
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 5,
          crossAxisSpacing: 5,
          childAspectRatio: 1,
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
                      padding: const EdgeInsets.symmetric(horizontal: 5.0),
                      child: BrandImageWidget(brand: brand),
                    ),
                  ),
                  Padding(
                    padding:
                        const EdgeInsets.only(top: 10.0, left: 8.0, right: 8.0),
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
    _initializeImageUrls();
  }

  void _initializeImageUrls() {
    try {
      String brandName = widget.brand['brand_name']?.toString() ?? '';
      String brandKey = widget.brand['brand_key']?.toString() ?? brandName;
      int brandId = widget.brand['brand_id'] ?? 0;

      String cleanBrandName = brandName
          .replaceAll(RegExp(r'[^\w\s-]'), '')
          .replaceAll(' ', '-')
          .toLowerCase();

      String cleanBrandKey = brandKey
          .replaceAll(RegExp(r'[^\w\s-]'), '')
          .replaceAll(' ', '-')
          .toLowerCase();

      _imageUrl1 =
          'https://growth.matridtech.net/brand-logo/brands/$cleanBrandKey.png';
      _imageUrl2 =
          'https://www.minsellprice.com/Brand-logo-images/$cleanBrandName.png';

      _currentUrl = _imageUrl1;

      log('BrandImageWidget [ID:$brandId] - Brand: "$brandName", Key: "$brandKey"');
      log('BrandImageWidget [ID:$brandId] - Clean Brand Name: "$cleanBrandName"');
      log('BrandImageWidget [ID:$brandId] - Clean Brand Key: "$cleanBrandKey"');
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
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 5.0),
      child: SizedBox(
        width: widget.width ?? double.infinity,
        height: widget.height ?? 115,
        child: _currentUrl.isEmpty
            ? Container(
                width: widget.width ?? 50,
                height: widget.height ?? 60,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.image_not_supported,
                  color: Colors.grey,
                  size: 24,
                ),
              )
            : CachedNetworkImage(
                imageUrl: _currentUrl,
                fit: BoxFit.contain,
                placeholder: (context, url) => Container(
                  width: widget.width ?? 50,
                  height: widget.height ?? 60,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Center(
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  ),
                ),
                errorWidget: (context, url, error) {
                  log('Image load error for URL: $url, Error: $error');
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (mounted) {
                      _onImageError();
                    }
                  });
                  return Container(
                    width: widget.width ?? 50,
                    height: widget.height ?? 60,
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.broken_image,
                      color: Colors.grey,
                      size: 20,
                    ),
                  );
                },
              ),
      ),
    );
  }
}

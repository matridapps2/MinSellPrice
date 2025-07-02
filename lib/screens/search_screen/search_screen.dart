import 'dart:convert';
import 'dart:developer';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:minsellprice/colors.dart';
import 'package:minsellprice/reposotory_services/database/database_constants.dart';
import 'package:minsellprice/reposotory_services/database/database_functions.dart';
import 'package:minsellprice/screens/ai_price_engine/ai_pricie_engine_screen.dart';
import 'package:minsellprice/screens/product_list_screen/product_list_screen.dart';
import 'package:minsellprice/screens/widgets/sample_product_screen.dart';
import 'package:minsellprice/services/extra_functions.dart';
import 'package:minsellprice/size.dart';

import 'package:sqflite/sqflite.dart';

import 'widget/labeled_text_field.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({
    super.key,
    required this.vendorId,
    required this.database,
  });

  final int vendorId;

  final Database database;

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _afSupplyController = TextEditingController();
  final TextEditingController _hpSkuController = TextEditingController();
  final TextEditingController _productMpnController = TextEditingController();
  final TextEditingController _productNameController = TextEditingController();

  final _searchController = ScrollController();

  @override
  void initState() {
    getSearchHistory(vendorId: widget.vendorId);
    getLabelName();
    super.initState();
  }

  int id = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            verticalSpace(verticalSpace: 5),
            SearchTextField(
                hintText: '',
                controller: _productMpnController,
                label: 'Product MPN'),
            verticalSpace(verticalSpace: 5),
            SearchTextField(
                hintText: '',
                controller: _productNameController,
                label: 'Product Name'),
            verticalSpace(verticalSpace: 10),
            InkWell(
              splashColor: Colors.blue,
              onTap: () async {
                if (_afSupplyController.text.isEmpty &&
                    _hpSkuController.text.isEmpty &&
                    _productMpnController.text.isEmpty &&
                    _productNameController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: const Text('Please Provide atleast one parameter'),
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                    margin: EdgeInsets.only(
                        bottom: MediaQuery.of(context).size.height * .5,
                        right: 20,
                        left: 20),
                  ));
                } else {
                  String afSku = _afSupplyController.text;
                  String hpSku = _hpSkuController.text;
                  String productMpn = _productMpnController.text;
                  String productName = _productNameController.text;

                  await DatabaseHelper().addSearchHistory(
                    db: widget.database,
                    vendorId: widget.vendorId,
                    afSku: afSku,
                    hpSku: hpSku,
                    productMpn: productMpn,
                    productName: productName,
                    id: id,
                  );

                  /*      await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ContentScreen(
                        vendorName: '',
                        vendorImage:
                        '${AppInfo.kBaseUrl(stagingSelector: 1)}vendor-logo/$vendorName.jpg',
                        vendorId: widget.vendorId.toString(),
                        date: '',
                        loadingData: '',
                        database: widget.database,
                        isVendorPriceAnalysis: false,
                        isVendorTable: false,
                        fromSearchScreen: true,
                        afSku: _afSupplyController.text,
                        hpSku: _hpSkuController.text,
                        productMpn: _productMpnController.text,
                        productName: _productNameController.text,
                      ),
                    ),
                  );*/
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ProductListScreen(
                        titleValue: _productNameController.text,
                        database: widget.database,
                        dataList: const [],
                        isBrands: false,
                        searchProduct: true,
                        productMpn: _productMpnController.text,
                        isCategory: false,
                        title: 'Looking for: ${_productNameController.text}',
                      ),
                    ),
                  );
                  await getSearchHistory(vendorId: widget.vendorId);
                }
              },
              child: Card(
                color: AppColors.primary,
                child: SizedBox(
                    width: w * .7,
                    height: 50,
                    child: Center(
                        child: AutoSizeText(
                      'Search',
                      style: GoogleFonts.openSans(
                          color: Colors.white,
                          fontSize: w * .06,
                          fontWeight: FontWeight.w700),
                    ))),
              ),
            ),
            verticalSpace(verticalSpace: 5),
            InkWell(
              splashColor: Colors.blue,
              onTap: () {
                _afSupplyController.clear();
                _hpSkuController.clear();
                _productMpnController.clear();
                _productNameController.clear();
              },
              child: Card(
                color: Colors.orange,
                child: SizedBox(
                    width: w * .7,
                    height: 50,
                    child: Center(
                        child: AutoSizeText(
                      'Clear',
                      style: GoogleFonts.openSans(
                          color: Colors.white,
                          fontSize: w * .06,
                          fontWeight: FontWeight.w700),
                    ))),
              ),
            ),
            verticalSpace(verticalSpace: 10),
            Align(
              alignment: Alignment.centerLeft,
              child: AutoSizeText(
                'Search History',
                style: GoogleFonts.openSans(
                    color: Colors.black,
                    decoration: TextDecoration.underline,
                    fontSize: w * .05,
                    fontWeight: FontWeight.w700),
              ),
            ),
            verticalSpace(verticalSpace: 10),
            searchHistory.isEmpty
                ? Align(
                    alignment: Alignment.center,
                    child: AutoSizeText(
                      'No Search',
                      style: GoogleFonts.openSans(
                          color: Colors.black,
                          fontSize: w * .045,
                          fontWeight: FontWeight.bold),
                    ),
                  )
                : Expanded(
                    child: Scrollbar(
                      controller: _searchController,
                      thumbVisibility: true,
                      trackVisibility: true,
                      thickness: 2,
                      interactive: true,
                      child: SingleChildScrollView(
                        controller: _searchController,
                        child: Column(
                          children: List.generate(
                            searchHistory.length + 1,
                            (index) => index == searchHistory.length
                                ? verticalSpace(verticalSpace: 120)
                                : InkWell(
                                    splashColor: Colors.blue,
                                    onTap: () {
                                      setState(() {
                                        _afSupplyController.text =
                                            searchHistory[index][afSkuKey];
                                        _hpSkuController.text =
                                            searchHistory[index][hpSkuKey];
                                        _productMpnController.text =
                                            searchHistory[index][productMPNKey];
                                        _productNameController.text =
                                            searchHistory[index]
                                                [productNameKey];
                                      });
                                      _searchController.animateTo(
                                        0,
                                        duration: const Duration(seconds: 1),
                                        curve: Curves.easeIn,
                                      );
                                    },
                                    child: Card(
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: SizedBox(
                                          width: w,
                                          child: Stack(
                                            children: [
                                              RichText(
                                                text: TextSpan(
                                                  style: GoogleFonts.openSans(
                                                      color: Colors.black,
                                                      fontSize: w * .04,
                                                      fontWeight:
                                                          FontWeight.bold),
                                                  children: [
                                                    TextSpan(
                                                      text: "Product MPN: ",
                                                      style:
                                                          GoogleFonts.openSans(
                                                              color:
                                                                  Colors.black,
                                                              fontSize: w * .04,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold),
                                                    ),
                                                    TextSpan(
                                                      text: searchHistory[index]
                                                          [productMPNKey],
                                                      style:
                                                          GoogleFonts.openSans(
                                                              color:
                                                                  Colors.black,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .normal),
                                                    ),
                                                    TextSpan(
                                                      text: "\nProduct Name: ",
                                                      style:
                                                          GoogleFonts.openSans(
                                                              color:
                                                                  Colors.black,
                                                              fontSize: w * .04,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold),
                                                    ),
                                                    TextSpan(
                                                      text: searchHistory[index]
                                                          [productNameKey],
                                                      style:
                                                          GoogleFonts.openSans(
                                                              color:
                                                                  Colors.black,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .normal),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              Align(
                                                alignment: Alignment.topRight,
                                                child: DeleteHistory(
                                                    database: widget.database,
                                                    historyId: int.tryParse(
                                                            '${searchHistory[index][listId]}') ??
                                                        0,
                                                    getHistory: () async =>
                                                        await getSearchHistory(
                                                            vendorId: widget
                                                                .vendorId)),
                                              )
                                            ],
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
        ),
      ),
    );
  }

  List<Map<String, dynamic>> searchHistory = [];
  String mainLabelName = '';
  String secLabelName = '';
  String vendorName = '';

  Future<void> getLabelName() async {
    final Map<String, dynamic> loginData =
        await DatabaseHelper().getUserInformation(db: widget.database);

    setState(() {
      mainLabelName = loginData[vendor_short_nameKey];
      secLabelName = loginData[sister_vendor_short_nameKey];
      vendorName = loginData[vendor_nameKey];
    });
  }

  Future<void> getSearchHistory({required int vendorId}) async {
    searchHistory = await DatabaseHelper().getHistoryData(db: widget.database);
    id = searchHistory.length + 1;
    id += id;
    log(jsonEncode(searchHistory));
    setState(() {});
  }
}

class DeleteHistory extends StatelessWidget {
  final Database database;
  final int historyId;
  final VoidCallback getHistory;

  const DeleteHistory({
    super.key,
    required this.database,
    required this.historyId,
    required this.getHistory,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      splashColor: Colors.blue,
      onTap: () async {
        DatabaseHelper().removeSearchHistory(
          db: database,
          listID: historyId,
        );
        getHistory();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'History Deleted',
            ),
          ),
        );
        // getSearchHistory(vendorId: widget.vendorId);
      },
      child: const Padding(
        padding: EdgeInsets.all(16.0),
        child: Icon(
          Icons.delete,
        ),
      ),
    );
  }
}

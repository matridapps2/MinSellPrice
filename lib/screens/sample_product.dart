import 'dart:developer';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shoppingmegamart/bloc/product_list_by_id_bloc/product_list_by_id_bloc.dart';
import 'package:shoppingmegamart/model/product_list_model.dart';
import 'package:shoppingmegamart/screens/InAppBrowser.dart';
import 'package:shoppingmegamart/screens/widgets/custom_loader.dart';
import 'package:shoppingmegamart/services/extra_functions.dart';
import 'package:shoppingmegamart/size.dart';

class SampleProductDesign extends StatefulWidget {
  const SampleProductDesign({
    super.key,
    required this.vendorName,
    required this.vendorImage,
    required this.loadingData,
    required this.vendorId,
    required this.date,
    this.id,
    this.loadingString,
    this.brandKey,
    required this.isVendorPriceAnalysis,
    required this.isVendorTable,
  });

  final String vendorName, vendorImage, vendorId, date, loadingData;
  final String? id, brandKey, loadingString;
  final bool isVendorPriceAnalysis, isVendorTable;

  @override
  State<SampleProductDesign> createState() => _SampleProductDesignState();
}

class _SampleProductDesignState extends State<SampleProductDesign> {
  DateTime selectedDate = DateTime.now().subtract(const Duration(days: 1));

  bool changeLayout = true;

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate:
          selectedDate ?? DateTime.now().subtract(const Duration(days: 1)),
      firstDate: DateTime(2022),
      lastDate: DateTime.now().subtract(const Duration(days: 1)),
    );

    if (pickedDate != null && pickedDate != selectedDate) {
      setState(() {
        selectedDate = pickedDate;
      });
      if (mounted) {
        // context.read<ProductListByIdBloc>().add(
        //       ProductListByIdLoadingEvent(
        //         isVendorTable: widget.isVendorTable,
        //         dataId: widget.id!,
        //         brandKey: widget.isVendorPriceAnalysis == true
        //             ? widget.vendorName
        //                 .toLowerCase()
        //                 .replaceAll(' ', '_')
        //                 .replaceAll('-', '_')
        //                 .replaceAll('%', '')
        //             : widget.brandKey,
        //         isVendorProducts: widget.isVendorPriceAnalysis,
        //         date: dateFormat
        //             .format(
        //               selectedDate,
        //             )
        //             .replaceAll('/', '-'),
        //         vendorId: widget.vendorId,
        //       ),
        //     );
      }
    }
  }

  @override
  void initState() {
    // TODO: implement initState

    // context.read<ProductListByIdBloc>().add(
    //       ProductListByIdLoadingEvent(
    //         vendorId: widget.vendorId,
    //         isVendorTable: widget.isVendorTable,
    //         date: widget.date,
    //         dataId: widget.id!,
    //         brandKey: widget.isVendorPriceAnalysis == true
    //             ? widget.vendorName
    //                 .toLowerCase()
    //                 .replaceAll(' ', '_')
    //                 .replaceAll('-', '_')
    //                 .replaceAll('%', '')
    //             : widget.brandKey,
    //         isVendorProducts: widget.isVendorPriceAnalysis,
    //       ),
    //     );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: true,
      child: Scaffold(
        body: Padding(
            padding: const EdgeInsets.all(8.0),
            child: BlocBuilder<ProductListByIdBloc, ProductListByIdState>(
              builder: (context, state) {
                {
                  return state is ProductListByIdLoading
                      ? Center(
                          child: CustomLoader(
                            vendorName: widget.loadingData,
                            imageString: widget.vendorImage,
                            isAssetImage: widget.isVendorTable,
                            loaderString: widget.loadingString,
                          ),
                        )
                      : state is ProductListByIdErrorState
                          ? Center(
                              child:
                                  AutoSizeText(state.errorMessage.toString()),
                            )
                          : state is ProductListByIdLoadedState
                              ? CustomScrollView(
                                  slivers: <Widget>[
                                    SliverAppBar(
                                      snap: false,
                                      backgroundColor: Colors.white,
                                      pinned: true,
                                      forceElevated: true,
                                      floating: false,
                                      expandedHeight: 130,
                                      leading: const SizedBox(),
                                      leadingWidth: 0,
                                      actions: [
                                        GestureDetector(
                                          onTap: () {
                                            setState(() {
                                              changeLayout = !changeLayout;
                                            });
                                          },
                                          child: const Padding(
                                            padding: EdgeInsets.all(8.0),
                                            child: Icon(
                                              Icons.change_circle,
                                              color: Colors.black,
                                            ),
                                          ),
                                        )
                                      ],
                                      flexibleSpace: FlexibleSpaceBar(
                                          centerTitle: true,
                                          title: Text(
                                            widget.vendorName,
                                            style: GoogleFonts.montserrat(
                                              fontSize: w * 0.035,
                                              color: Colors.black,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ), //Text
                                          background: Padding(
                                            padding: const EdgeInsets.only(
                                                bottom: 50.0,
                                                top: 20,
                                                left: 8,
                                                right: 8),
                                            child: CachedNetworkImage(
                                              // fit: BoxFit.cover,
                                              height: w * .1,
                                              imageUrl: widget.vendorImage,
                                            ),
                                          ) //Images.network
                                          ),
                                    ),
                                    SliverAppBar(
                                        snap: false,
                                        pinned: true,
                                        floating: false,
                                        leading: const SizedBox(),
                                        leadingWidth: 0,
                                        toolbarHeight: changeLayout == false
                                            ? h * .25
                                            : h * .11,
                                        backgroundColor: Colors.white,
                                        flexibleSpace: Column(
                                          children: [
                                            Visibility(
                                              visible: !changeLayout,
                                              child: Flexible(
                                                child: Align(
                                                  alignment:
                                                      Alignment.centerLeft,
                                                  child: Padding(
                                                    padding: const EdgeInsets
                                                        .symmetric(
                                                        horizontal: 8.0,
                                                        vertical: 8),
                                                    child: Row(
                                                      mainAxisSize:
                                                          MainAxisSize.min,
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .start,
                                                      children: [
                                                        Container(
                                                          width: w * 0.45,
                                                          decoration:
                                                              const BoxDecoration(
                                                            border: Border(
                                                              left: BorderSide(
                                                                color: Colors
                                                                    .black12,
                                                              ),
                                                              top: BorderSide(
                                                                color: Colors
                                                                    .black12,
                                                              ),
                                                              bottom:
                                                                  BorderSide(
                                                                color: Colors
                                                                    .black12,
                                                              ),
                                                            ),
                                                          ),
                                                          child: Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                    .symmetric(
                                                                    vertical:
                                                                        8),
                                                            child: Center(
                                                              child: RichText(
                                                                textAlign:
                                                                    TextAlign
                                                                        .center,
                                                                text: TextSpan(
                                                                  text:
                                                                      'Your Price\n',
                                                                  style: GoogleFonts
                                                                      .montserrat(
                                                                    fontSize: w *
                                                                        0.035,
                                                                    color: Colors
                                                                        .black,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold,
                                                                  ),
                                                                  children: [
                                                                    TextSpan(
                                                                      text:
                                                                          '- Discount\n',
                                                                      style: GoogleFonts
                                                                          .montserrat(
                                                                        fontSize:
                                                                            w * 0.035,
                                                                        color: Colors
                                                                            .green,
                                                                        fontWeight:
                                                                            FontWeight.bold,
                                                                      ),
                                                                    ),
                                                                    TextSpan(
                                                                      text:
                                                                          '+ Shipping\n',
                                                                      style: GoogleFonts
                                                                          .montserrat(
                                                                        fontSize:
                                                                            w * 0.035,
                                                                        color: Colors
                                                                            .black,
                                                                        fontWeight:
                                                                            FontWeight.bold,
                                                                      ),
                                                                    ),
                                                                  ],
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                        Container(
                                                          decoration:
                                                              const BoxDecoration(
                                                            border: Border(
                                                              left: BorderSide(
                                                                color: Colors
                                                                    .black12,
                                                              ),
                                                              right: BorderSide(
                                                                color: Colors
                                                                    .black12,
                                                              ),
                                                              top: BorderSide(
                                                                color: Colors
                                                                    .black12,
                                                              ),
                                                              bottom:
                                                                  BorderSide(
                                                                color: Colors
                                                                    .black12,
                                                              ),
                                                            ),
                                                          ),
                                                          width: w * 0.45,
                                                          child: Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                    .all(10),
                                                            child: Center(
                                                              child: RichText(
                                                                textAlign:
                                                                    TextAlign
                                                                        .center,
                                                                text: TextSpan(
                                                                  text:
                                                                      'Competitor Price\n',
                                                                  style: GoogleFonts
                                                                      .montserrat(
                                                                    fontSize: w *
                                                                        0.035,
                                                                    color: Colors
                                                                        .black,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold,
                                                                  ),
                                                                  children: [
                                                                    TextSpan(
                                                                      text:
                                                                          '- Discount\n',
                                                                      style: GoogleFonts
                                                                          .montserrat(
                                                                        fontSize:
                                                                            w * 0.035,
                                                                        color: Colors
                                                                            .green,
                                                                        fontWeight:
                                                                            FontWeight.bold,
                                                                      ),
                                                                    ),
                                                                    TextSpan(
                                                                      text:
                                                                          '+ Shipping\n',
                                                                      style: GoogleFonts
                                                                          .montserrat(
                                                                        fontSize:
                                                                            w * 0.035,
                                                                        color: Colors
                                                                            .black,
                                                                        fontWeight:
                                                                            FontWeight.bold,
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
                                                  ),
                                                ),
                                              ),
                                            ),
                                            Card(
                                              elevation: 4,
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.all(8.0),
                                                child: TextFormField(
                                                  onTap: () {
                                                    _selectDate(context);
                                                  },
                                                  readOnly: true,
                                                  decoration: InputDecoration(
                                                    border: InputBorder.none,
                                                    floatingLabelBehavior:
                                                        FloatingLabelBehavior
                                                            .always,
                                                    floatingLabelStyle:
                                                        GoogleFonts.montserrat(
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold),
                                                    labelText: 'Date',
                                                    hintText: selectedDate !=
                                                            null
                                                        ? dateFormat.format(
                                                            selectedDate)
                                                        : 'Select a date (yyyy/MM/dd)',
                                                    suffixIcon: const Icon(
                                                        Icons.calendar_today),
                                                  ),
                                                  controller:
                                                      TextEditingController(
                                                    text: selectedDate != null
                                                        ? dateFormat.format(
                                                            selectedDate)
                                                        : '',
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        )),
                                    SliverList(
                                      delegate: SliverChildBuilderDelegate(
                                        (context, index) => AnimatedSwitcher(
                                          duration: const Duration(seconds: 1),
                                          child: sampleWidget1(
                                              data: state.productList[index],
                                              context: context,
                                              index: index,
                                              vendorImage: widget.vendorImage),
                                        ),

                                        //
                                        //ListTile
                                        childCount: state.productList.length,
                                      ), //SliverChildBuildDelegate
                                    ) //SliverList
                                  ], //<Widget>[]
                                )
                              : const Center(child: Text('No Data'));
                }
              },
            )),
      ),
    );
  }
}

Widget sampleWidget({required Map<String, dynamic> data}) => Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 8.0, top: 10),
          child: SizedBox(
            width: w,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    FlutterLogo(
                      size: w * .16,
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    SizedBox(
                      width: w * .7,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisSize: MainAxisSize.max,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              AutoSizeText(
                                'MSP: ${data['msp']}',
                                style: GoogleFonts.montserrat(
                                  fontSize: w * 0.042,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              AutoSizeText(
                                'SKU: ${data['SKU']}',
                                style: GoogleFonts.montserrat(
                                  fontSize: w * 0.042,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(
                            height: 5,
                          ),

// 'Your Price: ${data['pre_price']}\nShipping included ${data['shipping']}',
//                             style: GoogleFonts.montserrat(
//                               fontSize: w * 0.035,
//                               fontWeight: FontWeight.bold,
//                             ),
//                           ),
                          const SizedBox(
                            height: 5,
                          ),
                          AutoSizeText(
                            'Your Price: ${data['pre_price']}\nShipping included ${data['shipping']}',
                            style: GoogleFonts.montserrat(
                              fontSize: w * 0.035,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(
          height: 10,
        ),
        RichText(
          text: TextSpan(
              text: 'Your price is',
              style: GoogleFonts.montserrat(
                  fontSize: w * 0.035,
                  fontWeight: FontWeight.bold,
                  color: Colors.black),
              children: [
                TextSpan(
                  text: data['lowerorhigher'].toString().contains('-')
                      ? ' ${data['lowerorhigher']} Lower'
                      : ' ${data['lowerorhigher']} Higher',
                  style: GoogleFonts.montserrat(
                    fontSize: w * 0.035,
                    fontWeight: FontWeight.bold,
                    color: data['lowerorhigher'].toString().contains('-')
                        ? Colors.green
                        : Colors.red,
                  ),
                ),
                TextSpan(
                  text: ' then your competitor',
                  style: GoogleFonts.montserrat(
                    fontSize: w * 0.035,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ]),
        ),
        const SizedBox(
          height: 10,
        ),
        SizedBox(
          child: DataTable(
            decoration: BoxDecoration(border: Border.all(color: Colors.grey)),
            columns: [
              DataColumn(
                label: SizedBox(
                  width: w * .25,
                  child: Center(
                    child: AutoSizeText(
                      'Your Price',
                      style: GoogleFonts.montserrat(
                        fontSize: w * 0.035,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
              DataColumn(
                label: CachedNetworkImage(
                  imageUrl: data['compititor_data']['logo'],
                  width: w * .4,
                  height: w * .1,
                ),
              ),
            ],
            rows: [
              DataRow(
                cells: [
                  DataCell(
                    Center(
                        child: Text(
                      data['finalPrice'],
                      style: GoogleFonts.montserrat(
                        fontSize: w * 0.035,
                        fontWeight: FontWeight.bold,
                      ),
                    )),
                  ),
                  DataCell(
                    Center(
                      child: Text(
                        data['compititor_data']['total'],
                        style: GoogleFonts.montserrat(
                          fontSize: w * 0.035,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
        const SizedBox(
          height: 10,
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
              decoration: BoxDecoration(
                  color: Colors.grey, borderRadius: BorderRadius.circular(25)),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8.0, vertical: 16),
                child: Center(
                  child: AutoSizeText(
                    'Check this item on competitor page',
                    style: GoogleFonts.montserrat(
                      fontSize: w * 0.035,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              )),
        ),
        const SizedBox(
          height: 10,
        ),
        SizedBox(
            width: w,
            child: const Divider(
              color: Colors.grey,
            )),
      ],
    );

Widget sampleWidget1(
    {required ProductListModel data,
    required int index,
    required String vendorImage,
    required BuildContext context}) {
  final productData = ProductData(
      productImage: data.productImage.isEmpty
          ? 'https://upload.wikimedia.org/wikipedia/commons/d/d1/Image_not_available.png?20210219185637'
          : data.productImage,
      price: data.vendorSku,
      productName: data.vendorSku.isEmpty
          ? data.secondarySku
          : data.secondarySku.isEmpty
              ? data.productMpn
              : data.vendorSku,
      firstLowest: "${data.firstVendorPercentage}%",
      yourPrice: data.firstVendorPrice,
      compPrice: data.secondVendorPrice.toString(),
      urProductUrl: data.firstVendorUrl,
      compUrl: data.firstVendorUrl,
      compName: data.secondVendorName,
      shipping:
          data.shipping.isEmpty ? data.vendorpriceShipping : data.shipping,
      discountAmount: data.firstVendorExtraDiscount,
      discountPercent: data.firstVendorExtraDiscount,
      compshipping: data.secondVendorPriceShipping.toString(),
      compdiscountAmount: data.secondVendorExtraDsicount,
      compdiscountPercent: data.secondVendorExtraDsicount,
      productUrl: data.firstVendorUrl);

  return Padding(
    padding: const EdgeInsets.all(8.0),
    child: GestureDetector(
      // onTap: () => Navigator.push(
      //     context,
      //     CupertinoPageRoute(
      //         builder: (context) => SampleListScreen(
      //               vendorImage: vendorImage,
      //             ))),
      child: Container(
        decoration: BoxDecoration(
          // color: Colors.grey.withOpacity(.2),
          border: Border.all(
            color: Colors.black.withOpacity(0.2),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 8.0, top: 6),
              child: GestureDetector(
                onTap: () async => await MyInAppBrowser().openUrlRequest(
                  urlRequest: URLRequest(
                      url: WebUri(productData.urProductUrl +
                          '?utm_source=shoppingmegamart.com&utm_medium=mobile-app')),
                  options: InAppBrowserClassOptions(
                    crossPlatform: InAppBrowserOptions(
                      toolbarTopBackgroundColor: Colors.blue,
                    ),
                  ),
                ),
                child: SizedBox(
                  width: w,
                  child: Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 0.15 * w,
                          height: 0.15 * w,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border:
                                Border.all(color: Colors.grey.withOpacity(.4)),
                            image: DecorationImage(
                              onError: (e, s) => log(e.toString()),
                              image: CachedNetworkImageProvider(
                                productData.productImage,
                                // scale: .5,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(
                          width: w * .05,
                        ),
                        AutoSizeText(
                          productData.productName,
                          style: GoogleFonts.montserrat(
                            fontSize: w * 0.046,
                            decoration: TextDecoration.underline,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(
                          width: 3,
                        ),
                        Transform.rotate(
                            angle: -120,
                            child: const Icon(
                              Icons.arrow_forward,
                              size: 15,
                              color: Colors.black,
                            ))
                      ],
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(
              height: 5,
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 4.0),
              child: RichText(
                text: TextSpan(
                    style: GoogleFonts.montserrat(
                        fontSize: w * 0.035,
                        fontWeight: FontWeight.bold,
                        color: Colors.black),
                    children: [
                      TextSpan(
                        text: productData.firstLowest,
                        style: GoogleFonts.montserrat(
                          fontSize: w * 0.04,
                          fontWeight: FontWeight.bold,
                          color: productData.firstLowest.contains('-')
                              ? Colors.green
                              : Colors.red,
                        ),
                      ),
                      TextSpan(
                        // text: ' then your competitor',

                        style: GoogleFonts.montserrat(
                          fontSize: w * 0.035,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ]),
              ),
            ),
            Center(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: w * .455,
                    height: w * .25,
                    decoration: BoxDecoration(
                      border: Border(
                        top: BorderSide(
                          color: Colors.grey.withOpacity(.2),
                        ),
                        bottom: BorderSide(
                          color: Colors.grey.withOpacity(.2),
                        ),
                      ),
                    ),
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: RichText(
                          text: TextSpan(
                            text: '\$${data.vendorPriceFinalPrice}\n',
                            style: GoogleFonts.montserrat(
                              fontSize: 0.043 * w,
                              color: Colors.red,
                              fontWeight: FontWeight.bold,
                            ),
                            children: [
                              TextSpan(
                                text: data.extraDiscount == '0.00'
                                    ? '\$${data.vendorpricePrice}'
                                    : '\$${data.sisterVendorBasePrice}',
                                style: GoogleFonts.montserrat(
                                  fontSize: 0.035 * w,
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                ),
                                children: [
                                  TextSpan(
                                    text: ' + \$${data.vendorpriceShipping}',
                                    style: GoogleFonts.montserrat(
                                      fontSize: 0.035 * w,
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  TextSpan(
                                    text: data.extraDiscount == '0.00'
                                        ? ''
                                        : '\n - ${data.extraDiscount}% (\$${returnDiscountPrice(discountPercentage: data.extraDiscount, mainPrice: data.sisterVendorBasePrice!.isEmpty ? data.sisterVendorFinalPrice!.isEmpty ? '0.0' : data.sisterVendorFinalPrice ?? '--' : data.sisterVendorBasePrice ?? '--')})',
                                    style: GoogleFonts.montserrat(
                                      fontSize: 0.035 * w,
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              )
                            ],
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ),
                  Container(
                    width: w * .455,
                    height: w * .25,
                    decoration: BoxDecoration(
                      border: Border(
                        left: BorderSide(
                          color: Colors.grey.withOpacity(.2),
                        ),
                        top: BorderSide(
                          color: Colors.grey.withOpacity(.2),
                        ),
                        bottom: BorderSide(
                          color: Colors.grey.withOpacity(.2),
                        ),
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Center(
                        child: data.vendorName.toLowerCase() ==
                                data.firstVendorName.toLowerCase()
                            ? RichText(
                                text: TextSpan(
                                  text: '\$${data.secondVendorPrice}\n',
                                  style: GoogleFonts.montserrat(
                                    fontSize: 0.043 * w,
                                    color: Colors.red,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  children: [
                                    TextSpan(
                                      text: '\$${data.secondVendorBasePrice}',
                                      style: GoogleFonts.montserrat(
                                        fontSize: 0.035 * w,
                                        color: Colors.black,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      children: [
                                        TextSpan(
                                          text:
                                              ' + \$${data.secondVendorPriceShipping}',
                                          style: GoogleFonts.montserrat(
                                            fontSize: 0.035 * w,
                                            color: Colors.black,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        TextSpan(
                                          text: data.secondVendorExtraDsicount ==
                                                  '0.00'
                                              ? ''
                                              : '\n - ${data.secondVendorExtraDsicount}% (\$${returnDiscountPrice(discountPercentage: data.secondVendorExtraDsicount, mainPrice: data.secondVendorBasePrice.isEmpty ? data.secondVendorPrice.isEmpty ? '0.0' : data.secondVendorPrice : data.secondVendorPrice)})',
                                          style: GoogleFonts.montserrat(
                                            fontSize: 0.035 * w,
                                            color: Colors.black,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    )
                                  ],
                                ),
                                textAlign: TextAlign.center,
                              )
                            : RichText(
                                text: TextSpan(
                                  text: '\$${data.firstVendorPrice}\n',
                                  style: GoogleFonts.montserrat(
                                    fontSize: 0.043 * w,
                                    color: Colors.red,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  children: [
                                    TextSpan(
                                      text: '\$${data.firstVendorBasePrice}',
                                      style: GoogleFonts.montserrat(
                                        fontSize: 0.035 * w,
                                        color: Colors.black,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      children: [
                                        TextSpan(
                                          text:
                                              ' + \$${data.firstVendorPriceShipping}',
                                          style: GoogleFonts.montserrat(
                                            fontSize: 0.035 * w,
                                            color: Colors.black,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        TextSpan(
                                          text: data.firstVendorExtraDiscount ==
                                                  '0.00'
                                              ? ''
                                              : '\n - ${data.firstVendorExtraDiscount}% (\$${returnDiscountPrice(discountPercentage: data.firstVendorExtraDiscount, mainPrice: data.firstVendorBasePrice.isEmpty ? data.firstVendorPrice.isEmpty ? '0.0' : data.firstVendorPrice : data.firstVendorBasePrice)})',
                                          style: GoogleFonts.montserrat(
                                            fontSize: 0.035 * w,
                                            color: Colors.black,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    )
                                  ],
                                ),
                                textAlign: TextAlign.center,
                              ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: GestureDetector(
                onTap: () async => await MyInAppBrowser().openUrlRequest(
                  urlRequest: URLRequest(
                      url: WebUri(data.vendorName.toLowerCase() ==
                              data.firstVendorName.toLowerCase()
                          ? data.secondVendorUrl +
                              '?utm_source=shoppingmegamart.com&utm_medium=mobile-app'
                          : data.firstVendorUrl +
                              '?utm_source=shoppingmegamart.com&utm_medium=mobile-app')),
                  options: InAppBrowserClassOptions(
                    crossPlatform: InAppBrowserOptions(
                      toolbarTopBackgroundColor: Colors.blue,
                    ),
                  ),
                ),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8.0, vertical: 6),
                  child: Center(
                    child: AutoSizeText(
                      data.vendorName.toLowerCase() ==
                              data.firstVendorName.toLowerCase()
                          ? data.secondVendorName
                          : data.firstVendorName,
                      style: GoogleFonts.montserrat(
                        fontSize: w * 0.035,
                        color: Colors.blue,
                        decoration: TextDecoration.underline,
                        decorationColor: Colors.blue,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

double returnFinalPrice(
    {required String price,
    required String discountPrice,
    required String shipping}) {
  // String stringValue = "sdas3.40%";

  // RegExp regex = RegExp(r'\d+(\.\d+)?');
  RegExp regex = RegExp(r'[^0-9.]');
  String priceString = price.replaceAll(regex, '');
  String discountString = discountPrice.replaceAll(regex, '');
  String shippingString = shipping.replaceAll(regex, '');
  {
    double number1 = 0.0;
    double number2 = 0.0;
    double number3 = 0.0;
    try {
      number1 = double.parse(priceString);
    } catch (e) {
      number1 = 0.0;
    }
    try {
      number2 = double.parse(discountString);
    } catch (e) {
      number2 = 0.0;
    }
    try {
      number3 = double.parse(shippingString);
    } catch (e) {
      number3 = 0.0;
    }

    double discountedPrice = number1 * (number2 / 100);

    // Calculate the sum
    double sum = number1 - discountedPrice + number3;

    if (kDebugMode) {
      print("Sum: \$$sum");
    }
    return double.parse(sum.toStringAsFixed(2));
  }
}

double returnDiscountPrice(
    {required String mainPrice, required String discountPercentage}) {
  RegExp regex = RegExp(r'[^0-9.]');
  String priceString = mainPrice.replaceAll(regex, '');
  String discountString = discountPercentage.replaceAll(regex, '');

  try {
    double number1 = double.parse(priceString);
    double number2 = double.parse(discountString);

    double discountedPrice = number1 * (number2 / 100);
    return double.parse(discountedPrice.toStringAsFixed(2));
  } catch (e) {
    return 0.0;
  }
}

class ProductData {
  final String price,
      productName,
      productUrl,
      firstLowest,
      yourPrice,
      compPrice,
      urProductUrl,
      compUrl,
      shipping,
      discountAmount,
      discountPercent,
      compshipping,
      compdiscountAmount,
      compdiscountPercent,
      productImage,
      compName;

  ProductData({
    required this.shipping,
    required this.productImage,
    required this.discountAmount,
    required this.discountPercent,
    required this.compshipping,
    required this.compdiscountAmount,
    required this.compdiscountPercent,
    required this.price,
    required this.productName,
    required this.productUrl,
    required this.firstLowest,
    required this.yourPrice,
    required this.compPrice,
    required this.urProductUrl,
    required this.compUrl,
    required this.compName,
  });
}

class ProductData2 {
  final String price,
      productName,
      productUrl,
      firstLowest,
      firstComp,
      secondComp,
      yourPrice,
      firstcompPrice,
      seccompPrice,
      urProductUrl,
      firstcompUrl,
      seccompUrl;

  ProductData2({
    required this.firstComp,
    required this.secondComp,
    required this.firstcompPrice,
    required this.seccompPrice,
    required this.firstcompUrl,
    required this.seccompUrl,
    required this.price,
    required this.productName,
    required this.productUrl,
    required this.firstLowest,
    required this.yourPrice,
    required this.urProductUrl,
  });
}

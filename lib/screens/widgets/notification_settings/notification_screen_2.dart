import 'dart:convert';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:minsellprice/screens/widgets/notification_settings/notification_settings_screen.dart';
import 'package:minsellprice/size.dart';

class NotificationSettingsScreen2 extends StatefulWidget {
  const NotificationSettingsScreen2({super.key});

  @override
  State<NotificationSettingsScreen2> createState() =>
      _NotificationSettingsScreen2State();
}

class _NotificationSettingsScreen2State
    extends State<NotificationSettingsScreen2> {
  List<Map<String, dynamic>> filterMap =
      filters['specificationAttributeFilters'];

  int activeIndexForPercent = 0;
  int activeIndexForNumberOfProducts = 0;
  int activeIndexForNotificationFrequency = 0;
  bool isRotationEnable = false;
  String percentageString = 'Lowest by 5%';
  String numberOfProductString = '5';
  String frequencyString = 'Hourly';

  final editingController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SizedBox(
          height: h,
          // decoration: const BoxDecoration(
          //   image: DecorationImage(
          //       opacity: .5,
          //       image: AssetImage(
          //         'assets/19449724.jpg',
          //       ),
          //       fit: BoxFit.fill),
          // ),
          child: Column(
            children: [
              SizedBox(
                height: h * .2 - 10,
                width: w,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Image.asset(
                          'assets/af-supply.png',
                          width: w * .6,
                          height: h * .08,
                        )),
                    Text(
                      'Notification Rules Setting',
                      style: TextStyle(
                          fontFamily: 'Chn Prop Arial Norman',
                          fontSize: 0.08 * w,
                          fontWeight: FontWeight.bold,
                          color: Colors.black),
                    )
                  ],
                ),
              ),
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(.5),
                    // borderRadius: BorderRadius.only(
                    //   topLeft: Radius.circular(20),
                    //   topRight: Radius.circular(20),
                    // ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          ...List.generate(
                            filterMap.length,
                            (index) => SizedBox(
                              width: w,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.max,
                                children: [
                                  Visibility(
                                    visible: filterMap[index]['name']
                                            .toString()
                                            .toLowerCase()
                                            .contains('rotate')
                                        ? false
                                        : true,
                                    child: Padding(
                                      padding: EdgeInsets.symmetric(
                                          vertical: 0.01 * w,
                                          horizontal: 0.01 * w),
                                      child: Row(
                                        children: [
                                          const SizedBox(
                                            width: 10,
                                          ),
                                          filterMap[index]['name']
                                                      .toString()
                                                      .toLowerCase()
                                                      .contains('percentage') ||
                                                  filterMap[index]['name']
                                                      .toString()
                                                      .toLowerCase()
                                                      .contains('number')
                                              ? const SizedBox(
                                                  height: 27,
                                                )
                                              : Image.asset(
                                                  filterMap[index]['image'],
                                                  width: 27,
                                                  height: 27,
                                                  color: Colors.grey.shade700,
                                                ),
                                          const SizedBox(
                                            width: 5,
                                          ),
                                          Text(
                                            filterMap[index]['name'],
                                            style: TextStyle(
                                                fontFamily:
                                                    'Chn Prop Arial Norman',
                                                fontSize: 0.055 * w,
                                                color: Colors.black,
                                                fontWeight: FontWeight.w500,
                                                wordSpacing: 2),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  filterMap[index]['name']
                                          .toString()
                                          .toLowerCase()
                                          .contains('brands')
                                      ? Padding(
                                          padding: const EdgeInsets.all(4.0),
                                          child: Wrap(
                                            spacing: 2,
                                            alignment: WrapAlignment.start,
                                            children: List.generate(
                                                filterMap[index]
                                                        ['specificationoptions']
                                                    .length,
                                                (index1) => Padding(
                                                      padding: const EdgeInsets
                                                          .symmetric(
                                                          vertical: 8.0,
                                                          horizontal: 10),
                                                      child: GestureDetector(
                                                        onTap: () {
                                                          _showBrands(
                                                            brandData: filterMap[
                                                                        index][
                                                                    'specificationoptions']
                                                                [
                                                                index1]['brands'],
                                                            editingController:
                                                                editingController,
                                                            context: context,
                                                          );
                                                        },
                                                        child: Container(
                                                          decoration: BoxDecoration(
                                                              color:
                                                                  Colors.blue,
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          25)),
                                                          width: .23 * w,
                                                          child: Center(
                                                            child: Padding(
                                                              padding:
                                                                  const EdgeInsets
                                                                      .symmetric(
                                                                      vertical:
                                                                          8.0),
                                                              child: Text(
                                                                filterMap[index]
                                                                            [
                                                                            'specificationoptions']
                                                                        [index1]
                                                                    ['name'],
                                                                style: const TextStyle(
                                                                    fontFamily:
                                                                        'Chn Prop Arial Norman',
                                                                    fontSize:
                                                                        18,
                                                                    color: Colors
                                                                        .white,
                                                                    wordSpacing:
                                                                        2),
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    )),
                                          ),
                                        )
                                      : filterMap[index]['name']
                                              .toString()
                                              .toLowerCase()
                                              .contains('percentage preset')
                                          ? Wrap(
                                              children: List.generate(
                                                filterMap[index]
                                                        ['specificationoptions']
                                                    .length,
                                                (index2) => Padding(
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                      horizontal: 4.0),
                                                  child: Column(
                                                    children: [
                                                      SizedBox(
                                                        height: 57,
                                                        // decoration:
                                                        //     const BoxDecoration(
                                                        //   border: Border(
                                                        //     bottom: BorderSide(
                                                        //       color: Colors.grey,
                                                        //     ),
                                                        //   ),
                                                        // ),
                                                        child: ListTile(
                                                          // subtitle:
                                                          trailing:
                                                              Transform.scale(
                                                            scale: 1.3,
                                                            child: Checkbox(
                                                              value: index2 ==
                                                                  activeIndexForPercent,
                                                              shape:
                                                                  const CircleBorder(),
                                                              onChanged: (val) {
                                                                setState(() {
                                                                  activeIndexForPercent =
                                                                      index2;
                                                                  percentageString =
                                                                      filterMap[index]['specificationoptions']
                                                                              [
                                                                              index2]
                                                                          [
                                                                          'name'];
                                                                });
                                                              },
                                                            ),
                                                          ),
                                                          title: AutoSizeText(
                                                            filterMap[index][
                                                                    'specificationoptions']
                                                                [
                                                                index2]['name'],
                                                            style: TextStyle(
                                                                fontFamily:
                                                                    'Chn Prop Arial Norman',
                                                                fontSize: 18,
                                                                color: Colors
                                                                    .grey
                                                                    .shade600,
                                                                wordSpacing: 2),
                                                          ),
                                                        ),
                                                      ),
                                                      Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .symmetric(
                                                                horizontal:
                                                                    16.0),
                                                        child: SizedBox(
                                                          width: w,
                                                          child: Divider(
                                                            height: 3,
                                                            color: Colors.grey
                                                                .withOpacity(
                                                                    .4),
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            )
                                          : filterMap[index]['name']
                                                  .toString()
                                                  .toLowerCase()
                                                  .contains('rotate')
                                              ? ListTile(
                                                  dense: false,
                                                  shape: Border.all(
                                                      color: Colors.white),
                                                  visualDensity:
                                                      VisualDensity.standard,
                                                  onTap: () {
                                                    setState(() {
                                                      isRotationEnable =
                                                          !isRotationEnable;
                                                    });
                                                  },
                                                  leading: Image.asset(
                                                    filterMap[index]['image'],
                                                    width: 27,
                                                    height: 27,
                                                    color: Colors.grey.shade600,
                                                  ),
                                                  title: Text(
                                                    filterMap[index]['name'],
                                                    style: TextStyle(
                                                        fontFamily:
                                                            'Chn Prop Arial Norman',
                                                        fontSize: 0.06 * w,
                                                        color: Colors.black,
                                                        fontWeight:
                                                            FontWeight.w500,
                                                        wordSpacing: 2),
                                                  ),
                                                  trailing: CupertinoSwitch(
                                                    value: isRotationEnable,
                                                    activeColor: Colors.blue,
                                                    onChanged: (value) {
                                                      setState(() {
                                                        isRotationEnable =
                                                            value;
                                                      });
                                                    },
                                                  ),
                                                )
                                              : filterMap[index]['name']
                                                      .toString()
                                                      .toLowerCase()
                                                      .contains('number')
                                                  ? Padding(
                                                      padding: const EdgeInsets
                                                          .symmetric(
                                                          horizontal: 8.0),
                                                      child: Wrap(
                                                        children: List.generate(
                                                            filterMap[index][
                                                                    'specificationoptions']
                                                                .length,
                                                            (index26) =>
                                                                GestureDetector(
                                                                  onTap: () {
                                                                    setState(
                                                                        () {
                                                                      numberOfProductString =
                                                                          filterMap[index]['specificationoptions'][index26]
                                                                              [
                                                                              'name'];
                                                                      activeIndexForNumberOfProducts =
                                                                          index26;
                                                                    });
                                                                  },
                                                                  child:
                                                                      SizedBox(
                                                                    width:
                                                                        0.3 * w,
                                                                    child: Row(
                                                                      mainAxisSize:
                                                                          MainAxisSize
                                                                              .max,
                                                                      mainAxisAlignment:
                                                                          MainAxisAlignment
                                                                              .start,
                                                                      children: [
                                                                        Transform
                                                                            .scale(
                                                                          scale:
                                                                              1.3,
                                                                          child: Checkbox(
                                                                              value: index26 == activeIndexForNumberOfProducts,
                                                                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                                                              onChanged: (val) {
                                                                                setState(() {
                                                                                  numberOfProductString = filterMap[index]['specificationoptions'][index26]['name'];
                                                                                  activeIndexForNumberOfProducts = index26;
                                                                                });
                                                                              }),
                                                                        ),
                                                                        Flexible(
                                                                          child:
                                                                              AutoSizeText(
                                                                            filterMap[index]['specificationoptions'][index26]['name'],
                                                                            style: TextStyle(
                                                                                fontFamily: 'Chn Prop Arial Norman',
                                                                                fontSize: 18,
                                                                                color: Colors.grey.shade600,
                                                                                wordSpacing: 2),
                                                                          ),
                                                                        )
                                                                      ],
                                                                    ),
                                                                  ),
                                                                )),
                                                      ),
                                                    )
                                                  : Wrap(
                                                      children: List.generate(
                                                          filterMap[index][
                                                                  'specificationoptions']
                                                              .length,
                                                          (index2) => Padding(
                                                                padding: const EdgeInsets
                                                                    .symmetric(
                                                                    horizontal:
                                                                        4.0),
                                                                child: Column(
                                                                  children: [
                                                                    SizedBox(
                                                                      height:
                                                                          57,
                                                                      // decoration:
                                                                      //     const BoxDecoration(
                                                                      //   border: Border(
                                                                      //     bottom: BorderSide(
                                                                      //       color: Colors.grey,
                                                                      //     ),
                                                                      //   ),
                                                                      // ),
                                                                      child:
                                                                          ListTile(
                                                                        onTap:
                                                                            () {
                                                                          activeIndexForNotificationFrequency =
                                                                              index2;
                                                                          frequencyString =
                                                                              filterMap[index]['specificationoptions'][index2]['name'];
                                                                          setState(
                                                                              () {});
                                                                        },
                                                                        // subtitle:
                                                                        trailing:
                                                                            Transform.scale(
                                                                          scale:
                                                                              1.3,
                                                                          child:
                                                                              Checkbox(
                                                                            value:
                                                                                index2 == activeIndexForNotificationFrequency,
                                                                            shape:
                                                                                const CircleBorder(),
                                                                            onChanged:
                                                                                (val) {
                                                                              activeIndexForNotificationFrequency = index2;
                                                                              frequencyString = filterMap[index]['specificationoptions'][index2]['name'];
                                                                              setState(() {});
                                                                            },
                                                                          ),
                                                                        ),
                                                                        title:
                                                                            AutoSizeText(
                                                                          filterMap[index]['specificationoptions'][index2]
                                                                              [
                                                                              'name'],
                                                                          style: TextStyle(
                                                                              fontFamily: 'Chn Prop Arial Norman',
                                                                              fontSize: 18,
                                                                              color: Colors.grey.shade600,
                                                                              wordSpacing: 2),
                                                                        ),
                                                                      ),
                                                                    ),
                                                                    Padding(
                                                                      padding: const EdgeInsets
                                                                          .symmetric(
                                                                          horizontal:
                                                                              16.0),
                                                                      child:
                                                                          SizedBox(
                                                                        width:
                                                                            w,
                                                                        child:
                                                                            Divider(
                                                                          height:
                                                                              3,
                                                                          color: Colors
                                                                              .grey
                                                                              .withOpacity(.4),
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  ],
                                                                ),
                                                              )
                                                          // GestureDetector(
                                                          //   onTap: () {
                                                          //     activeIndexForNotificationFrequency =
                                                          //         index2;
                                                          //     frequencyString =
                                                          //         filterMap[index]['specificationoptions'][index2]
                                                          //             [
                                                          //             'name'];
                                                          //     setState(
                                                          //         () {});
                                                          //   },
                                                          //   child:
                                                          //       SizedBox(
                                                          //     width:
                                                          //         0.3 * w,
                                                          //     child: Row(
                                                          //       children: [
                                                          //         Checkbox(
                                                          //             value: index2 ==
                                                          //                 activeIndexForNotificationFrequency,
                                                          //             onChanged:
                                                          //                 (val) {
                                                          //               activeIndexForNotificationFrequency = index2;
                                                          //               frequencyString = filterMap[index]['specificationoptions'][index2]['name'];
                                                          //               setState(() {});
                                                          //             }),
                                                          //         Flexible(
                                                          //           child:
                                                          //               AutoSizeText(
                                                          //             filterMap[index]['specificationoptions'][index2]['name'],
                                                          //                 style:
                                                          //                 TextStyle(
                                                          //                     fontFamily: 'Chn Prop Arial Norman',
                                                          //                     fontSize: 18,
                                                          //                     color: Colors.grey.shade600,
                                                          //                     wordSpacing: 2
                                                          //                 ),
                                                          //           ),
                                                          //         )
                                                          //       ],
                                                          //     ),
                                                          //   ),
                                                          // ),
                                                          ),
                                                    ),
                                  filterMap[index]['name']
                                              .toString()
                                              .toLowerCase()
                                              .contains('percentage preset') ||
                                          filterMap[index]['name']
                                              .toString()
                                              .toLowerCase()
                                              .contains('frequency')
                                      ? const SizedBox()
                                      : Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 20.0),
                                          child: SizedBox(
                                            width: w,
                                            child: Divider(
                                              color:
                                                  Colors.grey.withOpacity(.3),
                                              height: 2,
                                            ),
                                          ),
                                        ),
                                  const SizedBox(
                                    height: 15,
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
              ),
              SizedBox(
                width: w,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                  ),
                  child: Center(
                    child: GestureDetector(
                      onTap: () async {
                        if (numberOfProductString.isEmpty ||
                            frequencyString.isEmpty ||
                            percentageString.isEmpty) {
                          Fluttertoast.showToast(
                              msg: 'Please select proper options');
                        } else {
                          Map<String, dynamic> map = {
                            'brands': 'No Data Selected yet',
                            'percentage preset': percentageString,
                            'number of products': numberOfProductString,
                            'notification frequency': frequencyString,
                            'rotation enable': isRotationEnable,
                          };

                          Navigator.pop(context, jsonEncode(map));
                        }
                      },
                      child: Card(
                        shape: ContinuousRectangleBorder(
                            borderRadius: BorderRadius.circular(40)),
                        color: Colors.lightBlueAccent,
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: .3 * w,
                            vertical: 0.04 * w,
                          ),
                          child: Text(
                            'Add'.toUpperCase(),
                            style: GoogleFonts.bitter(
                              fontSize: 0.06 * w,
                              wordSpacing: 2,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
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
      ),
    );
  }
}

void _showBrands(
    {required List<String> brandData,
    required BuildContext context,
    required TextEditingController editingController}) {
  showGeneralDialog(
    context: context,
    barrierDismissible: true,
    barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
    barrierColor: Colors.black45,
    transitionBuilder: (context, a1, a2, widget) {
      return Transform.scale(
        scale: a1.value,
        child: Opacity(
          opacity: a1.value,
          child:
              StatefulBuilder(builder: (dialogBoxContext, setStateInDialogBox) {
            return SafeArea(
              child: Material(
                child: Center(
                  child: Container(
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.height,
                    padding: const EdgeInsets.all(10),
                    color: Colors.white,
                    child: Column(
                      children: [
                        Row(
                          children: [
                            GestureDetector(
                              onTap: () {
                                Navigator.of(dialogBoxContext).pop();
                              },
                              child: const Padding(
                                padding: EdgeInsets.all(12.0),
                                child: Icon(Icons.keyboard_backspace),
                              ),
                            ),
                            Flexible(
                              child: Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 8.0),
                                child: TextFormField(
                                  maxLines: 1,
                                  maxLength: 25,
                                  onChanged: (value) {
                                    // setStatee(() {
                                    //   _searchList =
                                    //       filterSearchResults(
                                    //           value);
                                    // });
                                  },
                                  controller: editingController,
                                  decoration: const InputDecoration(
                                      labelText: "Search Brands",
                                      hintText: "Search Brands",
                                      counterText: '',
                                      prefixIcon: Icon(Icons.search),
                                      border: OutlineInputBorder(
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(5.0)))),
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: Text(
                                'Select All',
                                style: GoogleFonts.bitter(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                    fontSize: 17),
                              ),
                            ),
                          ],
                        ),
                        Expanded(
                            child: Scrollbar(
                          thumbVisibility: true,
                          thickness: 4,
                          child: SingleChildScrollView(
                            child: SizedBox(
                              width: w,
                              child: Wrap(
                                children: List.generate(
                                  brandData.length,
                                  (index3) => Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: SizedBox(
                                      width: 0.4 * w,
                                      child: Row(
                                        mainAxisSize: MainAxisSize.max,
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: [
                                          Checkbox(
                                              value: true,
                                              shape: const CircleBorder(),
                                              onChanged: (val) {}),
                                          Flexible(
                                            child: AutoSizeText(
                                              brandData[index3],
                                              style: GoogleFonts.bitter(
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.black),
                                            ),
                                          )
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        )),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }),
        ),
      );
    },
    transitionDuration: const Duration(milliseconds: 200),
    pageBuilder: (BuildContext context, Animation<double> animation,
        Animation<double> secondaryAnimation) {
      return const SizedBox();
    },
  ).whenComplete(() => editingController.clear());
}

import 'dart:developer';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:minsellprice/app.dart';
import 'package:minsellprice/bloc/all_brand_bloc/all_brand_bloc.dart';
import 'package:minsellprice/screens/brand_screen.dart';
import 'package:minsellprice/screens/widgets/sample_product_screen.dart';
import 'package:minsellprice/services/extra_functions.dart';
import 'package:minsellprice/size.dart';

import 'package:sqflite/sqflite.dart';

import 'widgets/cusotm_dialog_box_screen.dart';

class AiPriceEngineScreen extends StatefulWidget {
  final String date, vendorName;
  final int vendorId;

  final Database database;

  const AiPriceEngineScreen({
    super.key,
    required this.date,
    required this.vendorId,
    required this.vendorName,
    required this.database,
  });

  @override
  State<AiPriceEngineScreen> createState() => _AiPriceEngineScreenState();
}

class _AiPriceEngineScreenState extends State<AiPriceEngineScreen> {
  List<AllBrandModel> allItems = [];

  List<String> _selectedHistory = [];
  List<String> _selectedHistoryPlumbing = [];
  List<String> _selectedHistoryPvf = [];
  List<String> _selectedHistoryTools = [];
  List<String> _selectedHistoryOther = [];

  final _maxController = TextEditingController();
  final _minController = TextEditingController();
  final _atpController = TextEditingController();
  final _salesController = TextEditingController();
  final _ageController = TextEditingController();
  final _compController = TextEditingController();
  final _salesMinController = TextEditingController();
  final _salesMaxController = TextEditingController();
  final _materialController = TextEditingController();
  final _currentDiscountController = TextEditingController();
  final _firstMinController = TextEditingController();
  final _secMinController = TextEditingController();

  int _competitiveValue = 1;
  int _mapValue = 1;
  String _atpSign = '=';
  String _salesSign = '=';
  String _agesSign = '=';
  String _compSign = '=';

  String _currentSign = '=';

  String _diff1stLowestSign = '=';

  String _secondDiffSign = "=";

  bool _discountEnabled = false;

  @override
  void initState() {
    context.read<AllBrandBloc>().add(
          AllBrandLoadingEvent(
            date: widget.date,
            vendorId: widget.vendorId.toString(),
          ),
        );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: buildAppBar(
          title: 'Ai Price Engine',
          centerTitle: true,
          style: GoogleFonts.openSans(
            fontSize: w * .055,
            fontWeight: FontWeight.w500,
            color: Colors.black,
          ),
          context: context,
        ),
        body: BlocListener<AllBrandBloc, AllBrandState>(
          listener: (context, state) {
            if (state is AllBrandLoadedState) {
              log('data available');
              state.data.forEach((key, value) {
                try {
                  final lower1 =
                      quoteKeysAndStrings((value)["lower more than 15%"]);
                  final lower2 = (value)["total_products"];
                  final lower3 = (value)["Image"];
                  final lower4 = (value)["key"];
                  final lower10 = (value)["brand_id"];
                  final lower5 = (value)["lower upto 5%"];
                  final lower6 = quoteKeysAndStrings((value)["higher upto 5%"]);
                  final lower7 =
                      quoteKeysAndStrings((value)["higher from 5% - 15%"]);
                  final lower9 =
                      quoteKeysAndStrings((value)["lower from 5% - 15%"]);
                  final lower8 =
                      quoteKeysAndStrings((value)["higher more than 15%"]);

                  final item = AllBrandModel(
                      lowerMoreThan15: HigherFrom515.fromJson(lower1),
                      totalProducts: lower2,
                      image: lower3,
                      key: lower4,
                      lowerFrom515: HigherFrom515.fromJson(lower9),
                      lowerUpto5: HigherFrom515.fromJson(lower5),
                      higherUpto5: HigherFrom515.fromJson(lower6),
                      higherFrom515: HigherFrom515.fromJson(lower7),
                      higherMoreThan15: HigherFrom515.fromJson(lower8),
                      brandId: lower10);
                  allItems.add(item);
                } catch (e) {
                  print(e);
                }
              });
            }
          },
          child: BlocBuilder<AllBrandBloc, AllBrandState>(
            builder: (context, state) {
              // var ;
              return state is AllBrandLoadingState
                  ? Center(
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
                    )
                  : state is AllBrandLoadedState
                      ? Padding(
                          padding: const EdgeInsets.all(6.0),
                          child: ListView(
                            shrinkWrap: true,
                            children: [
                              /*Brand Widgets*/
                              labelWidget(
                                label: 'Select Brand',
                              ),
                              verticalSpace(verticalSpace: 10),
                              Wrap(
                                children: [
                                  GestureDetector(
                                    onTap: () {
                                      // isElevated = !isElevated;
                                      showDialog(
                                        context: context,
                                        builder: (BuildContext context) {
                                          return CustomDialogBoxScreen(
                                            allBrands: allItems,
                                            selectedHistory: _selectedHistory,
                                            onChoiceSelection:
                                                (List<String> value) {
                                              print(value);
                                              setState(() {
                                                _selectedHistory = value;
                                              });
                                            },
                                            labelName: 'Heating',
                                          );
                                        },
                                      );
                                    },
                                    child: Padding(
                                      padding: const EdgeInsets.all(4.0),
                                      child: _selectedHistory.isNotEmpty
                                          ? Badge(
                                              label: Text(_selectedHistory
                                                  .length
                                                  .toString()),
                                              child: AnimatedContainer(
                                                duration: const Duration(
                                                  milliseconds: 200,
                                                ),
                                                height: w * .1,
                                                width: w * .3,
                                                decoration: BoxDecoration(
                                                  color: Colors.grey[300],
                                                  // shape: BoxShape.circle,
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                  // when _isElevated is false, value
                                                  // of inset parameter will be true
                                                  // that will create depth effect.
                                                  boxShadow: const [
                                                    BoxShadow(
                                                      color: Color(0xFFBEBEBE),
                                                      // Shadow for bottom right corner
                                                      offset: Offset(5, 5),
                                                      blurRadius: 30,
                                                      spreadRadius: 1,
                                                    ),
                                                    BoxShadow(
                                                      color: Colors.white,
                                                      // Shadow for top left corner
                                                      offset: Offset(-5, -5),
                                                      blurRadius: 30,
                                                      spreadRadius: 1,
                                                    ),
                                                  ],
                                                ),
                                                child: const Center(
                                                  child:
                                                      AutoSizeText('Heating'),
                                                ),
                                              ),
                                            )
                                          : AnimatedContainer(
                                              duration: const Duration(
                                                milliseconds: 200,
                                              ),
                                              height: w * .1,
                                              width: w * .3,
                                              decoration: BoxDecoration(
                                                color: Colors.grey[300],
                                                // shape: BoxShape.circle,
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                                // when _isElevated is false, value
                                                // of inset parameter will be true
                                                // that will create depth effect.
                                                boxShadow: const [
                                                  BoxShadow(
                                                    color: Color(0xFFBEBEBE),
                                                    // Shadow for bottom right corner
                                                    offset: Offset(5, 5),
                                                    blurRadius: 30,
                                                    spreadRadius: 1,
                                                  ),
                                                  BoxShadow(
                                                    color: Colors.white,
                                                    // Shadow for top left corner
                                                    offset: Offset(-5, -5),
                                                    blurRadius: 30,
                                                    spreadRadius: 1,
                                                  ),
                                                ],
                                              ),
                                              child: const Center(
                                                child: AutoSizeText('Heating'),
                                              ),
                                            ),
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: () {
                                      // isElevated = !isElevated;
                                      showDialog(
                                        context: context,
                                        builder: (BuildContext context) {
                                          return CustomDialogBoxScreen(
                                            allBrands: allItems,
                                            selectedHistory:
                                                _selectedHistoryPlumbing,
                                            onChoiceSelection:
                                                (List<String> value) {
                                              print(value);
                                              setState(() {
                                                _selectedHistoryPlumbing =
                                                    value;
                                              });
                                            },
                                            labelName: 'Plumbing',
                                          );
                                        },
                                      );
                                    },
                                    child: Padding(
                                      padding: const EdgeInsets.all(4.0),
                                      child: _selectedHistoryPlumbing.isNotEmpty
                                          ? Badge(
                                              label: Text(
                                                  _selectedHistoryPlumbing
                                                      .length
                                                      .toString()),
                                              child: AnimatedContainer(
                                                duration: const Duration(
                                                  milliseconds: 200,
                                                ),
                                                height: w * .1,
                                                width: w * .3,
                                                decoration: BoxDecoration(
                                                  color: Colors.grey[300],
                                                  // shape: BoxShape.circle,
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                  // when _isElevated is false, value
                                                  // of inset parameter will be true
                                                  // that will create depth effect.
                                                  boxShadow: const [
                                                    BoxShadow(
                                                      color: Color(0xFFBEBEBE),
                                                      // Shadow for bottom right corner
                                                      offset: Offset(5, 5),
                                                      blurRadius: 30,
                                                      spreadRadius: 1,
                                                    ),
                                                    BoxShadow(
                                                      color: Colors.white,
                                                      // Shadow for top left corner
                                                      offset: Offset(-5, -5),
                                                      blurRadius: 30,
                                                      spreadRadius: 1,
                                                    ),
                                                  ],
                                                ),
                                                child: const Center(
                                                  child:
                                                      AutoSizeText('Plumbing'),
                                                ),
                                              ),
                                            )
                                          : AnimatedContainer(
                                              duration: const Duration(
                                                milliseconds: 200,
                                              ),
                                              height: w * .1,
                                              width: w * .3,
                                              decoration: BoxDecoration(
                                                color: Colors.grey[300],
                                                // shape: BoxShape.circle,
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                                // when _isElevated is false, value
                                                // of inset parameter will be true
                                                // that will create depth effect.
                                                boxShadow: const [
                                                  BoxShadow(
                                                    color: Color(0xFFBEBEBE),
                                                    // Shadow for bottom right corner
                                                    offset: Offset(5, 5),
                                                    blurRadius: 30,
                                                    spreadRadius: 1,
                                                  ),
                                                  BoxShadow(
                                                    color: Colors.white,
                                                    // Shadow for top left corner
                                                    offset: Offset(-5, -5),
                                                    blurRadius: 30,
                                                    spreadRadius: 1,
                                                  ),
                                                ],
                                              ),
                                              child: const Center(
                                                child: AutoSizeText('Plumbing'),
                                              ),
                                            ),
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: () {
                                      // isElevated = !isElevated;
                                      showDialog(
                                        context: context,
                                        builder: (BuildContext context) {
                                          return CustomDialogBoxScreen(
                                            allBrands: allItems,
                                            selectedHistory:
                                                _selectedHistoryPvf,
                                            onChoiceSelection:
                                                (List<String> value) {
                                              print(value);
                                              setState(() {
                                                _selectedHistoryPvf = value;
                                              });
                                            },
                                            labelName: 'PVF',
                                          );
                                        },
                                      );
                                    },
                                    child: Padding(
                                      padding: const EdgeInsets.all(4.0),
                                      child: _selectedHistoryPvf.isNotEmpty
                                          ? Badge(
                                              label: Text(_selectedHistoryPvf
                                                  .length
                                                  .toString()),
                                              child: AnimatedContainer(
                                                duration: const Duration(
                                                  milliseconds: 200,
                                                ),
                                                height: w * .1,
                                                width: w * .3,
                                                decoration: BoxDecoration(
                                                  color: Colors.grey[300],
                                                  // shape: BoxShape.circle,
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                  // when _isElevated is false, value
                                                  // of inset parameter will be true
                                                  // that will create depth effect.
                                                  boxShadow: const [
                                                    BoxShadow(
                                                      color: Color(0xFFBEBEBE),
                                                      // Shadow for bottom right corner
                                                      offset: Offset(5, 5),
                                                      blurRadius: 30,
                                                      spreadRadius: 1,
                                                    ),
                                                    BoxShadow(
                                                      color: Colors.white,
                                                      // Shadow for top left corner
                                                      offset: Offset(-5, -5),
                                                      blurRadius: 30,
                                                      spreadRadius: 1,
                                                    ),
                                                  ],
                                                ),
                                                child: const Center(
                                                  child: AutoSizeText('PVF'),
                                                ),
                                              ),
                                            )
                                          : AnimatedContainer(
                                              duration: const Duration(
                                                milliseconds: 200,
                                              ),
                                              height: w * .1,
                                              width: w * .3,
                                              decoration: BoxDecoration(
                                                color: Colors.grey[300],
                                                // shape: BoxShape.circle,
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                                // when _isElevated is false, value
                                                // of inset parameter will be true
                                                // that will create depth effect.
                                                boxShadow: const [
                                                  BoxShadow(
                                                    color: Color(0xFFBEBEBE),
                                                    // Shadow for bottom right corner
                                                    offset: Offset(5, 5),
                                                    blurRadius: 30,
                                                    spreadRadius: 1,
                                                  ),
                                                  BoxShadow(
                                                    color: Colors.white,
                                                    // Shadow for top left corner
                                                    offset: Offset(-5, -5),
                                                    blurRadius: 30,
                                                    spreadRadius: 1,
                                                  ),
                                                ],
                                              ),
                                              child: const Center(
                                                child: AutoSizeText('PVF'),
                                              ),
                                            ),
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: () {
                                      // isElevated = !isElevated;
                                      showDialog(
                                        context: context,
                                        builder: (BuildContext context) {
                                          return CustomDialogBoxScreen(
                                            allBrands: allItems,
                                            selectedHistory:
                                                _selectedHistoryTools,
                                            onChoiceSelection:
                                                (List<String> value) {
                                              print(value);
                                              setState(() {
                                                _selectedHistoryTools = value;
                                              });
                                            },
                                            labelName: 'Heating',
                                          );
                                        },
                                      );
                                    },
                                    child: Padding(
                                      padding: const EdgeInsets.all(4.0),
                                      child: _selectedHistoryTools.isNotEmpty
                                          ? Badge(
                                              label: Text(_selectedHistoryTools
                                                  .length
                                                  .toString()),
                                              child: AnimatedContainer(
                                                duration: const Duration(
                                                  milliseconds: 200,
                                                ),
                                                height: w * .1,
                                                width: w * .3,
                                                decoration: BoxDecoration(
                                                  color: Colors.grey[300],
                                                  // shape: BoxShape.circle,
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                  // when _isElevated is false, value
                                                  // of inset parameter will be true
                                                  // that will create depth effect.
                                                  boxShadow: const [
                                                    BoxShadow(
                                                      color: Color(0xFFBEBEBE),
                                                      // Shadow for bottom right corner
                                                      offset: Offset(5, 5),
                                                      blurRadius: 30,
                                                      spreadRadius: 1,
                                                    ),
                                                    BoxShadow(
                                                      color: Colors.white,
                                                      // Shadow for top left corner
                                                      offset: Offset(-5, -5),
                                                      blurRadius: 30,
                                                      spreadRadius: 1,
                                                    ),
                                                  ],
                                                ),
                                                child: const Center(
                                                  child: AutoSizeText('Tools'),
                                                ),
                                              ),
                                            )
                                          : AnimatedContainer(
                                              duration: const Duration(
                                                milliseconds: 200,
                                              ),
                                              height: w * .1,
                                              width: w * .3,
                                              decoration: BoxDecoration(
                                                color: Colors.grey[300],
                                                // shape: BoxShape.circle,
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                                // when _isElevated is false, value
                                                // of inset parameter will be true
                                                // that will create depth effect.
                                                boxShadow: const [
                                                  BoxShadow(
                                                    color: Color(0xFFBEBEBE),
                                                    // Shadow for bottom right corner
                                                    offset: Offset(5, 5),
                                                    blurRadius: 30,
                                                    spreadRadius: 1,
                                                  ),
                                                  BoxShadow(
                                                    color: Colors.white,
                                                    // Shadow for top left corner
                                                    offset: Offset(-5, -5),
                                                    blurRadius: 30,
                                                    spreadRadius: 1,
                                                  ),
                                                ],
                                              ),
                                              child: const Center(
                                                child: AutoSizeText('Tools'),
                                              ),
                                            ),
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: () {
                                      // isElevated = !isElevated;
                                      showDialog(
                                        context: context,
                                        builder: (BuildContext context) {
                                          return CustomDialogBoxScreen(
                                            allBrands: allItems,
                                            selectedHistory:
                                                _selectedHistoryOther,
                                            onChoiceSelection:
                                                (List<String> value) {
                                              print(value);
                                              setState(() {
                                                _selectedHistoryOther = value;
                                              });
                                            },
                                            labelName: 'Others',
                                          );
                                        },
                                      );
                                    },
                                    child: Padding(
                                      padding: const EdgeInsets.all(4.0),
                                      child: _selectedHistoryOther.isNotEmpty
                                          ? Badge(
                                              label: Text(_selectedHistoryOther
                                                  .length
                                                  .toString()),
                                              child: AnimatedContainer(
                                                duration: const Duration(
                                                  milliseconds: 200,
                                                ),
                                                height: w * .1,
                                                width: w * .3,
                                                decoration: BoxDecoration(
                                                  color: Colors.grey[300],
                                                  // shape: BoxShape.circle,
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                  // when _isElevated is false, value
                                                  // of inset parameter will be true
                                                  // that will create depth effect.
                                                  boxShadow: const [
                                                    BoxShadow(
                                                      color: Color(0xFFBEBEBE),
                                                      // Shadow for bottom right corner
                                                      offset: Offset(5, 5),
                                                      blurRadius: 30,
                                                      spreadRadius: 1,
                                                    ),
                                                    BoxShadow(
                                                      color: Colors.white,
                                                      // Shadow for top left corner
                                                      offset: Offset(-5, -5),
                                                      blurRadius: 30,
                                                      spreadRadius: 1,
                                                    ),
                                                  ],
                                                ),
                                                child: const Center(
                                                  child: AutoSizeText('Others'),
                                                ),
                                              ),
                                            )
                                          : AnimatedContainer(
                                              duration: const Duration(
                                                milliseconds: 200,
                                              ),
                                              height: w * .1,
                                              width: w * .3,
                                              decoration: BoxDecoration(
                                                color: Colors.grey[300],
                                                // shape: BoxShape.circle,
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                                // when _isElevated is false, value
                                                // of inset parameter will be true
                                                // that will create depth effect.
                                                boxShadow: const [
                                                  BoxShadow(
                                                    color: Color(0xFFBEBEBE),
                                                    // Shadow for bottom right corner
                                                    offset: Offset(5, 5),
                                                    blurRadius: 30,
                                                    spreadRadius: 1,
                                                  ),
                                                  BoxShadow(
                                                    color: Colors.white,
                                                    // Shadow for top left corner
                                                    offset: Offset(-5, -5),
                                                    blurRadius: 30,
                                                    spreadRadius: 1,
                                                  ),
                                                ],
                                              ),
                                              child: const Center(
                                                child: AutoSizeText('Others'),
                                              ),
                                            ),
                                    ),
                                  ),
                                ],
                              ),
                              /*Brand Widgets Ends*/
                              verticalSpace(verticalSpace: 10),
                              /*Price Widgets*/
                              Row(
                                children: [
                                  Flexible(
                                    fit: FlexFit.tight,
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.all(2.0),
                                          child: labelWidget(
                                            label: 'Maximum Price',
                                            fontSize: w * .045,
                                          ),
                                        ),
                                        verticalSpace(verticalSpace: 5),
                                        Padding(
                                          padding: const EdgeInsets.only(
                                              bottom: 4.0),
                                          child: TextFormField(
                                            controller: _maxController,
                                            textAlign: TextAlign.start,
                                            keyboardType: TextInputType.number,
                                            textAlignVertical:
                                                TextAlignVertical.center,
                                            inputFormatters: <TextInputFormatter>[
                                              FilteringTextInputFormatter
                                                  .digitsOnly
                                            ],
                                            enableInteractiveSelection: false,
                                            decoration: InputDecoration(
                                              // enableInteractiveSelection: false,
                                              floatingLabelBehavior:
                                                  FloatingLabelBehavior.always,
                                              hintText: "Enter Maximum Price",
                                              label: const SizedBox(),
                                              enabledBorder: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(
                                                  10,
                                                ),
                                              ),
                                              border: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(
                                                  15,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  horizontalSpace(horizontalSpace: w * .04),
                                  Flexible(
                                    fit: FlexFit.tight,
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.all(2.0),
                                          child: labelWidget(
                                            label: 'Minimum Price',
                                            fontSize: w * .045,
                                          ),
                                        ),
                                        verticalSpace(verticalSpace: 5),
                                        SizedBox(
                                          height: 75,
                                          child: Center(
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.all(4.0),
                                              child: TextFormField(
                                                controller: _minController,
                                                textAlign: TextAlign.start,
                                                keyboardType:
                                                    TextInputType.number,
                                                textAlignVertical:
                                                    TextAlignVertical.center,
                                                inputFormatters: <TextInputFormatter>[
                                                  FilteringTextInputFormatter
                                                      .digitsOnly
                                                ],
                                                enableInteractiveSelection:
                                                    false,
                                                decoration: InputDecoration(
                                                  // enableInteractiveSelection: false,
                                                  floatingLabelBehavior:
                                                      FloatingLabelBehavior
                                                          .always,
                                                  hintText:
                                                      "Enter Minimum Price",
                                                  label: const SizedBox(),
                                                  enabledBorder:
                                                      OutlineInputBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                      10,
                                                    ),
                                                  ),
                                                  border: OutlineInputBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                      15,
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
                                ],
                              ),
                              /*Price Widgets Ends*/
                              verticalSpace(verticalSpace: 10),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.all(2.0),
                                        child: labelWidget(
                                          label: 'ATP',
                                          fontSize: w * .05,
                                        ),
                                      ),
                                      verticalSpace(verticalSpace: 5),
                                      CustomDropdown(
                                        onOptionSelect: (String value) {
                                          print(value);
                                          _atpSign = value;
                                          setState(() {});
                                        },
                                        onEditTextField: (String value) {
                                          setState(() {
                                            _atpController.text = value;
                                          });
                                        },
                                        controller: _atpController,
                                        length: 6,
                                      ),
                                    ],
                                  ),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.all(2.0),
                                        child: labelWidget(
                                          label: 'Sales',
                                          fontSize: w * .05,
                                        ),
                                      ),
                                      verticalSpace(verticalSpace: 5),
                                      CustomDropdown(
                                        onOptionSelect: (String value) {
                                          setState(() {
                                            _salesSign = value;
                                          });
                                        },
                                        onEditTextField: (String value) {
                                          setState(() {
                                            _salesController.text = value;
                                          });
                                        },
                                        controller: _salesController,
                                        length: 6,
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              /*ATP Widgets */
                              verticalSpace(verticalSpace: 15),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  labelWidget(
                                    label: 'Sales ATP Ratio',
                                    fontSize: w * .05,
                                  ),
                                  Row(
                                    children: [
                                      Flexible(
                                        child: SizedBox(
                                          width: w * .45,
                                          child: TextFormField(
                                            controller: _salesMinController,
                                            textAlign: TextAlign.start,
                                            keyboardType: TextInputType.number,
                                            textAlignVertical:
                                                TextAlignVertical.center,
                                            inputFormatters: <TextInputFormatter>[
                                              FilteringTextInputFormatter
                                                  .digitsOnly
                                            ],
                                            enableInteractiveSelection: false,
                                            decoration: InputDecoration(
                                              // enableInteractiveSelection: false,
                                              floatingLabelBehavior:
                                                  FloatingLabelBehavior.always,
                                              hintText: "From",
                                              label: const SizedBox(),
                                              enabledBorder: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(
                                                  10,
                                                ),
                                              ),
                                              border: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(
                                                  15,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                      horizontalSpace(horizontalSpace: 20),
                                      Flexible(
                                        child: SizedBox(
                                          width: w * .45,
                                          child: TextFormField(
                                            controller: _salesMaxController,
                                            textAlign: TextAlign.start,
                                            keyboardType: TextInputType.number,
                                            textAlignVertical:
                                                TextAlignVertical.center,
                                            inputFormatters: <TextInputFormatter>[
                                              FilteringTextInputFormatter
                                                  .digitsOnly
                                            ],
                                            enableInteractiveSelection: false,
                                            decoration: InputDecoration(
                                              // enableInteractiveSelection: false,
                                              floatingLabelBehavior:
                                                  FloatingLabelBehavior.always,
                                              hintText: "To",
                                              label: const SizedBox(),
                                              enabledBorder: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(
                                                  10,
                                                ),
                                              ),
                                              border: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(
                                                  15,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  )
                                ],
                              ),
                              /*ATP Widgets Ends*/
                              verticalSpace(verticalSpace: 10),
                              /*Radio Button Widget Here*/
                              labelWidget(label: 'Competitive Product'),
                              CustomRadioButton(
                                buttonLabelNames: const [
                                  'On Analysis',
                                  'Not On Analysis'
                                ],
                                onTapCallback: (value) {
                                  setState(() {
                                    _competitiveValue = value;
                                  });
                                },
                              ),
                              verticalSpace(verticalSpace: 10),
                              labelWidget(label: 'MAP'),
                              CustomRadioButton(
                                buttonLabelNames: const [
                                  'Map Price',
                                  'Non Map Price'
                                ],
                                onTapCallback: (value) {
                                  setState(() {
                                    _mapValue = value;
                                  });
                                },
                              ),
                              verticalSpace(verticalSpace: 10),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.all(2.0),
                                        child: labelWidget(
                                          label: 'Ages in Days',
                                          fontSize: w * .05,
                                        ),
                                      ),
                                      verticalSpace(verticalSpace: 5),
                                      CustomDropdown(
                                        onOptionSelect: (String value) {
                                          setState(() {
                                            _agesSign = value;
                                          });
                                        },
                                        onEditTextField: (String value) {
                                          setState(() {
                                            _ageController.text = value;
                                          });
                                        },
                                        controller: _ageController,
                                        length: 6,
                                      ),
                                    ],
                                  ),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.all(2.0),
                                        child: labelWidget(
                                          label: 'Competitor',
                                          fontSize: w * .05,
                                        ),
                                      ),
                                      verticalSpace(verticalSpace: 5),
                                      CustomDropdown(
                                        onOptionSelect: (String value) {
                                          setState(() {
                                            _compSign = value;
                                          });
                                        },
                                        onEditTextField: (String value) {
                                          setState(() {
                                            _compController.text = value;
                                          });
                                        },
                                        controller: _compController,
                                        length: 6,
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              verticalSpace(verticalSpace: 10),
                              labelWidget(
                                label: 'Material Group',
                              ),
                              TextFormField(
                                controller: _materialController,
                                enableInteractiveSelection: false,
                                textAlign: TextAlign.start,
                                // keyboardType: TextInputType.number,
                                textAlignVertical: TextAlignVertical.center,
                                decoration: InputDecoration(
                                  // enableInteractiveSelection: false,
                                  floatingLabelBehavior:
                                      FloatingLabelBehavior.always,
                                  hintText: "Enter Material Group",
                                  label: const SizedBox(),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(
                                      10,
                                    ),
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(
                                      15,
                                    ),
                                  ),
                                ),
                              ),
                              verticalSpace(verticalSpace: 10),
                              FittedBox(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.all(2.0),
                                          child: labelWidget(
                                            label: 'Current Discount',
                                            fontSize: w * .05,
                                          ),
                                        ),
                                        verticalSpace(verticalSpace: 5),
                                        CustomDropdown(
                                          onOptionSelect: (String value) {
                                            setState(() {
                                              _currentSign = value;
                                            });
                                          },
                                          onEditTextField: (String value) {
                                            setState(() {
                                              _currentDiscountController.text =
                                                  value;
                                            });
                                          },
                                          controller:
                                              _currentDiscountController,
                                          length: 5,
                                        ),
                                      ],
                                    ),
                                    horizontalSpace(horizontalSpace: 10),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 2.0),
                                          child: labelWidget(
                                            label: '% Diff from 1st Lowest',
                                            fontSize: w * .04,
                                          ),
                                        ),
                                        verticalSpace(verticalSpace: 5),
                                        CustomDropdown(
                                          length: 3,
                                          onOptionSelect: (String value) {
                                            setState(() {
                                              _diff1stLowestSign = value;
                                            });
                                          },
                                          onEditTextField: (String value) {
                                            setState(() {
                                              _firstMinController.text = value;
                                            });
                                          },
                                          controller: _firstMinController,
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              verticalSpace(verticalSpace: 10),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 8.0),
                                child: labelWidget(
                                    label: '% Diff from 2nd Lowest',
                                    fontSize: 18),
                              ),
                              Align(
                                alignment: Alignment.centerLeft,
                                child: CustomDropdown(
                                  onOptionSelect: (String value) {
                                    setState(() {
                                      _secondDiffSign = value;
                                    });
                                  },
                                  onEditTextField: (String value) {
                                    setState(() {
                                      _secMinController.text = value;
                                    });
                                  },
                                  controller: _secMinController,
                                  length: 3,
                                ),
                              ),
                              verticalSpace(
                                verticalSpace: 10,
                              ),
                              Card(
                                child: CheckboxListTile(
                                  value: _discountEnabled,
                                  onChanged: (bool? value) {
                                    setState(
                                      () {
                                        _discountEnabled = value!;
                                      },
                                    );
                                  },
                                  title: labelWidget(label: 'Discount Coupon'),
                                ),
                              ),
                              verticalSpace(
                                verticalSpace: 20,
                              ),
                              customButtonWidget(
                                buttonLabel: 'Submit',
                                color: Colors.blue,
                                fontColor: Colors.white,
                                onTapCallback: () {
                                  if (_selectedHistory.isEmpty &&
                                          _selectedHistoryPlumbing.isEmpty &&
                                          _selectedHistoryPvf.isEmpty &&
                                          _selectedHistoryTools.isEmpty &&
                                          _selectedHistoryOther.isEmpty &&
                                          _maxController.text.isEmpty &&
                                          _minController.text.isEmpty &&
                                          _atpController.text.isEmpty &&
                                          _salesMinController.text.isEmpty &&
                                          _salesMaxController.text.isEmpty &&
                                          _ageController.text.isEmpty &&
                                          _compController.text.isEmpty &&
                                          _materialController.text.isEmpty &&
                                          _currentDiscountController
                                              .text.isEmpty &&
                                          _firstMinController.text.isEmpty &&
                                          _secMinController.text.isEmpty
                                      // _aController.text.isEmpty &&

                                      ) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        showCloseIcon: true,
                                        behavior: SnackBarBehavior.floating,
                                        margin: EdgeInsets.only(
                                          left: 10,
                                          right: 10,
                                        ),
                                        dismissDirection: DismissDirection.none,
                                        content: Text(
                                            'Please enter at least one parameter value.'),
                                      ),
                                    );
                                  } else {
                                    List<int> brandIds =
                                        getBrandIds(allItems, _selectedHistory);
                                    List<int> brandIdsOfPlumbing = getBrandIds(
                                        allItems, _selectedHistoryPlumbing);
                                    List<int> brandIdsPvf = getBrandIds(
                                        allItems, _selectedHistoryPvf);
                                    List<int> brandIdsTools = getBrandIds(
                                        allItems, _selectedHistoryTools);
                                    List<int> brandIdsToolOthers = getBrandIds(
                                        allItems, _selectedHistoryOther);
                                    List<int> allIds = [
                                      ...brandIds,
                                      ...brandIdsToolOthers,
                                      ...brandIdsOfPlumbing,
                                      ...brandIdsPvf,
                                      ...brandIdsTools
                                    ];

                                    if (brandIds.isEmpty &&
                                        brandIdsTools.isEmpty &&
                                        brandIdsPvf.isEmpty &&
                                        brandIdsToolOthers.isEmpty &&
                                        brandIdsOfPlumbing.isEmpty) {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        const SnackBar(
                                          showCloseIcon: true,
                                          behavior: SnackBarBehavior.floating,
                                          margin: EdgeInsets.only(
                                            left: 10,
                                            right: 10,
                                          ),
                                          dismissDirection:
                                              DismissDirection.horizontal,
                                          content: Text(
                                              'Please select at least one brand.'),
                                        ),
                                      );
                                    } else {
                                      final Map<String, String> dataMap = {
                                        "brand_id": allIds.join(','),
                                        "minprice": _minController.text,
                                        "maxprice": _maxController.text,
                                        "signs": _atpSign,
                                        "atp_search": _atpController.text,
                                        "signs2": _salesSign,
                                        "sales_searchs": _salesController.text,
                                        "atp_from1": _salesMinController.text,
                                        "atp_to1": _salesMaxController.text,
                                        "competive[]":
                                            _competitiveValue.toString(),
                                        "mapping[]": _mapValue.toString(),
                                        "age_sign": _agesSign,
                                        "age_search": _ageController.text,
                                        "competitor_signs": _compSign,
                                        "competitor_search":
                                            _compController.text,
                                        "material_group":
                                            _materialController.text,
                                        "discount_signs": _currentSign,
                                        "discount_search":
                                            _currentDiscountController.text,
                                        "first_low_signs": _diff1stLowestSign,
                                        "first_low_search":
                                            _firstMinController.text,
                                        "second_low_signs": _secondDiffSign,
                                        "second_low_search":
                                            _secMinController.text,
                                        "brands_lowest_from": '',
                                        "brands_lowest_to": '',
                                        "discount-coupon":
                                            _discountEnabled == false
                                                ? ''
                                                : _discountEnabled.toString(),
                                      };
                                      print(dataMap);
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => ContentScreen(
                                            vendorName: '',
                                            vendorImage:
                                                '${AppInfo.kBaseUrl(stagingSelector: 1)}vendor-logo/${widget.vendorName}.jpg',
                                            vendorId:
                                                widget.vendorId.toString(),
                                            date: '',
                                            loadingData: '',
                                            database: widget.database,
                                            isVendorPriceAnalysis: false,
                                            isVendorTable: false,
                                            aiValue: dataMap,
                                          ),
                                        ),
                                      );
                                    }
                                  }
                                },
                              ),
                              verticalSpace(
                                verticalSpace: 20,
                              ),
                              customButtonWidget(
                                buttonLabel: 'Clear Filter',
                                color: Colors.orange,
                                onTapCallback: () {
                                  _selectedHistory.clear();
                                  _selectedHistoryPlumbing.clear();
                                  _selectedHistoryPvf.clear();
                                  _selectedHistoryTools.clear();
                                  _selectedHistoryOther.clear();
                                  _maxController.text = '';
                                  _minController.text = '';
                                  _atpController.text = '';
                                  _salesMinController.text = '';
                                  _salesMaxController.text = '';
                                  _ageController.text = '';
                                  _compController.text = '';
                                  _materialController.text = '';
                                  _currentDiscountController.text = '';
                                  _salesController.text = '';
                                  _firstMinController.text = '';
                                  _secMinController.text = '';
                                  setState(() {});
                                },
                              ),
                            ],
                          ),
                        )
                      : const Center(
                          child: Text("Error"),
                        );
            },
          ),
        ),
      ),
    );
  }

  Widget customButtonWidget(
      {required String buttonLabel,
      required Color color,
      required VoidCallback onTapCallback,
      Color? fontColor,
      double? fontSize}) {
    return GestureDetector(
      onTap: onTapCallback,
      child: Container(
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(15.0),
        ),
        width: w * .85,
        height: w * .2 - 15,
        child: Center(
          child: labelWidget(
            label: buttonLabel,
            fontColor: fontColor,
            fontSize: fontSize,
          ),
        ),
      ),
    );
  }
}

/*Widgets*/
AutoSizeText labelWidget(
    {required String label, double? fontSize, Color? fontColor}) {
  return AutoSizeText(
    label,
    style: GoogleFonts.montserrat(
        fontSize: fontSize ?? w * .05,
        fontWeight: FontWeight.w700,
        color: fontColor ?? Colors.black),
  );
}

AppBar buildAppBar(
    {required String title,
    List<Widget>? actions,
    required TextStyle style,
    required bool centerTitle,
    required BuildContext context}) {
  return AppBar(
    backgroundColor: Colors.white,
    leading: InkWell(
        onTap: () => Navigator.pop(context),
        child: const Icon(
          Icons.arrow_back,
          color: Colors.black,
        )),
    centerTitle: centerTitle,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    elevation: 4,
    title: Text(
      title,
      style: style,
    ),
  );
}

const List<String> brandsList = [
  'Heating',
  'Plumbing',
  'PVF',
  'Tools',
  'Others'
];

SizedBox horizontalSpace({required double horizontalSpace}) {
  return SizedBox(
    width: horizontalSpace,
  );
}

SizedBox verticalSpace({required double verticalSpace}) {
  return SizedBox(
    height: verticalSpace,
  );
}

class CustomDropdown extends StatefulWidget {
  const CustomDropdown({
    super.key,
    required this.onOptionSelect,
    required this.onEditTextField,
    required this.controller,
    required this.length,
  });

  final ValueChanged<String> onOptionSelect, onEditTextField;
  final TextEditingController controller;
  final int length;

  @override
  _CustomDropdownState createState() {
    return _CustomDropdownState();
  }
}

class _CustomDropdownState extends State<CustomDropdown> {
  // The current selected value of the dropdown menu
  String _dropdownValue = '=';

  // List of items in our dropdown menu
  List<String> items = [
    '=',
    '>',
    '>=',
    '<=',
    '<',
  ];

  @override
  void initState() {
    // TODO: implement initState
    // widget.onOptionSelect(_dropdownValue);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: w * .48,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Card(
            elevation: 3,
            child: SizedBox(
              width: w * .2,
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: DropdownButton(
                    underline: const SizedBox(),
                    // Initial Value
                    value: _dropdownValue,

                    // Down Arrow Icon
                    icon: const Icon(Icons.keyboard_arrow_down),

                    // Array list of items
                    items: items.map((String items) {
                      return DropdownMenuItem(
                        value: items,
                        child: Text(items),
                      );
                    }).toList(),
                    // After selecting the desired option,it will
                    // change button value to selected value
                    onChanged: (String? newValue) {
                      setState(() {
                        _dropdownValue = newValue!;
                      });
                      widget.onOptionSelect(_dropdownValue);
                    },
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(4.0),
            child: SizedBox(
              width: 80,
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.only(
                    left: 8.0,
                  ),
                  child: TextFormField(
                    maxLines: 1,
                    maxLength: widget.length,
                    controller: widget.controller,
                    textAlign: TextAlign.start,
                    keyboardType: TextInputType.number,
                    textAlignVertical: TextAlignVertical.center,
                    inputFormatters: <TextInputFormatter>[
                      FilteringTextInputFormatter.digitsOnly
                    ],
                    enableInteractiveSelection: false,
                    decoration: InputDecoration(
                      // enableInteractiveSelection: false,
                      floatingLabelBehavior: FloatingLabelBehavior.always,
                      hintText: "00",
                      hintStyle: GoogleFonts.openSans(color: Colors.grey),
                      counterText: '',
                      label: const SizedBox(),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(
                          10,
                        ),
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(
                          15,
                        ),
                      ),
                    ),
                    onSaved: (value) {
                      widget.onEditTextField(value!);
                    },
                    onFieldSubmitted: (value) {
                      widget.onEditTextField(value);
                    },
                    onChanged: (value) {
                      widget.onEditTextField(value);
                    },
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class CustomRadioButton extends StatefulWidget {
  final List<String> buttonLabelNames;
  final ValueChanged<int> onTapCallback;

  const CustomRadioButton({
    super.key,
    required this.buttonLabelNames,
    required this.onTapCallback,
  });

  @override
  State<CustomRadioButton> createState() => _CustomRadioButtonState();
}

class _CustomRadioButtonState extends State<CustomRadioButton> {
  int value = 0;

  Widget customRadioButton(String text, int index) {
    return OutlinedButton(
      onPressed: () {
        setState(() {
          value = index;
          widget.onTapCallback(index + 1);
        });
      },
      child: SizedBox(
        width: w * .6,
        child: Text(
          text,
          style: TextStyle(
            color: (value == index) ? Colors.green : Colors.black,
          ),
        ),
      ),
      // shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      // borderSide:
      // BorderSide(color: (value == index) ? Colors.green : Colors.black),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: List.generate(
        widget.buttonLabelNames.length,
        (index) => customRadioButton(
          widget.buttonLabelNames[index],
          index,
        ),
      ),
    );
  }
}

import 'dart:math';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:minsellprice/app.dart';
import 'package:minsellprice/screens/ai_price_engine/ai_pricie_engine_screen.dart';
import 'package:minsellprice/screens/brand_screen.dart';
import 'package:minsellprice/services/extra_functions.dart';
import 'package:minsellprice/size.dart';

class CustomDialogBoxScreen extends StatefulWidget {
  CustomDialogBoxScreen({
    super.key,
    required this.allBrands,
    required this.onChoiceSelection,
    required this.labelName,
    required this.selectedHistory,
  });

  final String labelName;

  final List<AllBrandModel> allBrands;
  List<String> selectedHistory;
  final ValueChanged<List<String>> onChoiceSelection;

  // final ValueChanged<List<bool>> onChoiceSelected;

  @override
  State<CustomDialogBoxScreen> createState() => _CustomDialogBoxScreenState();
}

class _CustomDialogBoxScreenState extends State<CustomDialogBoxScreen> {
  List<String> _choices = [];

  // List<bool> _selectedChoices = [];

  @override
  void initState() {
    // _selectedChoices = widget.selectedHistory;
    log(widget.selectedHistory.length);
    setState(() {
      temp = widget.selectedHistory;
    });
    _choices = List<String>.from(widget.allBrands.map((e) => e.key.toString()));
    searchItems = _choices;

    controller.addListener(queryListener);
    super.initState();
  }

  @override
  void dispose() {
    controller.removeListener(queryListener);
    controller.dispose();
    super.dispose();
  }

  List<String> searchItems = [];

  final SearchController controller = SearchController();

  void queryListener() {
    search(query: controller.text);
  }

  void search({required String query}) {
    setState(() {
      if (query.isEmpty) {
        searchItems = _choices;
      } else {
        searchItems = _choices
            .where(
              (element) =>
                  element.replaceAll('-', '').toString().toLowerCase().contains(
                        query.toLowerCase(),
                      ),
            )
            .toList();
      }
    });
  }

  List<String> temp = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            buildAppBar(
              centerTitle: false,
              title: 'Select Brand(s) (${widget.labelName})',
              style: GoogleFonts.openSans(
                  fontSize: w * .055,
                  fontWeight: FontWeight.w500,
                  color: Colors.black),
              context: context,
            ),
            verticalSpace(verticalSpace: 10),
            Padding(
              padding: const EdgeInsets.all(4.0),
              child: SearchBar(
                hintText: 'Search...',
                controller: controller,
                trailing: [
                  IconButton(
                    onPressed: queryListener,
                    icon: const Icon(Icons.search),
                  ),
                  InkWell(
                    onTap: () {
                      Fluttertoast.showToast(msg: 'Selecting All');
                      setState(() {
                        temp.isEmpty
                            ? temp = List.from(_choices.map((e) => e))
                            : temp.clear();
                        widget.onChoiceSelection(temp);
                      });
                    },
                    splashColor: Colors.blue,
                    child: Padding(
                      padding: const EdgeInsets.all(4.0),
                      child:
                          AutoSizeText(temp.isEmpty ? 'Select All' : 'Clear'),
                    ),
                  ),
                ],
              ),
            ),
            Flexible(
              child: Scrollbar(
                  thumbVisibility: true,
                  trackVisibility: true,
                  child: ListView.builder(
                    keyboardDismissBehavior:
                        ScrollViewKeyboardDismissBehavior.onDrag,
                    itemBuilder: (
                      context,
                      indexMain,
                    ) {
                      return Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: CheckboxListTile(
                          enabled: true,
                          title: Row(
                            children: [
                              CachedNetworkImage(
                                imageUrl:
                                    '${AppInfo.kBaseUrl(stagingSelector: 1)}brand-logo/brands/${searchItems[indexMain]}.png',
                                width: 45,
                                height: 35,
                              ),
                              horizontalSpace(horizontalSpace: 15),
                              Text(
                                capitalize(
                                  searchItems[indexMain].replaceAll('-', ' '),
                                ),
                                style: GoogleFonts.openSans(
                                    fontSize: 16, fontWeight: FontWeight.w500),
                              ),
                            ],
                          ),
                          visualDensity: VisualDensity.standard,
                          value: isItemPresentInOtherList(
                              indexMain, searchItems, temp),
                          onChanged: (value) {
                            setState(() {
                              // _selectedChoices[indexMain] = value!;
                              // widget.onChoiceSelected(_selectedChoices);
                              value == true
                                  ? temp.add(searchItems[indexMain])
                                  : temp.remove(searchItems[indexMain]);
                              widget.onChoiceSelection(temp);
                            });
                          },
                          dense: true,
                        ),
                      );
                    },
                    itemCount: searchItems.length,
                  )
                  // CustomScrollView(
                  //   slivers: [
                  //     SliverAnimatedList(
                  //       itemBuilder: (context, indexMain, animation) {
                  //         return Padding(
                  //           padding: const EdgeInsets.all(8.0),
                  //           child: CheckboxListTile(
                  //             enabled: true,
                  //             title: Row(
                  //               children: [
                  //                 CachedNetworkImage(
                  //                   imageUrl:
                  //                       '${AppInfo.kBaseUrl(stagingSelector: 1)}brand-logo/brands/${searchItems[indexMain]}.png',
                  //                   width: 45,
                  //                   height: 35,
                  //                 ),
                  //                 horizontalSpace(horizontalSpace: 15),
                  //                 Text(
                  //                   capitalize(
                  //                     searchItems[indexMain].replaceAll('-', ' '),
                  //                   ),
                  //                   style: GoogleFonts.openSans(
                  //                       fontSize: 16,
                  //                       fontWeight: FontWeight.w500),
                  //                 ),
                  //               ],
                  //             ),
                  //             visualDensity: VisualDensity.standard,
                  //             value: isItemPresentInOtherList(indexMain,searchItems,widget.selectedHistory),
                  //             onChanged: (value) {
                  //               setState(() {
                  //                 // _selectedChoices[indexMain] = value!;
                  //                 // widget.onChoiceSelected(_selectedChoices);
                  //                 value == true? temp.add(searchItems[indexMain]):temp.remove(searchItems[indexMain]);
                  //                 widget.onChoiceSelection(temp);
                  //
                  //               });
                  //             },
                  //             dense: true,
                  //           ),
                  //         );
                  //       },
                  //       initialItemCount: searchItems.length,
                  //     )
                  //   ],
                  // ),
                  ),
            )
          ],
        ),
      ),
    );
  }
}

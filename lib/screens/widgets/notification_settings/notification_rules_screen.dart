import 'dart:convert';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:minsellprice/screens/widgets/notification_settings/notification_screen_2.dart';
import 'package:minsellprice/size.dart';

class NotificationRulesScreen extends StatefulWidget {
  const NotificationRulesScreen({super.key});

  @override
  State<NotificationRulesScreen> createState() =>
      _NotificationRulesScreenState();
}

class _NotificationRulesScreenState extends State<NotificationRulesScreen> {
  final List<String> _rulesList = [];

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: CustomScrollView(
          slivers: [
            SliverAppBar(
              snap: false,
              backgroundColor: Colors.white,
              pinned: true,
              forceElevated: true,
              floating: false,
              expandedHeight: 50,
              leading: const Padding(
                padding: EdgeInsets.all(8.0),
                child: Icon(
                  Icons.keyboard_backspace,
                  color: Colors.black,
                ),
              ),
              leadingWidth: 0,
              actions: [
                GestureDetector(
                  onTap: () async {
                    String? dataInJsonString = await Navigator.push(
                        context,
                        CupertinoPageRoute(
                            builder: (context) =>
                                const NotificationSettingsScreen2()));
                    dataInJsonString != null
                        ? setState(() {
                            _rulesList.insert(0, dataInJsonString);
                          })
                        : null;
                  },
                  child: const Row(
                    children: [
                      Text(
                        'New Rule',
                        style: TextStyle(color: Colors.black),
                      ),
                      Padding(
                        padding: EdgeInsets.all(4.0),
                        child: Icon(
                          Icons.add,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                )
              ],
              flexibleSpace: FlexibleSpaceBar(
                centerTitle: true,
                title: AutoSizeText(
                  'Notification Rules',
                  style: GoogleFonts.montserrat(
                    fontSize: 0.045 * w,
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            SliverList(
              delegate: SliverChildBuilderDelegate(
                childCount: _rulesList.isEmpty ? 1 : _rulesList.length,
                (context, index) {
                  if (_rulesList.isEmpty) {
                    return SizedBox(
                      height: h - 100,
                      child: Align(
                        alignment: Alignment.center,
                        child: Text(
                          "No Rules!\nClick on \" New Rule + \" button",
                          textAlign: TextAlign.center,
                          style: GoogleFonts.aBeeZee(
                              color: Colors.black,
                              fontSize: 24,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    );
                  } else {
                    Map<String, dynamic> map = jsonDecode(_rulesList[index]);
                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Stack(
                        children: [
                          Card(
                            child: Column(
                              children: [
                                const SizedBox(
                                  height: 8,
                                ),
                                AutoSizeText(
                                  'Rule #${index + 1}'.toUpperCase(),
                                  style: GoogleFonts.aBeeZee(
                                    fontWeight: FontWeight.w900,
                                    fontSize: 20,
                                  ),
                                ),
                                const SizedBox(
                                  height: 8,
                                ),
                                ...List.generate(
                                  List<String>.from(
                                    map.keys.map(
                                      (e) => e,
                                    ),
                                  ).length,
                                  (index) => Row(
                                    mainAxisSize: MainAxisSize.max,
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      SizedBox(
                                        width: .44 * w,
                                        child: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: AutoSizeText(
                                            List<String>.from(
                                              map.keys.map(
                                                (e) => e,
                                              ),
                                            )[index]
                                                .toUpperCase(),
                                            style: GoogleFonts.aBeeZee(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16,
                                            ),
                                          ),
                                        ),
                                      ),
                                      SizedBox(
                                        width: .46 * w,
                                        child: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: List<String>.from(
                                            map.keys.map(
                                              (e) => e,
                                            ),
                                          )[index]
                                                  .toString()
                                                  .toLowerCase()
                                                  .contains('rotation')
                                              ? Padding(
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                    horizontal: 8.0,
                                                  ),
                                                  child: Align(
                                                      alignment:
                                                          Alignment.centerRight,
                                                      child: Image.asset(
                                                        List<String>.from(
                                                                  map.values
                                                                      .map(
                                                                    (e) => e
                                                                        .toString(),
                                                                  ),
                                                                )[index] ==
                                                                'false'
                                                            ? 'assets/images/off.png'
                                                            : 'assets/images/on.png',
                                                        width: 40,
                                                        height: 40,
                                                        cacheWidth: 120,
                                                      )),
                                                )
                                              : AutoSizeText(
                                                  List<String>.from(
                                                    map.values.map(
                                                      (e) => e.toString(),
                                                    ),
                                                  )[index],
                                                  textAlign: TextAlign.end,
                                                  style: GoogleFonts.robotoSlab(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 14,
                                                  ),
                                                ),
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              ],
                            ),
                          ),
                          const Align(
                            alignment: Alignment.topRight,
                            child: Padding(
                              padding: EdgeInsets.all(
                                10,
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.max,
                                crossAxisAlignment: CrossAxisAlignment.end,
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Padding(
                                    padding:
                                        EdgeInsets.symmetric(horizontal: 4.0),
                                    child: Icon(
                                      Icons.edit,
                                    ),
                                  ),
                                  Padding(
                                    padding:
                                        EdgeInsets.symmetric(horizontal: 4.0),
                                    child: Icon(
                                      Icons.delete,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                        ],
                      ),
                    );
                  }
                },
              ),
            )
          ],
        ),
      ),
    );
  }
}

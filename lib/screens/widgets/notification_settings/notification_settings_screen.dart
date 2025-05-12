import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shoppingmegamart/size.dart';

const Map<String, dynamic> filters = {
  'specificationAttributeFilters': [
    {
      'id': 12,
      'name': 'Brands',
      'image':'assets/images/brand.png',
      'specificationoptions': [
        {
          "name": 'Heating',
          "id":101,
          "brands":[
            "10 Black",
            "12002355",
            "30",
            "300W Titanium",
            "316223400",
            "3M",
            "3M AquaPure",
            "5304509706 Oven",
            "A",
            "A.O. Smith",
            "Access Lighting",
            "Accurate Lock",
            "ACO",
            "Acorn",
            "Adidas Originals",
            "Advance Tabco",
            "Afina",
            "Agape",
            "Aideepen",
            "Air Jordan",
            "AirQuest",
            "AIRTEC",
            "Alape",
            "Allanson",
            "Allegro",
            "Allied Brass",
            "Alno",
            "Alno Inc",
            "Alsons",
            "Altherm",
            "Altmans",
            "Amba",
            "Amerec",
            "American Metal",
            "American Plumber",
            "American Specialties",
            "American Standard",
            "American Valve",
            "Americh",
            "AmeriVent",
            "Amerock",
            "Ametek",
            "AMI Parts",
            "Amtrol",
            "Angle Grinder",
            "Antonio Lupi",
            "Anvil",
            "AO Smit",
            "AO Smith",
            "Aosmith"
          ],
        },
        {
          "name": 'Plumbing',
          "id":101,
          "brands":[
            "10 Black",
            "12002355",
            "30",
            "300W Titanium",
            "316223400",
            "3M",
            "3M AquaPure",
            "5304509706 Oven",
            "A",
            "A.O. Smith",
            "Access Lighting",
            "Accurate Lock",
            "ACO",
            "Acorn",
            "Adidas Originals",
            "Advance Tabco",
            "Afina",
            "Agape",
            "Aideepen",
            "Air Jordan",
            "AirQuest",
            "AIRTEC",
            "Alape",
            "Allanson",
            "Allegro",
            "Allied Brass",
            "Alno",
            "Alno Inc",
            "Alsons",
            "Altherm",
            "Altmans",
            "Amba",
            "Amerec",
            "American Metal",
            "American Plumber",
            "American Specialties",
            "American Standard",
            "American Valve",
            "Americh",
            "AmeriVent",
            "Amerock",
            "Ametek",
            "AMI Parts",
            "Amtrol",
            "Angle Grinder",
            "Antonio Lupi",
            "Anvil",
            "AO Smit",
            "AO Smith",
            "Aosmith"
          ],
        },
        {
          "name": 'PVF',
          "id":101,
          "brands":[
            "10 Black",
            "12002355",
            "30",
            "300W Titanium",
            "316223400",
            "3M",
            "3M AquaPure",
            "5304509706 Oven",
            "A",
            "A.O. Smith",
            "Access Lighting",
            "Accurate Lock",
            "ACO",
            "Acorn",
            "Adidas Originals",
            "Advance Tabco",
            "Afina",
            "Agape",
            "Aideepen",
            "Air Jordan",
            "AirQuest",
            "AIRTEC",
            "Alape",
            "Allanson",
            "Allegro",
            "Allied Brass",
            "Alno",
            "Alno Inc",
            "Alsons",
            "Altherm",
            "Altmans",
            "Amba",
            "Amerec",
            "American Metal",
            "American Plumber",
            "American Specialties",
            "American Standard",
            "American Valve",
            "Americh",
            "AmeriVent",
            "Amerock",
            "Ametek",
            "AMI Parts",
            "Amtrol",
            "Angle Grinder",
            "Antonio Lupi",
            "Anvil",
            "AO Smit",
            "AO Smith",
            "Aosmith"
          ],
        },
        {
          "name": 'Tools',
          "id":101,
          "brands":[
            "10 Black",
            "12002355",
            "30",
            "300W Titanium",
            "316223400",
            "3M",
            "3M AquaPure",
            "5304509706 Oven",
            "A",
            "A.O. Smith",
            "Access Lighting",
            "Accurate Lock",
            "ACO",
            "Acorn",
            "Adidas Originals",
            "Advance Tabco",
            "Afina",
            "Agape",
            "Aideepen",
            "Air Jordan",
            "AirQuest",
            "AIRTEC",
            "Alape",
            "Allanson",
            "Allegro",
            "Allied Brass",
            "Alno",
            "Alno Inc",
            "Alsons",
            "Altherm",
            "Altmans",
            "Amba",
            "Amerec",
            "American Metal",
            "American Plumber",
            "American Specialties",
            "American Standard",
            "American Valve",
            "Americh",
            "AmeriVent",
            "Amerock",
            "Ametek",
            "AMI Parts",
            "Amtrol",
            "Angle Grinder",
            "Antonio Lupi",
            "Anvil",
            "AO Smit",
            "AO Smith",
            "Aosmith"
          ],
        },
        {
          "name": 'Others',
          "id":101,
          "brands":[
            "10 Black",
            "12002355",
            "30",
            "300W Titanium",
            "316223400",
            "3M",
            "3M AquaPure",
            "5304509706 Oven",
            "A",
            "A.O. Smith",
            "Access Lighting",
            "Accurate Lock",
            "ACO",
            "Acorn",
            "Adidas Originals",
            "Advance Tabco",
            "Afina",
            "Agape",
            "Aideepen",
            "Air Jordan",
            "AirQuest",
            "AIRTEC",
            "Alape",
            "Allanson",
            "Allegro",
            "Allied Brass",
            "Alno",
            "Alno Inc",
            "Alsons",
            "Altherm",
            "Altmans",
            "Amba",
            "Amerec",
            "American Metal",
            "American Plumber",
            "American Specialties",
            "American Standard",
            "American Valve",
            "Americh",
            "AmeriVent",
            "Amerock",
            "Ametek",
            "AMI Parts",
            "Amtrol",
            "Angle Grinder",
            "Antonio Lupi",
            "Anvil",
            "AO Smit",
            "AO Smith",
            "Aosmith"
          ],
        },
      ]
    },
    {
      'id': 3,
      'name': 'Percentage Preset',
      'image':'assets/images/percentage.png',

      'specificationoptions': [
        {'id': 30, 'name': 'Lowest by 5%'},
        {'id': 34, 'name': 'Lowest by 5%-15%'},
        {'id': 10, 'name': 'Lowest by 15%'},
        {'id': 33, 'name': 'Highest by 5%'},
        {'id': 7, 'name': 'Highest by 5% - 15%'},
        {'id': 7, 'name': 'Highest by 15%'},
      ]
    },
    {
      'id': 6,
      'name': 'Number of products',
      'image':'assets/images/five.png',
      'specificationoptions': [
        {'id': 22, 'name': '5'},
        {'id': 29, 'name': '10'},
        {'id': 35, 'name': '15'},
        {'id': 23, 'name': '20'},
        {'id': 33, 'name': '25'},
      ]
    },
    {
      'id': 3,
      'name': 'Notification Frequency',
      'image':'assets/images/frequency.png',
      'specificationoptions': [
        {'id': 30, 'name': 'Hourly'},
        {'id': 34, 'name': 'Daily'},
        {'id': 10, 'name': 'Weekly'},
        {'id': 33, 'name': 'Monthly'},
        {'id': 7, 'name': 'Annually'},
      ]
    },
    {
      'id': 3,
      'name': 'Rotate Products',
      "image":'assets/images/suffle.png',
      'specificationoptions': [
        {'id': 30, 'name': 'Enable'},

      ]
    },
  ],
};

class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({Key? key}) : super(key: key);

  @override
  State<NotificationSettingsScreen> createState() =>
      _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState
    extends State<NotificationSettingsScreen> {
  int activeIndex = 0;

  List<Map<String, dynamic>> filterMap =
      filters['specificationAttributeFilters'][0]['specificationoptions'];

  final _controller = ScrollController();

  @override
  void dispose() {
    // TODO: implement dispose
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        // backgroundColor: Colors.grey.shade300,
        body: Container(
          color: Colors.white,
          child: Column(
            mainAxisSize: MainAxisSize.max,
            children: [
              Padding(
                padding: EdgeInsets.all(0.02 * w),
                child: Center(
                  child: Text(
                    'Notification Settings',
                    style: GoogleFonts.montserrat(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              Expanded(
                child: Row(
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Column(
                      children: List.generate(
                        filters['specificationAttributeFilters'].length,
                        (index) => InkWell(
                          onTap: () {
                            setState(() {
                              activeIndex = index;
                              filterMap =
                                  filters['specificationAttributeFilters']
                                      [index]['specificationoptions'];
                            });
                          },
                          child: Container(
                            color: activeIndex == index
                                ? Colors.lightBlueAccent
                                : Colors.grey.withOpacity(.2),
                            width: 0.33 * w,
                            height: 0.07 * h,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10.0, vertical: 15),
                              child: AutoSizeText(
                                filters['specificationAttributeFilters'][index]
                                        ['name']
                                    .toString()
                                    .toUpperCase(),
                                textAlign: TextAlign.left,
                                style: GoogleFonts.montserrat(
                                  fontSize: 0.04 * w,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      width: .67 * w,
                      child: gridLayout(
                        filterOptions: filterMap,
                        optionName: filters['specificationAttributeFilters']
                                [activeIndex]['name']
                            .toString()
                            .toLowerCase(),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                width: w,
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                  child: Row(
                    mainAxisSize: MainAxisSize.max,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Card(
                        color: Colors.lightBlueAccent,
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: .13 * w,
                            vertical: 0.03 * w,
                          ),
                          child: Text(
                            'Cancel',
                            style: GoogleFonts.montserrat(
                              fontSize: 0.045 * w,
                              wordSpacing: 2,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      Card(
                        color: Colors.lightBlueAccent,
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: .13 * w,
                            vertical: 0.03 * w,
                          ),
                          child: Text(
                            'Submit',
                            style: GoogleFonts.montserrat(
                              fontSize: 0.045 * w,
                              wordSpacing: 2,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget gridLayout(
      {required List<Map<String, dynamic>> filterOptions,
      required String optionName}) {
    return Scrollbar(
      thickness: 10,
      controller: _controller,
      thumbVisibility: true,
      child: GridView.count(
        controller: _controller,
        crossAxisCount: 1,
        childAspectRatio: 4 / 1,
        children: List.generate(
            filterOptions.length,
            (index) => Card(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 4.0,
                    ),
                    child: GestureDetector(
                      onTap: () {
                        // setState(() {
                        //   if (!_selectedList.contains(allFilterHolder[
                        //   index]
                        //       .specificationoptions[
                        //   index1]
                        //       .id
                        //       .toString())) {
                        //     selectedOption.add(
                        //         allFilterHolder[index]
                        //             .specificationoptions[index1]);
                        //     _selectedList.add(allFilterHolder[
                        //     index]
                        //         .specificationoptions[
                        //     index1]
                        //         .id
                        //         .toString());
                        //   } else {
                        //     selectedOption
                        //         .remove(
                        //         allFilterHolder[index].specificationoptions[index1]);
                        //     _selectedList.remove(allFilterHolder[
                        //     index]
                        //         .specificationoptions[
                        //     index1]
                        //         .id
                        //         .toString());
                        //     pageIndex =
                        //     0;
                        //   }
                        // });
                        // getFilters();
                      },
                      child: Container(
                        // color: mList
                        //     .isNotEmpty
                        //     ? isNamePresentInModifiedList(allFilterHolder[index].specificationoptions[index1].name) ==
                        //     true
                        //     ? Colors
                        //     .white
                        //     : Colors.black.withOpacity(
                        //     .3)
                        //     : Colors
                        //     .white,
                        // color: mList.isNotEmpty?!mList.contains( allFilterHolder[index])?Colors.black.withOpacity(0.6):mList[index].specificationoptions.contains(selectedOption)Colors.white,

                        child: SizedBox(
                          width: .30 * w,
                          child: Row(
                            children: [
                              Checkbox(
                                value: true,
                                onChanged: (val) {
                                  // setState(() {
                                  //   if (!_selectedList.contains(allFilterHolder[index].specificationoptions[index1].id.toString())) {
                                  //     selectedOption.add(allFilterHolder[index].specificationoptions[index1]);
                                  //     _selectedList.add(allFilterHolder[index].specificationoptions[index1].id.toString());
                                  //   } else {
                                  //     selectedOption.remove(allFilterHolder[index].specificationoptions[index1]);
                                  //     _selectedList.remove(allFilterHolder[index].specificationoptions[index1].id.toString());
                                  //     pageIndex = 0;
                                  //   }
                                  // });
                                  //
                                  // getFilters();
                                  // // searchedProducts = [];
                                },
                              ),
                              Visibility(
                                visible: optionName.toLowerCase() == 'colour'
                                    ? true
                                    : false,
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 3.0),
                                  child: Container(
                                    width: 0.05 * w,
                                    height: 0.05 * w,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Colors.white,
                                      border: Border.all(
                                          color: Colors.black, width: .5),
                                    ),
                                  ),
                                ),
                              ),
                              Flexible(
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 6.0, vertical: 3),
                                  child: AutoSizeText(
                                    filterOptions[index]['name'],
                                    // maxLines: allFilterHolder[index].name.toLowerCase().contains('family') || allFilterHolder[index].name.toLowerCase().contains('colour') ? 1 : 2,
                                    style: GoogleFonts.montserrat(
                                      fontSize: 0.035 * w,
                                      fontWeight: FontWeight.bold,
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
                )
            //     Card(
            //   child: Text(filterOptions[index]['name']),
            // ),
            ),
      ),
    );
  }
}

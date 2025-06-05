import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shoppingmegamart/app.dart';
import 'package:shoppingmegamart/model/vendor_dashboard_model.dart';
import 'package:shoppingmegamart/size.dart';
import 'package:sqflite/sqflite.dart';

import 'sample_product_screen.dart';

class DiscountTable extends StatelessWidget {
  const DiscountTable({
    super.key,
    required this.vendorId,
    required ScrollController healthHighlightController,
    required this.database,
    required List<DiscountingHealth> discountList,
  })  : _healthHighlightController = healthHighlightController,
        data = discountList;

  final ScrollController _healthHighlightController;

  final List<DiscountingHealth> data;
  final String vendorId;
  final Database database;

  List<DataColumn> _buildColumns() {
    List<String> columnNames =
        data.map((item) => item.discountValue.toString()).toSet().toList();
    return columnNames
        .map((columnName) => DataColumn(label: Text(columnName)))
        .toList();
  }

  List<DataRow> _buildRows() {
    List<DataRow> rows = [];
    Map<String, List<DiscountingHealth>> groupedData = {};
    for (var item in data) {
      String brandType = item.discountBrandType.toString();
      if (!groupedData.containsKey(brandType)) {
        groupedData[brandType] = [];
      }
      groupedData[brandType]!.add(item);
    }

    groupedData.forEach((brandType, items) {
      List<DataCell> cells = items
          .map<DataCell>(
              (item) => DataCell(Text(item.discountCount.toString())))
          .toList();
      DataRow row = DataRow(cells: [
        DataCell(Text(brandType)),
        ...cells,
      ]);
      rows.add(row);
    });

    return rows;
  }

  @override
  Widget build(BuildContext context) {
    List<Map<String, dynamic>> plumbingList = [];
    List<Map<String, dynamic>> toolsList = [];
    List<Map<String, dynamic>> pvfList = [];
    List<Map<String, dynamic>> heatingList = [];

    for (var e in data) {
      e.discountBrandType.toLowerCase() == 'plumbing'
          ? plumbingList.addAll([
              {
                'count': e.discountCount.toString(),
                'id': e.vendorId.toString(),
                'date': e.discountDate.toString(),
                'discount_id': e.discountId.toString(),
              }
            ])
          : null;
      e.discountBrandType.toLowerCase() == 'tools'
          ? toolsList.addAll([
              {
                'count': e.discountCount.toString(),
                'id': e.vendorId.toString(),
                'date': e.discountDate.toString(),
                'discount_id': e.discountId.toString(),
              }
            ])
          : null;
      e.discountBrandType.toLowerCase() == 'pvf'
          ? pvfList.addAll([
              {
                'count': e.discountCount.toString(),
                'id': e.vendorId.toString(),
                'date': e.discountDate.toString(),
                'discount_id': e.discountId.toString(),
              }
            ])
          : null;
      e.discountBrandType.toLowerCase() == 'heating'
          ? heatingList.addAll([
              {
                'count': e.discountCount.toString(),
                'id': e.vendorId.toString(),
                'date': e.discountDate.toString(),
                'discount_id': e.discountId.toString(),
              }
            ])
          : null;
    }

    return Row(
      children: [
        SizedBox(
          width: w * .28,
          child: DataTable(
            columns: [
              DataColumn(
                label: Text(
                  '',
                  style: GoogleFonts.montserrat(),
                ),
              )
            ],
            rows: [
              DataRow(
                cells: [
                  DataCell(
                    Text(
                      'Plumbing',
                      style: GoogleFonts.montserrat(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  )
                ],
              ),
              DataRow(
                cells: [
                  DataCell(
                    Text(
                      'Tools',
                      style: GoogleFonts.montserrat(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  )
                ],
              ),
              DataRow(
                cells: [
                  DataCell(
                    Text(
                      'PVF',
                      style: GoogleFonts.montserrat(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              DataRow(
                cells: [
                  DataCell(
                    Text(
                      'Heating',
                      style: GoogleFonts.montserrat(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        Flexible(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            controller: _healthHighlightController,
            clipBehavior: Clip.antiAliasWithSaveLayer,
            child: DataTable(
              columnSpacing: 10,
              // headingRowColor: MaterialStateColor.resolveWith(
              //     (states) => Colors.amberAccent),
              columns: <DataColumn>[
                DataColumn(
                  label: Card(
                    color: Colors.red,
                    elevation: 4,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 8.0, horizontal: 15),
                      child: Text(
                        '0%',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.montserrat(
                            fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                    ),
                  ),
                ),
                DataColumn(
                  label: Card(
                    color: Colors.orangeAccent,
                    elevation: 4,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 8.0, horizontal: 15),
                      child: Text(
                        '0% - 20%',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.montserrat(
                            fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                    ),
                  ),
                ),
                DataColumn(
                  label: Card(
                    color: Colors.green,
                    elevation: 4,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 8.0, horizontal: 15),
                      child: Text(
                        '20% - 50%',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.montserrat(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
                DataColumn(
                  label: Card(
                    color: Colors.redAccent,
                    elevation: 4,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 8.0, horizontal: 15),
                      child: Text(
                        '50% - 70%',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.montserrat(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
                DataColumn(
                  label: Card(
                    color: Colors.red,
                    elevation: 4,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 8.0, horizontal: 15),
                      child: Text(
                        '70%',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.montserrat(
                            fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                    ),
                  ),
                ),
              ],
              rows: <DataRow>[
                DataRow(
                  cells: List<DataCell>.generate(
                    plumbingList.length,
                    (index) => DataCell(
                        Center(
                          child: Text(
                            plumbingList[index]['count'],
                            textAlign: TextAlign.center,
                            style: GoogleFonts.montserrat(
                              color: index == 0
                                  ? Colors.red
                                  : index == 1
                                      ? Colors.orangeAccent
                                      : index == 2
                                          ? Colors.green
                                          : index == 3
                                              ? Colors.redAccent
                                              : Colors.red,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ), onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ContentScreen(
                            loadingString: _returnLoadingString(index),
                            isVendorTable: true,
                            brandKey: '',
                            vendorName: 'Plumbing',
                            vendorImage: vendorId == '${AppInfo.kVendorId}'
                                ? "https://www.afsupply.com/media/logo/stores/1/af-supply.png"
                                : 'https://www.homeperfect.com/media/logo/websites/1/home-perfect.png',
                            vendorId: vendorId.toString(),
                            id: plumbingList[index]['discount_id'],
                            date: plumbingList[index]['date'],
                            isVendorPriceAnalysis: false,
                            loadingData: 'Plumbing',
                            database: database,
                          ),
                        ),
                      );

                      log(jsonEncode(plumbingList[index]));
                    }),
                  ),
                ),
                DataRow(
                  cells: List<DataCell>.generate(
                    toolsList.length,
                    (index) => DataCell(
                        Center(
                          child: Text(
                            toolsList[index]['count'],
                            textAlign: TextAlign.center,
                            style: GoogleFonts.montserrat(
                                fontWeight: FontWeight.bold,
                                color: index == 0
                                    ? Colors.red
                                    : index == 1
                                        ? Colors.orangeAccent
                                        : index == 2
                                            ? Colors.green
                                            : index == 3
                                                ? Colors.redAccent
                                                : Colors.red),
                          ),
                        ), onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ContentScreen(
                            loadingString: _returnLoadingString(index),
                            isVendorTable: true,
                            brandKey: '',
                            vendorName: 'Tools',
                            vendorImage: vendorId == '${AppInfo.kVendorId}'
                                ? "https://www.afsupply.com/media/logo/stores/1/af-supply.png"
                                : 'https://www.homeperfect.com/media/logo/websites/1/home-perfect.png',
                            vendorId: vendorId.toString(),
                            id: toolsList[index]['discount_id'],
                            date: toolsList[index]['date'],
                            isVendorPriceAnalysis: false,
                            loadingData: 'Tools',
                            database: database,
                          ),
                        ),
                      );
                      log(jsonEncode(toolsList[index]));
                    }),
                  ),
                ),
                DataRow(
                  cells: List<DataCell>.generate(
                    pvfList.length,
                    (index) => DataCell(
                        Center(
                          child: Text(
                            pvfList[index]['count'],
                            textAlign: TextAlign.center,
                            style: GoogleFonts.montserrat(
                                fontWeight: FontWeight.bold,
                                color: index == 0
                                    ? Colors.red
                                    : index == 1
                                        ? Colors.orangeAccent
                                        : index == 2
                                            ? Colors.green
                                            : index == 3
                                                ? Colors.redAccent
                                                : Colors.red),
                          ),
                        ), onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ContentScreen(
                            isVendorTable: true,
                            brandKey: '',
                            vendorName: 'PVF',
                            vendorImage: vendorId == '${AppInfo.kVendorId}'
                                ? "https://www.afsupply.com/media/logo/stores/1/af-supply.png"
                                : 'https://www.homeperfect.com/media/logo/websites/1/home-perfect.png',
                            vendorId: vendorId.toString(),
                            id: pvfList[index]['discount_id'],
                            date: pvfList[index]['date'],
                            isVendorPriceAnalysis: false,
                            loadingData: 'PVF',
                            loadingString: _returnLoadingString(index),
                            database: database,
                          ),
                        ),
                      );
                      log(jsonEncode(pvfList[index]));
                    }),
                  ),
                ),
                DataRow(
                  cells: List<DataCell>.generate(
                    heatingList.length,
                    (index) => DataCell(
                        Center(
                          child: Text(
                            heatingList[index]['count'],
                            textAlign: TextAlign.center,
                            style: GoogleFonts.montserrat(
                                fontWeight: FontWeight.bold,
                                color: index == 0
                                    ? Colors.red
                                    : index == 1
                                        ? Colors.orangeAccent
                                        : index == 2
                                            ? Colors.green
                                            : index == 3
                                                ? Colors.redAccent
                                                : Colors.red),
                          ),
                        ), onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ContentScreen(
                            isVendorTable: true,
                            brandKey: '',
                            vendorName: 'Heating',
                            vendorImage: vendorId == '${AppInfo.kVendorId}'
                                ? "https://www.afsupply.com/media/logo/stores/1/af-supply.png"
                                : 'https://www.homeperfect.com/media/logo/websites/1/home-perfect.png',
                            vendorId: vendorId.toString(),
                            id: heatingList[index]['discount_id'],
                            date: heatingList[index]['date'],
                            isVendorPriceAnalysis: false,
                            loadingData: 'Heating',
                            loadingString: _returnLoadingString(index),
                            database: database,
                          ),
                        ),
                      );
                      log(jsonEncode(heatingList[index]));
                    }),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  String _returnLoadingString(int index) {
    switch (index) {
      case 0:
        return 'Discount 0%';
      case 1:
        return 'Discount 0% - 20%';
      case 2:
        return 'Discount 20% - 50%';
      case 3:
        return 'Discount 50% - 70%';
      case 4:
        return 'Discount 70%';
      default:
        return 'No Discount';
    }
  }
}

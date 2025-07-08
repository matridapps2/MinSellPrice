import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:minsellprice/reposotory_services/database/database_constants.dart';
import 'package:minsellprice/reposotory_services/database/database_functions.dart';
import 'package:sqflite/sqflite.dart';

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

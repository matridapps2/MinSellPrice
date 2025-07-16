import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:minsellprice/colors.dart';
import 'package:minsellprice/size.dart';
import 'package:sqflite/sqflite.dart';
import '../service_new/dashboard_categoies_db.dart';
import '../../product_list_screen/brand_product_list_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({
    super.key,
    required this.database,
  });

  final Database database;

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  List<Map<String, dynamic>> _searchResults = [];
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _searchFocusNode.dispose();
    _searchController.dispose();
    super.dispose();
  }

  // Navigate to brand product list screen
  void _navigateToBrandProductList(Map<String, dynamic> brand) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BrandProductListScreen(
          brandId: brand['brand_id'] ?? 0,
          brandName: brand['brand_name'] ?? '',
          database: widget.database,
          dataList: const [],
        ),
      ),
    );
  }

  Future<void> _performSearch(String query) async {
    setState(() {
      _isSearching = true;
    });

    try {
      final results = await DashboardCategoriesDB.searchCategoriesByName(query);
      setState(() {
        _searchResults = results;
        _isSearching = false;
      });
    } catch (e) {
      setState(() {
        _searchResults = [];
        _isSearching = false;
      });
      log('Error searching: $e');
    }
  }

  Future<void> _searchAndNavigate(String query) async {
    setState(() {
      _isSearching = true;
    });

    try {
      final results = await DashboardCategoriesDB.searchCategoriesByName(query);
      setState(() {
        _searchResults = results;
        _isSearching = false;
      });

      // If results found, navigate to the first brand
      if (results.isNotEmpty) {
        _navigateToBrandProductList(results.first);
      } else {
        // Show message if no results found
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'No brands found with this name',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            backgroundColor: Colors.orange,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      setState(() {
        _searchResults = [];
        _isSearching = false;
      });
      log('Error searching: $e');

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Error searching: $e',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  int id = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 80,
        backgroundColor: AppColors.primary,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: SizedBox(
          width: double.infinity,
          height: 40,
          child: TextFormField(
            enabled: true,
            controller: _searchController,
            focusNode: _searchFocusNode,
            autofocus: true,
            textInputAction: TextInputAction.search,
            onChanged: (value) {
              if (value.trim().isNotEmpty) {
                _performSearch(value.trim());
              } else {
                setState(() {
                  _searchResults.clear();
                  _isSearching = false;
                });
              }
            },
            onFieldSubmitted: (value) {
              if (value.trim().isNotEmpty) {
                // When user presses Enter, search and navigate to first result if available
                _searchAndNavigate(value.trim());
              }
            },
            cursorColor: AppColors.primary,
            decoration: InputDecoration(
              hintText: 'Search brands by name...',
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 10.0,
                vertical: 8.0,
              ),
              border: OutlineInputBorder(
                borderSide: BorderSide.none,
                borderRadius: BorderRadius.circular(20),
              ),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide.none,
                borderRadius: BorderRadius.circular(20),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide.none,
                borderRadius: BorderRadius.circular(20),
              ),
              disabledBorder: OutlineInputBorder(
                borderSide: BorderSide.none,
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          ),
        ),
        centerTitle: true,
      ),
      body: Padding(
          padding: const EdgeInsets.only(bottom: 5, top: 15),
          child: Container(
              color: const Color.fromARGB(255, 245, 245, 245),
              width: w,
              child: Column(children: [
                // Search results section
                Expanded(
                  child: _isSearching
                      ? const Center(
                          child: CircularProgressIndicator(),
                        )
                      : _searchResults.isEmpty &&
                              _searchController.text.isNotEmpty
                          ? const Center(
                              child: Text(
                                'No brands found',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey,
                                ),
                              ),
                            )
                          : _searchResults.isEmpty
                              ? const Center(
                                  child: Text(
                                    'Search for brands...',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.grey,
                                    ),
                                  ),
                                )
                              : ListView.builder(
                                  itemCount: _searchResults.length,
                                  itemBuilder: (context, index) {
                                    final brand = _searchResults[index];
                                    return ListTile(
                                      title: Text(
                                        brand['brand_name']?.toString() ?? '',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      onTap: () {
                                        _navigateToBrandProductList(brand);
                                      },
                                    );
                                  },
                                ),
                ),
              ]))),
    );
  }
}

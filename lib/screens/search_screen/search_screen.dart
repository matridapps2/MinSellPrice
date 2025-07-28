import 'dart:developer';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:minsellprice/core/apis/apis_calls.dart';
import 'package:minsellprice/core/utils/constants/colors.dart';
import 'package:minsellprice/screens/dashboard_screen/dashboard_screen.dart';
import 'package:minsellprice/screens/product_list_screen/brand_product_list_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:minsellprice/core/utils/constants/size.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({
    super.key,
  });

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  List<Map<String, dynamic>> _searchResults = [];
  bool _isSearching = false;
  String _currentSearchQuery = '';
  List<Map<String, dynamic>> _allBrands = [];
  List<Map<String, dynamic>> _list = [];
  List<Map<String, dynamic>> _recentSearches = [];
  static const String _recentSearchesKey = 'recent_searches';
  static const int _maxRecentSearches = 8;

  @override
  void initState() {
    super.initState();
    _loadAllBrands();
    _loadRecentSearches();
  }

  @override
  void dispose() {
    _searchFocusNode.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadRecentSearches() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final recentSearchesJson = prefs.getStringList(_recentSearchesKey) ?? [];

      setState(() {
        _recentSearches = recentSearchesJson
            .map((json) => Map<String, dynamic>.from(jsonDecode(json)))
            .toList();
      });

      log('Loaded ${_recentSearches.length} recent searches');
    } catch (e) {
      log('Error loading recent searches: $e');
    }
  }

  Future<void> _addToRecentSearches(Map<String, dynamic> brand) async {
    try {
      _recentSearches
          .removeWhere((item) => item['brand_id'] == brand['brand_id']);

      // Add to beginning
      _recentSearches.insert(0, brand);

      // Keep only the most recent searches
      if (_recentSearches.length > _maxRecentSearches) {
        _recentSearches = _recentSearches.take(_maxRecentSearches).toList();
      }

      // Save to SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      final recentSearchesJson =
          _recentSearches.map((brand) => jsonEncode(brand)).toList();
      await prefs.setStringList(_recentSearchesKey, recentSearchesJson);

      setState(() {});
      log('Added brand to recent searches: ${brand['brand_name']}');
    } catch (e) {
      log('Error saving recent search: $e');
    }
  }

  // Clear all recent searches
  Future<void> _clearRecentSearches() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_recentSearchesKey);

      setState(() {
        _recentSearches.clear();
      });

      log('Cleared all recent searches');
    } catch (e) {
      log('Error clearing recent searches: $e');
    }
  }

  Future<void> _loadAllBrands() async {
    try {
      log('Loading brands using centralized API method');
      final brandsData = await BrandsApi.fetchAllBrands(context);

      final homeGardenBrands = (brandsData["Home & Garden Brands"] ?? [])
          .whereType<Map<String, dynamic>>()
          .toList();

      final shoesApparels = (brandsData["Shoes & Apparels"] ?? [])
          .whereType<Map<String, dynamic>>()
          .toList();

      setState(() {
        _allBrands = [...homeGardenBrands, ...shoesApparels];
        _list = [...homeGardenBrands, ...shoesApparels];
      });

      log('Loaded ${_allBrands.length} brands from centralized API');
      log('Sample brand data: ${_allBrands.isNotEmpty ? _allBrands.first : 'No brands'}');

      // Log all brands with "American" in the name for debugging
      log('=== DEBUGGING AMERICAN BRANDS ===');
      for (int i = 0; i < _allBrands.length; i++) {
        final brand = _allBrands[i];
        final brandName = brand['brand_name']?.toString() ?? '';
        if (brandName.toLowerCase().contains('american')) {
          log('Brand $i: "$brandName" - Key: "${brand['brand_key']}" - ID: ${brand['brand_id']}');
        }
      }
      log('=== END DEBUGGING ===');
    } catch (e) {
      log('Exception loading brands from centralized API: ${e.toString()}');
    }
  }

  void _navigateToBrandProductList(Map<String, dynamic> brand) {
    _addToRecentSearches(brand);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BrandProductListScreen(
          brandId: brand['brand_id'] ?? 0,
          brandName: brand['brand_name'] ?? '',
          dataList: const [],
        ),
      ),
    );
  }

  Future<void> _performSearch(String query) async {
    _currentSearchQuery = query;

    setState(() {
      _isSearching = true;
    });

    try {
      final results = _allBrands
          .where((brand) {
            final brandName =
                brand['brand_name']?.toString().toLowerCase() ?? '';
            return brandName.contains(query.toLowerCase());
          })
          .take(5)
          .toList();

      log('Search query: "$query"');
      log('Found ${results.length} results');
      for (int i = 0; i < results.length; i++) {
        final brand = results[i];
        log('Result $i: "${brand['brand_name']}" - Key: "${brand['brand_key']}" - ID: ${brand['brand_id']}');
        log('Full brand data for result $i: $brand');
      }

      if (mounted && _currentSearchQuery == query) {
        setState(() {
          _searchResults = results;
          _isSearching = false;
        });
      }
    } catch (e) {
      if (mounted && _currentSearchQuery == query) {
        setState(() {
          _searchResults = [];
          _isSearching = false;
        });
      }
      log('Error searching: $e');
    }
  }

  Future<void> _searchAndNavigate(String query) async {
    setState(() {
      _isSearching = true;
    });

    try {
      final results = _allBrands
          .where((brand) {
            final brandName =
                brand['brand_name']?.toString().toLowerCase() ?? '';
            return brandName.contains(query.toLowerCase());
          })
          .take(5)
          .toList();

      setState(() {
        _searchResults = results;
        _isSearching = false;
      });

      if (results.isNotEmpty) {
        _navigateToBrandProductList(results.first);
      } else {
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

  Widget _buildRecentSearches() {
    if (_recentSearches.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Recent Searches',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              TextButton(
                onPressed: _clearRecentSearches,
                child: const Text(
                  'Clear All',
                  style: TextStyle(
                    color: Colors.red,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 100,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            itemCount: _recentSearches.length,
            itemBuilder: (context, index) {
              final brand = _recentSearches[index];
              return Container(
                width: 120,
                margin: const EdgeInsets.symmetric(horizontal: 4.0),
                child: Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: InkWell(
                    onTap: () => _navigateToBrandProductList(brand),
                    borderRadius: BorderRadius.circular(12),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Brand Image
                        SizedBox(
                          width: 50,
                          height: 40,
                          child: BrandImageWidget(
                            key: ValueKey('recent_${brand['brand_id']}_$index'),
                            brand: brand,
                            width: 50,
                            height: 40,
                          ),
                        ),
                        const SizedBox(height: 8),
                        // Brand Name
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: Text(
                            brand['brand_name']?.toString() ?? '',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

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
              log('Search text changed: "$value"');
              if (value.trim().isNotEmpty) {
                _performSearch(value.trim());
              } else {
                _currentSearchQuery = '';
                setState(() {
                  _searchResults.clear();
                  _isSearching = false;
                });
                log('Cleared search results');
              }
            },
            onFieldSubmitted: (value) {
              if (value.trim().isNotEmpty) {
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
                Expanded(
                  child: Builder(
                    builder: (context) {
                      log('Building search results - Text: "${_searchController.text}", Results: ${_searchResults.length}, Searching: $_isSearching');

                      if (_isSearching) {
                        return const Center(
                          child: CircularProgressIndicator(),
                        );
                      } else if (_searchController.text.isEmpty) {
                        // Show recent searches when no search is active
                        return SingleChildScrollView(
                          child: Column(
                            children: [
                              _buildRecentSearches(),
                            ],
                          ),
                        );
                      } else if (_searchResults.isEmpty) {
                        return const Center(
                          child: Text(
                            'No brands found',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey,
                            ),
                          ),
                        );
                      } else {
                        return ListView.builder(
                          itemCount: _searchResults.length,
                          itemBuilder: (context, index) {
                            final brand = _searchResults[index];
                            log('ListView.builder - Index $index: "${brand['brand_name']}" - Key: "${brand['brand_key']}" - ID: ${brand['brand_id']}');
                            log('ListView.builder - Full brand data for index $index: $brand');
                            return ListTile(
                              leading: BrandImageWidget(
                                key: ValueKey(
                                    'brand_${brand['brand_id']}_${index}'),
                                brand: brand,
                                width: 75,
                                height: 75,
                              ),
                              title: Text(
                                brand['brand_name']?.toString() ?? '',
                                style: const TextStyle(
                                  fontWeight: FontWeight.normal,
                                  fontSize: 19,
                                ),
                              ),
                              onTap: () {
                                _navigateToBrandProductList(brand);
                              },
                            );
                          },
                        );
                      }
                    },
                  ),
                ),
              ]))),
    );
  }
}

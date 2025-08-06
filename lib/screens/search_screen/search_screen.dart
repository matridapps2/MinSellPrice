import 'dart:developer';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:minsellprice/core/apis/apis_calls.dart';
import 'package:minsellprice/core/utils/constants/colors.dart';
import 'package:minsellprice/screens/dashboard_screen/dashboard_screen.dart';
import 'package:minsellprice/screens/product_list_screen/brand_product_list_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

  static const int _maxRecentSearches = 8;

  bool _isSearching = false;
  String _currentSearchQuery = '';
  static const String _recentSearchesKey = 'recent_searches';

  List<Map<String, dynamic>> _allBrands = [];
  List<Map<String, dynamic>> _list = [];
  List<Map<String, dynamic>> _recentSearches = [];
  List<Map<String, dynamic>> _searchResults = [];

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
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Recent Searches',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              TextButton.icon(
                onPressed: _clearRecentSearches,
                icon: const Icon(Icons.clear_all, size: 16, color: Colors.red),
                label: const Text(
                  'Clear All',
                  style: TextStyle(
                    color: Colors.red,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 120,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            itemCount: _recentSearches.length,
            itemBuilder: (context, index) {
              final brand = _recentSearches[index];
              return Container(
                width: 140,
                margin: const EdgeInsets.only(right: 12.0),
                child: Card(
                  elevation: 4,
                  shadowColor: Colors.black.withOpacity(0.1),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: InkWell(
                    onTap: () => _navigateToBrandProductList(brand),
                    borderRadius: BorderRadius.circular(16),
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Brand Image
                          Container(
                            width: 60,
                            height: 50,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              color: Colors.grey[100],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: BrandImageWidget(
                                key: ValueKey(
                                    'recent_${brand['brand_id']}_$index'),
                                brand: brand,
                                width: 60,
                                height: 50,
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          // Brand Name
                          Text(
                            brand['brand_name']?.toString() ?? '',
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Column(
        children: [
          // Fixed Header with Search
          Container(
            decoration: BoxDecoration(
              color: AppColors.primary,
              // gradient: LinearGradient(
              //   begin: Alignment.topLeft,
              //   end: Alignment.bottomRight,
              //   colors: [
              //     AppColors.primary,
              //     AppColors.primary.withOpacity(0.8),
              //     AppColors.primary.withOpacity(0.6),
              //   ],
              // ),
            ),
            child: SafeArea(
              child: Column(
                children: [
                  // App Bar
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_back,
                              color: Colors.white, size: 28),
                          onPressed: () => Navigator.pop(context),
                        ),
                        const Expanded(
                          child: Text(
                            'Discover Brands',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        const SizedBox(width: 48), // Balance the back button
                      ],
                    ),
                  ),
                  // Search Bar
                  Container(
                    margin: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(25),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
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
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                      decoration: InputDecoration(
                        hintText: 'What brand are you looking for?',
                        hintStyle: TextStyle(
                          color: Colors.grey[400],
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                        ),
                        prefixIcon: Container(
                          margin: const EdgeInsets.all(8),
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            Icons.search_rounded,
                            color: AppColors.primary,
                            size: 24,
                          ),
                        ),
                        suffixIcon: _searchController.text.isNotEmpty
                            ? Container(
                                margin: const EdgeInsets.all(8),
                                child: IconButton(
                                  icon: Container(
                                    padding: const EdgeInsets.all(4),
                                    decoration: BoxDecoration(
                                      color: Colors.grey[200],
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Icon(
                                      Icons.close,
                                      color: Colors.grey[600],
                                      size: 16,
                                    ),
                                  ),
                                  onPressed: () {
                                    _searchController.clear();
                                    setState(() {
                                      _searchResults.clear();
                                      _isSearching = false;
                                    });
                                  },
                                ),
                              )
                            : null,
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20.0,
                          vertical: 18.0,
                        ),
                        border: OutlineInputBorder(
                          borderSide: BorderSide.none,
                          borderRadius: BorderRadius.circular(25),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide.none,
                          borderRadius: BorderRadius.circular(25),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide:
                              BorderSide(color: AppColors.primary, width: 2),
                          borderRadius: BorderRadius.circular(25),
                        ),
                        disabledBorder: OutlineInputBorder(
                          borderSide: BorderSide.none,
                          borderRadius: BorderRadius.circular(25),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Scrollable Content
          Expanded(
            child: Builder(
              builder: (context) {
                log('Building search results - Text: "${_searchController.text}", Results: ${_searchResults.length}, Searching: $_isSearching');
                if (_isSearching) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 40,
                          height: 40,
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(
                                AppColors.primary),
                            strokeWidth: 3,
                          ),
                        ),
                        SizedBox(height: 16),
                        Text(
                          'Searching brands...',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
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
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.search_off_rounded,
                            size: 48,
                            color: Colors.grey[400],
                          ),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          'No brands found',
                          style: TextStyle(
                            fontSize: 20,
                            color: Colors.grey[700],
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Try searching with different keywords',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[500],
                          ),
                        ),
                      ],
                    ),
                  );
                } else {
                  return Column(
                    children: [
                      Expanded(
                        child: ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          itemCount: _searchResults.length,
                          itemBuilder: (context, index) {
                            final brand = _searchResults[index];
                            log('ListView.builder - Index $index: "${brand['brand_name']}" - Key: "${brand['brand_key']}" - ID: ${brand['brand_id']}');
                            log('ListView.builder - Full brand data for index $index: $brand');
                            return Container(
                              margin: const EdgeInsets.only(bottom: 16),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.05),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(16),
                                  onTap: () {
                                    _navigateToBrandProductList(brand);
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.all(16),
                                    child: Row(
                                      children: [
                                        Container(
                                          width: 70,
                                          height: 70,
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(12),
                                            color: Colors.grey[50],
                                            border: Border.all(
                                              color: Colors.grey[200]!,
                                              width: 1,
                                            ),
                                          ),
                                          child: ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(12),
                                            child: BrandImageWidget(
                                              key: ValueKey(
                                                  'brand_${brand['brand_id']}_${index}'),
                                              brand: brand,
                                              width: 70,
                                              height: 70,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 16),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                brand['brand_name']
                                                        ?.toString() ??
                                                    '',
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.w600,
                                                  fontSize: 16,
                                                  color: Colors.black87,
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                'View products',
                                                style: TextStyle(
                                                  fontSize: 13,
                                                  color: Colors.grey[600],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Container(
                                          padding: const EdgeInsets.all(8),
                                          decoration: BoxDecoration(
                                            color: AppColors.primary
                                                .withOpacity(0.1),
                                            borderRadius:
                                                BorderRadius.circular(8),
                                          ),
                                          child: Icon(
                                            Icons.arrow_forward_ios,
                                            color: AppColors.primary,
                                            size: 16,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}

import 'dart:developer';
import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:minsellprice/core/apis/apis_calls.dart';
import 'package:minsellprice/model/product_list_model_new.dart';

enum ProductState { initial, loading, loaded, error }

class ProductProvider extends ChangeNotifier {
  ProductState _state = ProductState.initial;
  ProductState get state => _state;

  // Removed filter-related variables
  List<VendorProduct> _allProducts = [];
  List<VendorProduct> get allProducts => _allProducts;

  List<VendorProduct> _brandProducts = [];
  List<VendorProduct> get brandProducts => _brandProducts;

  List<VendorProduct> _tempProductList = [];
  List<VendorProduct> get tempProductList => _tempProductList;

  int _currentApiPage = 1;
  int get currentApiPage => _currentApiPage;

  int _totalProductCount = 0;
  int get totalProductCount => _totalProductCount;

  bool _hasMoreData = true;
  bool get hasMoreData => _hasMoreData;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _isLoadingMore = false;
  bool get isLoadingMore => _isLoadingMore;

  bool _hasError = false;
  bool get hasError => _hasError;

  String _errorMessage = '';
  String get errorMessage => _errorMessage;

  DateTime? _lastLoadMoreTime;

  // Removed filter-related methods and variables

  Future<void> getProductList(String brandName, BuildContext context) async {
    _setState(ProductState.loading);
    _setLoading(true);
    _setError(false, '');

    try {
      final response = await BrandsApi.getProductListByBrandName(
          brandName,
          _currentApiPage,
          context
      );

      if (response != null) {
        final Map<String, dynamic> decoded = jsonDecode(response);
        final List<dynamic> jsonList = decoded['brand_product'] ?? [];

        final List<VendorProduct> fetchedProducts =
        jsonList.map((e) => VendorProduct.fromJson(e)).toList();

        _totalProductCount = decoded['productCount'] ?? 0;
        _allProducts = fetchedProducts;
        _brandProducts = List.from(_allProducts);
        _tempProductList = List.from(_allProducts);

        _hasMoreData = _allProducts.length < _totalProductCount && fetchedProducts.isNotEmpty;

        if (fetchedProducts.isEmpty) {
          _hasMoreData = false;
        }

        _setState(ProductState.loaded);
      } else {
        _setError(true, 'Failed to fetch products');
      }
    } catch (e) {
      _setError(true, 'Error: $e');
      log('Error in getProductList: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> loadMoreProducts(String brandName, BuildContext context) async {
    if (!_hasMoreData || _isLoadingMore) return;

    final now = DateTime.now();
    if (_lastLoadMoreTime != null &&
        now.difference(_lastLoadMoreTime!) < const Duration(milliseconds: 1000)) {
      return;
    }

    _setLoadingMore(true);
    _lastLoadMoreTime = now;

    try {
      _currentApiPage++;

      final response = await BrandsApi.getProductListByBrandName(
          brandName,
          _currentApiPage,
          context
      );

      if (response != null) {
        final Map<String, dynamic> decoded = jsonDecode(response);
        final List<dynamic> jsonList = decoded['brand_product'] ?? [];

        final List<VendorProduct> fetchedProducts =
        jsonList.map((e) => VendorProduct.fromJson(e)).toList();

        _allProducts.addAll(fetchedProducts);
        _brandProducts = List.from(_allProducts);
        _tempProductList = List.from(_allProducts);

        _hasMoreData = _allProducts.length < _totalProductCount && fetchedProducts.isNotEmpty;

        if (fetchedProducts.isEmpty) {
          _hasMoreData = false;
        }

        if (fetchedProducts.length < 100 && _hasMoreData) {
          if (fetchedProducts.length < 50) {
            _hasMoreData = false;
          }
        }
      }
    } catch (e) {
      log('Error loading more products: $e');
    } finally {
      _setLoadingMore(false);
    }
  }

  void retry() {
    _setState(ProductState.initial);
    _setError(false, '');
  }

  void _setState(ProductState state) {
    _state = state;
    notifyListeners();
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setLoadingMore(bool loading) {
    _isLoadingMore = loading;
    notifyListeners();
  }

  void _setError(bool hasError, String message) {
    _hasError = hasError;
    _errorMessage = message;
    notifyListeners();
  }
}
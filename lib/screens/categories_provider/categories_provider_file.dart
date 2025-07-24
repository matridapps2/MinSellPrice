import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

enum BrandsState { initial, loading, loaded, error }

class BrandsProvider extends ChangeNotifier {
  BrandsState _state = BrandsState.initial;
  List<Map<String, dynamic>> _homeGardenBrands = [];
  List<Map<String, dynamic>> _shoesApparels = [];
  String _errorMessage = '';

  // Getters
  BrandsState get state => _state;
  List<Map<String, dynamic>> get homeGardenBrands => _homeGardenBrands;
  List<Map<String, dynamic>> get shoesApparels => _shoesApparels;
  String get errorMessage => _errorMessage;

  bool get isLoaded => _state == BrandsState.loaded;
  bool get isLoading => _state == BrandsState.loading;
  bool get hasError => _state == BrandsState.error;

  Future<void> fetchBrands() async {
    if (_state == BrandsState.loading) return;

    _setState(BrandsState.loading);

    try {
      log('Fetching brands from API');
      final response = await http
          .get(Uri.parse('https://www.minsellprice.com/api/minsell-brand'))
          .timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        log('Brand API status code: ${response.statusCode}');
        final Map<String, dynamic> jsonData = json.decode(response.body);

        _homeGardenBrands = (jsonData["Home & Garden Brands"] ?? [])
            .whereType<Map<String, dynamic>>()
            .toList();

        _shoesApparels = (jsonData["Shoes & Apparels"] ?? [])
            .whereType<Map<String, dynamic>>()
            .toList();

        log('Brands loaded successfully - Home & Garden: ${_homeGardenBrands.length}, Shoes & Apparels: ${_shoesApparels.length}');
        _setState(BrandsState.loaded);
      } else {
        throw Exception('Failed to load brands: ${response.statusCode}');
      }
    } catch (e) {
      log('Error fetching brands: $e');
      _errorMessage = e.toString();
      _setState(BrandsState.error);
    }
  }

  void _setState(BrandsState newState) {
    _state = newState;
    notifyListeners();
  }

  void retry() {
    fetchBrands();
  }
}
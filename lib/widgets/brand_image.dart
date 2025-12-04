import 'dart:async';
import 'dart:developer';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:minsellprice/core/utils/constants/colors.dart';

class BrandImageWidget extends StatefulWidget {
  final Map<String, dynamic> brand;
  final double? width;
  final double? height;

  const BrandImageWidget({
    super.key,
    required this.brand,
    this.width,
    this.height,
  });

  @override
  State<BrandImageWidget> createState() => _BrandImageWidgetState();
}

class _BrandImageWidgetState extends State<BrandImageWidget> {
  late String _imageUrl1;
  late String _imageUrl2;
  late String _currentUrl;
  int _attempt = 0;

  @override
  void initState() {
    super.initState();
    _initCall();
  }

  void _initCall() async {
    await _initializeImageUrls();
  }

  Future<void> _initializeImageUrls() async {
    log('Get Image From Site');
    log('width: ${widget.width}');
    log('height: ${widget.height}');
    try {
      String brandName = widget.brand['brand_name']?.toString() ?? '';
      String brandKey = widget.brand['brand_key']?.toString() ?? '';
      int brandId = widget.brand['brand_id'] ?? 0;

      // Clean and process brand names more thoroughly
      String processedBrandName = brandName
          .trim()
          .replaceAll(RegExp(r'[^\w\s-]'),
          '') // Remove special characters except hyphens
          .replaceAll(
          RegExp(r'\s+'), '-') // Replace multiple spaces with single hyphen
          .replaceAll(
          RegExp(r'-+'), '-') // Replace multiple hyphens with single hyphen
          .replaceAll(RegExp(r'^-|-$'), '') // Remove leading/trailing hyphens
          .toLowerCase();

      String processedBrandKey = brandKey
          .trim()
          .replaceAll(RegExp(r'[^\w\s-]'),
          '') // Remove special characters except hyphens
          .replaceAll(
          RegExp(r'\s+'), '-') // Replace multiple spaces with single hyphen
          .replaceAll(
          RegExp(r'-+'), '-') // Replace multiple hyphens with single hyphen
          .replaceAll(RegExp(r'^-|-$'), '') // Remove leading/trailing hyphens
          .toLowerCase();

      _imageUrl1 =
      'https://www.minsellprice.com/Brand-logo-images/$processedBrandName.png';
      _imageUrl2 =
      'https://growth.matridtech.net/brand-logo/brands/$processedBrandKey.png';

      _currentUrl = _imageUrl1;

      log(
        'BrandImageWidget [ID:$brandId] - Brand: "$brandName", Key: "$brandKey"',
      );
      log(
        'BrandImageWidget [ID:$brandId] - Processed Brand Name: "$processedBrandName"',
      );
      log('BrandImageWidget [ID:$brandId] - URL 1: $_imageUrl1');
      log('BrandImageWidget [ID:$brandId] - URL 2: $_imageUrl2');
      log('BrandImageWidget [ID:$brandId] - Full brand data: ${widget.brand}');
    } catch (e) {
      log('Error initializing image URLs: $e');
      _currentUrl = '';
    }
  }

  void _onImageError() {
    setState(() {
      if (_attempt == 0) {
        // First failure: try second URL (growth.matridtech.net)
        _currentUrl = _imageUrl2;
        log('First URL failed, trying alternative URL: $_imageUrl2');
        _attempt++;
      } else {
        // Second failure: show placeholder
        _currentUrl = '';
        log('Both image URLs failed, showing placeholder');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: widget.width ?? double.infinity,
      height: widget.height ?? 100,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        // color: Colors.white,
      ),
      child: _currentUrl.isEmpty
          ? _buildPlaceholderWidget()
          : CachedNetworkImage(
        key: ValueKey(_currentUrl),
        // Force rebuild when URL changes
        imageUrl: _currentUrl,
        fit: BoxFit.contain,
        placeholder: (context, url) => _buildLoadingWidget(),
        errorWidget: (context, url, error) {
          log('Image load error for URL: $url, Error: $error');
          // Handle image error after frame is built
          // Execute callback after current frame is rendered
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              _onImageError();
            }
          });
          return _buildErrorWidget();
        },
      ),
    );
  }

  Widget _buildPlaceholderWidget() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.red,
        borderRadius: BorderRadius.circular(12),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.grey[100]!, Colors.grey[200]!],
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.2),
                  spreadRadius: 1,
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Icon(Icons.image, color: Colors.grey[400], size: 28),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingWidget() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.grey[50]!, Colors.grey[100]!],
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 33,
            height: 33,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  spreadRadius: 1,
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(
                  AppColors.primary.withOpacity(0.7),
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Loading...',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorWidget() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.red[50]!, Colors.red[100]!],
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.red.withOpacity(0.2),
                  spreadRadius: 1,
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Icon(
              Icons.broken_image_outlined,
              color: Colors.red[400],
              size: 24,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Image Error',
            style: TextStyle(
              color: Colors.red[600],
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
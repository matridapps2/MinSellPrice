import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:minsellprice/colors.dart';
import 'package:minsellprice/size.dart';

class BrandProductDetailScreen extends StatefulWidget {
  final String brandName;
  final String brandId;
  final int productId;

  const BrandProductDetailScreen({
    super.key,
    required this.brandName,
    required this.brandId,
    required this.productId,
  });

  @override
  State<BrandProductDetailScreen> createState() =>
      _BrandProductDetailScreenState();
}

class _BrandProductDetailScreenState extends State<BrandProductDetailScreen> {
  @override
  void initState() {
    super.initState();
    // Fetch the brand product detail when the screen initializes
    // context.read<BrandProductDetailBloc>().add(
    //       FetchBrandProductDetail(
    //         brandName: widget.brandName,
    //         brandId: widget.brandId,
    //         productId: widget.productId,
    //       ),
    //     );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.brandName} - Product Detail'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: SizedBox()
    );
  }

  Widget _buildProductDetail(dynamic brandProductDetail) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Product Information
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Product Information',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildInfoRow('Product Name',
                      brandProductDetail.productDetail.productName),
                  _buildInfoRow('Product MPN',
                      brandProductDetail.productDetail.productMpn),
                  _buildInfoRow('MSRP', brandProductDetail.productDetail.msrp),
                  _buildInfoRow(
                      'Brand', brandProductDetail.productDetail.brandName),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Vendor Products
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Vendor Products (${brandProductDetail.vendorProducts.length})',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ...brandProductDetail.vendorProducts
                      .map((vendor) => _buildVendorCard(vendor))
                      .toList(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVendorCard(dynamic vendor) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              vendor.vendorName,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 8),
            _buildInfoRow('Price', vendor.vendorpricePrice),
            _buildInfoRow('SKU', vendor.vendorSku),
            _buildInfoRow('Shipping', vendor.vendorpriceShipping),
            _buildInfoRow('Stock', vendor.vendorpriceStock.toString()),
            _buildInfoRow('Date', vendor.vendorpriceDate),
            if (vendor.deliveryText.isNotEmpty)
              _buildInfoRow('Delivery', vendor.deliveryText),
            if (vendor.vendorpriceOffers.isNotEmpty)
              _buildInfoRow('Offers', vendor.vendorpriceOffers),
          ],
        ),
      ),
    );
  }
}

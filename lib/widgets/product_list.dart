import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:minsellprice/core/utils/constants/colors.dart';
import 'package:minsellprice/core/utils/constants/size.dart';
import 'package:minsellprice/model/product_list_model_new.dart';
import 'package:minsellprice/widgets/brand_image.dart';

/// Product List Widget that displays products in a grid format
/// matching the design shown in the reference image
class ProductListWidget extends StatelessWidget {
  final List<VendorProduct> products;
  final Function(VendorProduct)? onProductTap;
  final int crossAxisCount;
  final double childAspectRatio;
  final double mainAxisSpacing;
  final double crossAxisSpacing;

  const ProductListWidget({
    super.key,
    required this.products,
    this.onProductTap,
    this.crossAxisCount = 2,
    this.childAspectRatio = 0.41,
    this.mainAxisSpacing = 16.0,
    this.crossAxisSpacing = 1.0,
  });

  @override
  Widget build(BuildContext context) {
    if (products.isEmpty) {
      return const Center(
        child: Text(
          'No products available',
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey,
          ),
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.only(bottom: 20.0),
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        mainAxisSpacing: mainAxisSpacing,
        crossAxisSpacing: crossAxisSpacing,
        childAspectRatio: childAspectRatio,
      ),
      itemCount: products.length,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4.0),
          child: _ProductCard(
            product: products[index],
            onTap: onProductTap,
          ),
        );
      },
    );
  }
}

/// Individual Product Card Widget
class _ProductCard extends StatelessWidget {
  final VendorProduct product;
  final Function(VendorProduct)? onTap;

  const _ProductCard({
    required this.product,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 0.0),
      child: GestureDetector(
        onTap: () => onTap?.call(product),
        child: Container(
          width: w * 0.45,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                spreadRadius: 2,
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Product Image
              _buildProductImage(),
              // Product Details
              Expanded(
                child: _buildProductDetails(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProductImage() {
    final imageUrl = _getProperImageUrl(product.productImage);

    return Container(
      width: double.infinity,
      height: w * 0.45,
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
        child: CachedNetworkImage(
          imageUrl: imageUrl,
          fit: BoxFit.contain,
          placeholder: (context, url) => Container(
            color: Colors.grey[200],
            child: Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(
                  AppColors.primary.withOpacity(0.7),
                ),
                strokeWidth: 2,
              ),
            ),
          ),
          errorWidget: (context, url, error) => Container(
            color: Colors.grey[200],
            child: Icon(
              Icons.image_not_supported_outlined,
              size: w * 0.08,
              color: Colors.grey[400],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProductDetails() {
    // Parse prices and discount
    final msrpStr = product.msrp.toString();
    final msrp = double.tryParse(
            msrpStr == '--' || msrpStr.isEmpty || msrpStr == 'null'
                ? '0'
                : msrpStr) ??
        0.0;
    final firstVendorPriceStr = product.firstVendorPrice.toString();
    final firstVendorPrice = double.tryParse(
            firstVendorPriceStr == '--' || firstVendorPriceStr.isEmpty
                ? '0'
                : firstVendorPriceStr) ??
        0.0;

    // Get discount percent from product, or calculate it if not available
    double discountPercent = product.discountPercent;

    // If discount is 0 but we have both MSRP and current price, calculate discount
    if (discountPercent == 0.0 &&
        msrp > 0 &&
        firstVendorPrice > 0 &&
        msrp > firstVendorPrice) {
      discountPercent = ((msrp - firstVendorPrice) / msrp) * 100;
      // Round to 1 decimal place to avoid floating point precision issues
      discountPercent = double.parse(discountPercent.toStringAsFixed(1));
    }

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Brand Logo
          _buildBrandLogo(),
          const SizedBox(height: 8),
          // Model Number
          _buildModelNumber(),
          const SizedBox(height: 6),
          // Product Name/Description
          _buildProductName(),
          //const Spacer(),
          const SizedBox(height: 15),

          // Price Section
          _buildPriceSection(firstVendorPrice, msrp, discountPercent),
        ],
      ),
    );
  }

  Widget _buildBrandLogo() {
    return Container(
      width: 90,
      height: 60,
      margin: const EdgeInsets.only(bottom: 4),
      child: BrandImageWidget(
        brand: {
          'brand_name': product.brandName,
          'brand_key': product.brandName.toLowerCase().replaceAll(' ', '-'),
          'brand_id': product.productId,
        },
        width: 90,
        height: 60,
      ),
    );
  }

  Widget _buildModelNumber() {
    return Text(
      product.productMpn.toUpperCase(),
      style: const TextStyle(
        fontFamily: 'Segoe UI',
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: Colors.black87,
      ),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildProductName() {
    return Container(
      height: 48,
      child: Text(
        product.productName.isEmpty
            ? 'Product Name Not Available'
            : product.productName,
        style: const TextStyle(
          color: Colors.black87,
          fontFamily: 'Segoe UI',
          fontSize: 16,
          height: 1.3,
          fontWeight: FontWeight.w500,
        ),
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  Widget _buildPriceSection(
    double currentPrice,
    double originalPrice,
    double discountPercent,
  ) {
    // Hide MSRP and discount when discount is 0% (or effectively 0%)
    // Use epsilon for floating point comparison
    const double discountEpsilon =
        0.1; // 0.1% discount threshold - hide if discount is less than 0.1%

    final discountIsZero = discountPercent.abs() < discountEpsilon;

    // Hide if discount is 0% or effectively 0%
    final shouldShowMsrpAndDiscount = !discountIsZero;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Price Row
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Current Price (discounted) - large and bold
            Flexible(
              child: Text(
                '\$${_formatPrice(currentPrice.toString())}',
                style: const TextStyle(
                  color: Colors.black87,
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Segoe UI',
                ),
              ),
            ),
            // Original Price (strikethrough) - only show if discounted and not same as current price
            if (discountPercent > 0 &&
                originalPrice > 0 &&
                shouldShowMsrpAndDiscount)
              Flexible(
                child: Text(
                  '\$${_formatPrice(originalPrice.toString())}',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 16,
                    decoration: TextDecoration.lineThrough,
                    decorationColor: Colors.grey[600],
                    fontFamily: 'Segoe UI',
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 10),
        // Discount Badge - only show if there's a discount and not same as MSRP
        if (discountPercent > 0 && shouldShowMsrpAndDiscount) ...[
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: AppColors.disCountColorBackground, // 232 245 233 100
              borderRadius: BorderRadius.circular(4),
              border:
                  Border.all(color: AppColors.disCountColorBorder, width: 1),
            ),
            child: Text(
              '${discountPercent.toStringAsFixed(0)}% OFF',
              style: const TextStyle(
                color: AppColors.disCountColor,
                fontSize: 16,
                fontWeight: FontWeight.bold,
                fontFamily: 'Segoe UI',
              ),
            ),
          ),
        ],
      ],
    );
  }

  String _getProperImageUrl(String? imageUrl) {
    if (imageUrl == null || imageUrl.isEmpty) {
      return 'https://www.minsellprice.com/assets/no_image/no_image.jpg';
    }

    if (imageUrl.startsWith('//')) {
      return 'https:$imageUrl';
    }

    if (!imageUrl.startsWith('http://') && !imageUrl.startsWith('https://')) {
      return 'https://$imageUrl';
    }
    return imageUrl;
  }

  /// Format price with 2 decimal places (no comma separators)
  String _formatPrice(String price) {
    try {
      // Remove any existing formatting and parse the number
      final cleanPrice = price.replaceAll(RegExp(r'[^\d.]'), '');
      final double? priceValue = double.tryParse(cleanPrice);

      if (priceValue == null) {
        return price; // Return original if parsing fails
      }

      // Format with 2 decimal places, no comma separators
      return priceValue.toStringAsFixed(2);
    } catch (e) {
      return price; // Return original if formatting fails
    }
  }
}

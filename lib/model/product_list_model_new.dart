import 'dart:convert';

ProductListModelNew productListModelNewFromJson(String str) {
  return ProductListModelNew.fromJson(json.decode(str));
}

String productListModelNewToJson(ProductListModelNew data) {
  return json.encode(data.toJson());
}

//****************************************************************************//
///                  MODEL MADE USING RESPONSE OF LIVE API                   ///
//****************************************************************************//

class ProductListModelNew {
  final String brandName;
  final String brandKey;
  final int productCount;
  final int pageNo;
  final int previousPage;
  final int totalNoOfPages;
  final List<VendorProduct> brandProduct;

  ProductListModelNew({
    required this.brandName,
    required this.brandKey,
    required this.productCount,
    required this.pageNo,
    required this.previousPage,
    required this.totalNoOfPages,
    required this.brandProduct,
  });

  factory ProductListModelNew.fromJson(Map<String, dynamic> json) {
    return ProductListModelNew(
      brandName: json['brandName'] ?? '',
      brandKey: json['brand_key'] ?? '',
      productCount: json['productCount'] ?? 0,
      pageNo: int.tryParse(json['page_no']?.toString() ?? '') ?? 1,
      previousPage: json['previous_page'] ?? 1,
      totalNoOfPages: json['total_no_of_pages'] ?? 1,
      brandProduct: List<VendorProduct>.from(
        (json['brand_product'] ?? []).map((x) => VendorProduct.fromJson(x)),
      ),
    );
  }

  Map<String, dynamic> toJson() => {
        'brandName': brandName,
        'brand_key': brandKey,
        'productCount': productCount,
        'page_no': pageNo,
        'previous_page': previousPage,
        'total_no_of_pages': totalNoOfPages,
        'brand_product':
            List<dynamic>.from(brandProduct.map((x) => x.toJson())),
      };
}

class VendorProduct {
  //**************************************************************************//
  ///         FIELDS FROM BRAND PRODUCTS API RESPONSE                        ///
  //**************************************************************************//
  final int productId;
  final String vendorpricePrice;
  final String brandName;
  final String vendorName;
  final String msrp;
  final int vendorIdCount;
  final String vendorpriceDate;
  final String vendorUrl;
  final String productMpn;
  final String productName;
  final String? productImage;
  final String? imageName;
  final int totalCount;

  VendorProduct({
    //************************************************************************//
    ///         FIELDS FROM BRAND PRODUCTS API RESPONSE                      ///
    //************************************************************************//
    required this.productId,
    required this.vendorpricePrice,
    required this.vendorName,
    required this.msrp,
    required this.vendorIdCount,
    required this.vendorpriceDate,
    required this.vendorUrl,
    required this.productMpn,
    required this.productName,
    this.productImage,
    this.imageName,
    required this.totalCount,
    required this.brandName,

  });

  factory VendorProduct.fromJson(Map<String, dynamic> json) => VendorProduct(
        //************************************************************************//
        ///         FIELDS FROM BRAND PRODUCTS API RESPONSE                    ///
        //************************************************************************//

        productId: json["product_id"] ?? 0,
        vendorpricePrice: json["vendorprice_price"] ?? '--',
        vendorName: json["vendor_name"] ?? '--',
        vendorIdCount: json["vendorIdCount"] ?? 0,
        vendorpriceDate: json["vendorprice_date"] ?? '--',
        msrp: json['msrp'] ?? '--',
        brandName: json["brand_name"] ?? '--',
        vendorUrl: json["vendor_url"] ?? '--',
        productMpn: json["product_mpn"] ?? '--',
        productName: json["product_name"] ?? '--',
        productImage: json["product_image"],
        imageName: json["image_name"],
        totalCount: json["total_count"] ?? 0,
      );

  Map<String, dynamic> toJson() {
    return {
      "product_id": productId,
      "vendorprice_price": vendorpricePrice,
      "vendor_name": vendorName,
      "vendorIdCount": vendorIdCount,
      "vendorprice_date": vendorpriceDate,
      'msrp': msrp,
      "brand_name": brandName,
      "vendor_url": vendorUrl,
      "product_mpn": productMpn,
      "product_name": productName,
      "product_image": productImage,
      "image_name": imageName,
      "total_count": totalCount,
    };
  }
}


/*Widget _buildPriceSection(VendorProduct product) {
  // Check if MSRP is null or empty
  bool hasMsrp = product.msrp != '--' &&
      product.msrp != 'null' &&
      product.msrp.isNotEmpty;

  return Container(
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(10),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Show MSRP with line-through only if MSRP is available
        if (hasMsrp)
          Padding(
            padding: const EdgeInsets.only(right: 10.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  '\$${_formatPrice(product.msrp)}',
                  style: const TextStyle(
                    color: Colors.black,
                    fontFamily: 'Segoe UI',
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    decoration: TextDecoration.lineThrough,
                    decorationThickness: 2,
                  ),
                ),
              ],
            ),
          ),
        // Show vendor price
        Padding(
          padding: const EdgeInsets.only(right: 10.0, top: 5),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                '\$${_formatPrice(product.vendorpricePrice)}',
                style: const TextStyle(
                  color: Colors.black,
                  fontFamily: 'Segoe UI',
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: w * .02,
                vertical: w * .015,
              ),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.primary,
                    AppColors.primary.withOpacity(0.8),
                  ],
                ),
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.3),
                    spreadRadius: 1,
                    blurRadius: 3,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.storefront_outlined,
                    color: Colors.white,
                    size: 18,
                  ),
                  const SizedBox(width: 2),
                  Text(
                    '${product.vendorIdCount}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 19,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(width: 2),
                  Text(
                    product.vendorIdCount == 1 ? 'vendor' : 'vendors',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    ),
  );
}*/

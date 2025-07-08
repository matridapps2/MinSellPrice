import 'dart:convert';
import 'dart:developer';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:minsellprice/colors.dart' show AppColors;
import 'package:minsellprice/model/product_list_model_new.dart'
    show ProductListModelNew, VendorProduct;
import 'package:minsellprice/reposotory_services/network_reposotory.dart'
    show NetworkCalls;
import 'package:minsellprice/screens/tushar_screen/model/product_details_model.dart';
import 'package:minsellprice/services/extra_functions.dart'
    show ColorExtension, getUniqueBrands;
import 'package:minsellprice/size.dart';

class ProductDetailsScreen extends StatefulWidget {
  final int productId;
  final String brandName;
  final String productMPN;
  final productImage;

  const ProductDetailsScreen({
    super.key,
    required this.productId,
    required this.brandName,
    required this.productMPN,
    required this.productImage,
  });

  @override
  State<ProductDetailsScreen> createState() => _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends State<ProductDetailsScreen> {
  ProductDetailsModel? productDetails;
  bool isLoading = true;
  String? errorMessage;
  List<String> filterVendor = [];
  List<String> uniqueVendors = [];
  List<VendorProduct> brandProducts = [];
  List<VendorProduct> tempProductList = [];
  List<VendorProduct> finalList = [];
  List<ProductListModelNew> brandDetails = [];
  final ScrollController _scrollController = ScrollController();
  String loadingMessage = '';

  @override
  void initState() {
    super.initState();
    _initCall();
  }

  void _initCall() async {
    await _fetchProductDetails();
    await _fetchBrandProducts();
  }

  Future<void> _fetchProductDetails() async {
    try {
      setState(() {
        isLoading = true;
        errorMessage = null;
      });

      final details = await ProductDetailsApiService.getProductDetails(
        brandName: widget.brandName,
        productMPN: widget.productMPN,
        productId: widget.productId,
      );

      if (mounted) {
        setState(() {
          productDetails = details;
        });
        // Debug: Print the fetched data
        log('Single API Data is');
        log('${productDetails?.toJson()}');
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          errorMessage = e.toString();
          isLoading = false;
        });
      }
    }
  }

  Future<void> _fetchBrandProducts() async {
    log('_fetchBrandProducts method is running');
    try {
      List<VendorProduct> allFetchedProducts = [];
      int pageNumber = 1;
      int maxPages = 5;
      int targetProducts = 20;

      while (pageNumber <= maxPages &&
          allFetchedProducts.length < targetProducts) {
        log('Fetching page $pageNumber');

        if (mounted) {
          setState(() {
            loadingMessage = 'Loading products... ';
          });
        }

        final allProductsResponse = await NetworkCalls()
            .getProductListByBrandName(widget.brandName.toString(), pageNumber);
        final Map<String, dynamic> decoded =
            jsonDecode(allProductsResponse ?? '{}');

        final List<dynamic> jsonList = decoded['brand_product'] ?? [];

        if (jsonList.isEmpty) {
          log('No more products found on page $pageNumber');
          break;
        }

        final List<VendorProduct> fetchedProducts =
            jsonList.map((e) => VendorProduct.fromJson(e)).toList();

        allFetchedProducts.addAll(fetchedProducts);
        log('Page $pageNumber: ${fetchedProducts.length} products, Total: ${allFetchedProducts.length}');
        if (pageNumber < maxPages &&
            allFetchedProducts.length < targetProducts) {
          await Future.delayed(const Duration(milliseconds: 100));
        }

        pageNumber++;
      }
      final List<VendorProduct> filteredProducts = allFetchedProducts
          .where((product) => product.productId != widget.productId)
          .toList();

      final List<VendorProduct> limitedProducts = filteredProducts.length > 20
          ? filteredProducts.take(20).toList()
          : filteredProducts;

      List<String> uniqueVendorsLocal = getUniqueBrands(limitedProducts);
      uniqueVendorsLocal =
          uniqueVendorsLocal.where((element1) => element1 != '--').toList();
      List<String> tempList = [];
      for (final vendor in uniqueVendorsLocal) {
        tempList.add(
            '$vendor Total Product(s): ${limitedProducts.where((element) => element.vendorName == vendor).toList().length} ');
      }

      if (mounted) {
        setState(() {
          brandProducts = limitedProducts;
          uniqueVendors = tempList;
          tempProductList = limitedProducts;
          finalList = limitedProducts;
          filterVendor = [];
          loadingMessage = 'Loading complete!';
          isLoading = false;
        });
      }

      log('Total Products fetched from all pages: ${allFetchedProducts.length}');
      log('Products after filtering current product: ${filteredProducts.length}');
      log('Final products to show: ${limitedProducts.length}');
      log('FinalList length: ${finalList.length}');
    } catch (e) {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
      log('Error in fetching Brand Product list: $e');
    }
  }

  Future<void> _refreshProductDetails() async {
    await _fetchProductDetails();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.brandName),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        actionsPadding: EdgeInsets.only(right: 15),
        actions: const [
          Icon(
            Icons.shopping_cart,
            size: 35,
            color: AppColors.primary,
          )
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refreshProductDetails,
        child: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    if (isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            Text(
              loadingMessage,
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    if (errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red,
            ),
            const SizedBox(height: 16),
            Text(
              'Error loading product details',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              errorMessage!,
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _fetchProductDetails,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (productDetails?.data == null) {
      return const Center(
        child: Text('No product details available'),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildProductImages(),
          const SizedBox(height: 16),
          _buildProductHeader(),
          const SizedBox(height: 16),
          _buildProductDetails(),
          const SizedBox(height: 16),
          _buildPriceAndRating(),
          const SizedBox(height: 16),
          _buildMoreName(),
          const SizedBox(height: 16),
          _buildMoreDesign(),
        ],
      ),
    );
  }

  Widget _buildProductHeader() {
    final data = productDetails!.data!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(data.productName ?? 'Product Name Not Available',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildProductImages() {
    final apiImages = productDetails!.data!.images;
    final productName = productDetails!.data!.productName ?? '';
    final fallbackImage = widget.productImage;

    if (apiImages != null && apiImages.isNotEmpty) {
      return SizedBox(
        height: 200,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: apiImages.length,
          itemBuilder: (context, index) {
            return Stack(
              alignment: Alignment.bottomLeft,
              children: [
                Container(
                  margin: const EdgeInsets.only(right: 8),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      apiImages[index],
                      width: 200,
                      height: 200,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          width: 200,
                          height: 200,
                          color: Colors.grey[200],
                          child: const Icon(
                            Icons.broken_image,
                            color: Colors.grey,
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      );
    }

    if (fallbackImage != null && fallbackImage.toString().isNotEmpty) {
      return Stack(
        alignment: Alignment.bottomLeft,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(
              fallbackImage,
              width: double.infinity,
              height: w * .5,
              fit: BoxFit.fitHeight,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  width: double.infinity,
                  height: 200,
                  color: Colors.grey[200],
                  child: const Icon(
                    Icons.broken_image,
                    color: Colors.grey,
                  ),
                );
              },
            ),
          ),
        ],
      );
    }

    return Stack(
      alignment: Alignment.bottomLeft,
      children: [
        Container(
          height: 200,
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(
            Icons.image_not_supported,
            size: 64,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }

  Widget _buildProductDetails() {
    final data = productDetails!.data!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CachedNetworkImage(
          imageUrl:
              'https://www.minsellprice.com/Brand-logo-images/${data.brandName.toString().replaceAll(' ', '-').toLowerCase()}.png',
          width: 150,
          placeholder: (context, url) =>
              const Center(child: CircularProgressIndicator()),
          errorWidget: (context, url, error) => Image.asset(
            'assets/images/no_image.png',
            width: 150,
          ),
        ),
      ],
    );
  }

  Widget _buildPriceAndRating() {
    final data = productDetails!.data!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '\$${data.price?.toStringAsFixed(2) ?? '--'}',
          style: const TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            ...List.generate(
                4,
                (index) =>
                    const Icon(Icons.star, color: Colors.amber, size: 20)),
            const Icon(Icons.star_border, color: Colors.amber, size: 20),
            const SizedBox(width: 8),
            Text(
              '(1 Reviews)', // You can use data.reviewCount if available
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMoreName() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'More From ${widget.brandName}',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildMoreDesign() {
    log('_buildMoreDesign method is running');
    log('finalList length: ${finalList.length}');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          controller: _scrollController,
          child: Row(
            children: finalList.map((product) {
              return Container(
                width: 160,
                margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                child: Card(
                  elevation: 3,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ProductDetailsScreen(
                            productId: product.productId,
                            brandName: widget.brandName ?? 'Unknown Brand',
                            productMPN: product.productMpn,
                            productImage: product.productImage,
                          ),
                        ),
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              product.productImage ?? '',
                              height: 80,
                              width: double.infinity,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  Image.asset('assets/no_image/no_image.jpg',
                                      height: 80, fit: BoxFit.cover),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            product.productName,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 14),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              ...List.generate(
                                  4,
                                  (index) => const Icon(Icons.star,
                                      color: Colors.amber, size: 14)),
                              const Icon(Icons.star_border,
                                  color: Colors.amber, size: 14),
                              const SizedBox(width: 4),
                              Text(
                                '(1)',
                                style: const TextStyle(
                                    fontSize: 12, color: Colors.grey),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '\$${product.vendorpricePrice}',
                            style: const TextStyle(
                              color: Colors.black87,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}

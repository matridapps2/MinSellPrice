import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:minsellprice/core/utils/constants/size.dart';

class ShimmerDesign extends StatefulWidget {
  const ShimmerDesign({
    super.key,
    required this.isDone,
  });

  final bool isDone;

  @override
  State<ShimmerDesign> createState() => _DashboardShimmer();
}

class _DashboardShimmer extends State<ShimmerDesign> {
  @override
  Widget build(BuildContext context) {
    // When isDone is false, show only brands grid shimmer (used in dashboard brands section)
    if (!widget.isDone) {
      return const BrandsShimmer();
    }

    // When isDone is true, show search bars shimmer (used in home page initial loading)
    return Container(
      color: const Color.fromARGB(255, 245, 245, 245),
      width: w,
      child: Column(
        children: [
          // Product Search Bar Shimmer
          _buildSearchBarShimmer('products'),

          // Brand Search Bar Shimmer
          _buildSearchBarShimmer('brands'),
        ],
      ),
    );
  }

  Widget _buildSearchBarShimmer(String type) {
    return Container(
      padding: const EdgeInsets.only(top: 1, bottom: 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.white, Colors.grey[50]!],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Shimmer.fromColors(
        baseColor: Colors.grey[300]!,
        highlightColor: Colors.grey[100]!,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Container(
            height:
                56, // Matches TextFormField height (contentPadding vertical: 16 * 2 + some space)
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  spreadRadius: 1,
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                // Icon placeholder (left side)
                Container(
                  margin: const EdgeInsets.all(8),
                  padding: const EdgeInsets.all(8),
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.grey[200]!,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                const SizedBox(width: 8),
                // Text placeholder
                Expanded(
                  child: Container(
                    height: 20,
                    decoration: BoxDecoration(
                      color: Colors.grey[200]!,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class BrandsShimmer extends StatelessWidget {
  const BrandsShimmer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Home & Garden Section Header Shimmer
        Container(
          margin: const EdgeInsets.only(left: 20.0, right: 20.0, top: 10.0),
          child: Shimmer.fromColors(
            baseColor: Colors.grey[300]!,
            highlightColor: Colors.grey[100]!,
            child: Row(
              children: [
                Container(
                  width: 4,
                  height: 30,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title shimmer
                      Container(
                        width: 180,
                        height: 28,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      const SizedBox(height: 4),
                      // Subtitle shimmer
                      Container(
                        width: 140,
                        height: 16,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),
        // Brands Grid Shimmer
        Shimmer.fromColors(
          baseColor: Colors.grey[300]!,
          highlightColor: Colors.grey[100]!,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childAspectRatio: 0.85,
              ),
              itemCount: 8, // Show 8 shimmer items (4 rows x 2 columns)
              itemBuilder: (context, index) => Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      spreadRadius: 2,
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.05),
                      spreadRadius: 1,
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      flex: 3,
                      child: Container(
                        margin: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.grey[200]!,
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16.0,
                          vertical: 12.0,
                        ),
                        child: Container(
                          height: 20,
                          decoration: BoxDecoration(
                            color: Colors.grey[200]!,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class CategoryShimmer extends StatelessWidget {
  const CategoryShimmer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Header Shimmer
          Shimmer.fromColors(
            baseColor: Colors.grey[300]!,
            highlightColor: Colors.grey[100]!,
            child: Row(
              children: [
                Container(
                  width: 5,
                  height: 28,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
                const SizedBox(width: 14),
                Container(
                  width: 180,
                  height: 28,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          // Slider Container Shimmer with horizontal scroll
          SizedBox(
            height: 220,
            child: Shimmer.fromColors(
              baseColor: Colors.grey[300]!,
              highlightColor: Colors.grey[100]!,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 4),
                itemCount: 3,
                itemBuilder: (context, index) {
                  // Calculate width similar to slider viewportFraction (0.92)
                  final screenWidth = MediaQuery.of(context).size.width;
                  final cardWidth =
                      (screenWidth - 32) * 0.92; // Account for margins

                  return Container(
                    width: cardWidth,
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: Colors.white,
                      border: Border.all(
                        color: Colors.grey[200]!,
                        width: 2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.15),
                          spreadRadius: 0,
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          spreadRadius: 0,
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(18),
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          // Background shimmer
                          Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  Colors.grey[200]!,
                                  Colors.grey[300]!,
                                ],
                              ),
                            ),
                          ),
                          // Bottom overlay shimmer for text area
                          Positioned(
                            bottom: 0,
                            left: 0,
                            right: 0,
                            child: Container(
                              height: 100,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    Colors.transparent,
                                    Colors.black.withOpacity(0.6),
                                  ],
                                ),
                              ),
                              padding: const EdgeInsets.all(24),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  // Category name shimmer
                                  Container(
                                    width: 150,
                                    height: 24,
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.8),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  // Button shimmer
                                  Container(
                                    width: 100,
                                    height: 32,
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.6),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ProductSectionShimmer extends StatelessWidget {
  final double? height;

  const ProductSectionShimmer({
    Key? key,
    this.height,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final sectionHeight = height ?? 380.0;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Header Shimmer
          Shimmer.fromColors(
            baseColor: Colors.grey[300]!,
            highlightColor: Colors.grey[100]!,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Container(
                        width: 5,
                        height: 28,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Container(
                          width: 180,
                          height: 28,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: 100,
                  height: 20,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          // Products Horizontal Scroll Shimmer
          SizedBox(
            height: sectionHeight,
            child: Shimmer.fromColors(
              baseColor: Colors.grey[300]!,
              highlightColor: Colors.grey[100]!,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 4),
                itemCount: 3,
                itemBuilder: (context, index) {
                  return Container(
                    width: 280,
                    margin: const EdgeInsets.symmetric(horizontal: 8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.grey[200]!, width: 1),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.1),
                          spreadRadius: 1,
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Product Image Shimmer
                        Container(
                          height: 180,
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.grey[200]!,
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(16),
                              topRight: Radius.circular(16),
                            ),
                          ),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.grey[300]!,
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                        // Brand Logo Shimmer
                        Padding(
                          padding: const EdgeInsets.only(
                              left: 12, top: 8, bottom: 4),
                          child: Container(
                            height: 40,
                            width: 80,
                            decoration: BoxDecoration(
                              color: Colors.grey[200]!,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        ),
                        // Product Details Shimmer
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Model Number Shimmer
                                Container(
                                  width: 120,
                                  height: 16,
                                  decoration: BoxDecoration(
                                    color: Colors.grey[200]!,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                ),
                                const SizedBox(height: 6),
                                // Product Name Shimmer
                                Container(
                                  width: double.infinity,
                                  height: 16,
                                  decoration: BoxDecoration(
                                    color: Colors.grey[200]!,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Container(
                                  width: 200,
                                  height: 16,
                                  decoration: BoxDecoration(
                                    color: Colors.grey[200]!,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                ),
                                const SizedBox(height: 12),
                                // Price Shimmer
                                Container(
                                  width: 100,
                                  height: 24,
                                  decoration: BoxDecoration(
                                    color: Colors.grey[200]!,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                // Discount Badge Shimmer
                                Container(
                                  width: 80,
                                  height: 24,
                                  decoration: BoxDecoration(
                                    color: Colors.grey[200]!,
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class HomeBoxDealsGridShimmer extends StatelessWidget {
  const HomeBoxDealsGridShimmer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Header Shimmer
          Shimmer.fromColors(
            baseColor: Colors.grey[300]!,
            highlightColor: Colors.grey[100]!,
            child: Row(
              children: [
                Container(
                  width: 5,
                  height: 28,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
                const SizedBox(width: 14),
                Container(
                  width: 180,
                  height: 28,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          // Products Grid Shimmer (2x2)
          Shimmer.fromColors(
            baseColor: Colors.grey[300]!,
            highlightColor: Colors.grey[100]!,
            child: GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childAspectRatio: 0.72,
              ),
              itemCount: 4,
              itemBuilder: (context, index) {
                return Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey[200]!, width: 1),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.1),
                        spreadRadius: 1,
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Product Image Shimmer
                      Container(
                        height: 130,
                        width: double.infinity,
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.grey[200]!,
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(16),
                            topRight: Radius.circular(16),
                          ),
                        ),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.grey[300]!,
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                      // Brand Logo Shimmer
                      Padding(
                        padding:
                            const EdgeInsets.only(left: 8, top: 4, bottom: 2),
                        child: Container(
                          height: 28,
                          width: 70,
                          decoration: BoxDecoration(
                            color: Colors.grey[200]!,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ),
                      // Product Details Shimmer
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 2),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Model Number Shimmer
                                  Container(
                                    width: 100,
                                    height: 10,
                                    decoration: BoxDecoration(
                                      color: Colors.grey[200]!,
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  // Product Name Shimmer
                                  Container(
                                    width: double.infinity,
                                    height: 11,
                                    decoration: BoxDecoration(
                                      color: Colors.grey[200]!,
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Container(
                                    width: 120,
                                    height: 11,
                                    decoration: BoxDecoration(
                                      color: Colors.grey[200]!,
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                  ),
                                ],
                              ),
                              Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Price Shimmer
                                  Container(
                                    width: 80,
                                    height: 15,
                                    decoration: BoxDecoration(
                                      color: Colors.grey[200]!,
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                  ),
                                  const SizedBox(height: 3),
                                  // Discount Badge Shimmer
                                  Container(
                                    width: 60,
                                    height: 18,
                                    decoration: BoxDecoration(
                                      color: Colors.grey[200]!,
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          // View All Deals Link Shimmer
          const SizedBox(height: 16),
          Center(
            child: Shimmer.fromColors(
              baseColor: Colors.grey[300]!,
              highlightColor: Colors.grey[100]!,
              child: Container(
                width: 120,
                height: 20,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

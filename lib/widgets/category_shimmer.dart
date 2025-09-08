import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

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
    return Stack(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product Search Bar Shimmer - Show when isDone is true
            Visibility(
              visible: widget.isDone,
              child: _buildSearchBarShimmer(),
            ),

            // Brand Search Bar Shimmer - Show when isDone is true
            Visibility(
              visible: widget.isDone,
              child: _buildSearchBarShimmer(),
            ),

            /// Brands Grid Shimmer - Show when isDone is false (loading state)
            Visibility(
              visible: !widget.isDone,
              child: const SizedBox(height: 25),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 8.0),
              child: BrandsShimmer(),
            ),
          ],
        ),
        Positioned(
          left: 10,
          right: 10,
          bottom: 50,
          child: Builder(
            builder: (BuildContext context) {
              final MediaQueryData mediaQuery = MediaQuery.of(context);
              final double bottomPadding = mediaQuery.padding.bottom;
              if (bottomPadding > 0) {
                return Container(
                  height: bottomPadding,
                  color: Colors.blueGrey,
                );
              } else {
                return const SizedBox.shrink();
              }
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSearchBarShimmer() {
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
            height: 20,
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
      children: [
        Shimmer.fromColors(
          baseColor: Colors.grey[300]!,
          highlightColor: Colors.grey[100]!,
          child: GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 5,
              crossAxisSpacing: 5,
              childAspectRatio: 1,
            ),
            itemCount: 50,
            itemBuilder: (context, index) => Card(
              elevation: 0.5,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
                side: const BorderSide(color: Colors.grey),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    flex: 3,
                    child: Container(
                      margin: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: Container(
                      margin: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      width: double.infinity,
                      height: 16,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

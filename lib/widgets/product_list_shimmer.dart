import 'package:flutter/material.dart';
import 'package:minsellprice/core/utils/constants/colors.dart';
import 'package:minsellprice/core/utils/constants/size.dart';

class ProductListShimmer extends StatelessWidget {
  const ProductListShimmer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10.0),
      child: Wrap(
        runSpacing: 10,
        children: List.generate(
          6,
          (index) => _buildShimmerCard(),
        ),
      ),
    );
  }

  Widget _buildShimmerCard() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0),
      child: Container(
        width: w * .45,
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
            _buildShimmerImage(),
            _buildShimmerDetails(),
          ],
        ),
      ),
    );
  }

  Widget _buildShimmerImage() {
    return Container(
      width: double.infinity,
      height: w * .45,
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
        child: _buildShimmerContainer(
          width: double.infinity,
          height: w * .45,
          borderRadius: 0,
        ),
      ),
    );
  }

  Widget _buildShimmerDetails() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Product Name Shimmer
          _buildShimmerContainer(
            width: double.infinity,
            height: w * .25,
            borderRadius: 8,
          ),
          const SizedBox(height: 8),

          // MPN Shimmer
          _buildShimmerContainer(
            width: w * .3,
            height: h * .06,
            borderRadius: 6,
          ),
          const SizedBox(height: 13),

          // Price Section Shimmer
          _buildPriceSectionShimmer(),
        ],
      ),
    );
  }

  Widget _buildPriceSectionShimmer() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Price Shimmer
        _buildShimmerContainer(
          width: w * .25,
          height: 24,
          borderRadius: 6,
        ),
        const SizedBox(height: 10),

        // Vendor Count Badge Shimmer
        _buildShimmerContainer(
          width: w * .35,
          height: 32,
          borderRadius: 8,
        ),
      ],
    );
  }

  Widget _buildShimmerContainer({
    required double width,
    required double height,
    required double borderRadius,
  }) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.grey[300]!,
            Colors.grey[100]!,
            Colors.grey[300]!,
          ],
          stops: const [0.0, 0.5, 1.0],
        ),
      ),
      child: ShaderMask(
        shaderCallback: (bounds) {
          return LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.grey[300]!,
              Colors.grey[100]!,
              Colors.grey[300]!,
            ],
            stops: const [0.0, 0.5, 1.0],
          ).createShader(bounds);
        },
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(borderRadius),
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}

class ProductCardShimmer extends StatefulWidget {
  const ProductCardShimmer({Key? key}) : super(key: key);

  @override
  State<ProductCardShimmer> createState() => _ProductCardShimmerState();
}

class _ProductCardShimmerState extends State<ProductCardShimmer>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _animation = Tween<double>(begin: -1.0, end: 2.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.repeat();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0),
      child: Container(
        width: w * .45,
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
            _buildAnimatedShimmerImage(),
            _buildAnimatedShimmerDetails(),
          ],
        ),
      ),
    );
  }

  Widget _buildAnimatedShimmerImage() {
    return Container(
      width: double.infinity,
      height: w * .45,
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
        child: _buildAnimatedShimmerContainer(
          width: double.infinity,
          height: w * .45,
          borderRadius: 0,
        ),
      ),
    );
  }

  Widget _buildAnimatedShimmerDetails() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Product Name Shimmer
          _buildAnimatedShimmerContainer(
            width: double.infinity,
            height: w * .25,
            borderRadius: 8,
          ),
          const SizedBox(height: 8),

          // MPN Shimmer
          _buildAnimatedShimmerContainer(
            width: w * .3,
            height: h * .06,
            borderRadius: 6,
          ),
          const SizedBox(height: 13),

          // Price Section Shimmer
          _buildAnimatedPriceSectionShimmer(),
        ],
      ),
    );
  }

  Widget _buildAnimatedPriceSectionShimmer() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Price Shimmer
        _buildAnimatedShimmerContainer(
          width: w * .25,
          height: 24,
          borderRadius: 6,
        ),
        const SizedBox(height: 10),

        // Vendor Count Badge Shimmer
        _buildAnimatedShimmerContainer(
          width: w * .35,
          height: 32,
          borderRadius: 8,
        ),
      ],
    );
  }

  Widget _buildAnimatedShimmerContainer({
    required double width,
    required double height,
    required double borderRadius,
  }) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(borderRadius),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.grey[300]!,
                Colors.grey[100]!,
                Colors.grey[300]!,
              ],
              stops: [
                _animation.value - 0.5,
                _animation.value,
                _animation.value + 0.5,
              ].map((value) => value.clamp(0.0, 1.0)).toList(),
            ),
          ),
        );
      },
    );
  }
}

class ProductListLoadingShimmer extends StatelessWidget {
  final int itemCount;

  const ProductListLoadingShimmer({
    Key? key,
    this.itemCount = 8,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildShimmerAppBar(),
      body: Column(
        children: [
          const SizedBox(height: 5),
          _buildShimmerProductCountBadge(),
          const SizedBox(height: 5),
          Expanded(
            child: _buildShimmerProductGrid(),
          ),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildShimmerAppBar() {
    return AppBar(
      surfaceTintColor: Colors.white,
      toolbarHeight: .18 * w,
      backgroundColor: Colors.white,
      centerTitle: false,
      title: _buildShimmerContainer(
        width: w * .54,
        height: 24,
        borderRadius: 6,
      ),
      actions: [
        _buildShimmerContainer(
          width: .23 * w,
          height: .23 * w,
          borderRadius: 8,
        ),
      ],
    );
  }

  Widget _buildShimmerProductCountBadge() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          const SizedBox(width: 12),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[200]!, width: 1),
              ),
              child: Row(
                children: [
                  _buildShimmerContainer(
                    width: 40,
                    height: 40,
                    borderRadius: 8,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildShimmerContainer(
                          width: w * .2,
                          height: 16,
                          borderRadius: 4,
                        ),
                        const SizedBox(height: 4),
                        _buildShimmerContainer(
                          width: w * .25,
                          height: 18,
                          borderRadius: 4,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShimmerProductGrid() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10.0),
      child: Wrap(
        runSpacing: 10,
        children: List.generate(
          itemCount,
          (index) => const ProductCardShimmer(),
        ),
      ),
    );
  }

  Widget _buildShimmerContainer({
    required double width,
    required double height,
    required double borderRadius,
  }) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        color: Colors.grey[300],
      ),
    );
  }
}

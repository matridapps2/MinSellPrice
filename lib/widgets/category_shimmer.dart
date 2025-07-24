import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';


class BrandsShimmer extends StatelessWidget {
  const BrandsShimmer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
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
        itemCount: 12,
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
                  margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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
    );
  }
}

class BrandsSectionShimmer extends StatelessWidget {
  final String title;

  const BrandsSectionShimmer({
    Key? key,
    required this.title,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 20.0),
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 27,
              fontWeight: FontWeight.bold,
              fontFamily: 'Segoe UI',
            ),
          ),
        ),

        const SizedBox(height: 25),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: BrandsShimmer(),
        ),
      ],
    );
  }
}
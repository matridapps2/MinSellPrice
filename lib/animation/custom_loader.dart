import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class CustomLoader extends StatelessWidget {
  const CustomLoader({super.key, this.width, this.height});
  final double? width, height;
  @override
  Widget build(BuildContext context) {
    return LottieBuilder.asset(
      'assets/lottie_animations/custom_loader_for_msp_ecommerce.json',
      repeat: true,
      reverse: true,
      width: width??50,
      height: height??50,
      fit: BoxFit.fill,
    );
  }
}

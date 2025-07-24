import 'package:auto_size_text/auto_size_text.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:minsellprice/core/utils/constants/size.dart';

class CustomLoader extends StatelessWidget {
  const CustomLoader({
    Key? key,
    this.width,
    this.height,
    this.loaderString,
    required this.vendorName,
    required this.imageString,
    required bool isAssetImage,
  })  : _isAssetImage = isAssetImage,
        super(key: key);

  final double? width, height;
  final String vendorName, imageString;
  final bool _isAssetImage;
  final String? loaderString;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _isAssetImage == true
            ? imageString.contains('https')
                ? Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15.0),
                    child: CachedNetworkImage(
                      imageUrl: imageString,
                      // width: w * .7,
                    ),
                  )
                : Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15.0),
                    child: Image.asset(
                      imageString,
                      width: w * .5,
                    ),
                  )
            : Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15.0),
                child: CachedNetworkImage(
                  imageUrl: imageString,
                  // width: w * .7,
                ),
              ),
        const SizedBox(
          height: 10,
        ),
        AutoSizeText(
          loaderString ?? '',
          textAlign: TextAlign.center,
          style: GoogleFonts.montserrat(
            fontSize: w * 0.055,
            color: Colors.black,
            // decoration: TextDecoration.underline,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(
          height: 10,
        ),
        Lottie.asset(
          'assets/lottie_animations/loading_bar.json',
          repeat: true,
          animate: true,
          width: width ?? 80,
          height: height ?? 80,
          frameRate: FrameRate(
            60,
          ),
        ),
      ],
    );
  }
}

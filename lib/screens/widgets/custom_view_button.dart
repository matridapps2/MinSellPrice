import 'package:auto_size_text/auto_size_text.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shoppingmegamart/app.dart';
import 'package:shoppingmegamart/services/extra_functions.dart';
import 'package:shoppingmegamart/size.dart';

class BuyAtButton extends StatelessWidget {
  const BuyAtButton(
      {super.key, this.height, this.width, required this.imageUrl});

  final double? width, height;
  final String imageUrl;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width ?? w * .4,
      height: height ?? w * .16,
      child: Stack(
        children: [
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              width: width ?? w * .4,
              height: height ?? w * .13,
              decoration: BoxDecoration(
                border: Border.all(
                  color: primaryColor,
                  width: 3,
                ),
                borderRadius: BorderRadius.circular(
                  3,
                ),
              ),
            ),
          ),
          Align(
            alignment: Alignment.topLeft,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4.0),
              child: Container(
                color: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 6,
                  vertical: 2,
                ),
                child: Text(
                  'Buy At',
                  style: TextStyle(
                    color: primaryColor,
                    fontFamily: 'MyriadPro-BoldCond',
                    fontSize: w * .043,
                    wordSpacing: .1,
                    letterSpacing: 0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding:
                const EdgeInsets.only(top: 20.0, left: 8, right: 8, bottom: 3),
            child: Center(
              child: CachedNetworkImage(
                imageUrl:
                    '${AppInfo.kBaseUrl(stagingSelector: 0)}vendor-logo/$imageUrl.jpg',
                height: h * 0.04,
                fit: BoxFit.fill,
                errorWidget: (_, c, e) => SizedBox(
                  child: Container(
                    width: w * .42,
                    padding: const EdgeInsets.all(2),
                    color: Colors.black,
                    child: Center(
                      child: AutoSizeText(
                        imageUrl,
                        maxLines: 1,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.albertSans(
                          color: Colors.white,
                          fontSize: w * .053,
                          letterSpacing: 0,
                          fontWeight: FontWeight.bold,
                          // fontFamily: 'JT Marnie Light',
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

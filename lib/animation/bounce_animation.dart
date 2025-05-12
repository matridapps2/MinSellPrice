import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shoppingmegamart/screens/widgets/sample_product_screen.dart';
import 'package:shoppingmegamart/size.dart';

class BounceAnimation extends StatefulWidget {
  const BounceAnimation({
    super.key,
    required this.finalPrice,
    required this.basePrice,
    required this.discountPrice,
    required this.shipping,
    required this.rp,
    required this.vendorName,
  });

  final String finalPrice, basePrice, discountPrice, shipping, rp, vendorName;

  @override
  State<BounceAnimation> createState() => _BounceAnimationState();
}

class _BounceAnimationState extends State<BounceAnimation>
    with TickerProviderStateMixin {
  late AnimationController _raisedButtonController,
      _raisedBounceController,
      _titleController,
      _titleController2,
      _finalPriceController,
      _finalPriceSlideController;

  late Animation<Offset> _titleAnimation,
      _titleAnimation2,
      _finalPriceSlideAnimation;

  late Animation<double> _finalPriceAnimation;
  double turns = 0.0;

  @override
  void initState() {
    // TODO: implement initState

    _titleController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2, milliseconds: 500),
    );
    _titleController2 = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4, milliseconds: 400),
    );
    _raisedButtonController = AnimationController(
      vsync: this,
      duration: const Duration(
        seconds: 4,
        milliseconds: 400,
      ),
    );
    _raisedBounceController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4, milliseconds: 500),
    );

    _finalPriceController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..addListener(() {
        setState(() {});
      });
    _finalPriceSlideController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..addListener(() {
        setState(() {});
      });
    _finalPriceAnimation = Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(
            parent: _finalPriceController, curve: Curves.easeOutSine));
    _finalPriceSlideAnimation =
        Tween<Offset>(begin: const Offset(0, .1), end: const Offset(0, -0.03))
            .animate(CurvedAnimation(
                parent: _finalPriceSlideController, curve: Curves.easeOutSine));

    _titleAnimation = Tween<Offset>(
      begin: const Offset(-1, 0.0),
      end: const Offset(-0.008, 0.0),
    ).animate(
      CurvedAnimation(
        parent: _titleController,
        curve: Curves.easeInOutBack,
      ),
    );
    _titleAnimation2 = Tween<Offset>(
      begin: const Offset(-1, 0.0),
      end: const Offset(-.008, 0.0),
    ).animate(
      CurvedAnimation(
        parent: _titleController2,
        curve: Curves.easeInOutBack,
      ),
    );

    _titleController.forward().whenComplete(() => null);
    _titleController2.forward().whenComplete(() {
      _raisedBounceController.forward();
      _raisedBounceController.repeat(reverse: true);
    });
    _finalPriceController.forward();
    setState(() => turns = 1.0);
    _finalPriceSlideController.forward();
    _finalPriceController.forward();
    _raisedButtonController.forward().whenComplete(() {});
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: w,
      // height: 100,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 8.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SlideTransition(
                      position: _titleAnimation,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Transform(
                          transform: Matrix4.skewX(-0.2),
                          child: Container(
                            width: w * .38,
                            decoration: BoxDecoration(
                                color: fromHex('#74b1b6').withOpacity(.8),
                                borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(10),
                                  bottomRight: Radius.circular(10),
                                )),
                            child: Center(
                              child: Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 6),
                                child: AutoSizeText(
                                  'Raise Price',
                                  style: GoogleFonts.montserrat(
                                    fontSize: 0.035 * w,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    SlideTransition(
                      position: _titleAnimation2,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 25.0,
                        ),
                        child: Transform(
                          transform: Matrix4.skewX(-0.2),
                          child: Container(
                            width: w * .38,
                            decoration: BoxDecoration(
                                color: fromHex('#015761').withOpacity(.8),
                                borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(10),
                                  bottomRight: Radius.circular(10),
                                )),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 6),
                              child: Center(
                                child: AutoSizeText(
                                  '\$${widget.rp}',
                                  style: GoogleFonts.montserrat(
                                    fontSize: 0.035 * w,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
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
              ),
              Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 5.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8.0,
                          ),
                          child: Image.asset(
                            widget.vendorName.toLowerCase().contains('af')
                                ? 'assets/af-supply.png'
                                : 'assets/home-perfect.png',
                            width: 0.3 * w,
                            height: 0.07 * w,
                            fit: BoxFit.fill,
                          ),
                        )
                      ],
                    ),
                  ),
                  const SizedBox(
                    height: 5,
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      FadeTransition(
                        opacity: _finalPriceAnimation,
                        child: SlideTransition(
                          position: _finalPriceSlideAnimation,
                          child: Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 8.0),
                            child: Tooltip(
                              decoration: BoxDecoration(
                                  color: Colors.grey,
                                  borderRadius: BorderRadius.circular(10)),
                              textAlign: TextAlign.center,
                              richMessage: TextSpan(
                                text: 'Final Price\n',
                                style: GoogleFonts.montserrat(
                                  fontSize: 0.035 * w,
                                  color: Colors.blue,
                                  fontWeight: FontWeight.bold,
                                ),
                                children: [
                                  TextSpan(
                                    text: 'Base Price + Shipping\n',
                                    style: GoogleFonts.montserrat(
                                      fontSize: 0.035 * w,
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  TextSpan(
                                    text: '- Discount',
                                    style: GoogleFonts.montserrat(
                                      fontSize: 0.035 * w,
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              triggerMode: TooltipTriggerMode.tap,
                              child: RichText(
                                text: TextSpan(
                                  text: '\$${widget.finalPrice}\n',
                                  style: GoogleFonts.montserrat(
                                    fontSize: 0.04 * w,
                                    color: Colors.blue,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  children: [
                                    TextSpan(
                                      text: '\$${widget.basePrice}',
                                      style: GoogleFonts.montserrat(
                                        fontSize: 0.035 * w,
                                        color: Colors.black,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      children: [
                                        TextSpan(
                                          text: ' + \$${widget.shipping}',
                                          style: GoogleFonts.montserrat(
                                            fontSize: 0.035 * w,
                                            color: Colors.black,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        TextSpan(
                                          text: widget.discountPrice == '0.00'
                                              ? ''
                                              : ' - \$${widget.discountPrice}',
                                          style: GoogleFonts.montserrat(
                                            fontSize: 0.035 * w,
                                            color: Colors.black,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    )
                                  ],
                                ),
                                textAlign: widget.discountPrice == '0.00'
                                    ? TextAlign.center
                                    : TextAlign.start,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    // TODO: implement dispose

    _raisedButtonController.dispose();
    _raisedBounceController.dispose();
    _titleController.dispose();
    _finalPriceController.dispose();
    _finalPriceSlideController.dispose();
    // _baseShippingController.dispose();
    super.dispose();
  }
}

class TiltedRectanglePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.blue // Set the fill color
      ..style = PaintingStyle.fill;

    final path = Path()
      ..moveTo(10, 0) // Starting point (top-left)
      ..lineTo(size.width + 25, 0) // Top-right corner
      ..lineTo(size.width, size.height) // Bottom-right corner
      ..lineTo(size.width, size.height) // Bottom-left corner
      ..close(); // Close the path to form a tilted rectangle

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}

class CurvedPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    var paint = Paint()
      ..color = Colors.teal
      ..strokeWidth = 15;

    var path = Path();

    path.moveTo(0, size.height * 0.7);
    path.quadraticBezierTo(size.width * 0.25, size.height * 0.7,
        size.width * 0.5, size.height * 0.8);
    path.quadraticBezierTo(size.width * 0.75, size.height * 0.9,
        size.width * 1.0, size.height * 0.8);
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}

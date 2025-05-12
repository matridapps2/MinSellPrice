import 'package:flutter/material.dart';

class SlideDownAnimationDemo extends StatefulWidget {
  const SlideDownAnimationDemo({super.key, required this.child});
  final Widget child;
  @override
  // ignore: library_private_types_in_public_api
  _SlideDownAnimationDemoState createState() => _SlideDownAnimationDemoState();
}

class _SlideDownAnimationDemoState extends State<SlideDownAnimationDemo>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _offsetAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );

    _offsetAnimation = Tween<Offset>(
      begin: const Offset(0, -1), // Start from off the screen above
      end: const Offset(0, 0), // End at the default position
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.ease,
    ));
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}

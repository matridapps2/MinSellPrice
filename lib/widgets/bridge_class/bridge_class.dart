import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:minsellprice/screens/spalsh_screen/splash_screen.dart';
import 'package:minsellprice/core/utils/constants/colors.dart';

class BridgeClass extends StatefulWidget {
  const BridgeClass({super.key});

  @override
  State<BridgeClass> createState() => _BridgeClassState();

  /* This method will returns the State object of the nearest ancestor StatefulWidget widget that is an instance of the given type T.*/
  static void createRebirth({required BuildContext context}) {
    context.findAncestorStateOfType<_BridgeClassState>()!.restartApp();
  }
}

class _BridgeClassState extends State<BridgeClass> {
  UniqueKey key = UniqueKey();
  bool _showSplash = false;

  @override
  void initState() {
    super.initState();
    // Show splash screen after minimal delay to prevent white screen
    Future.delayed(const Duration(milliseconds: 10), () {
      if (mounted) {
        setState(() {
          _showSplash = true;
        });
      }
    });
  }

  void restartApp() {
    setState(() => key = UniqueKey());
  }

  @override
  Widget build(BuildContext context) {
    return KeyedSubtree(
      key: key,
      child:
          _showSplash ? const SplashScreen() : _buildImmediateLoadingScreen(),
    );
  }

  Widget _buildImmediateLoadingScreen() {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.primary,
              AppColors.primary.withOpacity(0.8),
              AppColors.primary.withOpacity(0.6),
            ],
          ),
        ),
        child: const Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
          ),
        ),
      ),
    );
  }
}

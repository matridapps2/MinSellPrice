import 'package:flutter/material.dart';
import 'package:minsellprice/screens/splash_screen/splash_screen.dart';
import 'package:minsellprice/core/utils/constants/colors.dart';
import 'package:minsellprice/services/app_lifecycle_service.dart';

class BridgeClass extends StatefulWidget {
  const BridgeClass({super.key});

  @override
  State<BridgeClass> createState() => _BridgeClassState();
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

        // Set context for lifecycle service after splash screen is shown
        Future.delayed(const Duration(milliseconds: 100), () {
          AppLifecycleService().setCurrentContext(context);
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

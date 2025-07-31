import 'package:flutter/material.dart';

class NavigationService {
  // Singleton pattern - ensures only one instance exists
  static final NavigationService _instance = NavigationService._internal();
  factory NavigationService() => _instance;
  NavigationService._internal();

  // Global navigator key for navigation from anywhere in the app
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  // Open the notification screen from anywhere in the app
  void navigateToNotifications() {
    if (navigatorKey.currentState != null) {
      navigatorKey.currentState!.pushNamed('/notifications');
    }
  }

  // Navigate to specific product details page
  void navigateToProductDetails(String productId) {
    if (navigatorKey.currentState != null) {
      navigatorKey.currentState!.pushNamed('/product/$productId');
    }
  }

  // Navigate to offers/special deals section
  void navigateToOffers() {
    if (navigatorKey.currentState != null) {
      navigatorKey.currentState!.pushNamed('/offers');
    }
  }

  // Navigate to home and clear navigation stack
  void navigateToHome() {
    if (navigatorKey.currentState != null) {
      navigatorKey.currentState!.pushNamedAndRemoveUntil(
        '/',
        (route) => false,
      );
    }
  }

  // Get the global navigator key for external use
  GlobalKey<NavigatorState> getNavigatorKey() {
    return navigatorKey;
  }
}

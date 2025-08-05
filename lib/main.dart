import 'dart:developer';
import 'dart:io';
import 'package:connection_notifier/connection_notifier.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:minsellprice/screens/dashboard_screen/notification_screen/notification_screen.dart';
import 'package:minsellprice/widgets/bridge_class/bridge_class.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:minsellprice/services/background_service.dart';
import 'package:minsellprice/services/notification_service.dart';
import 'package:minsellprice/services/notification_permission_service.dart';
import 'package:minsellprice/services/navigation_service.dart';
import 'package:minsellprice/core/utils/firebase/firebase_options.dart';
import 'package:provider/provider.dart';
import 'core/utils/firebase/auth_provider.dart' as my_auth;
import 'core/utils/constants/colors.dart';

const Color primaryColor = AppColors.primary;

// Firebase messaging background handler
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  log('Handling a background message: ${message.messageId}');
}

// Immediate loading screen to prevent white screen
class ImmediateLoadingScreen extends StatelessWidget {
  const ImmediateLoadingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
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
      ),
    );
  }
}

void main() async {
  // Minimal initialization - only what's absolutely necessary
  WidgetsFlutterBinding.ensureInitialized();

  // Run the app immediately with loading screen - no delays
  runApp(
    ChangeNotifierProvider(
      create: (_) => my_auth.AuthProvider(),
      child: ConnectionNotifier(
        connectionNotificationOptions: const ConnectionNotificationOptions(
          alignment: AlignmentDirectional.topCenter,
        ),
        child: MaterialApp(
          navigatorKey: NavigationService().getNavigatorKey(),
          title: 'FlutterMinSellPrice',
          debugShowMaterialGrid: false,
          debugShowCheckedModeBanner: false,
          routes: {
            '/notifications': (context) => const NotificationScreen(),
          },
          theme: ThemeData(
            fontFamily: 'Segoe UI',
            primarySwatch: MaterialColor(_d90310, colorCodes),
            useMaterial3: true,
            primaryColor: Colors.white,
            textSelectionTheme: const TextSelectionThemeData(
              selectionColor: Colors.blue,
              cursorColor: Colors.blue,
            ),
            cardColor: Colors.white,
            appBarTheme:
                AppBarTheme(iconTheme: IconThemeData(color: primaryColor)),
            cardTheme: CardTheme(
              color: Colors.white,
              margin: const EdgeInsets.all(2),
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
          home: const SafeArea(
            top: true,
            child: BridgeClass(),
          ),
        ),
      ),
    ),
  );

  // Initialize everything in background after app is running
  _initializeEverythingInBackground();

  // Request notification permission after app is running
  _requestNotificationPermission();
}

// Initialize everything in background
Future<void> _initializeEverythingInBackground() async {
  try {
    // Set orientation
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);

    // Initialize Firebase
    await Firebase.initializeApp(
        options: Platform.isAndroid
            ? DefaultFirebaseOptions.android
            : DefaultFirebaseOptions.ios);

    // Setup Firebase messaging background handler
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // Get device token after Firebase is initialized
    try {
      String? deviceToken = await FirebaseMessaging.instance.getToken();
      if (deviceToken != null) {
        //  log('Device Token: $deviceToken');
      } else {
        log('Failed to get device token');
      }
    } catch (e) {
      log('Error getting device token: $e');
    }

    // Initialize notification service
    await NotificationService().initialize();

    // Initialize background service
    FlutterBackgroundService().invoke("setAsBackground");
    await initializeService();

    // Set gesture binding
    GestureBinding.instance.resamplingEnabled = true;

    // Android-specific initializations
    if (Platform.isAndroid) {
      await AndroidInAppWebViewController.setWebContentsDebuggingEnabled(true);

      var swAvailable = await AndroidWebViewFeature.isFeatureSupported(
          AndroidWebViewFeature.SERVICE_WORKER_BASIC_USAGE);
      var swInterceptAvailable = await AndroidWebViewFeature.isFeatureSupported(
          AndroidWebViewFeature.SERVICE_WORKER_SHOULD_INTERCEPT_REQUEST);

      if (swAvailable && swInterceptAvailable) {
        AndroidServiceWorkerController serviceWorkerController =
            AndroidServiceWorkerController.instance();

        await serviceWorkerController
            .setServiceWorkerClient(AndroidServiceWorkerClient(
          shouldInterceptRequest: (request) async {
            if (kDebugMode) {
              print(request);
            }
            return null;
          },
        ));
      }
    }

    log('All services initialized successfully in background');
  } catch (e) {
    log('Background service initialization error: $e');
  }
}

// Request notification permission
Future<void> _requestNotificationPermission() async {
  try {
    // Wait a bit for the app to fully load
    await Future.delayed(const Duration(seconds: 2));

    // Check and request notification permission
    final permissionService = NotificationPermissionService();

    // For testing: uncomment the next line to reset permission status
    // await permissionService.resetPermissionStatus();

    final granted = await permissionService.checkAndRequestPermission();

    if (granted) {
      log('Notification permission granted');
    } else {
      log('Notification permission denied or not requested');
    }
  } catch (e) {
    log('Error requesting notification permission: $e');
  }
}

const int _d90310 = 0xFFd90310;

Map<int, Color> colorCodes = {
  50: const Color(_d90310).withOpacity(.1),
  100: const Color(_d90310).withOpacity(.2),
  200: const Color(_d90310).withOpacity(.3),
  300: const Color(_d90310).withOpacity(.4),
  400: const Color(_d90310).withOpacity(.5),
  500: const Color(_d90310).withOpacity(.6),
  600: const Color(_d90310).withOpacity(.7),
  700: const Color(_d90310).withOpacity(.8),
  800: const Color(_d90310).withOpacity(.9),
  900: const Color(_d90310).withOpacity(1),
};

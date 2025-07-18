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
import 'package:permission_handler/permission_handler.dart';
import 'package:minsellprice/services/extra_functions.dart';
import 'package:minsellprice/screens/tushar_screen/dashboard_screen/dashboard_screen.dart';
import 'package:minsellprice/permissions/permissions.dart';
import 'package:minsellprice/screens/widgets/bridge_class/bridge_class.dart';
import 'package:minsellprice/services/background_service.dart';
import 'package:minsellprice/firebase_options.dart';
import 'package:provider/provider.dart';
import 'auth_provider.dart' as my_auth; // adjust path if needed
import 'package:minsellprice/notification_page/notification_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

import 'colors.dart';

const Color primaryColor = AppColors.primary;

Future<void> permission() async {
  if (await Permission.scheduleExactAlarm.isDenied) {
    await Permission.scheduleExactAlarm.request();
  }
}

bool _notificationClicked = false;
String _initialNotificationData = '';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
      options: Platform.isAndroid
          ? DefaultFirebaseOptions.android
          : DefaultFirebaseOptions.ios);

  requestNotificationPermission();
  setupFlutterNotifications();

  FlutterBackgroundService().invoke("setAsBackground");
  await initializeService();
  setupRemoteConfig();
  GestureBinding.instance.resamplingEnabled = true;

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

  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);

  FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) async {
    final notificationJson = message.notification != null
        ? jsonEncode({
      'title': message.notification?.title ?? '',
      'message': message.notification?.body ?? '',
      'image': message.notification?.android?.imageUrl ??
          message.notification?.apple?.imageUrl ??
          message.data['image'] ??
          '',
      'name': message.data['name'] ?? '',
      'time': DateTime.now().toIso8601String(),
      'isRead': false,
    })
        : '';
    if (notificationJson.isNotEmpty) {
      final prefs = await SharedPreferences.getInstance();
      final List<String> stored = prefs.getStringList('notifications') ?? [];
      stored.insert(0, notificationJson); // newest first
      await prefs.setStringList('notifications', stored);
      log('Notification added to shared preferences:');
      log(notificationJson);
    }
    navigatorKey.currentState?.push(
      MaterialPageRoute(
        builder: (context) => NotificationPage(),
      ),
    );
  });

  String? token = await FirebaseMessaging.instance.getToken();
  log("FCM Token: $token");

  runApp(
    ChangeNotifierProvider(
      create: (_) => my_auth.AuthProvider(),
      child: ConnectionNotifier(
        connectionNotificationOptions: const ConnectionNotificationOptions(
          alignment: AlignmentDirectional.topCenter,
        ),
        child: MaterialApp(
          navigatorKey: navigatorKey,
          title: 'FlutterMinSellPrice',
          debugShowMaterialGrid: false,
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            fontFamily: 'Segoe UI',
            primarySwatch: MaterialColor(_d90310, colorCodes),
            useMaterial3: true,
            // Disable Material 3 if needed
            // Customize other theme properties as desired
            // For example, you can set the primary color:
            primaryColor: Colors.white,
            // Or adjust the text selection theme:
            textSelectionTheme: const TextSelectionThemeData(
              selectionColor: Colors.blue,
              cursorColor: Colors.blue,
            ),
            cardColor: Colors.white,
            appBarTheme:
            AppBarTheme(iconTheme: IconThemeData(color: primaryColor)),
            // Set the card theme:
            cardTheme: CardTheme(
              color: Colors.white,
              margin: const EdgeInsets.all(2),
              // Set the desired card color
              elevation: 4, // Adjust elevation if needed
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8), // Customize card shape
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
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (_notificationClicked) {
        // Prepare notification data as JSON string
        final notificationJson = _initialNotificationData.isNotEmpty
            ? jsonEncode({
          'title': '',
          'message': _initialNotificationData,
          'image':
          '', // Add image URL if available in initial notification
          'name': '',
          'time': DateTime.now().toIso8601String(),
          'isRead': false,
        })
            : '';
        if (notificationJson.isNotEmpty) {
          final prefs = await SharedPreferences.getInstance();
          final List<String> stored =
              prefs.getStringList('notifications') ?? [];
          stored.insert(0, notificationJson);
          await prefs.setStringList('notifications', stored);
          log('Notification added to shared preferences (from _notificationClicked):');
          log(notificationJson);
        }
        navigatorKey.currentState?.push(
          MaterialPageRoute(builder: (context) => NotificationPage()),
        );
        _notificationClicked = false;
        _initialNotificationData = '';
      }
    });
    return ConnectionNotifier(
      connectionNotificationOptions: const ConnectionNotificationOptions(
        alignment: AlignmentDirectional.topCenter,
      ),
      child: MaterialApp(
        navigatorKey: navigatorKey,
        title: 'MinSellPrice',
        debugShowMaterialGrid: false,
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          fontFamily: 'Segoe UI',
          primarySwatch: MaterialColor(_d90310, colorCodes),
          useMaterial3: true,
          // Disable Material 3 if needed
          // Customize other theme properties as desired
          // For example, you can set the primary color:
          primaryColor: Colors.white,
          // Or adjust the text selection theme:
          textSelectionTheme: const TextSelectionThemeData(
            selectionColor: Colors.blue,
            cursorColor: Colors.blue,
          ),
          cardColor: Colors.white,
          appBarTheme:
          AppBarTheme(iconTheme: IconThemeData(color: primaryColor)),
          // Set the card theme:
          cardTheme: CardTheme(
            color: Colors.white,
            margin: const EdgeInsets.all(2),
            // Set the desired card color
            elevation: 4, // Adjust elevation if needed
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8), // Customize card shape
            ),
          ),
        ),
        home: const SafeArea(
          top: true,
          child: BridgeClass(),
        ),
      ),
    );
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

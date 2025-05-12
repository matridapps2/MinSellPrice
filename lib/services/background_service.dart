import 'dart:async';
import 'dart:developer';
import 'dart:io';
import 'dart:ui';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_background_service_android/flutter_background_service_android.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> initializeService() async {
  final service = FlutterBackgroundService();

// setupFlutterNotifications();

  await service.configure(
    androidConfiguration: AndroidConfiguration(
      onStart: onStart,
      autoStart: true,
      isForegroundMode: false,
      notificationChannelId: 'my_foreground',
      initialNotificationTitle: 'AWESOME SERVICE',
      initialNotificationContent: 'Initializing',
      foregroundServiceNotificationId: 888,
    ),
    iosConfiguration: IosConfiguration(
      autoStart: true,
      onForeground: onStart,
      onBackground: onIosBackground,
    ),
  );

  service.startService();
}

// run app from xcode, then from xcode menu, select Simulate Background Fetch

@pragma('vm:entry-point')
Future<bool> onIosBackground(ServiceInstance service) async {
  WidgetsFlutterBinding.ensureInitialized();
  DartPluginRegistrant.ensureInitialized();

  SharedPreferences preferences = await SharedPreferences.getInstance();
  await preferences.reload();
  final log = preferences.getStringList('log') ?? <String>[];
  log.add(DateTime.now().toIso8601String());
  await preferences.setStringList('log', log);

  return true;
}

/*Notification Data API */
late AndroidNotificationChannel channel;

/// Initialize the [FlutterLocalNotificationsPlugin] package.
late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;
bool isFlutterLocalNotificationsInitialized = false;

@pragma('vm:entry-point')
void notificationTapBackground(NotificationResponse notificationResponse) {
  // navigatorKey.currentState!.push(MaterialPageRoute(builder: (context)=>MyHomePage()));
  // ignore: avoid_print
  log('notification(${notificationResponse.id}) action tapped: '
      '${notificationResponse.actionId} with'
      ' payload: ${notificationResponse.payload}');
  if (notificationResponse.input?.isNotEmpty ?? false) {
    // ignore: avoid_print
    log('notification action tapped with input: ${notificationResponse.input}');
  }
}

Future<void> setupFlutterNotifications() async {
  channel = const AndroidNotificationChannel(
    'high_importance_channel', // id
    'High Importance Notifications', // title

    description: 'This channel is used for important notifications.',
    // description
    importance: Importance.high,
  );
  if (isFlutterLocalNotificationsInitialized) {
    return;
  } else {
    flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
    var initializationSettingsAndroid =
        const AndroidInitializationSettings('ic_stat_notifications_active');
    var initializationSettingsIOS = const DarwinInitializationSettings(requestSoundPermission: false,
      requestBadgePermission: false,

      requestAlertPermission: false, );
    var initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );
    flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onDidReceiveBackgroundNotificationResponse: notificationTapBackground);
  }


  /// We use this channel in the `AndroidManifest.xml` file to override the
  /// default FCM channel to enable heads up notifications.
  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);
  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
      IOSFlutterLocalNotificationsPlugin>()
      ?.requestPermissions(
    alert: true,
    badge: true,
    sound: true,
  );

  isFlutterLocalNotificationsInitialized = true;
}

void showFlutterNotification(RemoteMessage message) async {
  String? imageUrl = _getImageUrl(message.notification!);

  String? pictureUrl = imageUrl != null
      ? await _downloadAndSavePicture(imageUrl, 'random.png')
      : '';

  flutterLocalNotificationsPlugin.show(
      121, '', '', _buildDetails(message, pictureUrl, imageUrl != null));
}

String? _getImageUrl(RemoteNotification notification) {
  if (Platform.isIOS && notification.apple != null) {
    return notification.apple?.imageUrl;
  }
  if (Platform.isAndroid && notification.android != null) {
    return notification.android?.imageUrl;
  }
  return null;
}

Future<String?> _downloadAndSavePicture(String? url, String fileName) async {
  if (url == null) return null;
  final Directory directory = await getApplicationDocumentsDirectory();
  final String filePath = '${directory.path}/$fileName';
  final response = await get(Uri.parse(url));
  final File file = File(filePath);
  await file.writeAsBytes(response.bodyBytes);
  return filePath;
}

NotificationDetails _buildDetails(
    RemoteMessage message, String? picturePath, bool showBigPicture) {
  final AndroidNotificationDetails androidPlatformChannelSpecifics =
      AndroidNotificationDetails(
    '_channel.id',
    '_channel.name',
    channelDescription: ' _channel.description',
    styleInformation:
        _buildBigPictureStyleInformation(message, picturePath, showBigPicture),
    importance: Importance.max,
    icon: "ic_stat_notifications_active",
  );

  // final IOSNotificationDetails iOSPlatformChannelSpecifics = IOSNotificationDetails(
  //   attachments: [if (picturePath != null) IOSNotificationAttachment(picturePath)],
  // );

  final NotificationDetails details = NotificationDetails(
    android: androidPlatformChannelSpecifics,
    // iOS: iOSPlatformChannelSpecifics,
  );

  return details;
}

BigPictureStyleInformation? _buildBigPictureStyleInformation(
  RemoteMessage message,
  String? picturePath,
  bool showBigPicture,
) {
  if (picturePath == null) return null;
  final FilePathAndroidBitmap filePath = FilePathAndroidBitmap(picturePath);
  return BigPictureStyleInformation(
    showBigPicture ? filePath : const FilePathAndroidBitmap("empty"),
    largeIcon: filePath,
    contentTitle: message.notification!.title,
    htmlFormatContentTitle: true,
    summaryText: message.notification!.body,
    htmlFormatSummaryText: true,
  );
}

void onDidReceiveNotificationResponse(
    NotificationResponse notificationResponse) async {
  final String? payload = notificationResponse.payload;
  if (notificationResponse.payload != null) {
    debugPrint('notification payload: $payload');
  }
  Fluttertoast.showToast(msg: payload!);
  // Navigator.push(context, route)
}

/*End*/

@pragma('vm:entry-point')
void onStart(ServiceInstance service) async {
  DartPluginRegistrant.ensureInitialized();

  SharedPreferences preferences = await SharedPreferences.getInstance();
  await preferences.setString("hello", "world");

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  if (service is AndroidServiceInstance) {
    service.on('setAsForeground').listen((event) {
      service.setAsForegroundService();
    });

    service.on('setAsBackground').listen((event) {
      service.setAsBackgroundService();
    });
  }

  service.on('stopService').listen((event) {
    service.stopSelf();
  });

  // returnNotificationData();

  Timer.periodic(const Duration(hours: 6), (timer) async {
    final deviceInfo = DeviceInfoPlugin();
    String? device;
    if (Platform.isAndroid) {
      final androidInfo = await deviceInfo.androidInfo;
      device = androidInfo.model;
    }

    if (Platform.isIOS) {
      final iosInfo = await deviceInfo.iosInfo;
      device = iosInfo.model;
    }
    // DateTime dateTime = DateTime.now();
    // bool isTime = dateTime.hour == 10 && dateTime.minute==0 && dateTime.second==0;

    // returnNotificationData();
    service.invoke(
      'update',
      {
        "current_date": DateTime.now().toIso8601String(),
        "device": device,
      },
    );
  });
}

class BackgroundServiceClass extends StatefulWidget {
  const BackgroundServiceClass({Key? key}) : super(key: key);

  @override
  State<BackgroundServiceClass> createState() => _BackgroundServiceClassState();
}

class _BackgroundServiceClassState extends State<BackgroundServiceClass> {
  String text = "Stop Service";

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Service App'),
        ),
        body: Column(
          children: [
            StreamBuilder<Map<String, dynamic>?>(
              stream: FlutterBackgroundService().on('update'),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                final data = snapshot.data!;
                String? device = data["device"];
                DateTime? date = DateTime.tryParse(data["current_date"]);
                return Column(
                  children: [
                    Text(device ?? 'Unknown'),
                    Text(date.toString()),
                  ],
                );
              },
            ),
            ElevatedButton(
              child: const Text("Foreground Mode"),
              onPressed: () {
                FlutterBackgroundService().invoke("setAsForeground");
              },
            ),
            ElevatedButton(
              child: const Text("Background Mode"),
              onPressed: () {
                FlutterBackgroundService().invoke("setAsBackground");
              },
            ),
            ElevatedButton(
              child: Text(text),
              onPressed: () async {
                final service = FlutterBackgroundService();
                var isRunning = await service.isRunning();
                if (isRunning) {
                  service.invoke("stopService");
                } else {
                  service.startService();
                }

                if (!isRunning) {
                  text = 'Stop Service';
                } else {
                  text = 'Start Service';
                }
                setState(() {});
              },
            ),
            const Expanded(
              child: LogView(),
            ),
          ],
        ),
      ),
    );
  }
}

class LogView extends StatefulWidget {
  const LogView({Key? key}) : super(key: key);

  @override
  State<LogView> createState() => _LogViewState();
}

class _LogViewState extends State<LogView> {
  late final Timer timer;
  List<String> logs = [];

  @override
  void initState() {
    super.initState();
    timer = Timer.periodic(const Duration(seconds: 1), (timer) async {
      final SharedPreferences sp = await SharedPreferences.getInstance();
      await sp.reload();
      logs = sp.getStringList('log') ?? [];
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: logs.length,
      itemBuilder: (context, index) {
        final log = logs.elementAt(index);
        return Text(log);
      },
    );
  }
}

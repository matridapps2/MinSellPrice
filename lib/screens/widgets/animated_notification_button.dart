import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:minsellprice/reposotory_services/database/database_functions.dart';
import 'package:minsellprice/services/background_service.dart';
import 'package:sqflite/sqflite.dart';

class AnimatedNotificationButton extends StatefulWidget {
  final String productName, productData;
  final int vendorIdProductId, productSKU, isLiked, vendorId;
  int notifiedIntValue;
  final Database database;

  AnimatedNotificationButton(
      {super.key,
      required this.productName,
      required this.productData,
      required this.vendorIdProductId,
      required this.isLiked,
      required this.productSKU,
      required this.database,
      required this.vendorId,
      required this.notifiedIntValue});

  @override
  State<AnimatedNotificationButton> createState() =>
      _AnimatedNotificationButtonState();
}

class _AnimatedNotificationButtonState extends State<AnimatedNotificationButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _lottieController;

  int _currIndex = 0;

  @override
  void initState() {
    setState(() {
      _currIndex = widget.notifiedIntValue;
    });
    _lottieController =
        AnimationController(vsync: this, duration: const Duration(seconds: 3));
    super.initState();
  }

  Future<void> _handleNotificationClick(
      {required String title, required String content}) async {
    await DatabaseHelper().addAndUpdateProduct(
        db: widget.database,
        vendorId: int.parse('${widget.vendorId}${widget.productSKU}'),
        productSku: widget.productSKU,
        isLiked: widget.isLiked,
        isNotified: _currIndex,
        productData: widget.productData);

    await DatabaseHelper().showAllProducts(db: widget.database);

    NotificationSampleClass(
      title,
      content,
      null,
    ).showFlutterNotification();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 35,
      height: 35,
      child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: _currIndex == 0
                    ? Colors.white
                    : Colors.green.withOpacity(.7),
                // Shadow for bottom right corner
                offset: const Offset(5, 5),
                blurRadius: 20,
                spreadRadius: 1,
                // inset: false,
              ),
              const BoxShadow(
                color: Colors.white,
                // Shadow for top left corner
                offset: Offset(-5, -5),
                blurRadius: 20,
                spreadRadius: 1,
                // inset: false,
              ),
            ],
          ),
          child: Center(child: getAnimatedIcon())),
    );
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _lottieController.dispose();
    super.dispose();
  }

  Widget getAnimatedIcon() => GestureDetector(
        child: AnimatedSwitcher(
            duration: const Duration(seconds: 1, microseconds: 100),
            transitionBuilder: (child, anim) => RotationTransition(
                  turns: child.key == const ValueKey('icon1')
                      ? Tween<double>(begin: .75, end: 1).animate(anim)
                      : Tween<double>(begin: 0.75, end: 1).animate(anim),
                  child: ScaleTransition(scale: anim, child: child),
                ),
            child: _currIndex == 0
                ? const Icon(
                    Icons.notification_add_rounded,
                    key: ValueKey('icon1'),
                    size: 23,
                    color: Colors.grey,
                  )
                : const Icon(
                    Icons.notifications_active_rounded,
                    color: Colors.green,
                    size: 23,
                    key: ValueKey('icon2'),
                  )),
        onTap: () {
          setState(() {
            _currIndex = _currIndex == 0 ? 1 : 0;

            widget.notifiedIntValue = _currIndex;
          });
          _handleNotificationClick(
              title: _currIndex == 0
                  ? 'You have unsubscribe this product for further notifications.'
                  : 'You have subscribe this product for further notifications.',
              content: widget.productName);
        },
      );
}

class NotificationSampleClass {
  final String title;
  final String content;
  final String? imageUrl;

  NotificationSampleClass(this.title, this.content, this.imageUrl) {
    flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
    var initializationSettingsAndroid =
        const AndroidInitializationSettings('ic_stat_notifications_active');
    var initializationSettingsIOS =
        const DarwinInitializationSettings(requestAlertPermission: false);
    var initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );
    flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onDidReceiveBackgroundNotificationResponse: notificationTapBackground);
  }

  late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;

  void showFlutterNotification() async {
    Random random = Random();
    flutterLocalNotificationsPlugin.show(
        random.nextInt(999), '', '', _buildDetails());
  }

  NotificationDetails _buildDetails() {
    final AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      '_channel.id',
      '_channel.name',
      channelDescription: ' _channel.description',
      styleInformation: BigTextStyleInformation(content, contentTitle: title),
      importance: Importance.max,
      icon: "ic_stat_notifications_active",
      visibility: NotificationVisibility.public,
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
}

import 'package:flutter/material.dart';

class MyInheritedWidget extends InheritedWidget {
  const MyInheritedWidget(
      {Key? key,
      required this.childWidget,
      required this.vendorName,
      required this.vendorId})
      : super(key: key, child: childWidget);

  final Widget childWidget;

  final String vendorId, vendorName;

  static MyInheritedWidget of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<MyInheritedWidget>()!;
  }

  @override
  bool updateShouldNotify(MyInheritedWidget oldWidget) {
    return oldWidget.vendorName != vendorName && oldWidget.vendorId != vendorId;
  }
}

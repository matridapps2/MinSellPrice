import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:minsellprice/dashboard_screen.dart';
import '../colors.dart';
import '../size.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class NotificationPage extends StatefulWidget {
  const NotificationPage({super.key});

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  final List<Map<String, dynamic>> notifications = [];
  bool selectionMode = false;
  Set<int> selectedIndexes = {};

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> stored = prefs.getStringList('notifications') ?? [];
    notifications.clear();
    for (final jsonStr in stored) {
      try {
        final data = jsonDecode(jsonStr);
        notifications.add({
          'title': data['title'] ?? '',
          'message': data['message'] ?? '',
          'image': data['image'] ?? '',
          'name': data['name'] ?? '',
          'time': data['time'] ?? 'Just now',
          'isRead': data['isRead'] ?? false,
        });
      } catch (e) {
        log('Exception: ${e.toString()}');
      }
    }
    log('Loaded notifications:');
    for (final n in notifications) {
      print(n);
    }
    setState(() {});
  }

  Future<void> _deleteSelectedNotifications() async {
    final prefs = await SharedPreferences.getInstance();
    final sortedIndexes = selectedIndexes.toList()
      ..sort((a, b) => b.compareTo(a));
    for (final idx in sortedIndexes) {
      notifications.removeAt(idx);
    }
    final List<String> toStore =
        notifications.map((n) => jsonEncode(n)).toList();
    await prefs.setStringList('notifications', toStore);
    selectedIndexes.clear();
    selectionMode = false;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    double w = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        surfaceTintColor: Colors.white,
        toolbarHeight: .18 * w,
        backgroundColor: AppColors.primary,
        centerTitle: true,
        leading: selectionMode
            ? IconButton(
                icon: Icon(Icons.close, color: Colors.white, size: 30),
                onPressed: () {
                  setState(() {
                    selectionMode = false;
                    selectedIndexes.clear();
                  });
                },
              )
            : InkWell(
                onTap: () {
                  Navigator.of(context).pushReplacement(MaterialPageRoute(
                      builder: (context) => DashboardScreen()));
                },
                child: const Icon(
                  Icons.arrow_back,
                  color: Colors.white,
                  size: 30,
                ),
              ),
        title: selectionMode
            ? Text(
                'Total selected: ${selectedIndexes.length}',
                style: TextStyle(
                  fontSize: 22,
                  color: Colors.white,
                  fontFamily: 'Segoe UI',
                ),
              )
            : Text(
                'Notification',
                style: TextStyle(
                  fontSize: 25,
                  color: Colors.white,
                  fontFamily: 'Segoe UI',
                ),
              ),
        actions: [
          Visibility(
            visible: selectionMode,
            child: IconButton(
              icon: Icon(Icons.delete, color: Colors.white, size: 30),
              tooltip: 'Delete Selected',
              onPressed:
                  selectedIndexes.isEmpty ? null : _deleteSelectedNotifications,
            ),
          ),
        ],
      ),
      body: notifications.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.notifications_off_outlined,
                    size: 80,
                    color: Colors.grey[400],
                  ),
                  SizedBox(height: 16),
                  Text(
                    'No new notifications',
                    style: TextStyle(
                      fontSize: 20,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            )
          : Column(
              children: [
                if (selectionMode)
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Row(
                      children: [
                        Checkbox(
                          value:
                              selectedIndexes.length == notifications.length &&
                                  notifications.isNotEmpty,
                          onChanged: (checked) {
                            setState(() {
                              if (checked == true) {
                                selectedIndexes = Set<int>.from(List.generate(
                                    notifications.length, (i) => i));
                              } else {
                                selectedIndexes.clear();
                              }
                            });
                          },
                          activeColor: const Color.fromARGB(255, 237, 63, 69),
                          checkColor: Colors.white,
                        ),
                        const Text('Select All',
                            style: TextStyle(
                                fontSize: 15, fontWeight: FontWeight.w500)),
                      ],
                    ),
                  ),
                Expanded(
                  child: ListView.builder(
                    itemCount: notifications.length,
                    padding: EdgeInsets.only(left: 16, bottom: 16, right: 16),
                    itemBuilder: (context, index) {
                      final notification = notifications[index];
                      final isSelected = selectedIndexes.contains(index);
                      return Card(
                        margin: EdgeInsets.only(bottom: 12),
                        elevation: 2,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (selectionMode)
                              Padding(
                                padding: const EdgeInsets.only(left: 8, top: 8),
                                child: Checkbox(
                                  value: isSelected,
                                  onChanged: (checked) {
                                    setState(() {
                                      if (checked == true) {
                                        selectedIndexes.add(index);
                                      } else {
                                        selectedIndexes.remove(index);
                                      }
                                    });
                                  },
                                  activeColor: Color.fromARGB(255, 237, 63, 69),
                                  checkColor: Colors.white,
                                ),
                              ),
                            Expanded(
                              child: InkWell(
                                onTap: selectionMode
                                    ? () {
                                        setState(() {
                                          if (isSelected) {
                                            selectedIndexes.remove(index);
                                          } else {
                                            selectedIndexes.add(index);
                                          }
                                        });
                                      }
                                    : () {
                                        setState(() {
                                          notifications[index]['isRead'] = true;
                                        });
                                      },
                                onLongPress: () {
                                  if (!selectionMode) {
                                    setState(() {
                                      selectionMode = true;
                                      selectedIndexes.add(index);
                                    });
                                  }
                                },
                                child: Padding(
                                  padding: const EdgeInsets.all(12.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      if (notification['image']?.isNotEmpty ==
                                          true)
                                        ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(12),
                                          child: Image.network(
                                            notification['image'],
                                            height: 150,
                                            width: double.infinity,
                                            fit: BoxFit.cover,
                                            errorBuilder:
                                                (context, error, stackTrace) {
                                              return Container(
                                                height: 100,
                                                width: double.infinity,
                                                color: Colors.grey[300],
                                                child: Icon(Icons.broken_image,
                                                    size: 40,
                                                    color: Colors.grey[600]),
                                              );
                                            },
                                          ),
                                        ),
                                      SizedBox(height: 12),
                                      Text(
                                        notification['title'] ?? '',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                                      SizedBox(height: 8),
                                      Text(
                                        notification['message'] ?? '',
                                        style: TextStyle(fontSize: 14),
                                      ),
                                      SizedBox(height: 8),
                                      Text(
                                        notification['time'] ?? '',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }
}

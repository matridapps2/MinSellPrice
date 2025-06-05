import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:shoppingmegamart/loging_page/loging_page.dart';
import 'package:sqflite/sqflite.dart';
import '../notification_page/notification_page.dart';
import '../register_page/register_page.dart';
import '../reposotory_services/database/database_functions.dart';
import '../size.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import '../auth_provider.dart' as my_auth;
import '../utils/toast_messages/common_toasts.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:firebase_database/firebase_database.dart';

class CustomNavigationDrawer extends StatefulWidget {
  final VoidCallback? onLogout;

  const CustomNavigationDrawer({Key? key, this.onLogout}) : super(key: key);

  @override
  State<CustomNavigationDrawer> createState() => _CustomNavigationDrawerState();
}

class _CustomNavigationDrawerState extends State<CustomNavigationDrawer> {
  bool _isLoggedIn = false;
  Database? _database;
  String? _contactUrl;
  String? _privacyPolicyUrl;

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
    _fetchUrlsFromFirebase();
  }

  void refreshLoginStatus() {
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    try {
      final firebaseUser = FirebaseAuth.instance.currentUser;
      bool firebaseLoggedIn = firebaseUser != null;
      final db = await DatabaseHelper().database;
      bool dbLoggedIn = false;
      if (db != null) {
        dbLoggedIn = await DatabaseHelper().isUserLoggedIn(db: db);
      }
      setState(() {
        _database = db;
        _isLoggedIn = firebaseLoggedIn || dbLoggedIn;
      });
    } catch (e) {
      setState(() {
        _isLoggedIn = false;
      });
    }
  }

  Future<void> _logout() async {
    if (FirebaseAuth.instance.currentUser != null) {
      await FirebaseAuth.instance.signOut();
    }
    if (_database != null) {
      await DatabaseHelper().logout(db: _database!);
    }
    setState(() {
      _isLoggedIn = false;
    });
    if (widget.onLogout != null) widget.onLogout!();
  }

  Future<void> _fetchUrlsFromFirebase() async {
    try {
      final ref = FirebaseDatabase.instance.ref().child('users');
      final snapshot = await ref.get();
      if (snapshot.exists) {
        final data = snapshot.value as Map<dynamic, dynamic>?;
        if (data != null && data.isNotEmpty) {
          final firstUser = data.values.first as Map<dynamic, dynamic>;
          setState(() {
            _contactUrl = firstUser['contact url'] as String?;
            _privacyPolicyUrl = firstUser['privacy policy'] as String?;
          });
          log('_contactUrl $_contactUrl');
          log('_privacyPolicyUrl $_privacyPolicyUrl');
          log('data fetch successfully from firebase realtime database');
        }
      }
    } catch (e) {
      log('Exception ${e.toString()}');
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<my_auth.AuthProvider>(context);

    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            padding: EdgeInsets.only(bottom: 30),
            decoration: BoxDecoration(
              color: const Color.fromARGB(255, 237, 63, 69),
            ),
            child: Image.asset(
              'assets/shopping_mega_mart_logo.png',
              height: .2 * w,
            ),
          ),
          ListTile(
            leading: const Icon(Icons.shopping_cart,
                color: Color.fromARGB(255, 237, 63, 69), size: 30),
            title: const Text(
              'MY CART',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            onTap: () {
              Navigator.pop(context);
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.notifications,
                color: Color.fromARGB(255, 237, 63, 69), size: 30),
            title: const Text(
              'NOTIFICATIONS',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            onTap: () {
              Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (context) => NotificationPage()));
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.person_add,
                color: Color.fromARGB(255, 237, 63, 69), size: 30),
            title: const Text(
              'REGISTER',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            onTap: () {
              Navigator.pop(context);
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const RegisterPage(),
                ),
              );
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.contact_support,
                color: Color.fromARGB(255, 237, 63, 69), size: 30),
            title: const Text(
              'CONTACT US',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            onTap: () async {
              if (_contactUrl != null) {
                final Uri url = Uri.parse(_contactUrl!);
                if (await canLaunchUrl(url)) {
                  await launchUrl(url, mode: LaunchMode.inAppBrowserView);
                }
              }
              Navigator.pop(context);
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.privacy_tip,
                color: Color.fromARGB(255, 237, 63, 69), size: 30),
            title: const Text(
              'PRIVACY POLICY',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            onTap: () async {
              if (_privacyPolicyUrl != null) {
                final Uri url = Uri.parse(_privacyPolicyUrl!);
                if (await canLaunchUrl(url)) {
                  await launchUrl(url, mode: LaunchMode.inAppBrowserView);
                }
              }
              Navigator.pop(context);
            },
          ),
          const Divider(),
          ListTile(
            leading: Icon(
              authProvider.isLoggedIn ? Icons.logout : Icons.login,
              color: const Color.fromARGB(255, 237, 63, 69),
              size: 30,
            ),
            title: Text(
              authProvider.isLoggedIn ? 'LOGOUT' : 'LOGIN',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            onTap: () async {
              if (authProvider.isLoggedIn) {
                await authProvider.logout();
                Navigator.pop(context);
                CommonToasts.centeredMobile(
                    msg: 'Logged out successfully', context: context);
              } else {
                Navigator.pop(context);
                await Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => LoginPage(
                      onLoginSuccess: () {
                        authProvider.login();
                      },
                    ),
                  ),
                );
              }
            },
          ),
          const Divider(),
        ],
      ),
    );
  }
}

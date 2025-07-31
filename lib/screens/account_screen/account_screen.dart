import 'package:flutter/material.dart';
import 'package:minsellprice/core/utils/toast_messages/common_toasts.dart';
import 'package:minsellprice/screens/liked_product_screen/liked_product_screen.dart';
import 'package:minsellprice/screens/loging_page/loging_page.dart';
import 'package:minsellprice/screens/register_page/register_page.dart';
import 'package:minsellprice/screens/account_screen/privacy_policy_screen.dart';
import 'package:sqflite_common/sqlite_api.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:minsellprice/core/utils/firebase/auth_provider.dart' as my_auth;
import 'package:minsellprice/reposotory_services/database/database_functions.dart';


class AccountScreen extends StatefulWidget {
  const AccountScreen({
    super.key,
  });

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  final TextEditingController _emailController = TextEditingController();
  bool _isLoggedIn = false;
  Database? _database;

  @override
  void initState() {
    super.initState();
    _initCall();
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  void _initCall() async{
    await _checkLoginStatus();
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
    CommonToasts.centeredMobile(
        msg: 'Logged out successfully', context: context);
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<my_auth.AuthProvider>(context);

    return Scaffold(
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          Container(
            padding: const EdgeInsets.all(16.0),
            margin: const EdgeInsets.only(bottom: 24.0),
            decoration: BoxDecoration(
              color: Colors.blue[600],
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.3),
                  spreadRadius: 2,
                  blurRadius: 5,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.email_outlined,
                      color: Colors.white,
                      size: 28,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'SUBSCRIBE TO OUR NEWSLETTER',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              letterSpacing: 1.2,
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'Get all the latest information on Events, Sales and Offers.',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _emailController,
                        decoration: InputDecoration(
                          hintText: 'Your E-mail Address',
                          hintStyle: TextStyle(color: Colors.grey[400]),
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                        ),
                        keyboardType: TextInputType.emailAddress,
                      ),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey[800],
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'SUBSCRIBE',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.2,
                            ),
                          ),
                          SizedBox(width: 8),
                          Icon(Icons.arrow_forward, size: 18),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'MY ACCOUNT',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 16),
              _accountOption(Icons.person_add, 'Register', onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const RegisterPage(),
                  ),
                );
              }),
              _accountOption(
                authProvider.isLoggedIn ? Icons.logout : Icons.login,
                authProvider.isLoggedIn ? 'Logout' : 'Login',
                onTap: () async {
                  if (authProvider.isLoggedIn) {
                    await authProvider.logout();
                    await _logout();
                  } else {
                    await Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => LoginPage(
                          onLoginSuccess: () async{
                            authProvider.login();
                           await _checkLoginStatus();
                          },
                        ),
                      ),
                    );
                  }
                },
              ),
              _accountOption(Icons.account_circle_outlined, 'Contact Us'),
              const SizedBox(height: 24),
              // const Text(
              //   'ORDERS & CART',
              //   style: TextStyle(
              //       fontWeight: FontWeight.bold,
              //       fontSize: 16,
              //       letterSpacing: 1.2),
              // ),
              // _orderCartOption(Icons.local_shipping_outlined, 'Track My Order'),
              // _orderCartOption(Icons.location_on_outlined, 'Track Order'),
              // _orderCartOption(Icons.shopping_cart_outlined, 'View Cart'),
              // _orderCartOption(Icons.favorite_border, 'My Wishlist'),
              // const SizedBox(height: 24),
              const Text(
                'SUPPORT & INFO',
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    letterSpacing: 1.2),
              ),
              const SizedBox(height: 16),
              _supportInfoOption(Icons.help_outline, 'Help'),
              _supportInfoOption(
                Icons.privacy_tip_outlined,
                'Privacy Policy',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const PrivacyPolicyScreen(),
                    ),
                  );
                },
              ),
              const SizedBox(height: 50), // Extra space to ensure it's visible
            ],
          ),
        ],
      ),
    );
  }

  Widget _accountOption(IconData icon, String text, {VoidCallback? onTap}) {
    return ListTile(
      leading: Icon(icon, color: Colors.blue),
      title: Text(text),
      trailing: Icon(Icons.chevron_right),
      onTap: onTap ?? () {},
      contentPadding: EdgeInsets.zero,
      dense: true,
    );
  }

  Widget _orderCartOption(IconData icon, String text) {
    return ListTile(
      leading: Icon(icon, color: Colors.blue),
      title: Text(text),
      trailing: Icon(Icons.chevron_right),
      onTap: () {
        if (text == 'My Wishlist' && _database != null) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => LikedProduct(database: _database!),
            ),
          );
        }
      },
      contentPadding: EdgeInsets.zero,
      dense: true,
    );
  }

  Widget _supportInfoOption(IconData icon, String text, {VoidCallback? onTap}) {
    return ListTile(
      leading: Icon(icon, color: Colors.blue),
      title: Text(text),
      trailing: Icon(Icons.chevron_right),
      onTap: onTap ?? () {},
      contentPadding: EdgeInsets.zero,
      dense: true,
    );
  }
}

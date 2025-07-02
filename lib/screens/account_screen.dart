import 'package:flutter/material.dart';
import 'package:sqflite_common/sqlite_api.dart';
import '../register_page/register_page.dart';

class AccountScreen extends StatefulWidget {
  const AccountScreen({
    super.key,
    required Database database,
    required int vendorId,
  });

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children:[
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
            _accountOption(Icons.login, 'Login'),
            _accountOption(Icons.account_circle_outlined, 'Contact Us'),
            const SizedBox(height: 24),
            const Text(
              'ORDERS & CART',
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  letterSpacing: 1.2),
            ),
            _orderCartOption(Icons.local_shipping_outlined, 'Track My Order'),
            _orderCartOption(Icons.location_on_outlined, 'Track Order'),
            _orderCartOption(Icons.shopping_cart_outlined, 'View Cart'),
            _orderCartOption(Icons.favorite_border, 'My Wishlist'),
            _orderCartOption(Icons.notifications_none_outlined, 'Notification'),
            const SizedBox(height: 24),
            const Text(
              'SUPPORT & INFO',
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  letterSpacing: 1.2),
            ),
            _supportInfoOption(Icons.help_outline, 'Help'),
            _supportInfoOption(Icons.privacy_tip_outlined, 'Privacy Policy'),
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
      onTap: () {},
      contentPadding: EdgeInsets.zero,
      dense: true,
    );
  }

  Widget _supportInfoOption(IconData icon, String text) {
    return ListTile(
      leading: Icon(icon, color: Colors.blue),
      title: Text(text),
      trailing: Icon(Icons.chevron_right),
      onTap: () {},
      contentPadding: EdgeInsets.zero,
      dense: true,
    );
  }
}

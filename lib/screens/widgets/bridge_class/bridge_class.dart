import 'package:flutter/material.dart';
import 'package:minsellprice/app.dart';
import 'package:minsellprice/dashboard_screen.dart';
import 'package:minsellprice/reposotory_services/database/database_functions.dart';

import '../../../reposotory_services/database/database_constants.dart';

class BridgeClass extends StatefulWidget {
  const BridgeClass({super.key});

  @override
  State<BridgeClass> createState() => _BridgeClassState();

  /* This method will returns the State object of the nearest ancestor StatefulWidget widget that is an instance of the given type T.*/
  static void createRebirth({required BuildContext context}) {
    context.findAncestorStateOfType<_BridgeClassState>()!.restartApp();
  }
}

class _BridgeClassState extends State<BridgeClass> {
  UniqueKey key = UniqueKey();

  @override
  void initState() {
    super.initState();
    _initializeDatabase();
  }

  void restartApp() {
    setState(() => key = UniqueKey());
  }

  bool isUserLoggedIn = false;
  bool _showWhiteScreen = true;

  Future<void> _initializeDatabase() async {
    try {
      final database = await DatabaseHelper().database;
      if (database == null) {
        throw Exception('Database initialization failed');
      }

      final boolean = await DatabaseHelper().isUserLoggedIn(db: database);

      if (mounted) {
        setState(() {
          isUserLoggedIn = boolean;
        });
      }

      if (isUserLoggedIn == false) {
        await DatabaseHelper().insertLogin(database, {
          'id': 1,
          'email': 'afsupply@gmail.com',
          'name': 'AF Supply',
          'vendor_id': AppInfo.kVendorId,
          'vendor_name': 'AF Supply',
          'vendor_short_name': 'AF',
          'sister_concern_vendor': 10024,
          'sister_vendor_short_name': 'HP',
          fcm_token_key:
              'cmGoQkJZS4irsNs8sQ9HVb:APA91bH9h_3gs_S7cPPPhzSPFPaDyaxwTaNqIVOamRa8nPm-d_Kyrbs7hJeehGLuJhbSolGjCJEAqs-cDeSLxSOHac8Dvj1o_7WG-RufY3Bm-hEzH0aX4AHFijEK1VWqa1KOlzlTSHpZ'
        });
      }

      if (mounted) {
        Future.delayed(const Duration(seconds: 1)).then((value) => mounted
            ? setState(() {
                _showWhiteScreen = false;
              })
            : null);
      }
    } catch (e) {
      // Handle database initialization error
      if (mounted) {
        setState(() {
          _showWhiteScreen = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return KeyedSubtree(
      key: key,
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        body: _showWhiteScreen
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : const DashboardScreen(),
      ),
    );
  }
}

import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:minsellprice/reposotory_services/database/database_functions.dart';
import 'package:minsellprice/screens/spalsh_screen/splash_screen.dart';

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

  // Removed _showWhiteScreen variable since we always show splash screen

  Future<void> _initializeDatabase() async {
    try {
      final database = await DatabaseHelper().database;
      if (database == null) {
        throw Exception('Database initialization failed');
      }

      log('Database initialized successfully in BridgeClass');
      // No need to switch screens since we start with splash screen
    } catch (e) {
      // Handle database initialization error
      log('Database initialization error in BridgeClass: $e');
      // Even if database fails, we still show splash screen
    }
  }

  @override
  Widget build(BuildContext context) {
    return KeyedSubtree(
      key: key,
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        body: const SplashScreen(), // Always show splash screen immediately
      ),
    );
  }
}

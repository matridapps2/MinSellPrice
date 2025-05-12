import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shoppingmegamart/animation/custom_loader.dart';
import 'package:shoppingmegamart/app.dart';
import 'package:shoppingmegamart/bloc/database_bloc/database_setup/database_bloc.dart';
import 'package:shoppingmegamart/dashboard_screen.dart';
import 'package:shoppingmegamart/reposotory_services/database/database_functions.dart';
import 'package:shoppingmegamart/screens/login_screen.dart';

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
    context.read<DatabaseBloc>().add(DatabaseInitEvent());
    super.initState();
  }

  void restartApp() {
    setState(() => key = UniqueKey());
  }

  bool isUserLoggedIn = false;
  bool _showWhiteScreen = true;

  @override
  Widget build(BuildContext context) {
    return KeyedSubtree(
      key: key,
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        body: BlocListener<DatabaseBloc, DatabaseState>(
          listener: (context, state) async {
            if (state is DatabaseLoadedState) {
              final boolean =
                  await DatabaseHelper().isUserLoggedIn(db: state.database);
              Future.delayed(const Duration(seconds: 1));
              setState(() {
                isUserLoggedIn = boolean;
              });

              if(isUserLoggedIn == false){
                await DatabaseHelper().insertLogin(state.database, {'id': 1, 'email': 'afsupply@gmail.com', 'name': 'AF Supply', 'vendor_id': AppInfo.kVendorId, 'vendor_name': 'AF Supply', 'vendor_short_name': 'AF', 'sister_concern_vendor': 10024, 'sister_vendor_short_name': 'HP', fcm_token_key: 'cmGoQkJZS4irsNs8sQ9HVb:APA91bH9h_3gs_S7cPPPhzSPFPaDyaxwTaNqIVOamRa8nPm-d_Kyrbs7hJeehGLuJhbSolGjCJEAqs-cDeSLxSOHac8Dvj1o_7WG-RufY3Bm-hEzH0aX4AHFijEK1VWqa1KOlzlTSHpZ'});
                context.read<DatabaseBloc>().add(DatabaseInitEvent());
              }

              Future.delayed(const Duration(seconds: 1)).then((value) => mounted
                  ? setState(() {
                      _showWhiteScreen = false;
                    })
                  : null);
            }
          },
          child: _showWhiteScreen == true
              ? const Center(
                  child: CustomLoader(),
                )
              : isUserLoggedIn == true
                  ? const DashboardScreen()
                  : const LoginScreen(),
        ),
      ),
    );
  }
}

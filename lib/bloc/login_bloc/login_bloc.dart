import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:shoppingmegamart/reposotory_services/database/database_constants.dart';
import 'package:shoppingmegamart/reposotory_services/database/database_functions.dart';
import 'package:shoppingmegamart/reposotory_services/network_reposotory.dart';
import 'package:sqflite/sqflite.dart';

part 'login_event.dart';

part 'login_state.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  LoginBloc() : super(LoginInitialState()) {
    on<LoginUserEvent>((event, emit) async {
      emit(LoginLoadingState());

      try {
        final String response = await NetworkCalls().loginToSystem(
          loginDataAsMap: event.loginDataAsMap,
        );

        if ((jsonDecode(response) as Map).containsKey('error')) {
          emit(
            LoginErrorState(
              errorMsg: List<String>.from(
                  (jsonDecode(response)['error'] as List<dynamic>)
                      .map((e) => e)).join('\n'),
            ),
          );
        } else {


          final jsonData = jsonDecode(response);
          Map<String, dynamic> queryData = {
            idKey: jsonData[idKey],
            emailKey: jsonData[emailKey],
            nameKey: jsonData[nameKey],
            vendor_idKey: jsonData[vendor_idKey],
            vendor_nameKey: jsonData[vendor_nameKey],
            vendor_short_nameKey: jsonData[vendor_short_nameKey],
            sister_concern_vendorKey: jsonData[sister_concern_vendorKey],
            sister_vendor_short_nameKey: jsonData[sister_vendor_short_nameKey],
            fcm_token_key: event.fcmToken
          };
          await DatabaseHelper().insertLogin(event.database, queryData);
          emit(
            LoginLoadedState(
              loginData: response,
            ),
          );
        }
      } catch (e) {
        emit(
          LoginErrorState(
            errorMsg: e.toString(),
          ),
        );
      }

      // TODO: implement event handler
    });
  }
}

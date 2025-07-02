import 'dart:convert';

// import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
// import 'package:flutter_animated_icons/flutter_animated_icons.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:minsellprice/bloc/database_bloc/database_setup/database_bloc.dart';
import 'package:minsellprice/bloc/login_bloc/login_bloc.dart';
import 'package:minsellprice/reposotory_services/database/database_functions.dart';
import 'package:minsellprice/screens/widgets/bridge_class/bridge_class.dart';
import 'package:minsellprice/size.dart';
import 'package:sqflite/sqflite.dart';
import 'package:validators/validators.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _textEditingController = TextEditingController();
  final TextEditingController _passwordEditingController =
      TextEditingController();

  late Database database;
  String loginData = '';

  bool _showPassword = true;
  @override
  void dispose() {
    _textEditingController.clear();
    _passwordEditingController.clear();
    super.dispose();
  }

  bool isEmailCorrect = false;
  final _formKey = GlobalKey<FormState>();
  List<String> colorList = [
    "bb69a8",
    "d1c1f3",
    "be5574",
    "c2439a",
    "d99f9b",
    "3487af",
    "bf91e8",
    "8992e8",
    "aaccf8"
  ];

  @override
  Widget build(BuildContext context) {
    return BlocListener<DatabaseBloc, DatabaseState>(
      listener: (context, state) {
        state is DatabaseLoadedState
            ? setState(() => database = state.database)
            : null;
      },
      child: GestureDetector(
        child: Scaffold(
          body: Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                  image: AssetImage('assets/images/background.jpeg'),
                  fit: BoxFit.cover),
            ),
            child: SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    // mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Lottie.asset(
                        'assets/lottie_animations/login.json',

                        animate: true,
                        repeat: false,
                        height: .25 * h,
                        // width: .7 * w,
                        fit: BoxFit.contain,
                      ),
                      Text(
                        'Log In Now',
                        style: GoogleFonts.aBeeZee(
                          textStyle: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 40,
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      Container(
                        height: isEmailCorrect ? h * .35 : h * .28,
                        width: MediaQuery.of(context).size.width / 1.1,
                        decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(20)),
                        child: Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(
                                  left: 20, right: 20, bottom: 20, top: 20),
                              child: TextFormField(
                                controller: _textEditingController,
                                onChanged: (val) {
                                  setState(() {
                                    isEmailCorrect = isEmail(val);
                                  });
                                },
                                decoration: const InputDecoration(
                                  focusedBorder: UnderlineInputBorder(
                                      borderSide: BorderSide.none,
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(10))),
                                  enabledBorder: UnderlineInputBorder(
                                      borderSide: BorderSide.none,
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(10))),
                                  prefixIcon: Icon(
                                    Icons.person,
                                    color: Colors.blue,
                                  ),
                                  filled: true,
                                  fillColor: Colors.white,
                                  labelText: "Email",
                                  hintText: 'your-email@domain.com',
                                  labelStyle: TextStyle(
                                    color: Colors.blue,
                                  ),
                                ),
                              ),
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.only(left: 20, right: 20),
                              child: Form(
                                key: _formKey,
                                child: TextFormField(
                                  obscuringCharacter: '*',
                                  controller: _passwordEditingController,
                                  obscureText: _showPassword,
                                  decoration: InputDecoration(
                                    focusedBorder: const UnderlineInputBorder(
                                        borderSide: BorderSide.none,
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(10))),
                                    enabledBorder: const UnderlineInputBorder(
                                        borderSide: BorderSide.none,
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(10))),
                                    prefixIcon: const Icon(
                                      Icons.person,
                                      color: Colors.blue,
                                    ),
                                    suffix: GestureDetector(
                                      onTap: () => setState(() {
                                        _showPassword = !_showPassword;
                                      }),
                                      child: _showPassword
                                          ? const Icon(
                                              Icons.remove_red_eye_rounded,
                                              color: Colors.blue,
                                            )
                                          : const Icon(
                                              Icons.remove_red_eye_outlined,
                                              color: Colors.red,
                                            ),
                                    ),
                                    filled: true,
                                    fillColor: Colors.white,
                                    labelText: "Password",
                                    hintText: '*********',
                                    labelStyle: const TextStyle(
                                      color: Colors.blue,
                                    ),
                                  ),
                                  validator: (value) {
                                    if (value!.isEmpty && value.length < 5) {
                                      return 'Enter a valid password';
                                    }
                                    return null;
                                  },
                                ),
                              ),
                            ),
                            const SizedBox(
                              height: 20,
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: isEmailCorrect
                                  ? BlocListener<LoginBloc, LoginState>(
                                      listener: (context, state) async {
                                        // TODO: implement listener}
                                        state is LoginErrorState
                                            ? Fluttertoast.showToast(
                                                msg: state.errorMsg,
                                                toastLength: Toast.LENGTH_SHORT,
                                                gravity: ToastGravity.CENTER,
                                                timeInSecForIosWeb: 1,
                                                backgroundColor: Colors.red,
                                                textColor: Colors.white,
                                                fontSize: 16.0)
                                            : state is LoginLoadedState
                                                ? await _addLoginData(
                                                        loginData:
                                                            state.loginData)
                                                    .whenComplete(() async =>
                                                        BridgeClass
                                                            .createRebirth(
                                                                context:
                                                                    context))
                                                : null;
                                      },
                                      child: BlocBuilder<LoginBloc, LoginState>(
                                        builder: (context, state) {
                                          return ElevatedButton(
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor:
                                                    isEmailCorrect == false
                                                        ? Colors.red
                                                        : Colors.white
                                                            .withOpacity(.3),
                                              ),
                                              onPressed: () async {
                                                if (_formKey.currentState!
                                                    .validate()) {
                                                  final String loginData =
                                                      jsonEncode({
                                                    "email":
                                                        _textEditingController
                                                            .text,
                                                    "password":
                                                        _passwordEditingController
                                                            .text,
                                                  });
                                                  final fcmToken =
                                                      await FirebaseMessaging
                                                          .instance
                                                          .getToken();
                                                  context.read<LoginBloc>().add(
                                                      LoginUserEvent(
                                                          loginDataAsMap:
                                                              loginData,
                                                          database: database,
                                                          fcmToken: fcmToken!));
                                                }
                                              },
                                              child: state is LoginLoadedState ||
                                                      state
                                                          is LoginErrorState ||
                                                      state is LoginInitialState
                                                  ? const Text(
                                                      'Log In',
                                                      style: TextStyle(
                                                          fontSize: 17,
                                                          color: Colors.white),
                                                    )
                                                  : Lottie.asset(
                                                      'assets/lottie_animations/loading_bar.json',
                                                      repeat: true,
                                                      animate: true,
                                                      width: 50,
                                                      height: 50,
                                                      fit: BoxFit.cover,
                                                      frameRate: FrameRate(
                                                        60,
                                                      ),
                                                    ));
                                        },
                                      ),
                                    )
                                  : Container(),
                            ),
                            // GoogleLoginWidget(context)
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Column GoogleLoginWidget(BuildContext context) {
  //   return Column(
  //     children: [
  //       Row(
  //         crossAxisAlignment: CrossAxisAlignment.center,
  //         mainAxisAlignment: MainAxisAlignment.center,
  //         children: [
  //           SizedBox(
  //             width: w * .36,
  //             child: const Divider(
  //               color: Colors.black,
  //             ),
  //           ),
  //           const Padding(
  //             padding: EdgeInsets.all(8.0),
  //             child: Text('or'),
  //           ),
  //           SizedBox(
  //             width: w * .36,
  //             child: const Divider(
  //               color: Colors.black,
  //             ),
  //           ),
  //         ],
  //       ),
  //       Padding(
  //         padding: const EdgeInsets.symmetric(vertical: 8.0),
  //         child: Row(
  //           crossAxisAlignment: CrossAxisAlignment.center,
  //           mainAxisAlignment: MainAxisAlignment.center,
  //           children: [
  //             GestureDetector(
  //               onTap: () async {
  //                 await FirebaseService().signOutFromGoogle();
  //                 await FirebaseService().signInwithGoogle().then(
  //                       (value) => value != null
  //                           ? Navigator.push(
  //                               context,
  //                               MaterialPageRoute(
  //                                 builder: (context) => UserInfo(
  //                                   userDetails: value,
  //                                 ),
  //                               ),
  //                             )
  //                           : Fluttertoast.showToast(
  //                               msg: 'Unable to Login with Google Auth'),
  //                     );
  //               },
  //               child: Image.asset(
  //                 'assets/social/social.png',
  //                 width: 38,
  //                 height: 38,
  //                 fit: BoxFit.cover,
  //                 colorBlendMode: BlendMode.lighten,
  //               ),
  //             ),
  //             const SizedBox(
  //               width: 20,
  //             ),
  //             Image.asset(
  //               'assets/social/apple-logo.png',
  //               width: 38,
  //               height: 38,
  //               fit: BoxFit.cover,
  //             ),
  //           ],
  //         ),
  //       ),
  //     ],
  //   );
  // }

  Future<void> _addLoginData({required String loginData}) async {
    final fcmToken = await FirebaseMessaging.instance.getToken();
    print(fcmToken);
    // final Map<String, dynamic> jsonData = jsonDecode(loginData);

    // await DatabaseHelper().insertLogin(database, queryData);
    Future.delayed(const Duration(seconds: 1));

    await DatabaseHelper().createProductTable(db: database);
    await DatabaseHelper().createSearchHistoryTable(db: database);
    Future.delayed(const Duration(seconds: 1));
  }

  @override
  void initState() {
    // TODO: implement initState
    context.read<DatabaseBloc>().add(DatabaseInitEvent());

    super.initState();
  }
}

// class UserInfo extends StatelessWidget {
//   // final UserCredential userDetails;
//
//   const UserInfo({super.key, required this.userDetails});
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Center(
//         child: Column(
//           children: [
//             Text(userDetails.user!.displayName!),
//             Text(userDetails.user!.phoneNumber ?? 'No Phone Number'),
//             Text(userDetails.user!.email!),
//             Text(userDetails.user!.metadata.lastSignInTime!.toIso8601String()),
//             Text(userDetails.user!.uid),
//             CachedNetworkImage(imageUrl: userDetails.user!.photoURL!),
//           ],
//         ),
//       ),
//     );
//   }
// }

import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:minsellprice/core/utils/constants/colors.dart';
import 'package:minsellprice/core/utils/toast_messages/common_toasts.dart';
import 'package:minsellprice/screens/forgot_password/forgot_password.dart';
import 'package:minsellprice/screens/home_page/home_page.dart';
import 'package:minsellprice/screens/register_page/register_page.dart';
import 'package:minsellprice/core/utils/constants/size.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginPage extends StatefulWidget {
  final VoidCallback onLoginSuccess;
  const LoginPage({super.key, required this.onLoginSuccess});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _showPassword = false;
  bool _isRememberChecked = true;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _initCall();
  }

  void _initCall() async {
    await _getEmailPassword();
  }

  Future<void> _getEmailPassword() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String? emailId = preferences.getString('emailId');
    String? password = preferences.getString('password');
    if (emailId != null) _emailController.text = emailId;
    if (password != null) _passwordController.text = password;
  }

  Future<void> _storeEmailPassword(String emailId, String password) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    await preferences.setString('emailId', emailId);
    await preferences.setString('password', password);
  }

  Future<void> _removeEmailPassword() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    await preferences.remove('emailId');
    await preferences.remove('password');
  }

  void _showToast(String msg) {
    CommonToasts.centeredMobile(msg: msg, context: context);
  }

  Future<void> _login() async {
    FocusScope.of(context).unfocus();
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    if (email.isEmpty) {
      _showToast('Please Enter Email Id');
      return;
    } else if (password.isEmpty) {
      _showToast('Please Enter Password');
      return;
    } else if(!email.contains('@gmail.com')){
      _showToast('Enter Correct Email Id');
      return;
    }
    setState(() => _isLoading = true);
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      if (_isRememberChecked) {
        await _storeEmailPassword(email, password);
      } else {
        await _removeEmailPassword();
      }
      widget.onLoginSuccess();

      CommonToasts.centeredMobile(msg: 'Login successfully', context: context);
      Navigator.of(context).pushReplacement(MaterialPageRoute(
        builder: (context) => const HomePage(),
      ));
    } on FirebaseAuthException catch (e) {
      log('Exception in log in ${e.code}');
      String errorMsg = 'Login failed';

      switch (e.code) {
        case 'user-not-found':
          errorMsg = 'No user found for that email.';
          break;
        case 'invalid-credential':  // worng psw
          errorMsg = 'Wrong Password Provided.';
          break;
        case 'invalid-email':
          errorMsg = 'Invalid Email Format.';
          break;
        case 'user-disabled':
          errorMsg = 'This account has been disabled.';
          break;
        case 'too-many-requests':
          errorMsg = 'Too many failed attempts. Please try again later.';
          break;
        default:
          errorMsg = e.message ?? 'An authentication error occurred.';
      }
      _showToast(errorMsg);
    } catch (e) {
      _showToast('An unknown error occurred');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        toolbarHeight: 80,
        centerTitle: true,
        automaticallyImplyLeading: false,
        title: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white,
                Colors.grey[50]!,
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                spreadRadius: 1,
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              // Header Section
              Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 20, vertical: 20),
                child: Row(
                  children: [
                    // App Logo
                    Expanded(
                      child: Row(
                        children: [
                          // Container(
                          //   padding: const EdgeInsets.all(8),
                          //   decoration: BoxDecoration(
                          //     color: AppColors.primary,
                          //     borderRadius: BorderRadius.circular(12),
                          //     boxShadow: [
                          //       BoxShadow(
                          //         color:
                          //         AppColors.primary.withOpacity(0.3),
                          //         spreadRadius: 1,
                          //         blurRadius: 4,
                          //         offset: const Offset(0, 2),
                          //       ),
                          //     ],
                          //   ),
                          //   child: Icon(
                          //     Icons.shopping_bag,
                          //     color: Colors.white,
                          //     size: w * .06,
                          //   ),
                          // ),
                            Icon(
                              Icons.arrow_back_ios,
                              color: Colors.black,
                              size: w * .06,
                            ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment:
                              CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'MinSellPrice',
                                  style: TextStyle(
                                    color: AppColors.primary,
                                    fontSize: w * .05,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: 'Segoe UI',
                                  ),
                                ),
                                Text(
                                  'Find the best prices',
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: w * .025,
                                    fontWeight: FontWeight.w500,
                                    fontFamily: 'Segoe UI',
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Action Buttons
                    Row(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.1),
                                spreadRadius: 1,
                                blurRadius: 3,
                                offset: const Offset(0, 1),
                              ),
                            ],
                          ),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              borderRadius: BorderRadius.circular(12),
                              // onTap: () async {
                              //   Navigator.push(
                              //     context,
                              //     MaterialPageRoute(
                              //       builder: (context) =>
                              //       const NotificationScreen(),
                              //     ),
                              //   );
                              //   await _checkNotificationStatus();
                              // },
                              child: Container(
                                padding: const EdgeInsets.all(10),
                                child: Stack(
                                  children: [
                                    Icon(
                                      Icons.notifications_outlined,
                                      color: Colors.grey[700],
                                      size: w * .07,
                                    ),
                                  //  if (hasUnreadNotifications)
                                      Positioned(
                                        right: 0,
                                        top: 0,
                                        child: Container(
                                          width: 8,
                                          height: 8,
                                          decoration: const BoxDecoration(
                                            color: Colors.red,
                                            shape: BoxShape.circle,
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      resizeToAvoidBottomInset: true,
      body: SingleChildScrollView(
        child: Container(
          width: double.infinity,
          color: const Color(0xFFF9F6F8),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                children: [
                  Stack(
                    children: [
                      Container(
                        width: double.infinity,
                        height: MediaQuery.of(context).size.height * 0.25,
                        color: const Color.fromARGB(255, 51, 102, 153),
                        alignment: Alignment.center,
                        child: Image.asset(
                          'assets/app_logo/logo.png',
                          height: 60,
                          fit: BoxFit.contain,
                        ),
                      ),
                      // Positioned(
                      //   top: 16,
                      //   left: 4,
                      //   child: IconButton(
                      //     icon: const Icon(Icons.arrow_back,
                      //         color: Colors.white, size: 28),
                      //     onPressed: () {
                      //       Navigator.of(context).pop();
                      //     },
                      //   ),
                      // ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  const Text(
                    'Please enter your details',
                    style: TextStyle(
                      fontSize: 17,
                      color: Colors.black54,
                      fontFamily: 'Segoe UI',
                      fontWeight: FontWeight.w400,
                      letterSpacing: 1,
                    ),
                  ),
                  const SizedBox(height: 18),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Username/email',
                            style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                letterSpacing: 0.5)),
                        const SizedBox(height: 8),
                        TextField(
                          controller: _emailController,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            hintText: 'Enter your email',
                            hintStyle: TextStyle(
                              fontFamily: 'Segoe UI',
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Your password',
                                style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                    letterSpacing: 0.5)),
                            GestureDetector(
                              onTap: () {
                                Navigator.of(context).pushReplacement(
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          const ForgotPasswordPage()),
                                );
                              },
                              child: const Text('Forgot Password?',
                                  style: TextStyle(
                                    color: Color.fromARGB(255, 51, 102, 153),
                                    fontWeight: FontWeight.bold,
                                    fontFamily: 'Segoe UI',
                                  )),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          controller: _passwordController,
                          obscureText: !_showPassword,
                          decoration: InputDecoration(
                            border: const OutlineInputBorder(),
                            hintText: 'Enter your password',
                            hintStyle: const TextStyle(
                              fontFamily: 'Segoe UI',
                            ),
                            suffixIcon: IconButton(
                              icon: Icon(_showPassword
                                  ? Icons.visibility
                                  : Icons.visibility_off
                              ),
                              onPressed: () {
                                setState(() {
                                  _showPassword = !_showPassword;
                                });
                              },
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Checkbox(
                              value: _isRememberChecked,
                              activeColor:
                                  const Color.fromARGB(255, 51, 102, 153),
                              checkColor: Colors.white,
                              onChanged: (bool? newValue) {
                                setState(() {
                                  _isRememberChecked = newValue ?? false;
                                });
                              },
                            ),
                            const Text('Remember me',
                                style: TextStyle(fontFamily: 'Segoe UI')),
                          ],
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  const Color.fromARGB(255, 51, 102, 153),
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                            ),
                            onPressed: _isLoading ? null : _login,
                            child: _isLoading
                                ? const SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Text('Log in',
                                    style: TextStyle(
                                        fontSize: 18,
                                        fontFamily: 'Segoe UI',
                                        color: Colors.white)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 32.0),
                child: GestureDetector(
                  onTap: () {
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(builder: (context) => const RegisterPage()),
                    );
                  },
                  child: const Padding(
                    padding: EdgeInsets.only(top: 10.0),
                    child: Text(
                      "Don't have an account? Register",
                      style: TextStyle(
                        color: Color.fromARGB(255, 51, 102, 153),
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        fontFamily: 'Segoe UI',
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

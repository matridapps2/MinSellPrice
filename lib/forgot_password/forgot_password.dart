import 'dart:developer';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shoppingmegamart/utils/toast_messages/common_toasts.dart';
import '../loging_page/loging_page.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({Key? key}) : super(key: key);

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final TextEditingController _emailController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _getEmailPassword();
  }

  Future<void> _getEmailPassword() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String? emailId = preferences.getString('emailId');
    if (emailId != null) _emailController.text = emailId;
  }

  void _resetPassword() async {
    final email = _emailController.text.trim();
    if (email.isNotEmpty) {
      await sendPasswordResetEmail(email);
      CommonToasts.centeredMobile(
        msg: 'Password reset email sent',
        context: context,
      );
    } else {
      CommonToasts.centeredMobile(
        msg: 'Please enter a valid email',
        context: context,
      );
    }
  }

  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      Navigator.of(context).pushReplacement(MaterialPageRoute(
        builder: (context) => LoginPage(
          onLoginSuccess: () {},
        ),
      ));
      log('Password reset email sent.');
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        log('No user found for that email.');
      } else if (e.code == 'invalid-email') {
        log('Invalid email format.');
      } else {
        log('Error: $e');
      }
    } catch (e) {
      log('Unknown error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: SingleChildScrollView(
        child: Container(
          width: double.infinity,
          color: const Color(0xFFF9F6F8),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Stack(
                children: [
                  Container(
                    width: double.infinity,
                    height: MediaQuery.of(context).size.height * 0.32,
                    color: const Color.fromARGB(255, 237, 63, 69),
                    alignment: Alignment.center,
                    child: Image.asset(
                      'assets/shopping_mega_mart_logo.png',
                      height: 60,
                      fit: BoxFit.contain,
                    ),
                  ),
                  Positioned(
                    top: 16,
                    left: 4,
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back,
                          color: Colors.white, size: 28),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                  ),
                ],
              ),
              SizedBox(height: 30),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 400,
                    color: Colors.transparent,
                    child: Column(
                      children: [
                        Text(
                          "Forget Password",
                          style: TextStyle(
                            color: const Color.fromARGB(255, 237, 63, 69),
                            fontSize: 24,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 1,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          "Enter the email address and we’ll send reset instructions to reset your password.",
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 14,
                            fontFamily: "PublicSansRegular",
                            fontWeight: FontWeight.w400,
                            letterSpacing: 1,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 18),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 32.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Email',
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                      letterSpacing: 0.5)),
                              const SizedBox(height: 8),
                              TextField(
                                controller: _emailController,
                                decoration: const InputDecoration(
                                  border: OutlineInputBorder(),
                                  hintText: 'Your email..',
                                  hintStyle: TextStyle(
                                    fontFamily: 'Segoe UI',
                                  ),
                                ),
                              ),
                              const SizedBox(height: 20),
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor:
                                        const Color.fromARGB(255, 237, 63, 69),
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 16),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(30),
                                    ),
                                  ),
                                  onPressed: _resetPassword,
                                  child: _isLoading
                                      ? const SizedBox(
                                          width: 24,
                                          height: 24,
                                          child: CircularProgressIndicator(
                                            color: Colors.white,
                                            strokeWidth: 2,
                                          ),
                                        )
                                      : const Text('Send Reset Mail',
                                          style: TextStyle(
                                              fontSize: 18,
                                              fontFamily: 'Segoe UI',
                                              color: Colors.white)),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 13),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              "Back to log in page?",
                              style: TextStyle(
                                fontWeight: FontWeight.w500,
                                fontSize: 14,
                                color: Colors.grey,
                                letterSpacing: 0.5,
                              ),
                            ),
                            InkWell(
                              onTap: () {
                                Navigator.of(context)
                                    .pushReplacement(MaterialPageRoute(
                                  builder: (context) => LoginPage(
                                    onLoginSuccess: () {},
                                  ),
                                ));
                              },
                              child: const Text(
                                " Back now",
                                style: TextStyle(
                                  fontFamily: 'Segoe UI',
                                  fontWeight: FontWeight.w700,
                                  color: Color.fromARGB(255, 237, 63, 69),
                                  fontSize: 14,
                                  letterSpacing: 0.5,
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
            ],
          ),
        ),
      ),
    );
  }
}

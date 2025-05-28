import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shoppingmegamart/dashboard_screen.dart';
import 'package:shoppingmegamart/register_page/register_page.dart';
import 'package:shoppingmegamart/utils/toast_messages/common_toasts.dart';

import '../forgot_password/forgot_password.dart';

class LoginPage extends StatefulWidget {
  final VoidCallback onLoginSuccess;
  const LoginPage({Key? key, required this.onLoginSuccess}) : super(key: key);

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
    _getEmailPassword();
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
    if (email.isEmpty || password.isEmpty) {
      _showToast('Please enter email and password');
      return;
    }
    setState(() => _isLoading = true);
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      _showToast('Login successful!');
      if (_isRememberChecked) {
        await _storeEmailPassword(email, password);
      } else {
        await _removeEmailPassword();
      }
      widget.onLoginSuccess();
      Navigator.of(context).pop(true);

    } on FirebaseAuthException catch (e) {
      String errorMsg = 'Login failed';
      if (e.code == 'user-not-found') {
        errorMsg = 'No user found for that email.';
      } else if (e.code == 'wrong-password') {
        errorMsg = 'Wrong password provided.';
      } else if (e.message != null) {
        errorMsg = e.message!;
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
                                MaterialPageRoute(builder: (context) =>  ForgotPasswordPage()
                                ),
                                );
                              },
                              child: const Text('Forgot Password?',
                                  style: TextStyle(
                                    color: Color.fromARGB(255, 237, 63, 69),
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
                                  ? Icons.visibility_off
                                  : Icons.visibility),
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
                                  const Color.fromARGB(255, 237, 63, 69),
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
                                  const Color.fromARGB(255, 237, 63, 69),
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
                      MaterialPageRoute(builder: (context) => RegisterPage()),
                    );
                  },
                  child: const Padding(
                    padding: EdgeInsets.only(top: 10.0),
                    child: Text(
                      "Don't have an account? Register",
                      style: TextStyle(
                        color: Color.fromARGB(255, 237, 63, 69),
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

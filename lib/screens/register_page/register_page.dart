import 'package:flutter/material.dart';
import 'package:minsellprice/core/utils/constants/colors.dart';
import 'package:minsellprice/core/utils/toast_messages/common_toasts.dart';
import 'package:minsellprice/screens/home_page/home_page.dart';
import 'package:minsellprice/screens/loging_page/loging_page.dart';
import 'package:minsellprice/core/utils/constants/size.dart';
import 'package:firebase_auth/firebase_auth.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});
  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();
  bool showPassword = false;
  bool showConfirmPassword = false;

  Future<void> registerInFirebase() async {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();
    final confirmPassword = confirmPasswordController.text.trim();

    if (password != confirmPassword) {
      CommonToasts.centeredMobile(
          msg: 'Passwords do not match', context: context);
    }
    try {
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      CommonToasts.centeredMobile(msg: 'successful!', context: context);
    } on FirebaseAuthException catch (e) {
      CommonToasts.centeredMobile(msg: e.message ?? 'failed', context: context);
    } catch (e) {
      CommonToasts.centeredMobile(
          msg: 'An unknown error occurred', context: context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        surfaceTintColor: Colors.white,
        toolbarHeight: .18 * w,
        centerTitle: true,
        title: Image.asset(
          // 'assets/logo.png',
          'assets/minsellprice_logo.png',
          height: .2 * w,
        ),
        shape: Border.all(color: AppColors.primary, width: 0),
      ),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Stack(
              children: [
                Container(
                  width: double.infinity,
                  height: MediaQuery.of(context).size.height / 4,
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
            const SizedBox(height: 20),
            const Text(
              'Create your account',
              style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.black),
            ),
            const SizedBox(height: 22),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Email Id',
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 0.5)),
                  const SizedBox(height: 8),
                  TextField(
                    controller: emailController,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: 'Enter your email',
                      hintStyle: TextStyle(fontFamily: 'Segoe UI'),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text('Password',
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 0.5)),
                  const SizedBox(height: 8),
                  TextField(
                    controller: passwordController,
                    obscureText: !showPassword,
                    decoration: InputDecoration(
                      border: const OutlineInputBorder(),
                      hintText: 'Enter your password',
                      hintStyle: const TextStyle(fontFamily: 'Segoe UI'),
                      suffixIcon: IconButton(
                        icon: Icon(showPassword
                            ? Icons.visibility_off
                            : Icons.visibility),
                        onPressed: () {
                          setState(() {
                            showPassword = !showPassword;
                          });
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text('Confirm Password',
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 0.5)),
                  const SizedBox(height: 8),
                  TextField(
                    controller: confirmPasswordController,
                    obscureText: !showConfirmPassword,
                    decoration: InputDecoration(
                      border: const OutlineInputBorder(),
                      hintText: 'Re-enter your password',
                      hintStyle: const TextStyle(fontFamily: 'Segoe UI'),
                      suffixIcon: IconButton(
                        icon: Icon(showConfirmPassword
                            ? Icons.visibility_off
                            : Icons.visibility),
                        onPressed: () {
                          setState(() {
                            showConfirmPassword = !showConfirmPassword;
                          });
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            const Color.fromARGB(255, 51, 102, 153),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      onPressed: () async {
                        await registerInFirebase();
                        Navigator.of(context).pushReplacement(MaterialPageRoute(
                            builder: (context) => const HomePage()));
                      },
                      child: const Text('Register',
                          style: TextStyle(
                              fontSize: 18,
                              fontFamily: 'Segoe UI',
                              color: Colors.white)),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 32.0, left: 20),
                    child: GestureDetector(
                      onTap: () {
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(
                            builder: (context) => LoginPage(
                              onLoginSuccess: () {
                                // The login success will handle navigation to home page
                                // and the auth state will be updated automatically
                              },
                            ),
                          ),
                        );
                      },
                      child: const Padding(
                        padding: EdgeInsets.only(top: 10.0, left: 20),
                        child: Text(
                          "Already have an account? Log in",
                          style: TextStyle(
                            color: Color.fromARGB(255, 0, 35, 77),
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
          ],
        ),
      ),
    );
  }
}

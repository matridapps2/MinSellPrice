import 'package:flutter/material.dart';
import 'package:minsellprice/core/utils/constants/size.dart';
import 'package:minsellprice/screens/loging_page/loging_page.dart';
import '../constants/colors.dart';

class Constants {
  Constants._();

  static Widget noLoginDesign(BuildContext context, String text,) {
    return Container(
      height: h * 0.8,
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Login Required',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Please log in to view $text',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
              height: 1.5,
            ),
          ),
          const SizedBox(height: 20),
          Container(
            width: double.infinity,
            height: 50,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.primary, AppColors.primary.withOpacity(0.8)],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.3),
                  spreadRadius: 1,
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: () async {
                  await Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) =>
                          LoginPage(
                            onLoginSuccess: () {},
                          ),
                    ),
                  );
                },
                child: const Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.login_rounded, color: Colors.white, size: 20),
                      SizedBox(width: 12),
                      Text(
                        'Go to Login',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 17,
                          fontWeight: FontWeight.w600,
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
    );
  }


}
// const SizedBox(height: 24),
// Text(
//   'Don\'t have an account?',
//   style: TextStyle(
//     fontSize: 14,
//     color: Colors.grey[500],
//   ),
// ),
// const SizedBox(height: 8),
// GestureDetector(
//   onTap: () {
//     Navigator.pushReplacement(
//       context,
//       MaterialPageRoute(
//         builder: (context) => const RegisterPage(),
//       ),
//     );
//   },
//   child: const Text(
//     'Create Account',
//     style: TextStyle(
//       fontSize: 16,
//       fontWeight: FontWeight.w600,
//       color: AppColors.primary,
//       decoration: TextDecoration.underline,
//     ),
//   ),
// ),
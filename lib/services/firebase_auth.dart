// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:google_sign_in/google_sign_in.dart';
//
// class FirebaseService {
//   final FirebaseAuth _auth = FirebaseAuth.instance;
//
//   final GoogleSignIn _googleSignIn = GoogleSignIn();
//
//   Future<UserCredential?> signInwithGoogle() async {
//     try {
//       final GoogleSignInAccount? googleSignInAccount =
//           await _googleSignIn.signIn();
//
//       final GoogleSignInAuthentication googleSignInAuthentication =
//           await googleSignInAccount!.authentication;
//
//       final AuthCredential credential = GoogleAuthProvider.credential(
//         accessToken: googleSignInAuthentication.accessToken,
//         idToken: googleSignInAuthentication.idToken,
//       );
//
//    return   await _auth.signInWithCredential(credential);
//     } on FirebaseAuthException catch (e) {
//       print(e.message);
//
//       return null;
//     }
//   }
//
//   Future<void> signOutFromGoogle() async {
//     await _googleSignIn.signOut();
//
//     await _auth.signOut();
//   }
// }

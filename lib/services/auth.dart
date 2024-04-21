import 'package:chit_chat/helperfunctions/sharedpref_helper.dart';
import 'package:chit_chat/services/database.dart';
import 'package:chit_chat/views/home.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthMethods {
  final FirebaseAuth auth = FirebaseAuth.instance;

  getCurrentUser() async {
    return await auth.currentUser;
  }

  SignInWithGoogle(BuildContext context) async {
    final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
    final GoogleSignIn _googleSignIn = GoogleSignIn();

    final GoogleSignInAccount? googleSignInAccount =
        await _googleSignIn.signIn();
    final GoogleSignInAuthentication googleSignInAuthentication =
        await googleSignInAccount!.authentication;

    final AuthCredential credential = GoogleAuthProvider.credential(
      idToken: googleSignInAuthentication.idToken,
      accessToken: googleSignInAuthentication.accessToken,
    );

    UserCredential result =
        await _firebaseAuth.signInWithCredential(credential);

    User? userDetails = result.user;
    if (result != null) {
      SharedPreferenceHelper().saveUserEmail(userDetails?.email);
      SharedPreferenceHelper().saveUserId(userDetails?.uid);
      SharedPreferenceHelper()
          .saveUserName(userDetails?.email?.replaceAll("@gmail.com", ""));
      SharedPreferenceHelper().saveDisplayName(userDetails?.displayName);
      SharedPreferenceHelper().saveUserProfileUrl(userDetails?.photoURL);

      Map<String, dynamic> userInfoMap = {
        "email": userDetails!.email,
        "username": userDetails.email?.replaceAll("@gmail.com", ""),
        "Name": userDetails.displayName,
        "ProfileUrl": userDetails.photoURL,
      };

      DatabaseMethods().addUserInfoToDB(userDetails.uid, userInfoMap).then(
        (value) {
          Navigator.pushReplacement(
              context, MaterialPageRoute(builder: (context) => const Home()));
        },
      );
    }
  }

  Future SignOut() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    pref.clear();
    await auth.signOut();
  }
}

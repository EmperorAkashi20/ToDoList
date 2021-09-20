import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_state_manager/get_state_manager.dart';
import 'package:todo/Views/ResetPassword.dart';
import 'package:todo/Views/Dashboard.dart';
import 'package:todo/Views/SignUp.dart';

import '../CollectionNames.dart';
import '../main.dart';

class LoginController extends GetxController {
  var email;
  var password;
  var name;
  var docId;
  bool showSpinner = false;
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;

  onTapForgotPassword() {
    Get.to(() => ResetPasswordScreen());
  }

  onTapSignUpScreen() {
    Get.to(() => SignUpScreen());
  }

  Future getCurrentUser() async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        await _firestore
            .collection(collectionUser)
            .where('Email', isEqualTo: email)
            .get()
            .then((QuerySnapshot querySnapshot) {
          querySnapshot.docs.forEach((element) {
            name = element['First Name'];
            docId = element.id;
          });
        });
      }
    } catch (e) {
      print(e);
    }
  }

  onSubmitLogin() async {
    Get.isDialogOpen ?? true
        ? Offstage()
        : Get.dialog(Center(child: CircularProgressIndicator()),
            barrierDismissible: false);
    try {
      await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      await getCurrentUser();
      await MyApp.prefs.setString('email', email);
      await MyApp.prefs.setString('docId', docId);
      await MyApp.prefs.setString('userFirstName', name);
      Get.offAll(() => Dashboard());
    } catch (e) {
      print(e);
    }
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_state_manager/get_state_manager.dart';
import 'package:todo/Controllers/LoginController.dart';
import 'package:todo/Views/Dashboard.dart';

import '../main.dart';

@override
extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${this.substring(1)}";
  }
}

class SignUpController extends GetxController {
  final LoginController _loginController = Get.find();
  var email;
  var password;
  var phone;
  var firstName;
  var lastName;
  var confirmPassword;
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;

  Future getCurrentUser() async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        await _firestore
            .collection('Users')
            .where('Email', isEqualTo: email)
            .get()
            .then((QuerySnapshot querySnapshot) {
          querySnapshot.docs.forEach((element) {
            _loginController.name = element['First Name'];
            _loginController.docId = element.id;
          });
        });
      }
    } catch (e) {
      print(e);
    }
  }

  onTapSubmit() async {
    Get.isDialogOpen ?? true
        ? Offstage()
        : Get.dialog(Center(child: CircularProgressIndicator()),
            barrierDismissible: false);
    try {
      await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      await getCurrentUser();
      var a = firstName[0].toUpperCase() + firstName.substring(1);
      var b = lastName[0].toUpperCase() + lastName.substring(1);
      print(a);
      print(b);
      await _firestore.collection('Users').add({
        'Email': email,
        'First Name': a,
        'Last Name': b,
        'Full Name': a + ' ' + b,
        'Phone No': phone,
      });
      await getCurrentUser();
      await MyApp.prefs.setString('email', email);
      await MyApp.prefs.setString('docId', _loginController.docId);

      Get.offAll(() => Dashboard());
    } catch (e) {
      print(e);
    }
  }
}

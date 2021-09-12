import 'package:flutter/material.dart';

import 'Login.dart';
import 'Theme.dart';
import 'ToDoList/TodoList.dart';
import 'Widgets.dart/Checkbox.dart';
import 'Widgets.dart/PrimaryButton.dart';
import 'Widgets.dart/SignUpForm.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SignUpScreen extends StatefulWidget {
  static bool showSpinner = false;

  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${this.substring(1)}";
  }
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ModalProgressHUD(
        inAsyncCall: SignUpScreen.showSpinner,
        child: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: SingleChildScrollView(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: 70,
                  ),
                  Padding(
                    padding: kDefaultPadding,
                    child: Text(
                      'Create Account',
                      style: titleText,
                    ),
                  ),
                  SizedBox(
                    height: 5,
                  ),
                  Padding(
                    padding: kDefaultPadding,
                    child: Row(
                      children: [
                        Text(
                          'Already a member?',
                          style: subTitle,
                        ),
                        SizedBox(
                          width: 5,
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => LogInScreen()));
                          },
                          child: Text(
                            'Log In',
                            style: textButton.copyWith(
                              decoration: TextDecoration.underline,
                              decorationThickness: 1,
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Padding(
                    padding: kDefaultPadding,
                    child: SignUpForm(),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Padding(
                    padding: kDefaultPadding,
                    child: CheckBox('I agree to all the terms and conditions.'),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  GestureDetector(
                    onTap: () async {
                      setState(() {
                        SignUpScreen.showSpinner = true;
                      });
                      try {
                        final newUser =
                            await _auth.createUserWithEmailAndPassword(
                                email: SignUpForm.email.toString(),
                                password: SignUpForm.password.toString());
                        if (newUser != null) {
                          var a = SignUpForm.firstName.toString().capitalize();
                          var b = SignUpForm.lastName.toString().capitalize();
                          await _firestore.collection('Users').add({
                            'Email': SignUpForm.email,
                            'First Name': a,
                            'Last Name': b,
                            'Full Name': a + ' ' + b,
                            'Phone No': SignUpForm.phone,
                          });
                          Navigator.of(context).pushReplacement(
                            MaterialPageRoute(
                              builder: (BuildContext context) => ToDoList(),
                            ),
                          );
                          setState(() {
                            SignUpScreen.showSpinner = false;
                          });
                        }
                      } catch (e) {
                        print(e);
                      }
                    },
                    child: Padding(
                      padding: kDefaultPadding,
                      child: PrimaryButton(buttonText: 'Sign Up'),
                    ),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  // Padding(
                  //   padding: kDefaultPadding,
                  //   child: Text(
                  //     'Or log in with:',
                  //     style: subTitle.copyWith(color: kBlackColor),
                  //   ),
                  // ),
                  // SizedBox(
                  //   height: 20,
                  // ),
                  // Padding(
                  //   padding: kDefaultPadding,
                  //   child: LoginOption(),
                  // ),
                  SizedBox(
                    height: 20,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

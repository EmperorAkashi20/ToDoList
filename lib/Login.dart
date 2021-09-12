import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:todo/ToDoList/TodoList.dart';

import 'ResetPassword.dart';
import 'SignUp.dart';
import 'Theme.dart';
import 'Widgets.dart/LoginForm.dart';
import 'Widgets.dart/PrimaryButton.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';

class LogInScreen extends StatefulWidget {
  static var name;
  static var docId;
  static bool showSpinner = false;

  @override
  _LogInScreenState createState() => _LogInScreenState();
}

class _LogInScreenState extends State<LogInScreen> {
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;

  Future getCurrentUser() async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        await _firestore
            .collection('Users')
            .where('Email', isEqualTo: LogInForm.email)
            .get()
            .then((QuerySnapshot querySnapshot) {
          querySnapshot.docs.forEach((element) {
            LogInScreen.name = element['First Name'];
            LogInScreen.docId = element.id;
          });
        });
      }
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ModalProgressHUD(
        inAsyncCall: LogInScreen.showSpinner,
        child: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: Center(
            child: Padding(
              padding: kDefaultPadding,
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      height: 120,
                    ),
                    Text(
                      'Welcome Back',
                      style: titleText,
                    ),
                    SizedBox(
                      height: 5,
                    ),
                    Row(
                      children: [
                        Text(
                          'New to this app?',
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
                                builder: (context) => SignUpScreen(),
                              ),
                            );
                          },
                          child: Text(
                            'Sign Up',
                            style: textButton.copyWith(
                              decoration: TextDecoration.underline,
                              decorationThickness: 1,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    LogInForm(),
                    SizedBox(
                      height: 20,
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ResetPasswordScreen(),
                          ),
                        );
                      },
                      child: Text(
                        'Forgot password?',
                        style: TextStyle(
                          color: kZambeziColor,
                          fontSize: 14,
                          decoration: TextDecoration.underline,
                          decorationThickness: 1,
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    GestureDetector(
                      onTap: () async {
                        setState(() {
                          LogInScreen.showSpinner = true;
                        });
                        try {
                          await _auth.signInWithEmailAndPassword(
                              email: LogInForm.email.toString(),
                              password: LogInForm.password.toString());

                          await getCurrentUser();
                          Navigator.of(context).pushReplacement(
                            MaterialPageRoute(
                              builder: (BuildContext context) => ToDoList(),
                            ),
                          );
                          setState(() {
                            LogInScreen.showSpinner = false;
                          });
                        } catch (e) {
                          print(e);
                        }
                      },
                      child: PrimaryButton(
                        buttonText: 'Log In',
                      ),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    // Text(
                    //   'Or log in with:',
                    //   style: subTitle.copyWith(color: kBlackColor),
                    // ),
                    // SizedBox(
                    //   height: 20,
                    // ),
                    // LoginOption(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

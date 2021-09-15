import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:todo/Controllers/LoginController.dart';

import '../Theme.dart';
import '../Widgets.dart/LoginForm.dart';
import '../Widgets.dart/PrimaryButton.dart';

class LogInScreen extends StatelessWidget {
  final LoginController _loginController = Get.put(LoginController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
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
                          _loginController.onTapSignUpScreen();
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
                      _loginController.onTapForgotPassword();
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
                    onTap: () {
                      _loginController.onSubmitLogin();
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
    );
  }
}

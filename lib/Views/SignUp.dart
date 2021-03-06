import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:todo/Controllers/SignUpController.dart';

import '../Theme.dart';
import '../Widgets.dart/Checkbox.dart';
import '../Widgets.dart/PrimaryButton.dart';
import '../Widgets.dart/SignUpForm.dart';

class SignUpScreen extends StatelessWidget {
  final SignUpController _signUpController = Get.put(SignUpController());
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
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
                          Get.back();
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
                  onTap: () {
                    _signUpController.onTapSubmit();
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
    );
  }
}

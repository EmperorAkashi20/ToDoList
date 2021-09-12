import 'package:flutter/material.dart';

import '../Theme.dart';

class SignUpForm extends StatefulWidget {
  static String? email;
  static String? firstName;
  static String? lastName;
  static String? phone;
  static String? password;
  static String? confirmPassword;
  @override
  _SignUpFormState createState() => _SignUpFormState();
}

class _SignUpFormState extends State<SignUpForm> {
  bool _isObscure = true;
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        buildFirstNameInputForm('First Name'),
        buildLastNameInputForm('Last Name'),
        buildEmailInputForm('Email'),
        buildPhoneInputForm('Phone'),
        buildPasswordInputForm('Password', true),
        buildConfirmPasswordInputForm('Confirm Password', true),
      ],
    );
  }

  Padding buildPasswordInputForm(String hint, bool pass) {
    return Padding(
        padding: EdgeInsets.symmetric(vertical: 5),
        child: TextFormField(
          onChanged: (value) {
            SignUpForm.password = value;
          },
          obscureText: pass ? _isObscure : false,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: kTextFieldColor),
            focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: kPrimaryColor)),
            suffixIcon: pass
                ? IconButton(
                    onPressed: () {
                      setState(() {
                        _isObscure = !_isObscure;
                      });
                    },
                    icon: _isObscure
                        ? Icon(
                            Icons.visibility_off,
                            color: kTextFieldColor,
                          )
                        : Icon(
                            Icons.visibility,
                            color: kPrimaryColor,
                          ))
                : null,
          ),
        ));
  }

  Padding buildConfirmPasswordInputForm(String hint, bool pass) {
    return Padding(
        padding: EdgeInsets.symmetric(vertical: 5),
        child: TextFormField(
          onChanged: (value) {
            SignUpForm.confirmPassword = value;
          },
          obscureText: pass ? _isObscure : false,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: kTextFieldColor),
            focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: kPrimaryColor)),
            suffixIcon: pass
                ? IconButton(
                    onPressed: () {
                      setState(() {
                        _isObscure = !_isObscure;
                      });
                    },
                    icon: _isObscure
                        ? Icon(
                            Icons.visibility_off,
                            color: kTextFieldColor,
                          )
                        : Icon(
                            Icons.visibility,
                            color: kPrimaryColor,
                          ))
                : null,
          ),
        ));
  }

  Padding buildEmailInputForm(String hint) {
    return Padding(
        padding: EdgeInsets.symmetric(vertical: 5),
        child: TextFormField(
          keyboardType: TextInputType.emailAddress,
          onChanged: (value) {
            SignUpForm.email = value;
          },
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: kTextFieldColor),
            focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: kPrimaryColor)),
          ),
        ));
  }

  Padding buildFirstNameInputForm(String hint) {
    return Padding(
        padding: EdgeInsets.symmetric(vertical: 5),
        child: TextFormField(
          keyboardType: TextInputType.name,
          onChanged: (value) {
            SignUpForm.firstName = value;
          },
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: kTextFieldColor),
            focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: kPrimaryColor)),
          ),
        ));
  }

  Padding buildLastNameInputForm(String hint) {
    return Padding(
        padding: EdgeInsets.symmetric(vertical: 5),
        child: TextFormField(
          keyboardType: TextInputType.name,
          onChanged: (value) {
            SignUpForm.lastName = value;
          },
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: kTextFieldColor),
            focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: kPrimaryColor)),
          ),
        ));
  }

  Padding buildPhoneInputForm(String hint) {
    return Padding(
        padding: EdgeInsets.symmetric(vertical: 5),
        child: TextFormField(
          keyboardType: TextInputType.phone,
          onChanged: (value) {
            SignUpForm.phone = value;
          },
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: kTextFieldColor),
            focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: kPrimaryColor)),
          ),
        ));
  }
}

import 'package:flutter/material.dart';

import '../Theme.dart';

class LogInForm extends StatefulWidget {
  static String? email;
  static String? password;
  @override
  _LogInFormState createState() => _LogInFormState();
}

class _LogInFormState extends State<LogInForm> {
  bool _isObscure = true;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        buildEmailInputForm('Email'),
        buildInputForm('Password', true),
      ],
    );
  }

  Padding buildInputForm(String label, bool pass) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 5),
      child: TextFormField(
        onChanged: (value) {
          LogInForm.password = value;
        },
        obscureText: pass ? _isObscure : false,
        decoration: InputDecoration(
            labelText: label,
            labelStyle: TextStyle(
              color: kTextFieldColor,
            ),
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: kPrimaryColor),
            ),
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
                          ),
                  )
                : null),
      ),
    );
  }

  Padding buildEmailInputForm(String label) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 5),
      child: TextFormField(
        keyboardType: TextInputType.emailAddress,
        onChanged: (value) {
          LogInForm.email = value;
        },
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(
            color: kTextFieldColor,
          ),
          focusedBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: kPrimaryColor),
          ),
        ),
      ),
    );
  }
}

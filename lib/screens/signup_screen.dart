import 'package:flutter/material.dart';

import '../services/auth_service.dart';

class SignupScreen extends StatefulWidget {
  static const String id = '/signup-screen';

  @override
  _SignupScreenState createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();

  String _name, _email, _password;

  void _submit() {
    if (_formKey.currentState.validate()) {
      _formKey.currentState.save();
    }

    AuthService.signUpUser(context, _name, _email, _password);
  }

  void _navigateBackToLogin() {
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
          child: Container(
        height: MediaQuery.of(context).size.height,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              'Instagram',
              style: TextStyle(fontSize: 50.0, fontFamily: 'Billabong'),
            ),
            Form(
                key: _formKey,
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 30.0, vertical: 10.0),
                      child: TextFormField(
                        decoration: InputDecoration(labelText: 'Name'),
                        validator: (value) =>
                            value.trim().isEmpty ? "Invalid name" : null,
                        onSaved: (value) => _name = value,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 30.0, vertical: 10.0),
                      child: TextFormField(
                        autocorrect: false,
                        decoration: InputDecoration(labelText: 'Email'),
                        validator: (value) =>
                            !value.contains('@') ? "Invalid email" : null,
                        onSaved: (value) => _email = value,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 30.0, vertical: 10.0),
                      child: TextFormField(
                        obscureText: true,
                        decoration: InputDecoration(labelText: 'Password'),
                        validator: (value) => value.length < 6
                            ? "Password must be at leat 6 characters"
                            : null,
                        onSaved: (value) => _password = value,
                      ),
                    ),
                    SizedBox(
                      height: 20.0,
                    ),
                    Container(
                      width: 250.0,
                      child: TextButton(
                          onPressed: _submit,
                          style: ButtonStyle(
                            overlayColor: MaterialStateProperty.all<Color>(
                                Colors.blue[600]),
                            backgroundColor:
                                MaterialStateProperty.all<Color>(Colors.blue),
                          ),
                          child: Text(
                            'Sign Up',
                            style:
                                TextStyle(color: Colors.white, fontSize: 16.0),
                          )),
                    ),
                    SizedBox(
                      height: 10.0,
                    ),
                    Container(
                      width: 250.0,
                      child: TextButton(
                          onPressed: _navigateBackToLogin,
                          style: ButtonStyle(
                            overlayColor: MaterialStateProperty.all<Color>(
                                Colors.blue[600]),
                            backgroundColor:
                                MaterialStateProperty.all<Color>(Colors.blue),
                          ),
                          child: Text(
                            'Back to login',
                            style:
                                TextStyle(color: Colors.white, fontSize: 16.0),
                          )),
                    )
                  ],
                ))
          ],
        ),
      )),
    );
  }
}

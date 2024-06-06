import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'widget.dart';  // Import file widget.dart

class SignUpPage extends StatefulWidget {
  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _auth = FirebaseAuth.instance;

void _signUp() async {
  try {
    await _auth.createUserWithEmailAndPassword(
      email: _emailController.text,
      password: _passwordController.text,
    );
    Navigator.pop(context); // Always navigate back after successful signup
  } catch (e) {
    showErrorDialog(context, e.toString());
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Sign Up'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('assets/logo.png', height: 100),
            SizedBox(height: 20),
            CustomTextField(
              controller: _emailController,
              label: 'Email',
            ),
            SizedBox(height: 10),
            CustomTextField(
              controller: _passwordController,
              label: 'Password',
              isPassword: true,
            ),
            SizedBox(height: 20),
            CustomButton(
              text: 'Sign Up',
              onPressed: _signUp,
            ),
          ],
        ),
      ),
    );
  }
}

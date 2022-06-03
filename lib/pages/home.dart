// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'login.dart';
import 'signup.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Live Location tracking"),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
        ElevatedButton(
          onPressed: navigateToLoginPage, 
          child: const Text('Log In')),
         ElevatedButton(
          onPressed: navigateToSignUpPage, 
          child: const Text('Sign Up'))
      ],
      ),
      
    );
  }
  void navigateToLoginPage(){
          Navigator.push(context, MaterialPageRoute(builder: (context) => LoginPage(), fullscreenDialog: true)
        );
  }
  void navigateToSignUpPage(){
          Navigator.push(context, MaterialPageRoute(builder: (context) => SignUpPage(), fullscreenDialog: true)
        );
  }
}
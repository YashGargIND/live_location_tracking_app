import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'home.dart';

class WelcomePage extends StatefulWidget {
  const WelcomePage({Key? key, required this.user}) : super(key: key);
  final UserCredential user;
  @override
  State<WelcomePage> createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
      title : Text('Welcome ${widget.user.user!.email}'),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Expanded(child: Container()),
          ElevatedButton(
            onPressed: () {}, 
            child: const Text('My Groups')),
          ElevatedButton(
            onPressed: () {}, 
            child: const Text('Profile')),
          ElevatedButton(
            child: const Text("SignOut"),
            onPressed: ()  {
              FirebaseAuth.instance.signOut();
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => HomePage()));
            },),
          Expanded(child: Container()),
      ],
      ), 
      
      
    );
  }
}
// ignore_for_file: prefer_const_constructors_in_immutables

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'welcome.dart';

class LoginPage extends StatefulWidget {
  LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  late String _email, _password;
  bool _showPassword = false;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Log In'),
      ),
      body: Column(
        children: [
          Form(
            key : _formKey,
            child: Column(
              children: [
                TextFormField(
                  validator: (input){
                    if(input!.isEmpty){
                      return 'Please enter an Email';
                    }
                    else{
                      return '';
                    }
                  },
                  onSaved: (input) => _email = input!,
                  decoration: const InputDecoration(
                    labelText: "Email",
                  ),
                ),
                TextFormField(
                  validator: (input){
                    if(input!.length < 8){
                      return 'Please enter minimum 8 characters';
                    }
                    else{
                      return '';
                    }
                  },
                  onSaved: (input) => _password = input!,
                  decoration: const InputDecoration(
                    labelText: "Password",
                  ),
                  obscureText: !_showPassword,
                ),
                Row(
                  children: [
                    Checkbox(
                      value: _showPassword, 
                      onChanged: (val) {
                        setState(() {
                          _showPassword = !_showPassword;
                        });
                      }),
                    const Text('Show Password')
                  ],
                ),
                ElevatedButton(
                  onPressed: signIn, 
                  child: const Text('Sign In')),

            ]) ,)
      ]),
    );
  }
  Future<void> signIn() async{
    final formState = _formKey.currentState;
    if(formState!.validate()){
      formState.save();
      try{
      UserCredential user = await FirebaseAuth.instance.signInWithEmailAndPassword(email: _email, password: _password);
      Navigator.of(context).pop();
      Navigator.push(context, MaterialPageRoute(builder: (context) => WelcomePage(user : user)));
      }
      catch(err){
        print(err);
      }
    }
  }
}
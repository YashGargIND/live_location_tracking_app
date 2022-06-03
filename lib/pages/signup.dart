import 'welcome.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';


class SignUpPage extends StatefulWidget {
  const SignUpPage({Key? key}) : super(key: key);

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  late String _name , _email, _password;
  bool _showPassword = false;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SignUp'),
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
                      return 'Please enter your name';
                    }
                  },
                  onSaved: (input) => _name = input!,
                  decoration: const InputDecoration(
                    labelText: "Full Name",
                  ),
                ),
                TextFormField(
                  validator: (input){
                    if(input!.isEmpty){
                      return 'Please enter an Email';
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
                  onPressed: signUp, 
                  child: const Text('Sign Up')),

            ]) ,)
      ]),
    );
  }
  Future<void> signUp() async{
    final formState = _formKey.currentState;
    if(formState!.validate()){
      formState.save();
      try{
      UserCredential user = await FirebaseAuth.instance.createUserWithEmailAndPassword(email: _email, password: _password);
      // user.user!.sendEmailVerification();
      Navigator.of(context).pop();
      CollectionReference users = FirebaseFirestore.instance.collection('users');
      String uid = user.user!.uid.toString();
      users.add({
        "name" : _name,
        "uid" : uid,
      });
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => WelcomePage(user : user)));
      }
      catch(err){
        print(err);
      }
    }
  }
}
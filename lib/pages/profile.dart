import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

late User loggedInUser;

class Profile extends StatefulWidget {
  const Profile({Key? key}) : super(key: key);

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  final _auth = FirebaseAuth.instance;
  final userCollection = FirebaseFirestore.instance.collection("users");
  late String _name, _email, _dp;
  getCurrentUser() {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        loggedInUser = user;
      }
    } catch (err) {
      print(err);
    }
  }

  void initState() {
    super.initState();
    getCurrentUser();
  }

  Future<void> userData() async {
    final uid = loggedInUser.uid;
    DocumentSnapshot ds = await userCollection.doc(uid).get();
    _dp = ds.get("dp");
    _name = ds.get('name');
    _email = ds.get("email");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("My profile"),
      ),
      body: FutureBuilder(
          future: userData(),
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return Text("Loading");
            }
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Text("Name = $_name"),
                Text("Email = $_email")
              ],
            );
          }),
    );
  }
}

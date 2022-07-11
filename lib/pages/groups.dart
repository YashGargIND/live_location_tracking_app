import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:live_location_tracking_app/pages/search.dart';

class Groups extends StatefulWidget {
  const Groups({Key? key}) : super(key: key);

  @override
  State<Groups> createState() => _GroupsState();
}

class _GroupsState extends State<Groups> {
  String _username = " ";
  // CollectionReference ds = FirebaseFirestore.instance.collection('users');
  final String? _uid = FirebaseAuth.instance.currentUser?.uid;
  // Stream<QuerySnapshot> username = FirebaseFirestore.instance.collection('users').where('uid', isEqualTo: FirebaseAuth.instance.currentUser?.uid).snapshots();

  Future<void> getcurrentuser() async {
    await FirebaseFirestore.instance
        .collection('users')
        .where('uid', isEqualTo: _uid)
        .get()
        .then((snapshot) {
      setState(() {
        _username = snapshot.docs.first['name'];
      });
    });
  }
  // Stream<QuerySnapshot> groups = FirebaseFirestore.instance
  //  .collection('groups')
  //  .where('users', arrayContains: FirebaseFirestore.instance.collection('users').where('uid', isEqualTo: FirebaseAuth.instance.currentUser?.uid).snapshots().first)
  //  .snapshots();

  void initState() {
    super.initState();
    getcurrentuser();
  }

  @override
  Widget build(BuildContext context) {
    print("hello");
    // getcurrentuser();
    print(_username);
    return Scaffold(
      appBar: AppBar(
        title: Text('My Groups'),
      ),
      body: StreamBuilder(
          stream: FirebaseFirestore.instance
              .collection('groups')
              .where('users', arrayContains: _username)
              .snapshots(),
          builder:
              (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }
            return ListView(
                children: snapshot.data!.docs.map((grp) {
              return Center(
                  child: (Padding(
                padding: EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Expanded(
                    //   child:SizedBox(
                    //     height: 3.0,
                    //   ) ,),
                    Card(
                        child: ListTile(
                          
                            title: Padding(
                             padding: EdgeInsets.symmetric(horizontal: 8.0,vertical: 4.0),
                              child: Text(
                                grp['Group Name'],
                                style: TextStyle(
                                  fontSize: 20.0,
                                  fontWeight: FontWeight.bold,
                                ),
                                
                              ),
                              
                            ),
                            
                            subtitle: Padding(
                             padding: EdgeInsets.symmetric(horizontal: 8.0,vertical: 4.0),
                              child: Text(
                                grp['users'].toString().substring(1, grp['users'].toString().length-1),
                                style: TextStyle(
                                  fontSize: 12.0,
                                  fontWeight: FontWeight.bold,
                                ),
                                
                              ),
                              
                            ))),
                  ],
                ),
              )));
            }).toList());
          }),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
              context, MaterialPageRoute(builder: (context) => Search()));
        },
        child: Icon(
          Icons.add,
        ),
      ),
    );
  }
}

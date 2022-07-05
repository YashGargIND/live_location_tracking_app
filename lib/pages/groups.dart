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
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('My Groups'),
    ),
        floatingActionButton: FloatingActionButton(
          onPressed:(){
            Navigator.push(
                    context, MaterialPageRoute(builder: (context) => Search()));},
          child: Icon(
            Icons.add,
          ),
           ),);
  }
}

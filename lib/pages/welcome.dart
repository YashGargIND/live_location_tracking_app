import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:live_location_tracking_app/pages/groups.dart';
import 'package:live_location_tracking_app/pages/profile.dart';
import 'package:location/location.dart';
import 'package:geolocator/geolocator.dart';
import 'home.dart';
import 'profile.dart';

class WelcomePage extends StatefulWidget {
  const WelcomePage({Key? key, required this.user}) : super(key: key);
  final UserCredential user;
  @override
  State<WelcomePage> createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> {
  Location location = Location();
  late bool _serviceEnabled;
  late PermissionStatus _permissionGranted;
  late LocationData _locationData;
// late GoogleMapController _controller;

  void serviceEnable() async {
    _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await location.requestService();
      if (!_serviceEnabled) {
        return;
      }
    }
  }

  void permissionGrant() async {
    _permissionGranted = await location.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await location.requestPermission();
      location.enableBackgroundMode(enable: true);
      if (_permissionGranted != PermissionStatus.granted) {
        return;
      }
    }
  }

  Future<void> addLocationToDatabase() async {
    return FirebaseFirestore.instance
        .collection('users')
        .doc(widget.user.user!.email)
        .update({'location': _locationData.toString()})
        .then((value) => print("location data is $_locationData.toString()"))
        .catchError((err) {
          print("error");
        });
  }

  Future<void> locationInfo() async {
    _locationData = await location.getLocation();
  }

  @override
  void initState() {
    super.initState();
    serviceEnable();
    permissionGrant();
    // locationInfo();
    // if(_serviceEnabled){
    // print("true");
    // }
    // else{
    //   print("false");
    // }
    // print(_permissionGranted);
    //   if (defaultTargetPlatform == TargetPlatform.android) {
//   AndroidGoogleMapsFlutter.useAndroidViewSurface = true;
// }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Welcome ${(widget.user.user!.email)}'),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Expanded(child: Container()),
          Text("Your current Location :"),
          FutureBuilder(
              future: locationInfo(),
              builder: (context, snapshot) {
                if (snapshot.connectionState != ConnectionState.done) {
                  return Text("Loading");
                }
                try {
                  return Text(
                      "Latitude = ${_locationData.latitude!}, Longitude = ${_locationData.longitude!}");
                } catch (err) {
                  return Text(err.toString());
                }
                // Text("Longitude = ${_locationData.longitude!}"),
              }),
          ElevatedButton(
              onPressed: () {
                addLocationToDatabase();
                Navigator.push(
                    context, MaterialPageRoute(builder: (context) => Groups(locdata : _locationData)));
              },
              child: const Text('My Groups')),
          ElevatedButton(
              onPressed: () {
                
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => Profile()));
              },
              child: const Text('Profile')),
          ElevatedButton(
            child: const Text("SignOut"),
            onPressed: () {
              addLocationToDatabase();
              FirebaseAuth.instance.signOut();
              Navigator.pushReplacement(
                  context, MaterialPageRoute(builder: (context) => HomePage()));
            },
          ),
          Expanded(child: Container()),
        ],
      ),
    );
  }
}

import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:geoflutterfire/geoflutterfire.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:rxdart/rxdart.dart';

class MapPage extends StatefulWidget {
  MapPage(
      {Key? key, required this.grpid, required this.uid, required this.locdata})
      : super(key: key);
  LocationData locdata;
  String grpid;
  String? uid;
  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  // final Completer<GoogleMapController> _controller = Completer();
  final List<Marker> markers = [];
  BehaviorSubject<double> radius = BehaviorSubject();
  late Stream<List<DocumentSnapshot>> stream;
  double _value = 1.0;
  String _label = '';
  changed(value) {
    setState(() {
      _value = value;
      _label = '${_value.toInt().toString()}kms';
      radius.add(value);
      markers.clear();
    });
  }

  void _updateMarkers(List<DocumentSnapshot> documentList) {
    markers.clear();
    print('updated markers');
    documentList.forEach(
      (DocumentSnapshot document) {
        GeoPoint point = document['position']['geopoint'];
        String name = document['name'];
        _addMarker(point.latitude, point.longitude, name);
      },
    );
  }

  void _addMarker(double lat, double lng, String name) {
    var _marker = Marker(
        markerId: MarkerId(UniqueKey().toString()),
        position: LatLng(lat, lng),
        icon: name == name
            ? BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange)
            : BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueViolet),
        infoWindow: InfoWindow(title: name, snippet: '${lat},${lng}'));
    setState(() {
      markers.add(_marker);
    });
  }

  late String _username;
  late GoogleMapController _controller;
  @override
  void initState() {
    super.initState();

    _currentPosition = widget.locdata;
    print(_currentPosition.latitude!);
    getLoc();
    GeoFirePoint center = Geoflutterfire().point(
        latitude: _currentPosition.latitude!,
        longitude: _currentPosition.longitude!);
    stream = radius.switchMap((rad) {
      return Geoflutterfire()
          .collection(
              collectionRef: FirebaseFirestore.instance
                  .collection('groups')
                  .doc(widget.grpid)
                  .collection('locations'))
          .within(
              center: center, radius: rad, field: 'position', strictMode: true);
    });
  }
  // void initState() {
  //   super.initState();
  //   if (defaultTargetPlatform == TargetPlatform.android) {
  //     AndroidGoogleMapsFlutter.useAndroidViewSurface = true;
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Stack(
            children: [
              Container(
                height: MediaQuery.of(context).size.height-170-13.143,
                   width: MediaQuery.of(context).size.width,
                child: GoogleMap(
                  mapType: MapType.normal,
                  myLocationEnabled: true,
                  markers : markers.toSet(),
                  // ignore: prefer_const_constructors
                  initialCameraPosition: CameraPosition(
                      // bearing: 192.8334901395799,
                      target: LatLng(_currentPosition.latitude!, _currentPosition.longitude!),
                      // target: LatLng(0, 0),
                      // tilt: 59.440717697143555,
                      
                      zoom: 10.0),
                  onMapCreated: (GoogleMapController controller) {
                    _onMapCreate(controller);
                  },
                ),
              ),
    
              
            ],
            
          ),
          Slider(
                min: 0,
                max: 1001,
                divisions: 200,
                value: _value,
                label: _label,
                activeColor: Colors.brown,
                inactiveColor: Colors.grey[100],
                onChanged: (double value)=>changed(value),
              )
        ],
      ),
    );
    
  }

    @override
   void dispose() {
     setState(() {
       _controller.dispose();
     });
     super.dispose();
   }
   void _onMapCreate(GoogleMapController _ctrlr) {
     print('yeeeeeehow');
     _controller = _ctrlr;
     Location location = Location();
     location.onLocationChanged.listen((l) async {
       print(l.latitude);
       GeoFirePoint myloc = Geoflutterfire()
           .point(latitude: l.latitude!, longitude: l.longitude!);
       dbadd(myloc);
     });
     stream.listen((List<DocumentSnapshot> documentList) {
       _updateMarkers(documentList);
     });
   }


  // void _updateMarker() {
  //   markers.clear();
  //   grp.
  // }
  late LocationData _currentPosition;
  void getLoc() async {
    Location location = Location();
    late bool _serviceEnabled;
    late PermissionStatus _permissionGranted;

    _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await location.requestService();
      if (!_serviceEnabled) {
        return;
      }
    }

    _permissionGranted = await location.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await location.requestPermission();
      location.enableBackgroundMode(enable: true);
      if (_permissionGranted != PermissionStatus.granted) {
        return;
      }
    }

    _currentPosition = await location.getLocation();
    location.onLocationChanged.listen((LocationData currentLocation) {
      GeoFirePoint myLocation = Geoflutterfire().point(
          latitude: currentLocation.latitude as double,
          longitude: currentLocation.longitude as double);
      dbadd(myLocation);
      print("${currentLocation.latitude} : ${currentLocation.longitude}");
      setState(() {
        _currentPosition = currentLocation;
      });
    });
  }

  Future<void> dbadd(GeoFirePoint myLocation) async {
    await FirebaseFirestore.instance
        .collection('users')
        .where('uid', isEqualTo: widget.uid)
        .get()
        .then((snapshot) {
      setState(() {
        _username = snapshot.docs.first['name'];
      });
    });

    FirebaseFirestore.instance
        .collection('groups')
        .doc(widget.grpid)
        .collection('locations')
        .doc(widget.uid)
        .set({'name': _username, 'position': myLocation.data});
  }
}

import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapPage extends StatefulWidget {
  MapPage({Key? key, required this.grp}) : super(key: key);
  QueryDocumentSnapshot grp;
  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  // final Completer<GoogleMapController> _controller = Completer();
  late GoogleMapController _controller;
  @override
  void initState() {
    super.initState();
    if (defaultTargetPlatform == TargetPlatform.android) {
      AndroidGoogleMapsFlutter.useAndroidViewSurface = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        GoogleMap(
          mapType: MapType.hybrid,
          // ignore: prefer_const_constructors
          initialCameraPosition: CameraPosition(
              bearing: 192.8334901395799,
              // target: LatLng(_locationData.latitude!, _locationData.longitude!),
              target: LatLng(0, 0),
              tilt: 59.440717697143555,
              zoom: 19.151926040649414),
          onMapCreated: (GoogleMapController controller) {
            _onMapcreate(controller);
          },
        )
      ],
    );
  }
}

void _onMapcreate(GoogleMapController controller) {
  var _controller = controller;
}

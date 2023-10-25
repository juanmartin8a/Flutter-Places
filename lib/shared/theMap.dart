import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:geoflutterfire/geoflutterfire.dart';
import 'package:geolocator/geolocator.dart';
import 'package:location/location.dart';
import '../services/database.dart';
import 'package:provider/provider.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geocoder/geocoder.dart' as geoC;
import 'package:geocoding/geocoding.dart' as geocoding;

class TheMapState extends StatefulWidget {
  final double statusBar;
  final Map<MarkerId, Marker> markers;
  final GoogleMapController controller;
  final double latitude;
  final double longitude;
  TheMapState({this.statusBar, this.markers, this.controller, this.latitude, this.longitude});
  @override
  _TheMapStateState createState() => _TheMapStateState();
}

class _TheMapStateState extends State<TheMapState> {
  GoogleMapController _controller;
  Location location = Location();
  final Geolocator _geoLocator = Geolocator();
  Geoflutterfire geo = Geoflutterfire();
  List<Marker> myMarker;
  //Map<MarkerId, Marker> markers = <MarkerId, Marker>{};
  CameraPosition _position;
  var currentLat;
  var currentLon;
  String mapCenterPoint;
  dynamic tripForm;

  void _onMapCreated(GoogleMapController controller) async {
    setState(() {
      _controller = controller;
    });
  }

  getCurrentPos() async {
    var currentLocation = await location.getLocation();
    setState(() {
      currentLat = currentLocation.latitude;
      currentLon = currentLocation.longitude;
    });
  }

  void _updateCameraPosition(CameraPosition position) async {
    setState(() {
      _position = position;
    });
  }

  _animateToUser() async {
    var pos = await location.getLocation();

    _controller.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(
      target: LatLng(pos.latitude, pos.longitude),
      zoom: 12.0,
    )));
  }

  @override
  void initState() {
    _controller = widget.controller;
    //myMarker = widget.myMarker;
    //print('the marker is ${myMarker.length}');
    if (mounted) {
      getCurrentPos();
      print('the controller is $_controller');
    }
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    AppBar appBar = AppBar(
        elevation: 0.0,
        automaticallyImplyLeading: false,
        actions: [
          GestureDetector(
              onTap: () {
                _animateToUser();
              },
              child: Icon(
                Icons.near_me,
                color: Colors.white,
              ))
        ],
        backgroundColor: Colors.transparent,
        leading: IconButton(
            onPressed: () {
              //widget.refresh();
              Navigator.of(context).pop();
            },
            icon: Icon(Icons.keyboard_arrow_left, color: Colors.white, size: 36)),
        title: Container(
            child: Text('Place Location',
                style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w800))),
        centerTitle: true);
    return Scaffold(
        //appBar: PreferredSize(preferredSize: Size.fromHeight(appBar.preferredSize.height), child: appBar),
        backgroundColor: Colors.black,
        body: Stack(children: [
          Container(
              child: currentLat == null || currentLon == null
                  ? Container()
                  : GoogleMap(
                      onMapCreated: _onMapCreated,
                      initialCameraPosition:
                          CameraPosition(target: LatLng(widget.latitude, widget.longitude), zoom: 13),
                      myLocationEnabled: true, // Add little blue dot for device location, requires permission from user
                      mapType: MapType.normal,
                      myLocationButtonEnabled: false,
                      markers: Set<Marker>.of(widget.markers.values), //Set<Marker>.of(markers.values),
                      onCameraMove: _updateCameraPosition,
                      mapToolbarEnabled: false,
                      zoomControlsEnabled: false,
                    )),
          Container(
              height: appBar.preferredSize.height + widget.statusBar,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                    colors: [Colors.black38, Colors.transparent],
                    begin: const FractionalOffset(0.0, 0.0),
                    end: const FractionalOffset(0.0, 1),
                    stops: [0.0, 1.0],
                    tileMode: TileMode.clamp),
              ),
              child: appBar),
        ]));
  }
}

import 'package:flutter/material.dart';
import 'package:geoflutterfire/geoflutterfire.dart';
import 'package:geolocator/geolocator.dart';
import 'package:location/location.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geocoder/geocoder.dart' as geoC;
import 'package:geocoding/geocoding.dart' as geocoding;
import 'package:workingOnUI/screens/home/new/tripForm.dart';

class MapState extends StatefulWidget {
  final double statusBar;
  final GoogleMapController controller;
  final dynamic handleTap;
  final dynamic refresh;
  List<Marker> myMarker;
  final TextEditingController price;
  final TextEditingController days;
  final TextEditingController nights;
  final String imgPath;
  MapState(
      {this.statusBar,
      this.controller,
      this.myMarker,
      this.handleTap,
      this.refresh,
      this.days,
      this.imgPath,
      this.nights,
      this.price});
  @override
  _MapStateState createState() => _MapStateState();
}

class _MapStateState extends State<MapState> {
  GoogleMapController _controller;
  Location location = Location();
  final Geolocator _geoLocator = Geolocator();
  Geoflutterfire geo = Geoflutterfire();
  List<Marker> myMarker;
  Map<MarkerId, Marker> markers = <MarkerId, Marker>{};
  CameraPosition _position;
  var currentLat;
  var currentLon;
  String mapCenterPoint;
  dynamic tripForm;

  _handleTap(LatLng tappedPoint) {
    setState(() {
      myMarker.clear();
      myMarker.add(Marker(
        markerId: MarkerId('position'),
        position: tappedPoint,
      ));
      print('the marker is ${myMarker.length}');
      myMarker = widget.myMarker;
    });
  }

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
    final coordinatesPos = geoC.Coordinates(currentLat, currentLon);
    var newPlace = await geoC.Geocoder.local //google('AIzaSyA4w6O6Zjlx22C0GCEKAg6TmUwQPaL0jtk')
        .findAddressesFromCoordinates(coordinatesPos);
    var first = newPlace.first;

    _controller.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(
      target: LatLng(pos.latitude, pos.longitude),
      zoom: 12.0,
    )));
    setState(() {
      if (first.locality != null) {
        mapCenterPoint = first.locality;
        print('position local is ${first.locality}');
      } else if (first.locality == null && first.adminArea != null) {
        print('position admin is ${first.adminArea}');
        mapCenterPoint = first.adminArea;
      } else {
        null;
      }
    });
  }

  @override
  void initState() {
    _controller = widget.controller;
    myMarker = widget.myMarker;
    print('the marker is ${myMarker.length}');
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
              Navigator.pushReplacement(
                  context,
                  PageRouteBuilder(
                      transitionDuration: Duration(milliseconds: 400),
                      transitionsBuilder: (BuildContext context, Animation<double> animation,
                          Animation<double> secondaryAnimation, Widget child) {
                        animation = CurvedAnimation(parent: animation, curve: Curves.easeInOut);
                        return SlideTransition(
                          position: Tween<Offset>(
                            begin: const Offset(-1.0, 0.0),
                            end: const Offset(0.0, 0.0),
                          ).animate(animation),
                          child: child,
                        );
                      },
                      pageBuilder: (context, Animation<double> animation, Animation<double> secondaryAnimation) =>
                          TripForm(
                              statusBar: widget.statusBar,
                              //controller: _geoController,
                              myMarker: myMarker,
                              //refresh: refresh,
                              price: widget.price,
                              days: widget.days,
                              nights: widget.nights,
                              comesFromMaps: true,
                              imgPath: widget.imgPath)));
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
                      initialCameraPosition: CameraPosition(
                          target: myMarker.isEmpty
                              ? LatLng(currentLat, currentLon)
                              : LatLng(myMarker[0].position.latitude, myMarker[0].position.longitude),
                          zoom: 13),
                      myLocationEnabled: true, // Add little blue dot for device location, requires permission from user
                      mapType: MapType.normal,
                      myLocationButtonEnabled: false,
                      markers: Set.from(myMarker), //Set<Marker>.of(markers.values),
                      onCameraMove: _updateCameraPosition,
                      mapToolbarEnabled: false,
                      zoomControlsEnabled: false,
                      onTap: _handleTap)),
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

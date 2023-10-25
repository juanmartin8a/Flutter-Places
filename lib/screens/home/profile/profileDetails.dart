import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:geoflutterfire/geoflutterfire.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:provider/provider.dart';
import 'package:workingOnUI/models/user.dart';
import 'package:workingOnUI/services/database.dart';
import 'package:workingOnUI/shared/theMap.dart';

class ProfileDetails extends StatefulWidget {
  final dynamic image;
  final String uid;
  final String id;
  final String days;
  final String nights;
  final String placeName;
  final String areaName;
  final String price;
  final dynamic marker;
  final double statusBar;
  final int index;
  final List<Map<String, dynamic>> tripsList;
  final bool accesedFromProf;
  ProfileDetails(
      {this.areaName,
      this.days,
      this.nights,
      this.id,
      this.image,
      this.placeName,
      this.price,
      this.uid,
      this.marker,
      this.statusBar,
      this.index,
      this.tripsList,
      this.accesedFromProf});
  @override
  ProfileDetailsState createState() => ProfileDetailsState();
}

class ProfileDetailsState extends State<ProfileDetails> {
  PageController _controller;
  GoogleMapController _geoController;
  Location location = Location();
  final Geolocator _geoLocator = Geolocator();
  Geoflutterfire geo = Geoflutterfire();
  List<Marker> myMarker = [];
  CameraPosition _position;
  var currentLat;
  var currentLon;
  var markerLat;
  var markerLon;
  Map<MarkerId, Marker> markers = <MarkerId, Marker>{};
  int currentPage;
  String headerName;
  double blur;
  Color opacity;
  double horizontalMargin;
  double verticalMargin;
  double borRadius;
  Offset animatedOffset;
  Color offsetColor;
  bool tripExists = false;

  _onMapCreated(GoogleMapController controller) async {
    setState(() {
      _geoController = controller;
    });
  }

  getCurrentPos() async {
    var currentLocation = await location.getLocation();
    setState(() {
      currentLat = currentLocation.latitude;
      currentLon = currentLocation.longitude;
    });
  }

  _updateCameraPosition(CameraPosition position) async {
    setState(() {
      _position = position;
    });
  }

  _addMarker() {
    final user = Provider.of<CustomUser>(context, listen: false);
    String markerIdPos = user.uid;
    print('the markerIdPos is $markerIdPos');
    final MarkerId markerId = MarkerId(markerIdPos);
    final Marker marker = Marker(
      markerId: markerId,
      position: LatLng(markerLat, markerLon),
      //infoWindow: InfoWindow(title: '$userName')
    );
    setState(() {
      markers[markerId] = marker;
    });
  }

  refresh() {
    setState(() {});
  }

  _addTrip() {
    final user = Provider.of<CustomUser>(context, listen: false);
    Map<String, dynamic> addTripMap = {
      'tripId': widget.id,
      'addedBy': user.uid,
      'from': widget.uid,
    };
    DatabaseService(uid: user.uid, docId: widget.id).addtrip(addTripMap);
    String chatRoomId = 'chatWith${widget.uid}${user.uid}';
    print('constant name below');
    List users = [widget.uid, user.uid];
    Map<String, dynamic> chatRoomMap = {
      'users': users,
      'chatroomId': chatRoomId,
    };
    DatabaseService().createChatRoom(chatRoomId, chatRoomMap);
  }

  checkIfTripExists() async {
    final user = Provider.of<CustomUser>(context, listen: false);
    DocumentSnapshot theDoc = await FirebaseFirestore.instance
        .collection('usernames')
        .doc(user.uid)
        .collection('trips')
        .doc(widget.tripsList[currentPage]['id'])
        .get();
    setState(() {
      print('hello world');
      tripExists = theDoc.exists;
    });
  }

  @override
  void initState() {
    currentPage = widget.index;
    headerName = widget.placeName;
    _controller = PageController(initialPage: widget.index, viewportFraction: 0.80);
    markerLat = widget.marker['geopoint'].latitude;
    markerLon = widget.marker['geopoint'].longitude;
    super.initState();
    checkIfTripExists();
    if (mounted) {
      _addMarker();
    }
    getCurrentPos();
  }

  @override
  void dispose() {
    _geoController.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  void deactivate() {
    _geoController.dispose();
    super.deactivate();
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<CustomUser>(context);
    Future<DocumentSnapshot> theDoc =
        FirebaseFirestore.instance.collection('usernames').doc(user.uid).collection('trips').doc(widget.id).get();
    return Scaffold(
        appBar: AppBar(
          elevation: 0.0,
          automaticallyImplyLeading: false,
          backgroundColor: Colors.transparent,
          actions: [
            widget.uid != user.uid
                ? tripExists
                    ? MaterialButton(
                        onPressed: () {
                          setState(() {
                            DatabaseService(uid: user.uid, docId: widget.id).deleteTrip();
                            checkIfTripExists();
                          });
                        },
                        child: Text('Added',
                            style: TextStyle(
                                color: widget.accesedFromProf ? Colors.blueAccent[400] : Colors.tealAccent[700],
                                fontSize: 17,
                                fontWeight: FontWeight.w700)))
                    : MaterialButton(
                        onPressed: () {
                          setState(() {
                            _addTrip();
                            checkIfTripExists();
                          });
                        },
                        child: Text('Add',
                            style: TextStyle(
                                color: widget.accesedFromProf ? Colors.blueAccent[400] : Colors.tealAccent[700],
                                fontSize: 17,
                                fontWeight: FontWeight.w700)))
                : MaterialButton(onPressed: () {})
          ],
          leading: IconButton(
              onPressed: () => Navigator.of(context).pop(),
              icon: Icon(Icons.keyboard_arrow_left,
                  color: widget.accesedFromProf ? Colors.blueAccent[400] : Colors.tealAccent[700], size: 36)),
          title: Container(
              child: Text('$headerName',
                  style: TextStyle(
                      color: widget.accesedFromProf ? Colors.blueAccent[400] : Colors.tealAccent[700],
                      fontSize: 22,
                      fontWeight: FontWeight.w800))),
          centerTitle: true,
        ),
        backgroundColor: Colors.grey[150],
        body: Container(
            child: Container(
                child: Center(
                    child: PageView.builder(
                        itemCount: widget.tripsList.length,
                        controller: _controller,
                        onPageChanged: (index) {
                          markerLat = widget.tripsList[index]['marker']['geopoint'].latitude;
                          markerLon = widget.tripsList[index]['marker']['geopoint'].longitude;
                          headerName = widget.tripsList[index]['placeName'];
                          setState(() {
                            currentPage = index;
                            _addMarker();
                            checkIfTripExists();
                            refresh();
                          });
                        },
                        itemBuilder: (context, index) {
                          bool active = index == currentPage;
                          horizontalMargin = active ? 15 : 20;
                          verticalMargin = active ? 60 : 110;
                          opacity = active ? Colors.grey[50] : Colors.grey[50];
                          blur = active ? 8 : 3;
                          double spreadRadius = active ? 0.2 : 0.1;
                          borRadius = active ? 20 : 15;
                          double borRadius2 = active ? 22 : 16;
                          animatedOffset = active ? Offset(2.5, 2) : Offset(0, 0);
                          offsetColor = active
                              ? widget.accesedFromProf
                                  ? Colors.blueAccent[400]
                                  : Colors.greenAccent[400]
                              : widget.accesedFromProf
                                  ? Colors.blueAccent[400]
                                  : Colors.greenAccent[400];
                          double childHeight = active ? 180 : 140;
                          double childWidth = active ? 110 : 100;
                          return AnimatedContainer(
                            duration: Duration(milliseconds: 350),
                            curve: Curves.easeIn,
                            margin: EdgeInsets.symmetric(vertical: verticalMargin, horizontal: horizontalMargin),
                            //padding: EdgeInsets.symmetric(horizontal: horizontalMargin),
                            decoration: BoxDecoration(
                                color: opacity,
                                boxShadow: [
                                  BoxShadow(
                                    blurRadius: blur,
                                    color: offsetColor,
                                    spreadRadius: spreadRadius,
                                    offset: animatedOffset,
                                  )
                                ],
                                borderRadius: BorderRadius.circular(borRadius)),
                            child: Container(
                                child: Stack(
                              children: [
                                widget.accesedFromProf
                                    ? Hero(
                                        tag: 'gridYeah',
                                        child: Align(
                                            alignment: Alignment.topCenter,
                                            child: FractionallySizedBox(
                                              heightFactor: 0.60,
                                              widthFactor: 1,
                                              child: AnimatedContainer(
                                                  duration: Duration(milliseconds: 350),
                                                  curve: Curves.easeIn,
                                                  decoration: BoxDecoration(
                                                    color: Colors.grey[200],
                                                    borderRadius: BorderRadius.only(
                                                        topLeft: Radius.circular(borRadius),
                                                        topRight: Radius.circular(borRadius)),
                                                    image: DecorationImage(
                                                        image: NetworkImage(widget.tripsList[index]['image']),
                                                        fit: BoxFit.cover),
                                                  )),
                                            )),
                                      )
                                    : Align(
                                        alignment: Alignment.topCenter,
                                        child: FractionallySizedBox(
                                          heightFactor: 0.60,
                                          widthFactor: 1,
                                          child: AnimatedContainer(
                                              duration: Duration(milliseconds: 350),
                                              curve: Curves.easeIn,
                                              decoration: BoxDecoration(
                                                color: Colors.grey[200],
                                                borderRadius: BorderRadius.only(
                                                    topLeft: Radius.circular(borRadius),
                                                    topRight: Radius.circular(borRadius)),
                                                image: DecorationImage(
                                                    image: NetworkImage(widget.tripsList[index]['image']),
                                                    fit: BoxFit.cover),
                                              )),
                                        )),
                                Align(
                                  alignment: Alignment.bottomCenter,
                                  child: FractionallySizedBox(
                                      heightFactor: 0.52,
                                      widthFactor: 1,
                                      child: Column(
                                        children: [
                                          Align(
                                            alignment: Alignment.bottomRight,
                                            child: Container(
                                                //color: Colors.red,
                                                margin: EdgeInsets.symmetric(vertical: 6, horizontal: 22),
                                                child: StreamBuilder<DocumentSnapshot>(
                                                    stream: DatabaseService(uid: widget.tripsList[index]['uid'])
                                                        .getUserByUid(),
                                                    builder: (context, AsyncSnapshot<DocumentSnapshot> snapshot) {
                                                      if (snapshot.hasData) {
                                                        Map<String, dynamic> userDoc = snapshot.data.data();
                                                        return Container(
                                                            child: Text('${userDoc['name']}',
                                                                textAlign: TextAlign.right,
                                                                style: TextStyle(
                                                                  color: Colors.white,
                                                                  fontSize: 15.7,
                                                                  fontWeight: FontWeight.w600,
                                                                  shadows: <Shadow>[
                                                                    Shadow(
                                                                      blurRadius: 6.0,
                                                                      color: Colors.grey[900],
                                                                    ),
                                                                  ],
                                                                )));
                                                      } else {
                                                        return Container();
                                                      }
                                                    })),
                                          ),
                                          AnimatedContainer(
                                              duration: Duration(milliseconds: 350),
                                              curve: Curves.easeIn,
                                              decoration: BoxDecoration(
                                                color: Colors.grey[50],
                                                borderRadius: BorderRadius.only(
                                                    bottomLeft: Radius.circular(borRadius),
                                                    bottomRight: Radius.circular(borRadius),
                                                    topLeft: Radius.circular(borRadius2),
                                                    topRight: Radius.circular(borRadius2)),
                                              ),
                                              child: Column(children: [
                                                Container(
                                                    margin: EdgeInsets.all(8),
                                                    child: widget.tripsList[index]['marker'].isEmpty
                                                        ? Container
                                                        : Text('${widget.tripsList[index]['areaName']}',
                                                            style: TextStyle(
                                                                color: Colors.grey[800],
                                                                fontSize: 17,
                                                                fontWeight: FontWeight.w700))),
                                                Container(
                                                    child: Row(
                                                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                                        children: [
                                                      GestureDetector(
                                                        onTap: () {
                                                          //_showDialog(context);
                                                        },
                                                        child: AnimatedContainer(
                                                            duration: Duration(milliseconds: 350),
                                                            curve: Curves.easeIn,
                                                            height: childHeight,
                                                            width: childWidth,
                                                            decoration: BoxDecoration(
                                                              color: Colors.grey[200],
                                                              borderRadius: BorderRadius.circular(16),
                                                            ),
                                                            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                                                            child: Column(
                                                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                                              children: [
                                                                FractionallySizedBox(
                                                                    widthFactor: 1,
                                                                    child: Container(
                                                                      child: FractionallySizedBox(
                                                                          widthFactor: 1,
                                                                          child: Container(
                                                                              child: Text(
                                                                                  'days: ${widget.tripsList[index]['days']}',
                                                                                  textAlign: TextAlign.left,
                                                                                  style: TextStyle(
                                                                                      color: Colors.grey[700],
                                                                                      fontSize: 16,
                                                                                      fontWeight: FontWeight.w600)))),
                                                                    )),
                                                                FractionallySizedBox(
                                                                  widthFactor: 1,
                                                                  child: Container(
                                                                    child: Text(
                                                                        'nights: ${widget.tripsList[index]['nights']}',
                                                                        style: TextStyle(
                                                                            color: Colors.grey[700],
                                                                            fontSize: 16,
                                                                            fontWeight: FontWeight.w600)),
                                                                  ),
                                                                ),
                                                                FractionallySizedBox(
                                                                    widthFactor: 1,
                                                                    child: Container(
                                                                        child: Text(
                                                                            '\$${widget.tripsList[index]['price']}',
                                                                            style: TextStyle(
                                                                                color: Colors.grey[700],
                                                                                fontSize: 16,
                                                                                fontWeight: FontWeight.w600))))
                                                              ],
                                                            )),
                                                      ),
                                                      AnimatedContainer(
                                                          duration: Duration(milliseconds: 350),
                                                          curve: Curves.easeIn,
                                                          height: childHeight,
                                                          width: childWidth,
                                                          //margin: EdgeInsets.all(20),
                                                          decoration: BoxDecoration(
                                                            color: Colors.grey[200],
                                                            borderRadius: BorderRadius.circular(16),
                                                          ),
                                                          child: ClipRRect(
                                                              borderRadius: BorderRadius.circular(16),
                                                              child: Stack(
                                                                children: [
                                                                  currentLat == null || currentLon == null
                                                                      ? Container()
                                                                      : GoogleMap(
                                                                          onMapCreated: _onMapCreated,
                                                                          initialCameraPosition: CameraPosition(
                                                                              target: LatLng(
                                                                                  widget
                                                                                      .tripsList[index]['marker']
                                                                                          ['geopoint']
                                                                                      .latitude,
                                                                                  widget
                                                                                      .tripsList[index]['marker']
                                                                                          ['geopoint']
                                                                                      .longitude),
                                                                              zoom: 12),
                                                                          myLocationEnabled:
                                                                              true, // Add little blue dot for device location, requires permission from user
                                                                          mapType: MapType.normal,
                                                                          myLocationButtonEnabled: false,
                                                                          markers: Set<Marker>.of(markers.values),
                                                                          onCameraMove: _updateCameraPosition,
                                                                          mapToolbarEnabled: false,
                                                                          zoomControlsEnabled: false,
                                                                        ),
                                                                  InkWell(
                                                                      onTap: () {
                                                                        //dispose();
                                                                        print('salsa choque');
                                                                        Navigator.push(
                                                                            context,
                                                                            PageRouteBuilder(
                                                                                transitionDuration:
                                                                                    Duration(milliseconds: 400),
                                                                                transitionsBuilder:
                                                                                    (BuildContext context,
                                                                                        Animation<double> animation,
                                                                                        Animation<double>
                                                                                            secondaryAnimation,
                                                                                        Widget child) {
                                                                                  animation = CurvedAnimation(
                                                                                      parent: animation,
                                                                                      curve: Curves.easeInOut);
                                                                                  return SlideTransition(
                                                                                    position: Tween<Offset>(
                                                                                      begin: const Offset(0.0, 1.0),
                                                                                      end: const Offset(0.0, 0.0),
                                                                                    ).animate(animation),
                                                                                    child: child,
                                                                                  );
                                                                                },
                                                                                pageBuilder: (context,
                                                                                        Animation<double> animation,
                                                                                        Animation<double>
                                                                                            secondaryAnimation) =>
                                                                                    TheMapState(
                                                                                        statusBar: widget.statusBar,
                                                                                        markers: markers,
                                                                                        controller: _geoController,
                                                                                        latitude: widget
                                                                                            .tripsList[index]['marker']
                                                                                                ['geopoint']
                                                                                            .latitude,
                                                                                        longitude: widget
                                                                                            .tripsList[index]['marker']
                                                                                                ['geopoint']
                                                                                            .longitude)));
                                                                      },
                                                                      child: Container(
                                                                        height: 180,
                                                                        width: 120,
                                                                      ))
                                                                ],
                                                              )))
                                                    ]))
                                              ])),
                                        ],
                                      )),
                                )
                              ],
                            )),
                          );
                        })))));
  }
}

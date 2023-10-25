import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'dart:io';
import 'package:camera/camera.dart';
import 'package:path_provider/path_provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:workingOnUI/models/uploadTrip.dart';
import 'package:workingOnUI/models/user.dart';
import 'package:workingOnUI/screens/home/new/cameraOrGallery.dart';
import 'package:workingOnUI/screens/home/new/data.dart';
import 'package:workingOnUI/services/database.dart';
import 'package:workingOnUI/shared/camera.dart';
import 'package:geoflutterfire/geoflutterfire.dart';
import 'package:geolocator/geolocator.dart';
import 'package:location/location.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geocoder/geocoder.dart' as geoC;
import 'package:geocoding/geocoding.dart' as geocoding;
import 'package:workingOnUI/shared/map.dart';
import 'package:workingOnUI/shared/theMap.dart';

class TripForm extends StatefulWidget {
  final double statusBar;
  final bool comesFromMaps;
  List<Marker> myMarker;
  final TextEditingController price;
  final TextEditingController days;
  final TextEditingController nights;
  final String imgPath;
  TripForm({this.statusBar, this.comesFromMaps, this.days, this.imgPath, this.myMarker, this.nights, this.price});
  @override
  _TripFormState createState() => _TripFormState();
}

class _TripFormState extends State<TripForm> with SingleTickerProviderStateMixin {
  List cameras;
  File imgPath;
  String thePath;
  GoogleMapController _geoController;
  Location location = Location();
  final Geolocator _geoLocator = Geolocator();
  Geoflutterfire geo = Geoflutterfire();
  List<Marker> myMarker = [];
  Map<MarkerId, Marker> markers = <MarkerId, Marker>{};
  CameraPosition _position;
  var currentLat;
  var currentLon;
  String mapCenterPoint;
  final _formKey = GlobalKey<FormState>();
  TextEditingController _priceController = TextEditingController();
  TextEditingController _daysController = TextEditingController();
  TextEditingController _nightsController = TextEditingController();
  String locationName;
  String adminArea;
  bool barrierDismissible = true;
  final FirebaseStorage _storage = FirebaseStorage(storageBucket: 'gs://flutterplaces-4bc44.appspot.com');
  StorageUploadTask _uploadTask;
  StorageTaskSnapshot _taskSnapshot;
  AnimationController _controller;
  //Animation<Color> _colorAnimation;
  Animation _curve;
  Animation<Alignment> _alignAnimation;
  Animation<double> _paddingAnimation;

  static const LatLng _center = const LatLng(45.521563, -122.677433);

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
    final coordinatesPos = geoC.Coordinates(_position.target.latitude, _position.target.longitude);
    var newPlace = await geoC.Geocoder.local //google('AIzaSyA4w6O6Zjlx22C0GCEKAg6TmUwQPaL0jtk')
        .findAddressesFromCoordinates(coordinatesPos);
    var first = newPlace.first;
    setState(() {
      _position = position;
      print('position mid position is ${_position.target.toString()}');
      if (first.locality != null) {
        mapCenterPoint = first.locality;
        print('position local is ${first.locality}');
      } else if (first.locality == null && first.adminArea != null) {
        mapCenterPoint = first.adminArea;
        print('position admin is ${first.adminArea}');
      } else {
        print('poboth admin and locality are not working');
      }
    });
  }

  _saveTripToDatabase() async {
    final user = Provider.of<CustomUser>(this.context, listen: false);
    if (_priceController.text.isNotEmpty &&
        _daysController.text.isNotEmpty &&
        _nightsController.text.isNotEmpty &&
        myMarker.isNotEmpty &&
        TripImages.thePath.isNotEmpty) {
      print('it is true');
      String filePath = 'trips/${DateTime.now()}.png';
      _uploadTask = _storage.ref().child(filePath).putFile(File(TripImages.thePath));
      _taskSnapshot = await _uploadTask.onComplete;
      final String downloadUrl = await _taskSnapshot.ref.getDownloadURL();
      DocumentReference docRef = FirebaseFirestore.instance.collection('trips').doc();
      GeoFirePoint point =
          geo.point(latitude: myMarker[0].position.latitude, longitude: myMarker[0].position.longitude);
      Map<String, dynamic> tripMap = {
        'image': downloadUrl,
        'uid': user.uid,
        'id': docRef.id,
        'price': _priceController.text,
        'days': _daysController.text,
        'nights': _nightsController.text,
        'marker': point.data,
        'placeName': locationName,
        'areaName': adminArea,
      };
      DatabaseService().uploadTrip(tripMap, docRef);
      //setState(() {
      TripImages.thePath = '';
      //});
      Navigator.of(this.context).pop();
    } else {
      _controller.forward();

      print('not true');
    }
  }

  getPlaceName() async {
    final coordinatesPos = geoC.Coordinates(myMarker[0].position.latitude, myMarker[0].position.longitude);
    var newPlace = await geoC.Geocoder.local //google('AIzaSyA4w6O6Zjlx22C0GCEKAg6TmUwQPaL0jtk')
        .findAddressesFromCoordinates(coordinatesPos);
    setState(() {
      var first = newPlace.first;
      setState(() {
        print('hey');
        if (first.locality != null) {
          locationName = '${first.countryName}';
          adminArea = '${first.locality}';
        } else {
          locationName = '${first.countryName}';
          adminArea = '${first.adminArea}';
        }
      });
    });
  }

  _showDialog(BuildContext context) {
    //assert(!barrierDismissible || barrierLabel != null);
    showGeneralDialog(
        barrierLabel: "Label",
        barrierDismissible: true,
        context: context,
        transitionDuration: Duration(milliseconds: 400),
        transitionBuilder: (context, anim1, anim2, child) {
          return SlideTransition(
            position: Tween(begin: Offset(0, 1), end: Offset(0, 0)).animate(anim1),
            child: child,
          );
        },
        pageBuilder: (context, anim1, anim2) {
          return Dialog(
              insetPadding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width * 0.15),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: TripFormData(
                statusBar: widget.statusBar,
                priceController: _priceController,
                daysController: _daysController,
                nightsController: _nightsController,
                refresh: refresh,
              ));
        });
  }

  refresh() {
    setState(() {
      if (myMarker.isNotEmpty) {
        print('hey 1');
        getPlaceName();
      }
    });
  }

  @override
  void initState() {
    super.initState();
    if (widget.comesFromMaps == true) {
      thePath = widget.imgPath;
      _priceController = widget.price;
      _daysController = widget.days;
      _nightsController = widget.nights;
      myMarker = widget.myMarker;
    }
    getCurrentPos();
    if (myMarker.isNotEmpty) {
      print('hey 1');
      getPlaceName();
    }
    print('my marker is $myMarker');
    _controller = AnimationController(duration: Duration(milliseconds: 300), vsync: this);
    _curve = CurvedAnimation(parent: _controller, curve: Curves.bounceInOut);
    _paddingAnimation = TweenSequence(<TweenSequenceItem<double>>[
      TweenSequenceItem<double>(tween: Tween<double>(begin: 10, end: 20), weight: 45),
      TweenSequenceItem<double>(tween: Tween<double>(begin: 20, end: 0), weight: 45),
      TweenSequenceItem<double>(tween: Tween<double>(begin: 0, end: 10), weight: 45),
      //TweenSequenceItem<double>(tween: Tween<double>(begin: 45, end: 30), weight: 45)
    ]).animate(_curve);
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _controller.reset();
      }
    });
  }

  @override
  void dispose() {
    _geoController.dispose();
    //_controller.dispose();
    super.dispose();
  }

  @override
  void deactivate() {
    print('deactivate called');
    _geoController.dispose();
    super.deactivate();
  }

  @override
  Widget build(BuildContext context) {
    cameraOrGalleryBottomSheet() {
      showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          barrierColor: Colors.black.withAlpha(30),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(10.0)),
          ),
          builder: (BuildContext context) {
            return Wrap(
              children: [CameraOrGallery(statusBar: widget.statusBar, refresh: refresh, accesedFrom: 'form')],
            );
          });
    }

    AppBar appBar = AppBar(
      elevation: 0.0,
      automaticallyImplyLeading: false,
      backgroundColor: Colors.transparent,
      actions: [
        AnimatedBuilder(
            animation: _controller,
            builder: (context, _) {
              return Container(
                width: MediaQuery.of(context).size.width * 0.15,
                padding: EdgeInsets.only(right: _paddingAnimation.value),
                child: Center(
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _saveTripToDatabase();
                      });
                    },
                    child: Text('Save',
                        style: TextStyle(color: Colors.redAccent, fontSize: 17, fontWeight: FontWeight.w700)),
                  ),
                ),
              );
            })
      ],
      leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: Icon(Icons.keyboard_arrow_left, color: Colors.redAccent, size: 36)),
      title: Container(
          child: Text('Create a Trip',
              style: TextStyle(color: Colors.redAccent, fontSize: 22, fontWeight: FontWeight.w800))),
      centerTitle: true,
    );
    return Scaffold(
        resizeToAvoidBottomPadding: false,
        backgroundColor: Colors.grey[150],
        appBar: PreferredSize(preferredSize: Size.fromHeight(appBar.preferredSize.height), child: appBar),
        body: Container(
            child: Container(
                child: Center(
                    child: FractionallySizedBox(
          widthFactor: 0.8,
          child: Container(
              //width: double.infinity * 0.8,
              /*constraints: BoxConstraints.expand(
                                width: double.infinity * 0.8
                              ),*/
              margin: EdgeInsets.symmetric(vertical: 60, horizontal: 15),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    blurRadius: 12,
                    color: Colors.redAccent[100],
                    spreadRadius: 0.2,
                    offset: Offset(5, 4),
                  )
                ],
              ),
              child: Stack(
                children: [
                  Align(
                      alignment: Alignment.topCenter,
                      child: FractionallySizedBox(
                        heightFactor: 0.60,
                        widthFactor: 1,
                        child: GestureDetector(
                            onTap: () {
                              setState(() {
                                //cameraBottomSheet(context);
                                cameraOrGalleryBottomSheet();
                              });
                            },
                            child: Container(
                                decoration: TripImages.thePath == null
                                    ? BoxDecoration(
                                        color: Colors.grey[200],
                                        borderRadius: BorderRadius.only(
                                            topLeft: Radius.circular(20), topRight: Radius.circular(20)),
                                      )
                                    : BoxDecoration(
                                        color: Colors.grey[200],
                                        borderRadius: BorderRadius.only(
                                            topLeft: Radius.circular(20), topRight: Radius.circular(20)),
                                        image: DecorationImage(
                                            image: FileImage(File(TripImages.thePath)), fit: BoxFit.cover)))),
                      )),
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: FractionallySizedBox(
                      heightFactor: 0.48,
                      widthFactor: 1,
                      child: Container(
                          decoration: BoxDecoration(
                            color: Colors.grey[50],
                            borderRadius: BorderRadius.only(
                                bottomLeft: Radius.circular(20),
                                bottomRight: Radius.circular(20),
                                topLeft: Radius.circular(22),
                                topRight: Radius.circular(22)),
                          ),
                          child: Column(children: [
                            Container(
                                margin: EdgeInsets.all(12),
                                child: myMarker.isEmpty
                                    ? Text('Place Name',
                                        style: TextStyle(
                                            color: Colors.grey[800], fontSize: 16, fontWeight: FontWeight.w700))
                                    : locationName == null
                                        ? Container()
                                        : Text('$adminArea',
                                            style: TextStyle(
                                                color: Colors.grey[800], fontSize: 16, fontWeight: FontWeight.w700))),
                            Container(
                                child: Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
                              GestureDetector(
                                onTap: () {
                                  _showDialog(context);
                                },
                                child: Container(
                                    height: 180,
                                    width: 120,
                                    decoration: BoxDecoration(
                                      color: Colors.grey[200],
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                                    child: Form(
                                        key: _formKey,
                                        child: Column(
                                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                          children: [
                                            FractionallySizedBox(
                                                widthFactor: 1,
                                                child: Container(
                                                  child: FractionallySizedBox(
                                                      widthFactor: 1,
                                                      child: Container(
                                                          child: _daysController == null
                                                              ? Text('days: ',
                                                                  textAlign: TextAlign.left,
                                                                  style: TextStyle(
                                                                      color: Colors.grey[700],
                                                                      fontSize: 16,
                                                                      fontWeight: FontWeight.w600))
                                                              : Text('days: ${_daysController.text}',
                                                                  textAlign: TextAlign.left,
                                                                  style: TextStyle(
                                                                      color: Colors.grey[700],
                                                                      fontSize: 16,
                                                                      fontWeight: FontWeight.w600)))),
                                                )),
                                            FractionallySizedBox(
                                              widthFactor: 1,
                                              child: Container(
                                                child: _nightsController == null
                                                    ? Text('nights: ',
                                                        style: TextStyle(
                                                            color: Colors.grey[700],
                                                            fontSize: 16,
                                                            fontWeight: FontWeight.w600))
                                                    : Text('nights: ${_nightsController.text}',
                                                        style: TextStyle(
                                                            color: Colors.grey[700],
                                                            fontSize: 16,
                                                            fontWeight: FontWeight.w600)),
                                              ),
                                            ),
                                            FractionallySizedBox(
                                                widthFactor: 1,
                                                child: Container(
                                                    child: _priceController == null
                                                        ? Text('\$-',
                                                            style: TextStyle(
                                                                color: Colors.grey[700],
                                                                fontSize: 16,
                                                                fontWeight: FontWeight.w600))
                                                        : Text('\$${_priceController.text}',
                                                            style: TextStyle(
                                                                color: Colors.grey[700],
                                                                fontSize: 16,
                                                                fontWeight: FontWeight.w600))))
                                          ],
                                        ))),
                              ),
                              InkWell(
                                onTap: () {
                                  print('hey there');
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => MapState(
                                                statusBar: widget.statusBar,
                                              )));
                                },
                                child: Container(
                                    height: 180,
                                    width: 120,
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
                                                        target: myMarker.isEmpty
                                                            ? LatLng(currentLat, currentLon)
                                                            : LatLng(myMarker[0].position.latitude,
                                                                myMarker[0].position.longitude),
                                                        zoom: 12),
                                                    myLocationEnabled:
                                                        true, // Add little blue dot for device location, requires permission from user
                                                    mapType: MapType.normal,
                                                    myLocationButtonEnabled: false,
                                                    markers: Set.from(myMarker),
                                                    onCameraMove: _updateCameraPosition,
                                                    mapToolbarEnabled: false,
                                                    zoomControlsEnabled: false,
                                                  ),
                                            InkWell(
                                                onTap: () {
                                                  Navigator.pushReplacement(
                                                      context,
                                                      PageRouteBuilder(
                                                          transitionDuration: Duration(milliseconds: 400),
                                                          transitionsBuilder: (BuildContext context,
                                                              Animation<double> animation,
                                                              Animation<double> secondaryAnimation,
                                                              Widget child) {
                                                            animation = CurvedAnimation(
                                                                parent: animation, curve: Curves.easeInOut);
                                                            return SlideTransition(
                                                              position: Tween<Offset>(
                                                                begin: const Offset(1.0, 0.0),
                                                                end: const Offset(0.0, 0.0),
                                                              ).animate(animation),
                                                              child: child,
                                                            );
                                                          },
                                                          pageBuilder: (context, Animation<double> animation,
                                                                  Animation<double> secondaryAnimation) =>
                                                              MapState(
                                                                  statusBar: widget.statusBar,
                                                                  controller: _geoController,
                                                                  myMarker: myMarker,
                                                                  refresh: refresh,
                                                                  price: _priceController,
                                                                  days: _daysController,
                                                                  nights: _nightsController,
                                                                  imgPath: thePath)));
                                                },
                                                child: Container(
                                                  height: 180,
                                                  width: 120,
                                                ))
                                          ],
                                        ))),
                              )
                            ]))
                          ])),
                    ),
                  )
                ],
              )),
        )))));
  }
}

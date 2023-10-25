import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:workingOnUI/models/user.dart';
import 'package:workingOnUI/screens/home/mainPage/mainDetails.dart';
import 'package:workingOnUI/services/database.dart';

class MainPageScreen extends StatefulWidget {
  final List<Map<String, dynamic>> tripsList;
  final double statusBar;
  /*final dynamic image;
  final String uid;
  final String id;
  final int days;
  final int nights;
  final String placeName;
  final String areaName;
  final int price;
  final dynamic marker;*/
  MainPageScreen(
      {
      /*this.areaName,
    this.days,
    this.nights,
    this.id,
    this.image,
    this.placeName,
    this.price,*/
      this.tripsList,
      this.statusBar
      /*this.uid,
    this.marker,*/
      });
  @override
  _MainPageScreenState createState() => _MainPageScreenState();
}

class _MainPageScreenState extends State<MainPageScreen> {
  final ScrollController _scrollController = ScrollController();
  String _prevLastDocument;
  DocumentSnapshot _lastDocument;
  bool _gettingMoreTrips = false;
  bool _moreTripsAvailable = true;
  List<DocumentSnapshot> trips = [];

  _getTrips() async {
    Query q = FirebaseFirestore.instance.collection('trips').orderBy("price").startAt([_prevLastDocument]).limit(12);
    setState(() {});
    QuerySnapshot querySnapshot = await q.get();
    trips = querySnapshot.docs;
    _lastDocument = querySnapshot.docs[querySnapshot.docs.length - 1];
    setState(() {});
  }

  _getMoreTrips() async {
    //getmoreTrips(_lastDoc) async {
    if (_moreTripsAvailable == false) {
      return;
    }
    if (_gettingMoreTrips == true) {
      return;
    }
    _gettingMoreTrips = true;
    Query q = FirebaseFirestore.instance
        .collection('trips')
        .orderBy("price")
        .startAfter([_lastDocument.data()['price']]).limit(12);

    QuerySnapshot querySnapshot = await q.get();
    if (querySnapshot.docs.length < 12 || querySnapshot.docs.length == 0) {
      _moreTripsAvailable = false;
    }
    _lastDocument = querySnapshot.docs[querySnapshot.docs.length - 1];
    //List<Map<String, dynamic>> tripsList = [];
    /*for (int i = 0; i < querySnapshot.docs.length; i++) {
      Map<String, dynamic> tripsMap = {
        'image': querySnapshot.docs[i].data()['image'],
        'uid': querySnapshot.docs[i].data()['uid'],
        'id': querySnapshot.docs[i].data()['id'],
        'days': querySnapshot.docs[i].data()['days'],
        'nights': querySnapshot.docs[i].data()['nights'],
        'placeName': querySnapshot.docs[i].data()['placeName'],
        'areaName': querySnapshot.docs[i].data()['areaName'],
        'price': querySnapshot.docs[i].data()['price'],
        'marker': querySnapshot.docs[i].data()['marker'],
      };
      widget.tripsList.add(tripsMap);
    }*/
    trips.addAll(querySnapshot.docs);
    setState(() {});
    _gettingMoreTrips = false;
    //widget.tripsList.addAll(tripsList);
  }

  @override
  void initState() {
    _prevLastDocument = widget.tripsList[0]['price'];
    _getTrips();
    super.initState();
    _scrollController.addListener(() {
      double maxScroll = _scrollController.position.maxScrollExtent;
      double currentScroll = _scrollController.position.pixels;
      double delta = MediaQuery.of(context).size.height * 0.25;
      if (maxScroll - currentScroll < delta) {
        _getMoreTrips();
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<CustomUser>(context);
    return Scaffold(
        appBar: AppBar(
          elevation: 0.0,
          leading: IconButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              icon: Icon(Icons.keyboard_arrow_left_rounded, color: Colors.tealAccent[400], size: 34)),
          backgroundColor: Colors.transparent,
        ),
        backgroundColor: Colors.grey[50],
        body: Container(
            margin: EdgeInsets.all(12),
            child: ListView.builder(
                controller: _scrollController,
                itemCount: trips.length,
                shrinkWrap: true,
                itemBuilder: (context, index) {
                  return InkWell(
                    onTap: () {
                      print('tapped index is $index');
                      Navigator.push(
                          context,
                          PageRouteBuilder(
                              transitionDuration: Duration(milliseconds: 400),
                              transitionsBuilder: (BuildContext context, Animation<double> animation,
                                  Animation<double> secondaryAnimation, Widget child) {
                                animation = CurvedAnimation(parent: animation, curve: Curves.easeInOut);
                                return SlideTransition(
                                  position: Tween<Offset>(
                                    begin: const Offset(1.0, 0.0),
                                    end: const Offset(0.0, 0.0),
                                  ).animate(animation),
                                  child: child,
                                );
                              },
                              pageBuilder:
                                  (context, Animation<double> animation, Animation<double> secondaryAnimation) =>
                                      MainDetails(
                                        image: trips[index].data()['image'],
                                        uid: trips[index].data()['uid'],
                                        id: trips[index].data()['id'],
                                        days: trips[index].data()['days'],
                                        nights: trips[index].data()['nights'],
                                        placeName: trips[index].data()['placeName'],
                                        areaName: trips[index].data()['areaName'],
                                        price: trips[index].data()['price'],
                                        marker: trips[index].data()['marker'],
                                        statusBar: widget.statusBar,
                                        index: index,
                                        tripsList: trips,
                                        accesedFromProf: false,
                                      )));
                    },
                    child: Container(
                        //color: Colors.red,
                        padding: EdgeInsets.symmetric(vertical: 8, horizontal: 10),
                        child: Row(
                          children: [
                            Expanded(
                              flex: 4,
                              child: Container(
                                  child: Row(
                                children: [
                                  Align(
                                    child: Container(
                                        constraints: BoxConstraints.expand(
                                          width: MediaQuery.of(context).size.width * 0.145,
                                          height: MediaQuery.of(context).size.width * 0.145,
                                        ),
                                        decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(15),
                                            image: DecorationImage(
                                              image: NetworkImage(
                                                trips[index].data()['image'],
                                              ),
                                              fit: BoxFit.cover,
                                            ))),
                                  ),
                                  Container(
                                      margin: EdgeInsets.only(left: 10),
                                      child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                                          children: [
                                            AnimatedDefaultTextStyle(
                                                style: TextStyle(
                                                    color: Colors.grey[800], fontSize: 17, fontWeight: FontWeight.w600),
                                                duration: Duration(milliseconds: 200),
                                                curve: Curves.easeInOut,
                                                child: Text(
                                                  trips[index].data()['areaName'],
                                                  textAlign: TextAlign.left,
                                                )),
                                            AnimatedDefaultTextStyle(
                                                style: TextStyle(
                                                  color: Colors.grey[600],
                                                  fontSize: 13,
                                                  //fontWeight: FontWeight.w600
                                                ),
                                                duration: Duration(milliseconds: 200),
                                                curve: Curves.easeInOut,
                                                child: Text(
                                                  'days: ${trips[index].data()['days']}, nights: ${trips[index].data()['nights']}',
                                                  textAlign: TextAlign.left,
                                                )),
                                          ]))
                                ],
                              )),
                            ),
                            Expanded(
                                flex: 1,
                                child: AnimatedDefaultTextStyle(
                                    style:
                                        TextStyle(color: Colors.grey[700], fontSize: 16, fontWeight: FontWeight.w600),
                                    duration: Duration(milliseconds: 200),
                                    curve: Curves.easeInOut,
                                    child: Text(
                                      '\$${trips[index].data()['price']}',
                                      textAlign: TextAlign.right,
                                    ))),
                          ],
                        )),
                  );
                })));
  }
}

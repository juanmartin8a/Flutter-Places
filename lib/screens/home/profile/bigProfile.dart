import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:workingOnUI/models/uploadTrip.dart';
import 'package:workingOnUI/models/user.dart';
import 'package:workingOnUI/screens/home/mainPage/mainDetails.dart';
import 'package:workingOnUI/screens/home/new/cameraOrGallery.dart';
import 'package:workingOnUI/screens/home/profile/changeName.dart';
import 'package:workingOnUI/screens/home/profile/gridView.dart';
import 'package:workingOnUI/screens/home/profile/profileDetails.dart';
import 'package:workingOnUI/services/auth.dart';
import 'package:workingOnUI/services/database.dart';

class TheBiggerProfile extends StatefulWidget {
  final Map<String, dynamic> userDocs;
  final double statusBar;
  final int index;
  final dynamic refresh;
  TheBiggerProfile({this.userDocs, this.statusBar, this.index, this.refresh});
  @override
  _TheBiggerProfileState createState() => _TheBiggerProfileState();
}

class _TheBiggerProfileState extends State<TheBiggerProfile> with TickerProviderStateMixin {
  TabController _theTabController;

  refresh() {
    setState(() {});
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
              child: ChangeName(
                statusBar: widget.statusBar,
                refresh: refresh,
                name: widget.userDocs['name'],
                username: widget.userDocs['username'],
              ));
        });
  }

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
            children: [CameraOrGallery(statusBar: widget.statusBar, refresh: refresh, accesedFrom: 'profile')],
          );
        });
  }

  @override
  void initState() {
    if (mounted) {
      _theTabController = TabController(vsync: this, length: 2, initialIndex: widget.index);
    }
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    _theTabController.dispose();
    TripImages.thePath = '';
    //TripImages.theFile = '';
  }

  @override
  void deactivate() {
    super.deactivate();
    _theTabController.dispose();
    TripImages.thePath = '';
    //TripImages.theFile = '';
  }

  Widget build(BuildContext context) {
    final AuthService _auth = AuthService();
    final user = Provider.of<CustomUser>(this.context);
    AppBar appBar = AppBar(
      elevation: 0.0,
      automaticallyImplyLeading: false,
      backgroundColor: Colors.transparent,
    );
    return StreamBuilder<DocumentSnapshot>(
        stream: DatabaseService(uid: user.uid).getUserByUid(),
        builder: (context, AsyncSnapshot<DocumentSnapshot> snapshot) {
          if (snapshot.hasData) {
            Map<String, dynamic> userDocs = snapshot.data.data();
            return Scaffold(
                resizeToAvoidBottomPadding: false,
                backgroundColor: Colors.grey[150],
                appBar: PreferredSize(
                    preferredSize: Size.fromHeight(appBar.preferredSize.height),
                    child: appBar = AppBar(
                      elevation: 0.0,
                      automaticallyImplyLeading: false,
                      backgroundColor: Colors.transparent,
                      actions: [
                        MaterialButton(
                            onPressed: () async {
                              Navigator.of(context).pop();
                              await _auth.signOut();
                            },
                            child: Text('Logout',
                                style: TextStyle(color: Colors.red, fontSize: 16, fontWeight: FontWeight.w500)))
                      ],
                      leading: IconButton(
                          onPressed: () => Navigator.of(context).pop(),
                          icon: Icon(Icons.keyboard_arrow_left, color: Colors.blueAccent[400], size: 36)),
                      title: Container(
                          child: Text('${userDocs['username']}',
                              style:
                                  TextStyle(color: Colors.blueAccent[400], fontSize: 22, fontWeight: FontWeight.w800))),
                      //centerTitle: true,
                    )),
                body: Container(
                    child: Center(
                        child: FractionallySizedBox(
                            widthFactor: 0.8,
                            child: Container(
                                margin: EdgeInsets.symmetric(vertical: 60, horizontal: 15),
                                decoration: BoxDecoration(
                                  color: Colors.grey[50],
                                  borderRadius: BorderRadius.circular(20),
                                  boxShadow: [
                                    BoxShadow(
                                      blurRadius: 12,
                                      color: Colors.blueAccent[400],
                                      spreadRadius: 0.2,
                                      offset: Offset(5, 4),
                                    )
                                  ],
                                ),
                                child: Container(
                                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                                    child: Column(
                                      children: [
                                        Container(
                                            child: Row(
                                          children: [
                                            GestureDetector(
                                              onLongPress: () {
                                                cameraOrGalleryBottomSheet();
                                              },
                                              child: Container(
                                                  height: MediaQuery.of(context).size.height * 0.09,
                                                  width: MediaQuery.of(context).size.height * 0.09,
                                                  decoration: BoxDecoration(
                                                      color: Colors.grey[200],
                                                      borderRadius: BorderRadius.circular(100 / 2),
                                                      image: DecorationImage(
                                                        image: NetworkImage(userDocs['profileImg']),
                                                        fit: BoxFit.cover,
                                                      ))),
                                            ),
                                            GestureDetector(
                                              onLongPress: () {
                                                _showDialog(context);
                                              },
                                              child: Container(
                                                  margin: EdgeInsets.only(left: 16),
                                                  child: Column(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                                    children: [
                                                      Container(
                                                          child: Text('${userDocs['name']}',
                                                              textAlign: TextAlign.left,
                                                              style: TextStyle(
                                                                  color: Colors.grey[800],
                                                                  fontSize: 18,
                                                                  fontWeight: FontWeight.w700))),
                                                      Container(
                                                          child: Text('${userDocs['username']}',
                                                              textAlign: TextAlign.left,
                                                              style: TextStyle(
                                                                  color: Colors.grey[600],
                                                                  fontSize: 15,
                                                                  fontWeight: FontWeight.w500)))
                                                    ],
                                                  )),
                                            ),
                                          ],
                                        )),
                                        Wrap(children: [
                                          Container(
                                              margin: EdgeInsets.only(top: 16),
                                              //padding: EdgeInsets.symmetric(horizontal: 10),
                                              //color: Colors.red,
                                              child: TabBar(
                                                controller: _theTabController,
                                                tabs: [
                                                  Container(
                                                      padding: EdgeInsets.symmetric(vertical: 4),
                                                      child: Text('Trips',
                                                          style: TextStyle(
                                                            fontSize: 16,
                                                            color: Colors.grey[800],
                                                          ))),
                                                  Container(
                                                      child: Text('My Trips',
                                                          style: TextStyle(
                                                            fontSize: 16,
                                                            color: Colors.grey[800],
                                                          )))
                                                ],
                                              )),
                                        ]),
                                        Expanded(
                                            //color: Colors.red,
                                            child: Container(
                                          margin: EdgeInsets.only(top: 10),
                                          child: TabBarView(
                                            controller: _theTabController,
                                            children: [
                                              Container(
                                                  child: FutureBuilder(
                                                      future: DatabaseService(uid: user.uid).getTripsForUser(),
                                                      builder: (context, snap) {
                                                        if (snap.hasData) {
                                                          List<Map<String, dynamic>> userTripsList = [];
                                                          for (int i = 0; i < snap.data.docs.length; i++) {
                                                            Map<String, dynamic> userTripsMap = {
                                                              'tripId': snap.data.docs[i].data()['tripId'],
                                                            };
                                                            userTripsList.add(userTripsMap);
                                                          }
                                                          return GridView.count(
                                                              crossAxisCount: 2,
                                                              childAspectRatio: 9 / 14,
                                                              children:
                                                                  List.generate(snap.data.docs.length, (int index) {
                                                                return Padding(
                                                                  padding:
                                                                      EdgeInsets.symmetric(horizontal: 3, vertical: 3),
                                                                  child: FutureBuilder(
                                                                      future: DatabaseService()
                                                                          .queryTrips(userTripsList[index]['tripId']),
                                                                      builder: (context, snaps) {
                                                                        if (snaps.hasData) {
                                                                          List<Map<String, dynamic>> theUserTripsList =
                                                                              [];
                                                                          for (int i = 0;
                                                                              i < snaps.data.docs.length;
                                                                              i++) {
                                                                            Map<String, dynamic> userTripsMap = {
                                                                              'image':
                                                                                  snaps.data.docs[i].data()['image'],
                                                                              'uid': snaps.data.docs[i].data()['uid'],
                                                                              'id': snaps.data.docs[i].data()['id'],
                                                                              'days': snaps.data.docs[i].data()['days'],
                                                                              'nights':
                                                                                  snaps.data.docs[i].data()['nights'],
                                                                              'placeName': snaps.data.docs[i]
                                                                                  .data()['placeName'],
                                                                              'areaName':
                                                                                  snaps.data.docs[i].data()['areaName'],
                                                                              'price':
                                                                                  snaps.data.docs[i].data()['price'],
                                                                              'marker':
                                                                                  snaps.data.docs[i].data()['marker'],
                                                                            };
                                                                            theUserTripsList.add(userTripsMap);
                                                                          }
                                                                          return GestureDetector(
                                                                            onTap: () {
                                                                              Navigator.push(
                                                                                  context,
                                                                                  PageRouteBuilder(
                                                                                      transitionDuration:
                                                                                          Duration(milliseconds: 400),
                                                                                      pageBuilder: (context,
                                                                                              Animation<double>
                                                                                                  animation,
                                                                                              Animation<double>
                                                                                                  secondaryAnimation) =>
                                                                                          ProfileDetails(
                                                                                            image:
                                                                                                theUserTripsList[index]
                                                                                                    ['image'],
                                                                                            uid: theUserTripsList[index]
                                                                                                ['uid'],
                                                                                            id: theUserTripsList[index]
                                                                                                ['id'],
                                                                                            days:
                                                                                                theUserTripsList[index]
                                                                                                    ['days'],
                                                                                            nights:
                                                                                                theUserTripsList[index]
                                                                                                    ['nights'],
                                                                                            placeName:
                                                                                                theUserTripsList[index]
                                                                                                    ['placeName'],
                                                                                            areaName:
                                                                                                theUserTripsList[index]
                                                                                                    ['areaName'],
                                                                                            price:
                                                                                                theUserTripsList[index]
                                                                                                    ['price'],
                                                                                            marker:
                                                                                                theUserTripsList[index]
                                                                                                    ['marker'],
                                                                                            statusBar: widget.statusBar,
                                                                                            index: index,
                                                                                            tripsList: theUserTripsList,
                                                                                            accesedFromProf: true,
                                                                                          )));
                                                                            },
                                                                            child: Container(
                                                                                child: GrisViewChild(
                                                                                    statusBar: widget.statusBar,
                                                                                    tripsList: theUserTripsList,
                                                                                    index: index)),
                                                                          );
                                                                        } else {
                                                                          return Container();
                                                                        }
                                                                      }),
                                                                );
                                                              }));
                                                        } else {
                                                          return Container();
                                                        }
                                                      })),
                                              Container(
                                                  child: FutureBuilder(
                                                      future: DatabaseService().getUserTrips(user.uid),
                                                      builder: (context, snap) {
                                                        if (snap.hasData) {
                                                          List<Map<String, dynamic>> userTripsList = [];
                                                          for (int i = 0; i < snap.data.docs.length; i++) {
                                                            Map<String, dynamic> userTripsMap = {
                                                              'image': snap.data.docs[i].data()['image'],
                                                              'uid': snap.data.docs[i].data()['uid'],
                                                              'id': snap.data.docs[i].data()['id'],
                                                              'days': snap.data.docs[i].data()['days'],
                                                              'nights': snap.data.docs[i].data()['nights'],
                                                              'placeName': snap.data.docs[i].data()['placeName'],
                                                              'areaName': snap.data.docs[i].data()['areaName'],
                                                              'price': snap.data.docs[i].data()['price'],
                                                              'marker': snap.data.docs[i].data()['marker'],
                                                            };
                                                            userTripsList.add(userTripsMap);
                                                          }
                                                          return Container(
                                                              child: GridView.count(
                                                                  crossAxisCount: 2,
                                                                  childAspectRatio: 9 / 14,
                                                                  children:
                                                                      List.generate(userTripsList.length, (int index) {
                                                                    return Padding(
                                                                        padding: EdgeInsets.symmetric(
                                                                            horizontal: 3, vertical: 3),
                                                                        child: GestureDetector(
                                                                          onTap: () {
                                                                            Navigator.push(
                                                                                context,
                                                                                PageRouteBuilder(
                                                                                    transitionDuration:
                                                                                        Duration(milliseconds: 400),
                                                                                    pageBuilder: (context,
                                                                                            Animation<double> animation,
                                                                                            Animation<double>
                                                                                                secondaryAnimation) =>
                                                                                        ProfileDetails(
                                                                                          image: userTripsList[index]
                                                                                              ['image'],
                                                                                          uid: userTripsList[index]
                                                                                              ['uid'],
                                                                                          id: userTripsList[index]
                                                                                              ['id'],
                                                                                          days: userTripsList[index]
                                                                                              ['days'],
                                                                                          nights: userTripsList[index]
                                                                                              ['nights'],
                                                                                          placeName:
                                                                                              userTripsList[index]
                                                                                                  ['placeName'],
                                                                                          areaName: userTripsList[index]
                                                                                              ['areaName'],
                                                                                          price: userTripsList[index]
                                                                                              ['price'],
                                                                                          marker: userTripsList[index]
                                                                                              ['marker'],
                                                                                          statusBar: widget.statusBar,
                                                                                          index: index,
                                                                                          tripsList: userTripsList,
                                                                                          accesedFromProf: true,
                                                                                        )));
                                                                          },
                                                                          child: GrisViewChild(
                                                                              statusBar: widget.statusBar,
                                                                              tripsList: userTripsList,
                                                                              index: index),
                                                                        ));
                                                                  })));
                                                        } else {
                                                          return Container();
                                                        }
                                                      }))
                                            ],
                                          ),
                                        )),
                                      ],
                                    )))))));
          } else {
            return Container();
          }
        });
  }
}

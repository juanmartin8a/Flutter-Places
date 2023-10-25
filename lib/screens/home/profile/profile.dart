import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:workingOnUI/models/user.dart';
import 'package:workingOnUI/screens/home/profile/bigProfile.dart';
import 'package:workingOnUI/screens/home/profile/gridView.dart';
import 'package:workingOnUI/services/database.dart';

class Profile extends StatefulWidget {
  final double statusBar;
  final double width;
  final int currentPage;
  Profile({this.statusBar, this.width, this.currentPage});
  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> with TickerProviderStateMixin {
  bool active = false;
  double blur;
  Color opacity;
  double horizontalWidth;
  double borRadius;
  Offset animatedOffset;
  Color offsetColor;
  TabController _tabController;
  int initTapPos = 0;

  refresh() {
    setState(() {});
  }

  @override
  void initState() {
    _tabController = TabController(vsync: this, length: 2);
    super.initState();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  void deactivate() {
    _tabController.dispose();
    super.deactivate();
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<CustomUser>(this.context);
    horizontalWidth = widget.currentPage == 2 ? 10.0 : MediaQuery.of(context).size.width * 0.12;
    opacity = widget.currentPage == 2 ? Colors.grey[50] : Colors.grey[50].withOpacity(0.4);
    blur = widget.currentPage == 2 ? 8 : 0;
    borRadius = widget.currentPage == 2 ? 20 : 10;
    animatedOffset = widget.currentPage == 2 ? Offset(2.5, 2) : Offset(0.7, 0.2);
    offsetColor = widget.currentPage == 2 ? Colors.blueAccent[400] : Colors.blue[300];
    return AnimatedContainer(
        duration: Duration(milliseconds: 300),
        curve: Curves.easeIn,
        margin: EdgeInsets.symmetric(vertical: MediaQuery.of(context).size.height * 0.12, horizontal: horizontalWidth),
        //width: 50,
        //height: height,
        decoration: BoxDecoration(
            color: opacity,
            boxShadow: [
              BoxShadow(
                blurRadius: blur,
                color: offsetColor,
                spreadRadius: 0.2,
                offset: animatedOffset,
              )
            ],
            borderRadius: BorderRadius.circular(borRadius)),
        child: Container(
            margin: EdgeInsets.all(12),
            child: StreamBuilder<DocumentSnapshot>(
                stream: DatabaseService(uid: user.uid).getUserByUid(),
                builder: (context, AsyncSnapshot<DocumentSnapshot> snapshot) {
                  if (snapshot.hasData) {
                    Map<String, dynamic> userDocs = snapshot.data.data();
                    return Container(
                        child: Column(children: [
                      GestureDetector(
                        onTap: () {
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
                                          TheBiggerProfile(
                                            statusBar: widget.statusBar,
                                            userDocs: userDocs,
                                            index: initTapPos,
                                          )));
                        },
                        child: Wrap(
                          children: [
                            Container(
                              child: Row(
                                //crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                      height: MediaQuery.of(context).size.height * 0.08,
                                      width: MediaQuery.of(context).size.height * 0.08,
                                      decoration: BoxDecoration(
                                          color: Colors.grey[200],
                                          borderRadius: BorderRadius.circular(100 / 2),
                                          image: DecorationImage(
                                            image: NetworkImage(userDocs['profileImg']),
                                            fit: BoxFit.cover,
                                          ))),
                                  Container(
                                      margin: EdgeInsets.only(left: 12),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                        children: [
                                          Container(
                                              child: Text('${userDocs['name']}',
                                                  textAlign: TextAlign.left,
                                                  style: TextStyle(
                                                      color: Colors.grey[800],
                                                      fontSize: 17,
                                                      fontWeight: FontWeight.w700))),
                                          Container(
                                              child: Text('${userDocs['username']}',
                                                  textAlign: TextAlign.left,
                                                  style: TextStyle(
                                                      color: Colors.grey[600],
                                                      fontSize: 14,
                                                      fontWeight: FontWeight.w500)))
                                        ],
                                      ))
                                ],
                              ),
                            )
                          ],
                        ),
                      ),
                      Wrap(children: [
                        Container(
                            margin: EdgeInsets.only(top: 16),
                            //padding: EdgeInsets.symmetric(horizontal: 10),
                            //color: Colors.red,
                            child: TabBar(
                              controller: _tabController,
                              onTap: (deatails) {
                                _tabController.addListener(() {
                                  initTapPos = _tabController.index;
                                  //print('my index is ' + initTapPos.toString());
                                });
                              },
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
                        child: GestureDetector(
                          onTap: () {
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
                                            TheBiggerProfile(
                                              statusBar: widget.statusBar,
                                              refresh: refresh,
                                              userDocs: userDocs,
                                              index: initTapPos,
                                            )));
                          },
                          child: TabBarView(
                            controller: _tabController,
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
                                              children: List.generate(snap.data.docs.length, (int index) {
                                                return Padding(
                                                  padding: EdgeInsets.symmetric(horizontal: 3, vertical: 3),
                                                  child: FutureBuilder(
                                                      future:
                                                          DatabaseService().queryTrips(userTripsList[index]['tripId']),
                                                      builder: (context, snaps) {
                                                        if (snaps.hasData) {
                                                          List<Map<String, dynamic>> theUserTripsList = [];
                                                          for (int i = 0; i < snaps.data.docs.length; i++) {
                                                            Map<String, dynamic> userTripsMap = {
                                                              'image': snaps.data.docs[i].data()['image'],
                                                              'uid': snaps.data.docs[i].data()['uid'],
                                                              'id': snaps.data.docs[i].data()['id'],
                                                              'days': snaps.data.docs[i].data()['days'],
                                                              'nights': snaps.data.docs[i].data()['nights'],
                                                              'placeName': snaps.data.docs[i].data()['placeName'],
                                                              'areaName': snaps.data.docs[i].data()['areaName'],
                                                              'price': snaps.data.docs[i].data()['price'],
                                                              'marker': snaps.data.docs[i].data()['marker'],
                                                            };
                                                            theUserTripsList.add(userTripsMap);
                                                          }
                                                          return Container(
                                                              child: GrisViewChild(
                                                                  statusBar: widget.statusBar,
                                                                  tripsList: theUserTripsList,
                                                                  index: index));
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
                                                  children: List.generate(userTripsList.length, (int index) {
                                                    return Padding(
                                                        padding: EdgeInsets.symmetric(horizontal: 3, vertical: 3),
                                                        child: GrisViewChild(
                                                            statusBar: widget.statusBar,
                                                            tripsList: userTripsList,
                                                            index: index));
                                                  })));
                                        } else {
                                          return Container();
                                        }
                                      }))
                            ],
                          ),
                        ),
                      )),
                    ]));
                  } else {
                    return Container();
                  }
                })));
  }
}

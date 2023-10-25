import 'package:flutter/material.dart';
import 'package:workingOnUI/screens/home/mainPage/mainPageScreen.dart';
import 'package:workingOnUI/services/database.dart';

class MainPageView extends StatefulWidget {
  final double statusBar;
  final double width;
  final int currentPage;
  MainPageView({this.statusBar, this.width, this.currentPage});
  @override
  _MainPageViewState createState() => _MainPageViewState();
}

class _MainPageViewState extends State<MainPageView> {
  bool active = false;
  double blur;
  Color opacity;
  double horizontalWidth;
  double borRadius;
  Offset animatedOffset;
  Color offsetColor;
  final scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    horizontalWidth = widget.currentPage == 0 ? 10.0 : MediaQuery.of(context).size.width * 0.12;
    double imgWidth = widget.currentPage == 0
        ? MediaQuery.of(context).size.width * 0.13
        : MediaQuery.of(context).size.width * (0.13 * 0.76);
    double sixTeenMargin = widget.currentPage == 0 ? 16 : 16 * 0.76;
    double fourTeenMargin = widget.currentPage == 0 ? 13 : 13 * 0.76;
    //double imgMargin = widget.currentPage == 0 ? 0 : 24;
    opacity = widget.currentPage == 0 ? Colors.grey[50] : Colors.grey[50].withOpacity(0.4);
    blur = widget.currentPage == 0 ? 8 : 0;
    borRadius = widget.currentPage == 0 ? 20 : 10;
    animatedOffset = widget.currentPage == 0 ? Offset(2.5, 2) : Offset(0.7, 0.2);
    offsetColor = widget.currentPage == 0 ? Colors.greenAccent[400] : Colors.greenAccent[100];
    return AnimatedContainer(
      duration: Duration(milliseconds: 200),
      curve: Curves.easeIn,
      margin: EdgeInsets.symmetric(vertical: MediaQuery.of(context).size.height * 0.12, horizontal: horizontalWidth),
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
          margin: EdgeInsets.all(6),
          decoration: BoxDecoration(color: Colors.grey[50], borderRadius: BorderRadius.circular(20)),
          child: FutureBuilder(
              future: DatabaseService().getTrips(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  List<Map<String, dynamic>> tripsList = [];
                  for (int i = 0; i < snapshot.data.docs.length; i++) {
                    Map<String, dynamic> tripsMap = {
                      'image': snapshot.data.docs[i].data()['image'],
                      'uid': snapshot.data.docs[i].data()['uid'],
                      'id': snapshot.data.docs[i].data()['id'],
                      'days': snapshot.data.docs[i].data()['days'],
                      'nights': snapshot.data.docs[i].data()['nights'],
                      'placeName': snapshot.data.docs[i].data()['placeName'],
                      'areaName': snapshot.data.docs[i].data()['areaName'],
                      'price': snapshot.data.docs[i].data()['price'],
                      'marker': snapshot.data.docs[i].data()['marker'],
                    };
                    tripsList.add(tripsMap);
                  }
                  return GestureDetector(
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
                                      MainPageScreen(tripsList: tripsList, statusBar: widget.statusBar)));
                    },
                    child: Container(
                        child: ListView.builder(
                            physics: NeverScrollableScrollPhysics(),
                            itemCount: tripsList.length,
                            shrinkWrap: true,
                            itemBuilder: (context, index) {
                              return Container(
                                  padding: EdgeInsets.symmetric(vertical: 8, horizontal: 10),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        flex: 4,
                                        child: Container(
                                            child: Row(
                                          children: [
                                            AnimatedContainer(
                                              duration: Duration(milliseconds: 300),
                                              curve: Curves.easeIn,
                                              constraints: BoxConstraints.expand(
                                                width: imgWidth,
                                                height: imgWidth,
                                              ),
                                              child: Container(
                                                  decoration: BoxDecoration(
                                                      borderRadius: BorderRadius.circular(12),
                                                      image: DecorationImage(
                                                        image: NetworkImage(
                                                          tripsList[index]['image'],
                                                        ),
                                                        fit: BoxFit.cover,
                                                      ))),
                                            ),
                                            Container(
                                                margin: EdgeInsets.only(left: 10),
                                                child: Column(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                                    children: [
                                                      AnimatedDefaultTextStyle(
                                                          style: TextStyle(
                                                              color: Colors.grey[800],
                                                              fontSize: sixTeenMargin,
                                                              fontWeight: FontWeight.w600),
                                                          duration: Duration(milliseconds: 200),
                                                          curve: Curves.easeInOut,
                                                          child: Text(
                                                            tripsList[index]['areaName'],
                                                            textAlign: TextAlign.left,
                                                          )),
                                                      AnimatedDefaultTextStyle(
                                                          style: TextStyle(
                                                            color: Colors.grey[600],
                                                            fontSize: fourTeenMargin,
                                                            //fontWeight: FontWeight.w600
                                                          ),
                                                          duration: Duration(milliseconds: 200),
                                                          curve: Curves.easeInOut,
                                                          child: Text(
                                                            'days: ${tripsList[index]['days']}, nights: ${tripsList[index]['nights']}',
                                                            textAlign: TextAlign.left,
                                                          )),
                                                    ]))
                                          ],
                                        )),
                                      ),
                                      Expanded(
                                          flex: 1,
                                          child: AnimatedDefaultTextStyle(
                                              style: TextStyle(
                                                  color: Colors.grey[700],
                                                  fontSize: sixTeenMargin,
                                                  fontWeight: FontWeight.w600),
                                              duration: Duration(milliseconds: 200),
                                              curve: Curves.easeInOut,
                                              child: Text(
                                                '\$${tripsList[index]['price']}',
                                              ))),
                                    ],
                                  ));
                            })),
                  );
                } else {
                  return Container();
                }
              })),
    );
  }
}

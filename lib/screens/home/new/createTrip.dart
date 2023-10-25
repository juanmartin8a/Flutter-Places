import 'package:flutter/material.dart';
import 'package:workingOnUI/screens/home/new/tripForm.dart';

class CreateTrip extends StatefulWidget {
  final double statusBar;
  final double width;
  final int currentPage;
  CreateTrip({this.statusBar, this.width, this.currentPage});
  @override
  _CreateTripState createState() => _CreateTripState();
}

class _CreateTripState extends State<CreateTrip> {
  bool active = false;
  double blur;
  Color opacity;
  double horizontalWidth;
  double borRadius;
  Offset animatedOffset;
  Color offsetColor;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    horizontalWidth = widget.currentPage == 1 ? 10.0 : MediaQuery.of(context).size.width * 0.12;
    opacity = widget.currentPage == 1 ? Colors.grey[50] : Colors.grey[50].withOpacity(0.4);
    blur = widget.currentPage == 1 ? 8 : 0;
    borRadius = widget.currentPage == 1 ? 20 : 10;
    animatedOffset = widget.currentPage == 1 ? Offset(2.5, 2) : Offset(0.7, 0.2);
    offsetColor = widget.currentPage == 1 ? Colors.redAccent[100] : Colors.red[200];
    return AnimatedContainer(
        duration: Duration(milliseconds: 300),
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
            child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
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
                          pageBuilder: (context, Animation<double> animation, Animation<double> secondaryAnimation) =>
                              TripForm(
                                statusBar: widget.statusBar,
                                comesFromMaps: false,
                              )));
                },
                child: Container(
                    decoration: BoxDecoration(
                      color: Colors.redAccent[400],
                      borderRadius: BorderRadius.circular(20),
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 40, vertical: 10),
                    child: Text('Create a Trip',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                        ))))
          ],
        )));
  }
}

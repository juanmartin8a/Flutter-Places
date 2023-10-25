import "package:flutter/material.dart";

class TheLoader extends StatefulWidget {
  @override
  _TheLoaderState createState() => _TheLoaderState();
}

class _TheLoaderState extends State<TheLoader> with SingleTickerProviderStateMixin {
  Animation<double> animBarOneHeight;
  Animation<double> animBarTwoHeight;
  Animation<double> animBarThreeHeight;
  AnimationController controller;

  double barOneHeight = 40;
  double barTwoHeight = 40;
  double barThreeHeight = 40;

  @override
  void initState() {
    super.initState();
    controller =
        AnimationController(lowerBound: 0.0, upperBound: 1.0, vsync: this, duration: Duration(milliseconds: 2200));
    //controller.forward();
    animBarOneHeight = TweenSequence(<TweenSequenceItem<double>>[
      TweenSequenceItem<double>(tween: Tween<double>(begin: 40, end: 160), weight: 45),
      TweenSequenceItem<double>(tween: Tween<double>(begin: 160, end: 40), weight: 45),
    ]).animate(
      CurvedAnimation(
        parent: controller,
        curve: Interval(
          0.0,
          0.33,
          curve: Curves.ease,
        ),
      ),
    );
    animBarTwoHeight = TweenSequence(<TweenSequenceItem<double>>[
      TweenSequenceItem<double>(tween: Tween<double>(begin: 40, end: 160), weight: 45),
      TweenSequenceItem<double>(tween: Tween<double>(begin: 160, end: 40), weight: 45),
    ]).animate(
      CurvedAnimation(
        parent: controller,
        curve: Interval(
          0.27,
          0.66,
          curve: Curves.ease,
        ),
      ),
    );
    animBarThreeHeight = TweenSequence(<TweenSequenceItem<double>>[
      TweenSequenceItem<double>(tween: Tween<double>(begin: 40, end: 160), weight: 45),
      TweenSequenceItem<double>(tween: Tween<double>(begin: 160, end: 40), weight: 45),
    ]).animate(
      CurvedAnimation(
        parent: controller,
        curve: Interval(
          0.60,
          1.0,
          curve: Curves.ease,
        ),
      ),
    );
    controller.addListener(() {
      setState(() {
        barOneHeight = animBarOneHeight.value;
        barTwoHeight = animBarTwoHeight.value;
        barThreeHeight = animBarThreeHeight.value;
        //if (controller.value >= 0.66) controller.repeat();
      });
    });
    //controller.forward();
    controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        //controller.repeat();
      }
    });
    controller.repeat();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.grey[100],
        body: Container(
            child: Center(
                child: Container(
                    //color: Colors.red,
                    margin: EdgeInsets.only(bottom: (MediaQuery.of(context).size.height * 0.32) / 2),
                    width: MediaQuery.of(context).size.width * 0.50,
                    height: MediaQuery.of(context).size.height * 0.32,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Align(
                          alignment: Alignment.bottomCenter,
                          child: Container(
                              width: 40,
                              height: barOneHeight,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(40),
                                color: Colors.grey[800],
                              )),
                        ),
                        Align(
                          alignment: Alignment.bottomCenter,
                          child: Container(
                              width: 40,
                              height: barTwoHeight,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(40),
                                color: Colors.grey[800],
                              )),
                        ),
                        Align(
                          alignment: Alignment.bottomCenter,
                          child: Container(
                              width: 40,
                              height: barThreeHeight,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(40),
                                color: Colors.grey[800],
                              )),
                        ),
                      ],
                    )))));
  }
}

import 'package:flutter/material.dart';
import 'package:workingOnUI/models/uploadTrip.dart';
import 'package:workingOnUI/screens/home/chat/chatRooms.dart';
import 'package:workingOnUI/screens/home/mainPage/mainPage.dart';
import 'package:workingOnUI/screens/home/new/createTrip.dart';
import 'package:workingOnUI/screens/home/profile/profile.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> with SingleTickerProviderStateMixin {
  PageController _pageController;
  TabController _tabController;
  int currentPage;
  int theIndex = 0;
  int tabIndex;
  bool active = false;
  bool isPageCanChange = true;
  double blur;
  Color opacity;
  double horizontalWidth;

  onPageChange(int index, {PageController p, TabController t}) async {
    if (p != null) {
      //determine which switch is
      isPageCanChange = false;
      await _pageController.animateToPage(index,
          duration: Duration(milliseconds: 500),
          curve: Curves.ease); //Wait for pageview to switch, then release pageivew listener
      isPageCanChange = true;
    } else {
      _tabController.animateTo(index); //Switch Tabbar
    }
  }

  @override
  void initState() {
    _tabController = TabController(length: 3, vsync: this, initialIndex: 0);
    //tabIndex = tabController.index;

    _tabController.addListener(() {
      if (_tabController.indexIsChanging) {
        onPageChange(_tabController.index, p: _pageController);
      }
    });
    _pageController = PageController(initialPage: 0, viewportFraction: 1);
    currentPage = theIndex;
    _pageController.addListener(() {
      int next = _pageController.page.round();

      if (currentPage != next) {
        setState(() {
          currentPage = next;
          tabIndex = next;
        });
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          elevation: 0.0,
          actions: [
            IconButton(
                onPressed: () {
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
                              ChatRooms(
                                statusBar: MediaQuery.of(context).padding.top,
                              )));
                },
                icon: Icon(Icons.messenger_outline_rounded, color: Colors.deepPurpleAccent, size: 30))
          ],
          leading: IconButton(onPressed: () {}, icon: Icon(Icons.location_on, color: Colors.tealAccent[400], size: 30)),
          backgroundColor: Colors.transparent,
        ),
        backgroundColor: Colors.grey[200],
        body: Container(
            child: Stack(children: [
          Align(
              alignment: Alignment.centerLeft,
              child: Container(
                  //color: Colors.red,
                  //height: MediaQuery.of(context).size.height * 0.68,
                  width: MediaQuery.of(context).size.width * 0.87,
                  child: Center(
                      child: Container(
                          margin: EdgeInsets.symmetric(horizontal: 25),
                          child: PageView(
                              controller: _pageController,
                              onPageChanged: (index) {
                                print('the current page index is $currentPage');
                                setState(() {
                                  theIndex = index;
                                  if (isPageCanChange) {
                                    // because the pageview switch will call back this method,
                                    //it will trigger the switch tabbar operation,
                                    //so define a flag, control pageview callback
                                    onPageChange(index);
                                  }
                                });
                              },
                              scrollDirection: Axis.vertical,
                              children: [
                                MainPageView(
                                  statusBar: MediaQuery.of(context).padding.top,
                                  currentPage: currentPage,
                                ),
                                CreateTrip(
                                  statusBar: MediaQuery.of(context).padding.top,
                                  currentPage: currentPage,
                                ),
                                Profile(
                                  statusBar: MediaQuery.of(context).padding.top,
                                  currentPage: currentPage,
                                ),
                              ]))))),
          Align(
              alignment: Alignment.centerRight,
              child: Container(
                  height: MediaQuery.of(context).size.height * 0.35,
                  width: MediaQuery.of(context).size.width * 0.13,
                  //color: Colors.red,
                  child: Center(
                    child: RotatedBox(
                        quarterTurns: 1,
                        child: TabBar(
                          indicatorColor: Colors.transparent,
                          controller: _tabController,
                          tabs: [
                            RotatedBox(
                                quarterTurns: 3,
                                child: AnimatedContainer(
                                    duration: Duration(milliseconds: 200),
                                    curve: Curves.elasticInOut,
                                    width: currentPage == 0 ? 36 : 32,
                                    //color: Colors.blue,
                                    child: Icon(
                                      Icons.home_outlined,
                                      color: currentPage == 0 ? Colors.greenAccent[400] : Colors.grey[500],
                                      size: currentPage == 0 ? 36 : 32,
                                    ))),
                            RotatedBox(
                                quarterTurns: 3,
                                child: AnimatedContainer(
                                    duration: Duration(milliseconds: 200),
                                    curve: Curves.elasticInOut,
                                    width: currentPage == 1 ? 36 : 32,
                                    //color: Colors.blue,
                                    child: Icon(
                                      Icons.add_box_outlined,
                                      color: currentPage == 1 ? Colors.redAccent : Colors.grey[500],
                                      size: currentPage == 1 ? 36 : 32,
                                    ))),
                            RotatedBox(
                                quarterTurns: 3,
                                child: AnimatedContainer(
                                    duration: Duration(milliseconds: 200),
                                    curve: Curves.elasticInOut,
                                    width: currentPage == 2 ? 36 : 32,
                                    //color: Colors.blue,
                                    child: Icon(
                                      Icons.person_outline_rounded,
                                      color: currentPage == 2 ? Colors.indigoAccent[400] : Colors.grey[500],
                                      size: currentPage == 2 ? 36 : 32,
                                    ))),
                          ],
                        )),
                  )))
        ])));
  }
}

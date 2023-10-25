import 'package:flutter/material.dart';

class GrisViewChild extends StatefulWidget {
  final List<Map<String, dynamic>> tripsList;
  final double statusBar;
  final int index;
  GrisViewChild({this.statusBar, this.tripsList, this.index});
  @override
  _GrisViewChildState createState() => _GrisViewChildState();
}

class _GrisViewChildState extends State<GrisViewChild> {
  @override
  Widget build(BuildContext context) {
    return Container(
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(14),
        ),
        child: Stack(children: [
          Hero(
            tag: 'gridYeah',
            child: Align(
                alignment: Alignment.topCenter,
                child: FractionallySizedBox(
                  heightFactor: 0.6,
                  widthFactor: 1,
                  child: Container(
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(14),
                        image: DecorationImage(
                          image: NetworkImage(
                            widget.tripsList[widget.index]['image'],
                          ),
                          fit: BoxFit.cover,
                        )),
                  ),
                )),
          ),
          Align(
              alignment: Alignment.bottomCenter,
              child: FractionallySizedBox(
                heightFactor: 0.48,
                widthFactor: 1,
                child: Container(
                    padding: EdgeInsets.all(3),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(14),
                          bottomRight: Radius.circular(14),
                          topLeft: Radius.circular(12),
                          topRight: Radius.circular(12)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Container(
                            child: Text(widget.tripsList[widget.index]['areaName'],
                                textAlign: TextAlign.center, style: TextStyle(color: Colors.grey[900], fontSize: 13))),
                        Container(
                            margin: EdgeInsets.only(top: 8, left: 3),
                            child: Text('days: ${widget.tripsList[widget.index]['days']}',
                                textAlign: TextAlign.left, style: TextStyle(color: Colors.grey[800], fontSize: 13))),
                        Container(
                            margin: EdgeInsets.only(top: 5, left: 3),
                            child: Text('nights: ${widget.tripsList[widget.index]['nights']}',
                                textAlign: TextAlign.left, style: TextStyle(color: Colors.grey[800], fontSize: 13))),
                        Container(
                            margin: EdgeInsets.only(top: 5, left: 3),
                            child: Text('\$${widget.tripsList[widget.index]['price']}',
                                textAlign: TextAlign.left, style: TextStyle(color: Colors.grey[800], fontSize: 13)))
                      ],
                    )),
              ))
        ]));
  }
}

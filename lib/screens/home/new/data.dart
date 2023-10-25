import 'package:flutter/material.dart';

class TripFormData extends StatefulWidget {
  final TextEditingController priceController;
  final TextEditingController daysController;
  final TextEditingController nightsController;
  final double statusBar;
  final dynamic refresh;
  TripFormData({this.priceController, this.daysController, this.statusBar, this.nightsController, this.refresh});
  @override
  _TripFormDataState createState() => _TripFormDataState();
}

class _TripFormDataState extends State<TripFormData> {
  @override
  Widget build(BuildContext context) {
    return Wrap(
      children: [
        Container(
            //height: MediaQuery.of(context).size.height * 0.30,
            //width: MediaQuery.of(context).size.height * 0.60,
            padding: EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: Colors.grey[50],
            ),
            child: Column(
              children: [
                Container(
                    padding: EdgeInsets.symmetric(vertical: 8, horizontal: 18),
                    child: Row(children: [
                      Expanded(
                        flex: 2,
                        child: Container(
                            child: Text('days: ',
                                style: TextStyle(color: Colors.grey[800], fontSize: 16, fontWeight: FontWeight.w600))),
                      ),
                      Expanded(
                        flex: 6,
                        child: Container(
                            child: TextField(
                                controller: widget.daysController,
                                maxLines: null,
                                cursorColor: Colors.blue,
                                maxLength: 2,
                                textAlignVertical: TextAlignVertical.center,
                                keyboardType: TextInputType.number,
                                style: TextStyle(fontSize: 16.5, color: Colors.grey[800], fontWeight: FontWeight.w600),
                                decoration: InputDecoration(
                                  isDense: true,
                                  counterText: '',
                                  contentPadding: EdgeInsets.symmetric(vertical: 4),
                                  focusedBorder: InputBorder.none,
                                  enabledBorder: InputBorder.none,
                                  //hintText: 'Chat',
                                ))),
                      )
                    ])),
                Container(
                    padding: EdgeInsets.symmetric(vertical: 8, horizontal: 18),
                    child: Row(children: [
                      Expanded(
                        flex: 2,
                        child: Container(
                            child: Text('nights: ',
                                style: TextStyle(color: Colors.grey[800], fontSize: 16, fontWeight: FontWeight.w600))),
                      ),
                      Expanded(
                        flex: 6,
                        child: Container(
                            child: TextField(
                                controller: widget.nightsController,
                                maxLines: null,
                                cursorColor: Colors.blue,
                                maxLength: 2,
                                textAlignVertical: TextAlignVertical.center,
                                keyboardType: TextInputType.number,
                                style: TextStyle(fontSize: 16.5, color: Colors.grey[800], fontWeight: FontWeight.w600),
                                decoration: InputDecoration(
                                  isDense: true,
                                  counterText: '',
                                  contentPadding: EdgeInsets.symmetric(vertical: 4),
                                  focusedBorder: InputBorder.none,
                                  enabledBorder: InputBorder.none,
                                  //hintText: 'Chat',
                                ))),
                      )
                    ])),
                Container(
                    padding: EdgeInsets.symmetric(vertical: 8, horizontal: 18),
                    child: Row(children: [
                      Expanded(
                        flex: 2,
                        child: Container(
                            child: Text('\$',
                                style: TextStyle(color: Colors.grey[800], fontSize: 16, fontWeight: FontWeight.w600))),
                      ),
                      Expanded(
                        flex: 6,
                        child: Container(
                            child: TextField(
                                controller: widget.priceController,
                                maxLines: null,
                                cursorColor: Colors.blue,
                                maxLength: 5,
                                textAlignVertical: TextAlignVertical.center,
                                keyboardType: TextInputType.number,
                                style: TextStyle(fontSize: 16.5, color: Colors.grey[800], fontWeight: FontWeight.w600),
                                decoration: InputDecoration(
                                  isDense: true,
                                  counterText: '',
                                  contentPadding: EdgeInsets.symmetric(vertical: 4),
                                  focusedBorder: InputBorder.none,
                                  enabledBorder: InputBorder.none,
                                  //hintText: 'Chat',
                                ))),
                      )
                    ])),
                GestureDetector(
                  onTap: () {
                    widget.refresh();
                    Navigator.of(context).pop();
                  },
                  child: FractionallySizedBox(
                    widthFactor: 0.8,
                    child: Container(
                        margin: EdgeInsets.symmetric(vertical: 8, horizontal: 18),
                        decoration:
                            BoxDecoration(borderRadius: BorderRadius.circular(30), color: Colors.lightBlueAccent[400]),
                        padding: EdgeInsets.symmetric(vertical: 10),
                        child: Center(
                            child: Text('Done',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 1.02,
                                )))),
                  ),
                )
              ],
            ))
      ],
    );
  }
}

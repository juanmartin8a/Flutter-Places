import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:workingOnUI/models/user.dart';
import 'package:workingOnUI/services/database.dart';

class ChangeName extends StatefulWidget {
  final double statusBar;
  final dynamic refresh;
  final String name;
  final String username;
  ChangeName({this.statusBar, this.refresh, this.name, this.username});
  @override
  _ChangeNameState createState() => _ChangeNameState();
}

class _ChangeNameState extends State<ChangeName> {
  TextEditingController name;
  TextEditingController username;

  updateNameAndUsername() {
    final user = Provider.of<CustomUser>(this.context, listen: false);
    DatabaseService(uid: user.uid).updateName(name.text);
    DatabaseService(uid: user.uid).updateUsername(username.text);
  }

  @override
  void initState() {
    name = TextEditingController(text: widget.name);
    username = TextEditingController(text: widget.username);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Wrap(
      children: [
        Container(
            //height: MediaQuery.of(context).size.height * 0.30,
            //width: MediaQuery.of(context).size.height * 0.60,
            //padding: EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: Colors.grey[50],
            ),
            child: Column(
              children: [
                Container(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    child: Text('Edit Profile',
                        style: TextStyle(color: Colors.grey[800], fontSize: 17, fontWeight: FontWeight.w700))),
                Container(
                    padding: EdgeInsets.symmetric(vertical: 8, horizontal: 6),
                    decoration: BoxDecoration(
                        border: Border(
                            bottom: BorderSide(width: 0.3, color: Colors.grey[700]),
                            top: BorderSide(width: 0.3, color: Colors.grey[700]))),
                    child: Row(children: [
                      Container(
                        //flex: 2,
                        child: Container(
                            child: Text('name: ',
                                style: TextStyle(color: Colors.grey[800], fontSize: 16, fontWeight: FontWeight.w600))),
                      ),
                      Expanded(
                        flex: 6,
                        child: Container(
                            margin: EdgeInsets.only(left: 6),
                            child: TextField(
                                controller: name,
                                maxLines: null,
                                cursorColor: Colors.blue,
                                maxLength: 15,
                                onChanged: (details) {
                                  setState(() {});
                                },
                                textAlignVertical: TextAlignVertical.center,
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
                    padding: EdgeInsets.symmetric(vertical: 8, horizontal: 6),
                    decoration: BoxDecoration(border: Border(bottom: BorderSide(width: 0.3, color: Colors.grey[700]))),
                    child: Row(children: [
                      Container(
                        //flex: 2,
                        child: Container(
                            child: Text('username: ',
                                style: TextStyle(color: Colors.grey[800], fontSize: 16, fontWeight: FontWeight.w600))),
                      ),
                      Expanded(
                        flex: 6,
                        child: Container(
                            margin: EdgeInsets.only(left: 6),
                            child: TextField(
                                controller: username,
                                maxLines: null,
                                cursorColor: Colors.blue,
                                maxLength: 15,
                                onChanged: (details) {
                                  setState(() {});
                                },
                                textAlignVertical: TextAlignVertical.center,
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
                    if (name.text != widget.name || username.text != widget.username) {
                      widget.refresh();
                      updateNameAndUsername();
                      Navigator.of(context).pop();
                    }
                  },
                  child: FractionallySizedBox(
                    widthFactor: 0.8,
                    child: Container(
                        margin: EdgeInsets.symmetric(vertical: 8, horizontal: 18),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(30),
                            color: name.text != widget.name || username.text != widget.username
                                ? Colors.lightBlueAccent[400]
                                : Colors.grey[800]),
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
                ),
                GestureDetector(
                  onTap: () {
                    widget.refresh();
                    Navigator.of(context).pop();
                  },
                  child: FractionallySizedBox(
                    widthFactor: 0.8,
                    child: Container(
                        margin: EdgeInsets.symmetric(vertical: 8, horizontal: 18),
                        //padding: EdgeInsets.symmetric(vertical: 10),
                        child: Center(
                            child: Text('Cancel',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 17,
                                  color: Colors.grey[800],
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

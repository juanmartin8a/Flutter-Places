import 'package:flutter/material.dart';

class ChatImage extends StatefulWidget {
  final double statusBar;
  final String imgNet;
  ChatImage({this.statusBar, this.imgNet});
  @override
  _ChatImageState createState() => _ChatImageState();
}

class _ChatImageState extends State<ChatImage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.black,
        body: Stack(children: [
          Positioned.fill(child: Container(child: Image.network(widget.imgNet))),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: AppBar(
              elevation: 0.0,
              leading: IconButton(
                  //padding: EdgeInsets.only(top: widget.statusBar),
                  icon: Icon(
                    Icons.clear_rounded,
                    color: Colors.white,
                    size: 34,
                  ),
                  onPressed: () => Navigator.of(context).pop()),
              backgroundColor: Colors.transparent,
            ),
          )
        ]));
  }
}

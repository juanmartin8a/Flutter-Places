import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:workingOnUI/models/user.dart';
import 'package:workingOnUI/services/database.dart';

class ChatImagePrev extends StatefulWidget {
  final dynamic imgPath;
  final String chatRoomId;
  ChatImagePrev({this.imgPath, this.chatRoomId});

  @override
  _ChatImagePrevState createState() => _ChatImagePrevState();
}

class _ChatImagePrevState extends State<ChatImagePrev> {
  final FirebaseStorage _storage = FirebaseStorage(storageBucket: 'gs://flutterplaces-4bc44.appspot.com');
  StorageUploadTask _uploadTask;
  StorageTaskSnapshot _taskSnapshot;

  sendMessage(BuildContext context) async {
    final user = Provider.of<CustomUser>(context, listen: false);
    String filePath = 'chat/${DateTime.now()}.png';
    _uploadTask = _storage.ref().child(filePath).putFile(File(widget.imgPath));
    _taskSnapshot = await _uploadTask.onComplete;
    final String downloadUrl = await _taskSnapshot.ref.getDownloadURL();
    DocumentReference docRef =
        FirebaseFirestore.instance.collection('chatRoom').doc(widget.chatRoomId).collection('chat').doc();
    Map<String, dynamic> messageMap = {
      'message': downloadUrl,
      'sendBy': user.uid,
      'time': DateTime.now().millisecondsSinceEpoch,
      'id': docRef.id,
      'seen': false,
      'chatRoomId': widget.chatRoomId,
      'type': 'file'
    };
    DatabaseService(uid: widget.chatRoomId).addConversationMessages(messageMap, docRef);
    setState(() {
      //messageController.text = '';
    });
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Stack(children: [
      Positioned.fill(child: Container(child: Image.file(File(widget.imgPath), fit: BoxFit.fill))),
      Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height * 0.15,
              color: Colors.transparent,
              child: Container(
                  child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  GestureDetector(
                      onTap: () {
                        sendMessage(context);
                      },
                      child: Container(
                        height: 55,
                        padding: EdgeInsets.symmetric(vertical: 8, horizontal: 6),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                              colors: [Colors.black38, Colors.transparent],
                              begin: const FractionalOffset(0.0, 1),
                              end: const FractionalOffset(0.0, 0.0),
                              stops: [0.0, 1.0],
                              tileMode: TileMode.clamp),
                        ),
                        child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                          Container(),
                          Container(
                              child: Container(
                                  margin: EdgeInsets.only(left: 12),
                                  child: Icon(Icons.send_rounded, color: Colors.white, size: 30)))
                        ]),
                      ))
                ],
              )))),
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

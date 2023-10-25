import 'package:flutter/material.dart';
import 'package:workingOnUI/screens/home/chat/chatImage.dart';
import 'package:workingOnUI/services/database.dart';

class InChatChild extends StatelessWidget {
  final String message;
  final bool isSendByMe;
  final String id;
  final String sendBy;
  final String chatRoomId;
  final String type;
  InChatChild({this.message, this.isSendByMe, this.id, this.sendBy, this.chatRoomId, this.type});

  @override
  Widget build(BuildContext context) {
    if (!isSendByMe) {
      DatabaseService(uid: chatRoomId, docId: id).updateChat(true);
    }
    return Container(
        padding: EdgeInsets.only(
            top: 4,
            bottom: 4,
            left: isSendByMe ? MediaQuery.of(context).size.width * 0.3 : 24,
            right: isSendByMe ? 24 : MediaQuery.of(context).size.width * 0.3),
        alignment: isSendByMe ? Alignment.centerRight : Alignment.centerLeft,
        margin: EdgeInsets.symmetric(vertical: 2),
        width: MediaQuery.of(context).size.width,
        child: Container(
            padding: EdgeInsets.symmetric(horizontal: type == 'string' ? 16 : 3, vertical: type == 'string' ? 12 : 3),
            decoration: BoxDecoration(
                color: isSendByMe ? Colors.indigoAccent[400] : Colors.deepPurpleAccent,
                borderRadius: isSendByMe
                    ? BorderRadius.only(
                        topLeft: Radius.circular(18),
                        topRight: Radius.circular(18),
                        bottomRight: Radius.circular(0),
                        bottomLeft: Radius.circular(16),
                      )
                    : BorderRadius.only(
                        topLeft: Radius.circular(18),
                        topRight: Radius.circular(18),
                        bottomRight: Radius.circular(18),
                        bottomLeft: Radius.circular(0),
                      )),
            child: type == 'string'
                ? Text(message,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                    ))
                : GestureDetector(
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => ChatImage(
                                    imgNet: message,
                                  )));
                    },
                    child: Container(
                      height: MediaQuery.of(context).size.height * 0.16,
                      width: MediaQuery.of(context).size.height * 0.16,
                      decoration: BoxDecoration(
                          borderRadius: isSendByMe
                              ? BorderRadius.only(
                                  topLeft: Radius.circular(18),
                                  topRight: Radius.circular(18),
                                  bottomRight: Radius.circular(0),
                                  bottomLeft: Radius.circular(16),
                                )
                              : BorderRadius.only(
                                  topLeft: Radius.circular(18),
                                  topRight: Radius.circular(18),
                                  bottomRight: Radius.circular(18),
                                  bottomLeft: Radius.circular(0),
                                ),
                          image: DecorationImage(image: NetworkImage(message), fit: BoxFit.cover)),
                    ),
                  )));
  }
}

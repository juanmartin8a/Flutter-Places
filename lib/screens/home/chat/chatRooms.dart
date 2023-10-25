import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:workingOnUI/models/user.dart';
import 'package:workingOnUI/screens/home/chat/in_chat.dart';
import 'package:workingOnUI/services/database.dart';

class ChatRooms extends StatefulWidget {
  final double statusBar;
  ChatRooms({this.statusBar});
  @override
  _ChatRoomsState createState() => _ChatRoomsState();
}

class _ChatRoomsState extends State<ChatRooms> {
  @override
  Widget build(BuildContext context) {
    final user = Provider.of<CustomUser>(this.context);
    AppBar appBar = AppBar(
      elevation: 0.0,
      automaticallyImplyLeading: false,
      backgroundColor: Colors.transparent,
      leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: Icon(Icons.keyboard_arrow_left, color: Colors.deepPurpleAccent, size: 36)),
      title: Container(
          child: Text('Chats',
              style: TextStyle(color: Colors.deepPurpleAccent, fontSize: 22, fontWeight: FontWeight.w800))),
    );
    return Scaffold(
        appBar: PreferredSize(preferredSize: Size.fromHeight(appBar.preferredSize.height), child: appBar),
        backgroundColor: Colors.grey[100],
        body: Container(
            margin: EdgeInsets.all(16),
            child: StreamBuilder(
                stream: DatabaseService().getChatRooms(user.uid),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    List<Map<String, dynamic>> chatRoomList = [];
                    for (int i = 0; i < snapshot.data.docs.length; i++) {
                      Map<String, dynamic> chatRoomMap = {
                        'chatRoomId': snapshot.data.docs[i].data()['chatroomId'],
                        'users': snapshot.data.docs[i].data()['users'],
                      };
                      chatRoomList.add(chatRoomMap);
                    }
                    print('the chat list length is ${chatRoomList[0]['chatRoomId']}');
                    return Container(
                        child: ListView.builder(
                            itemCount: chatRoomList.length,
                            itemBuilder: (context, index) {
                              return Container(
                                  child: StreamBuilder<DocumentSnapshot>(
                                      stream: DatabaseService(
                                              uid: chatRoomList[index]['users'][0] == user.uid
                                                  ? chatRoomList[index]['users'][1]
                                                  : chatRoomList[index]['users'][0])
                                          .getUserByUid(),
                                      builder: (context, AsyncSnapshot<DocumentSnapshot> snap) {
                                        if (snap.connectionState == ConnectionState.done || snap.hasData) {
                                          Map<String, dynamic> userDocs = snap.data.data();
                                          return InkWell(
                                            onTap: () {
                                              Navigator.push(
                                                  context,
                                                  PageRouteBuilder(
                                                      transitionDuration: Duration(milliseconds: 400),
                                                      transitionsBuilder: (BuildContext context,
                                                          Animation<double> animation,
                                                          Animation<double> secondaryAnimation,
                                                          Widget child) {
                                                        animation =
                                                            CurvedAnimation(parent: animation, curve: Curves.easeInOut);
                                                        return SlideTransition(
                                                          position: Tween<Offset>(
                                                            begin: const Offset(1.0, 0.0),
                                                            end: const Offset(0.0, 0.0),
                                                          ).animate(animation),
                                                          child: child,
                                                        );
                                                      },
                                                      pageBuilder: (context, Animation<double> animation,
                                                              Animation<double> secondaryAnimation) =>
                                                          InChat(
                                                            statusBar: widget.statusBar,
                                                            userDocs: userDocs,
                                                            chatRoomId: chatRoomList[index]['chatRoomId'],
                                                            index: index,
                                                          )));
                                            },
                                            child: Container(
                                                padding: EdgeInsets.symmetric(horizontal: 6, vertical: 8),
                                                child: Row(
                                                    mainAxisAlignment: MainAxisAlignment.start,
                                                    crossAxisAlignment: CrossAxisAlignment.center,
                                                    children: [
                                                      Container(
                                                          child: CircleAvatar(
                                                        radius: 26,
                                                        backgroundImage: NetworkImage(
                                                          userDocs['profileImg'],
                                                          //fit: BoxFit.cover,
                                                        ),
                                                        backgroundColor: Colors.grey[200],
                                                      )),
                                                      Container(
                                                          padding: EdgeInsets.only(left: 12),
                                                          child: Text('${userDocs['username']}',
                                                              textAlign: TextAlign.left,
                                                              style: TextStyle(
                                                                  color: Colors.grey[700],
                                                                  fontSize: 18,
                                                                  fontWeight: FontWeight.w700)))
                                                    ])),
                                          );
                                        } else {
                                          return Container();
                                        }
                                      }));
                            }));
                  } else {
                    return Container();
                  }
                })));
  }
}

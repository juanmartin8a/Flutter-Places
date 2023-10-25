import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:workingOnUI/models/uploadTrip.dart';
import 'package:workingOnUI/models/user.dart';
import 'package:workingOnUI/screens/home/chat/inChatChild.dart';
import 'package:workingOnUI/screens/home/new/cameraOrGallery.dart';
import 'package:workingOnUI/services/database.dart';

class InChat extends StatefulWidget {
  final Map<String, dynamic> userDocs;
  final double statusBar;
  final int index;
  final String chatRoomId;
  InChat({this.userDocs, this.statusBar, this.index, this.chatRoomId});
  @override
  _InChatState createState() => _InChatState();
}

class _InChatState extends State<InChat> {
  TextEditingController messageController = TextEditingController();
  GlobalKey _textfieldKey = GlobalKey();
  var _textSize;
  Offset cardPosition;
  final ValueNotifier<double> _rowHeight = ValueNotifier<double>(-1);

  refresh() {
    setState(() {});
  }

  chatMessagesList(BuildContext context) {
    final user = Provider.of<CustomUser>(this.context, listen: false);
    return StreamBuilder(
        stream: chatMessagesStream,
        builder: (context, snapshot) {
          return snapshot.hasData
              ? ListView.builder(
                  itemCount: snapshot.data.docs.length,
                  itemBuilder: (context, index) {
                    return InChatChild(
                        message: snapshot.data.docs[index].data()['message'],
                        isSendByMe: snapshot.data.docs[index].data()['sendBy'] == user.uid,
                        id: snapshot.data.docs[index].data()['id'],
                        chatRoomId: snapshot.data.docs[index].data()['chatRoomId'],
                        type: snapshot.data.docs[index].data()['type'],
                        sendBy: snapshot.data.docs[index].data()['sendBy']);
                  })
              : Container();
        });
  }

  cameraOrGalleryBottomSheet() {
    showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        barrierColor: Colors.black.withAlpha(30),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(10.0)),
        ),
        builder: (BuildContext context) {
          return Wrap(
            children: [
              CameraOrGallery(
                  statusBar: widget.statusBar, refresh: refresh, accesedFrom: 'chat', chatRoomId: widget.chatRoomId)
            ],
          );
        });
  }

  sendMessage() {
    final user = Provider.of<CustomUser>(this.context, listen: false);
    if (messageController.text.isNotEmpty) {
      print('the chat id is ${widget.chatRoomId}');
      DocumentReference docRef =
          FirebaseFirestore.instance.collection('chatRoom').doc(widget.chatRoomId).collection('chat').doc();
      Map<String, dynamic> messageMap = {
        'message': messageController.text,
        'sendBy': user.uid,
        'time': DateTime.now().millisecondsSinceEpoch,
        'id': docRef.id,
        'seen': false,
        'chatRoomId': widget.chatRoomId,
        'type': 'string'
      };
      DatabaseService(uid: widget.chatRoomId).addConversationMessages(messageMap, docRef);
      setState(() {
        messageController.text = '';
      });
    }
  }

  @override
  void initState() {
    DatabaseService().getConversationMessages(widget.chatRoomId).then((value) {
      setState(() {
        chatMessagesStream = value;
      });
    });
    super.initState();
  }

  @override
  void dispose() {
    TripImages.thePath = '';
    //TripImages.theFile.delete();
    super.dispose();
  }

  Stream chatMessagesStream;
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
          child: Text('${widget.userDocs['username']}',
              style: TextStyle(color: Colors.deepPurpleAccent, fontSize: 22, fontWeight: FontWeight.w800))),
      //centerTitle: true,
    );
    return Scaffold(
        backgroundColor: Colors.grey[100],
        appBar: PreferredSize(preferredSize: Size.fromHeight(appBar.preferredSize.height), child: appBar),
        body: Container(
            child: Stack(
          children: [
            Align(alignment: Alignment.topCenter, child: chatMessagesList(context)),
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                  alignment: Alignment.bottomCenter,
                  width: MediaQuery.of(context).size.width,
                  child: Container(
                      //key: _textfieldKey,
                      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.grey[50],
                        border: Border(
                            top: BorderSide(
                          color: Colors.grey[600],
                          width: 0.2,
                        )),
                      ),
                      constraints: BoxConstraints(
                        maxHeight: 120,
                      ),
                      //height: 100,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                              flex: 8,
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8),
                                  color: Colors.grey[300],
                                ),
                                child: TextField(
                                    textInputAction: TextInputAction.send,
                                    maxLines: null,
                                    keyboardType: TextInputType.multiline,
                                    controller: messageController,
                                    cursorColor: Colors.deepPurpleAccent,
                                    textAlignVertical: TextAlignVertical.center,
                                    style: TextStyle(
                                      fontSize: 17,
                                    ),
                                    onSubmitted: (details) {
                                      sendMessage();
                                    },
                                    decoration: InputDecoration(
                                      isDense: true,
                                      contentPadding: EdgeInsets.only(left: 12, right: 12, top: 9, bottom: 9),
                                      focusedBorder: InputBorder.none,
                                      enabledBorder: InputBorder.none,
                                      hintText: 'Chat',
                                    )),
                              )),
                          Expanded(
                              flex: 1,
                              child: GestureDetector(
                                  onTap: () {
                                    FocusScope.of(context).unfocus();
                                    cameraOrGalleryBottomSheet();
                                  },
                                  child: Container(
                                      margin: EdgeInsets.only(right: 12),
                                      padding: EdgeInsets.only(top: 9, bottom: 9),
                                      child: Icon(
                                        Icons.attach_file_rounded,
                                        color: Colors.grey[800],
                                        size: 27,
                                      )))),
                          Expanded(
                              flex: 1,
                              child: GestureDetector(
                                  onTap: () {
                                    sendMessage();
                                  },
                                  child: Container(
                                      margin: EdgeInsets.only(right: 12),
                                      padding: EdgeInsets.only(top: 9, bottom: 9),
                                      child: Icon(
                                        Icons.send_rounded,
                                        color: Colors.indigoAccent[700],
                                        size: 27,
                                      )))),
                        ],
                      ))),
            ),
          ],
        )));
  }
}

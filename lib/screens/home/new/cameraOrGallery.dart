import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:workingOnUI/models/uploadTrip.dart';
import 'package:workingOnUI/models/user.dart';
import 'package:workingOnUI/services/database.dart';
import 'package:workingOnUI/shared/camera.dart';
import 'package:workingOnUI/shared/cameraPrev.dart';

class CameraOrGallery extends StatefulWidget {
  final double statusBar;
  final dynamic refresh;
  final String accesedFrom;
  final String chatRoomId;
  CameraOrGallery({this.statusBar, this.refresh, this.accesedFrom, this.chatRoomId});
  @override
  _CameraOrGalleryState createState() => _CameraOrGalleryState();
}

class _CameraOrGalleryState extends State<CameraOrGallery> {
  File theFile;
  final FirebaseStorage _storage = FirebaseStorage(storageBucket: 'gs://flutterplaces-4bc44.appspot.com');
  StorageUploadTask _uploadTask;
  StorageTaskSnapshot _taskSnapshot;

  Future<void> _pickImage(BuildContext context, ImageSource source) async {
    final selected = await ImagePicker().getImage(source: source);
    if (mounted) {
      setState(() {
        TripImages.theFile = File(selected.path);
        theFile = File(selected.path);
      });
    }
    if (widget.accesedFrom == 'chat') {
      Navigator.push(context,
          MaterialPageRoute(builder: (context) => ChatImagePrev(imgPath: theFile, chatRoomId: widget.chatRoomId)));
    } else if (widget.accesedFrom == 'profile') {
      setState(() {
        _cropImage();
      });
    }
  }

  Future<void> _cropImage() async {
    final user = Provider.of<CustomUser>(this.context, listen: false);
    File cropped = await ImageCropper.cropImage(
      sourcePath: TripImages.thePath,
      cropStyle: CropStyle.circle,
      androidUiSettings: AndroidUiSettings(
        toolbarColor: Colors.purple,
        toolbarWidgetColor: Colors.white,
        toolbarTitle: 'Crop',
      ),
    );
    //if (mounted) {
    //setState(() {
    theFile = cropped ?? theFile;
    print('the path is now ${TripImages.thePath}');
    //});
    //}
    String filePath = 'profile/${DateTime.now()}.png';
    _uploadTask = _storage.ref().child(filePath).putFile(theFile);
    _taskSnapshot = await _uploadTask.onComplete;
    final String downloadUrl = await _taskSnapshot.ref.getDownloadURL();
    DatabaseService(uid: user.uid).updateProfileImg(downloadUrl);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        width: MediaQuery.of(context).size.width,
        color: Colors.white,
        //padding: EdgeInsets.all(8),
        child: Column(
          children: [
            GestureDetector(
              onTap: () {
                if (widget.accesedFrom == 'chat') {
                  Navigator.of(context).pop();
                  Navigator.push(
                      context,
                      PageRouteBuilder(
                          transitionDuration: Duration(milliseconds: 400),
                          transitionsBuilder: (BuildContext context, Animation<double> animation,
                              Animation<double> secondaryAnimation, Widget child) {
                            animation = CurvedAnimation(parent: animation, curve: Curves.easeInOut);
                            return SlideTransition(
                              position: Tween<Offset>(
                                begin: const Offset(0.0, 1.0),
                                end: const Offset(0.0, 0.0),
                              ).animate(animation),
                              child: child,
                            );
                          },
                          pageBuilder: (context, Animation<double> animation, Animation<double> secondaryAnimation) =>
                              CameraState(
                                  statusBar: widget.statusBar,
                                  refresh: widget.refresh,
                                  chatRoomId: widget.chatRoomId,
                                  accesedFrom: widget.accesedFrom)));
                } else if (widget.accesedFrom == 'profile') {
                  Navigator.of(context).pop();
                  Navigator.push(
                      context,
                      PageRouteBuilder(
                          transitionDuration: Duration(milliseconds: 400),
                          transitionsBuilder: (BuildContext context, Animation<double> animation,
                              Animation<double> secondaryAnimation, Widget child) {
                            animation = CurvedAnimation(parent: animation, curve: Curves.easeInOut);
                            return SlideTransition(
                              position: Tween<Offset>(
                                begin: const Offset(0.0, 1.0),
                                end: const Offset(0.0, 0.0),
                              ).animate(animation),
                              child: child,
                            );
                          },
                          pageBuilder: (context, Animation<double> animation, Animation<double> secondaryAnimation) =>
                              CameraState(
                                  statusBar: widget.statusBar,
                                  refresh: widget.refresh,
                                  chatRoomId: widget.chatRoomId,
                                  accesedFrom: widget.accesedFrom)));
                } else {
                  Navigator.of(context).pop();
                  Navigator.push(
                      context,
                      PageRouteBuilder(
                          transitionDuration: Duration(milliseconds: 400),
                          transitionsBuilder: (BuildContext context, Animation<double> animation,
                              Animation<double> secondaryAnimation, Widget child) {
                            animation = CurvedAnimation(parent: animation, curve: Curves.easeInOut);
                            return SlideTransition(
                              position: Tween<Offset>(
                                begin: const Offset(0.0, 1.0),
                                end: const Offset(0.0, 0.0),
                              ).animate(animation),
                              child: child,
                            );
                          },
                          pageBuilder: (context, Animation<double> animation, Animation<double> secondaryAnimation) =>
                              CameraState(
                                  statusBar: widget.statusBar,
                                  refresh: widget.refresh,
                                  chatRoomId: widget.chatRoomId,
                                  accesedFrom: widget.accesedFrom)));
                }
              },
              child: Container(
                  padding: EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                  //width: MediaQuery.of(context).size.width,
                  decoration: BoxDecoration(border: Border(bottom: BorderSide(width: 0.5, color: Colors.grey[400]))),
                  child: Row(children: [
                    Container(
                        padding: EdgeInsets.zero,
                        //width: MediaQuery.of(context).size.width,
                        child: Icon(Icons.photo_camera_outlined, color: Colors.deepPurpleAccent)),
                    Container(
                        margin: EdgeInsets.only(left: 8),
                        //width: MediaQuery.of(context).size.width,
                        child: Text('Camera',
                            style: TextStyle(color: Colors.grey[900], fontSize: 17, fontWeight: FontWeight.w600)))
                  ])),
            ),
            GestureDetector(
              onTap: () {
                _pickImage(context, ImageSource.gallery);
                Navigator.of(context).pop();
              },
              child: Container(
                  padding: EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                  //width: MediaQuery.of(context).size.width,
                  child: Row(children: [
                    Container(
                        padding: EdgeInsets.zero,
                        //width: MediaQuery.of(context).size.width,
                        child: Icon(Icons.photo_library, color: Colors.deepPurpleAccent)),
                    Container(
                        //width: MediaQuery.of(context).size.width,
                        margin: EdgeInsets.only(left: 8),
                        child: Text('Gallery',
                            style: TextStyle(color: Colors.grey[900], fontSize: 17, fontWeight: FontWeight.w600)))
                  ])),
            )
          ],
        ));
  }
}

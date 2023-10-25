import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
//import 'package:path/path.dart';
import 'package:camera/camera.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:path/path.dart';
import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:workingOnUI/models/uploadTrip.dart';
import 'package:workingOnUI/models/user.dart';
import 'package:workingOnUI/services/database.dart';
import 'package:workingOnUI/shared/cameraPrev.dart';
//import 'package:path_provider/path_provider.dart';

class CameraState extends StatefulWidget {
  final double statusBar;
  final CameraController controller;
  final String thePath;
  final dynamic refresh;
  final String accesedFrom;
  final String chatRoomId;
  CameraState({this.controller, this.statusBar, this.thePath, this.refresh, this.accesedFrom, this.chatRoomId});
  @override
  _CameraStateState createState() => _CameraStateState();
}

class _CameraStateState extends State<CameraState> {
  CameraController _controller;
  Future<void> _controllerInitializer;
  List cameras;
  int selectedCameraIndex;
  String thePath;
  final FirebaseStorage _storage = FirebaseStorage(storageBucket: 'gs://flutterplaces-4bc44.appspot.com');
  StorageUploadTask _uploadTask;
  StorageTaskSnapshot _taskSnapshot;
  File theFile;

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
    theFile = cropped ?? File(TripImages.thePath);
    print('the path is now ${TripImages.thePath}');
    //});
    //}
    String filePath = 'profile/${DateTime.now()}.png';
    _uploadTask = _storage.ref().child(filePath).putFile(theFile);
    _taskSnapshot = await _uploadTask.onComplete;
    final String downloadUrl = await _taskSnapshot.ref.getDownloadURL();
    DatabaseService(uid: user.uid).updateProfileImg(downloadUrl);
  }

  getCamera(CameraDescription camera) async {
    _controller = CameraController(
      camera,
      ResolutionPreset.high,
    );
    _controller.addListener(() {
      if (mounted) {
        setState(() {});
      }

      if (_controller.value.hasError) {
        print('Camera error ${_controller.value.errorDescription}');
      }
    });
    try {
      _controllerInitializer = _controller.initialize();
    } on CameraException catch (e) {
      print('the camera error is ${e.toString()}');
    }
    if (mounted) {
      setState(() {});
    }
  }

  void _onCapturePressed(context) async {
    try {
      TripImages.thePath = join((await getTemporaryDirectory()).path, '${DateTime.now()}.png');
      await _controller.takePicture(TripImages.thePath);

      widget.refresh();
      if (widget.accesedFrom == 'chat') {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => ChatImagePrev(imgPath: TripImages.thePath, chatRoomId: widget.chatRoomId)));
      } else if (widget.accesedFrom == 'profile') {
        setState(() {
          _cropImage();
        });
        Navigator.of(context).pop();
      } else {
        Navigator.of(context).pop();
      }
      print('the path captured is $thePath');
    } catch (e) {
      print('the error is ${e.toString()}');
    }
  }

  void onSwitchCamera() {
    setState(() {
      print('oh hey!');
      selectedCameraIndex = selectedCameraIndex < cameras.length - 1 ? selectedCameraIndex + 1 : 0;
      CameraDescription selectedCamera = cameras[selectedCameraIndex];
      getCamera(selectedCamera);
    });
  }

  @override
  void initState() {
    super.initState();
    thePath = TripImages.thePath;
    print('the path is $thePath');
    availableCameras().then((availableCameras) {
      cameras = availableCameras;

      if (cameras.length > 0) {
        setState(() {
          selectedCameraIndex = 0;
          getCamera(cameras[selectedCameraIndex]).then((void v) {});
        });
      } else {
        print('No camera available');
      }
    }).catchError((err) {
      print('Error :${err.code}Error message : ${err.message}');
    });
  }

  @override
  void dispose() {
    _controller.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    AppBar appBar = AppBar(
        elevation: 0.0,
        automaticallyImplyLeading: false,
        backgroundColor: Colors.transparent,
        leading: IconButton(
            onPressed: () {
              widget.refresh();
              Navigator.of(context).pop();
            },
            icon: Icon(Icons.keyboard_arrow_down, color: Colors.white.withOpacity(0.9), size: 36)),
        title: Container(
            child: Text('Camera',
                style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 22, fontWeight: FontWeight.w800))),
        centerTitle: true);
    return Scaffold(
        backgroundColor: Colors.black,
        body: Stack(children: [
          ClipRRect(
              child: FutureBuilder(
                  future: _controllerInitializer,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.done) {
                      return Stack(children: [
                        CameraPreview(_controller),
                        Positioned.fill(
                            child: GestureDetector(
                          onDoubleTap: () => setState(() {
                            print('double tap registered');
                            onSwitchCamera();
                          }),
                        )),
                        Positioned.fill(
                            child: Container(
                                margin: EdgeInsets.symmetric(vertical: 20),
                                child: Align(
                                    alignment: Alignment.bottomCenter,
                                    child: Container(
                                        width: MediaQuery.of(context).size.width * 0.70,
                                        height: MediaQuery.of(context).size.height * 0.13,
                                        color: Colors.transparent,
                                        child: Row(
                                          //mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Expanded(flex: 2, child: Container()),
                                            GestureDetector(
                                              onTap: () {
                                                if (mounted) {}
                                                _onCapturePressed(context);
                                              },
                                              child: SizedBox(
                                                  height: MediaQuery.of(context).size.height * 0.11,
                                                  width: MediaQuery.of(context).size.height * 0.11,
                                                  child: AspectRatio(
                                                      aspectRatio: 1,
                                                      child: Container(
                                                          decoration: BoxDecoration(
                                                              color: Colors.transparent,
                                                              borderRadius: BorderRadius.circular(100 / 2),
                                                              border: Border.all(
                                                                width: 5,
                                                                color: Colors.white.withOpacity(0.95),
                                                              )),
                                                          child: Container(
                                                            margin: EdgeInsets.all(5),
                                                            decoration: BoxDecoration(
                                                              color: Colors.white.withOpacity(0.86),
                                                              borderRadius: BorderRadius.circular(100 / 2),
                                                            ),
                                                          )))),
                                            ),
                                            Expanded(
                                                flex: 2,
                                                child: GestureDetector(
                                                  onTap: () => onSwitchCamera(),
                                                  child: Container(
                                                      child: Icon(Icons.sync_outlined, color: Colors.white, size: 34)),
                                                ))
                                          ],
                                        ))))),
                      ]);
                    } else {
                      return Container(
                          child: Center(child: Text('loading...', style: TextStyle(color: Colors.grey[50]))));
                    }
                  })),
          Container(
              height: appBar.preferredSize.height + widget.statusBar,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                    colors: [Colors.black26, Colors.transparent],
                    begin: const FractionalOffset(0.0, 0.0),
                    end: const FractionalOffset(0.0, 1),
                    stops: [0.0, 1.0],
                    tileMode: TileMode.clamp),
              ),
              child: appBar),
        ]));
  }
}

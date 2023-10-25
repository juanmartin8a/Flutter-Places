import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import '../models/user.dart';

class DatabaseService {
  final String uid;
  final String docId;
  DatabaseService({this.uid, this.docId});

  final CollectionReference userCollection = FirebaseFirestore.instance.collection('usernames');
  final CollectionReference tripsCollection = FirebaseFirestore.instance.collection('trips');
  final CollectionReference memoriesCollection = FirebaseFirestore.instance.collection('memories');
  final CollectionReference chatCollection = FirebaseFirestore.instance.collection('chatRoom');
  // final firestoreInstance = FirebaseFirestore.instance;

  Future uploadUserInfo(userMap) async {
    print(userMap);
    return await userCollection.doc(uid).set(userMap);
  }

  // userData from snapshot
  UserData _userDataFromSnapshot(DocumentSnapshot snapshot) {
    return UserData(
      uid: uid,
      name: snapshot.data()['name'],
      email: snapshot.data()['email'],
      imageUrl: snapshot.data()['imageUrl'],
    );
  }

  Stream<UserData> get userData {
    return userCollection.doc(uid).snapshots().map(_userDataFromSnapshot);
  }

  getUserByUsername(String username) async {
    print('userByUsername printed');
    return await userCollection.where('userNameIndex', arrayContains: username).get();
  }

  getUserByUserEmail(String email) async {
    return userCollection
        .where(
          'email',
          isEqualTo: email,
        )
        .get();
  }

  //for trips

  Future uploadTrip(tripMap, docRef) async {
    return await docRef.set(tripMap);
  }

  Future getTrips() async {
    return await tripsCollection.orderBy("price").limit(10).get();
  }

  getmoreTrips(_lastDoc) async {
    return await tripsCollection.startAfter([_lastDoc]).limit(15).get();
  }

  //get user
  Stream<DocumentSnapshot> getUserByUid() {
    return userCollection.doc(uid).snapshots();
  }

  //get user trips
  getUserTrips(String userUid) async {
    return await tripsCollection.where('uid', isEqualTo: userUid).get();
  }

  //add trip
  addtrip(addTripMap) async {
    return await userCollection.doc(uid).collection('trips').doc(docId).set(addTripMap);
  }

  deleteTrip() async {
    return await userCollection.doc(uid).collection('trips').doc(docId).delete();
  }

  //for chats
  Future createChatRoom(chatRoomId, chatRoomMap) async {
    return await chatCollection.doc(chatRoomId).set(chatRoomMap);
  }

  updateChat(bool value) async {
    return await chatCollection.doc(uid).collection('chat').doc(docId).update({'seen': value});
  }

  deleteChat() async {
    return await chatCollection.doc(uid).collection('chat').doc(docId).delete();
  }

  Future addConversationMessages(messageMap, docRef) async {
    /*DocumentReference documentReference =
        chatCollection.doc(uid).collection('chat').doc();*/
    return await docRef.set(messageMap).catchError((e) {
      print(e.toString());
    });
  }

  getConversationMessages(String chatRoomId) async {
    return chatCollection.doc(chatRoomId).collection('chat').orderBy('time', descending: false).snapshots();
  }

  getChatRooms(String userName) {
    return chatCollection.where('users', arrayContains: userName).snapshots();
  }

  //check if trip is added
  Future<bool> isTripAdded() async {
    try {
      var result = await userCollection.doc(uid).collection('trips').doc(docId).get();
      return result.exists;
    } catch (e) {
      throw e;
    }
  }

  checkIfTripAdded() async {
    return await userCollection.doc(uid).collection('trips').doc(docId).get();
  }

  //edit profile
  updateName(String name) async {
    return await userCollection.doc(uid).update({'name': name});
  }

  updateUsername(String username) async {
    return await userCollection.doc(uid).update({'username': username});
  }

  updateProfileImg(String newPath) async {
    return await userCollection.doc(uid).update({'profileImg': newPath});
  }

  getTripsForUser() async {
    return await userCollection.doc(uid).collection('trips').get();
  }

  queryTrips(String tripId) async {
    return await tripsCollection.where('id', isEqualTo: tripId).get();
  }
}

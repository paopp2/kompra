import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:geoflutterfire/geoflutterfire.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:kompra/data/firebase_backend_connections.dart';
import 'package:kompra/domain/models/client.dart';
import 'package:kompra/domain/models/transaction.dart' as my;

class FirebaseTasks {

  //TODO fix return
  static Future<AuthResult> createNewUserWithEmailAndPass(
      {
        @required String name,
        @required String phoneNum,
        @required String email,
        @required String password,
      }) async {
    final newUser = await fireAuth.createUserWithEmailAndPassword(
        email: email, password: password);
    if (newUser != null) {
      clientsCollection.document(email).setData({
        'clientName' : name,
        'clientPhoneNum' : phoneNum,
        'clientEmail' : email,
      });
      print('Sign up success');
      return newUser;
    }
  }

  static Future<AuthResult> logInUserWithEmailAndPass (
      {String email, String password}) {
    final existingUser = fireAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
    );
    if(existingUser != null) {
      print('Log in successful');
      return existingUser;
    }
  }

  static Future<Client> getClient({String email}) async {
    DocumentSnapshot snapshot = await clientsCollection.document(email).get();
    String em = snapshot.data['clientEmail'];
    String name = snapshot.data['clientName'];
    String phoneNum = snapshot.data['clientPhoneNum'];
    return Client(
      clientEmail: em,
      clientName: name,
      clientPhoneNum: phoneNum,
    );
  }

  static Future<FirebaseUser> getCurrentUser() {
    return fireAuth.currentUser();
  }

  static Future<DocumentReference> postTransactionRequest(my.Transaction trans) {
    return pendingTransactionsCollection.add({
      'clientName' : trans.client.clientName,
      'clientEmail' : trans.client.clientEmail,
      'clientPhoneNum' : trans.client.clientPhoneNum,
      'location' : trans.location,
      'locationName' : trans.locationName,
      'transactionPhase' : trans.phase.toString(),
      'groceryList' : trans.groceryList,
    });
  }

  static void signOut() {
    fireAuth.signOut();
  }

  static void deleteDocument(String docID) async {
    pendingTransactionsCollection.document(docID).delete();
  }

  static Stream<DocumentSnapshot> getTransactionDocumentSnapshot(String docID) {
    return pendingTransactionsCollection.document(docID).snapshots();
  }

  static Stream<DocumentSnapshot> getShopperDocumentSnapshot(String shopperEmail) {
    return shoppersCollection.document(shopperEmail).snapshots();
  }

  static getGeoFlutterPoint(LatLng latlng) {
    GeoFirePoint location = geo.point(latitude: latlng.latitude, longitude: latlng.longitude);
    return location.data;
  }

  static Stream<List<DocumentSnapshot>> getNearestShoppersStream(LatLng center) {
    GeoFirePoint geoCenter = geo.point(latitude: center.latitude, longitude: center.longitude);

    double radius = 50;
    String field = 'location';

    Stream<List<DocumentSnapshot>> stream = geo.collection(collectionRef: shoppersCollection)
        .within(center: geoCenter, radius: radius, field: field);
    return stream;
  }
}
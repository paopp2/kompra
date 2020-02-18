import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geoflutterfire/geoflutterfire.dart';

final fireAuth = FirebaseAuth.instance;
final fireStore = Firestore.instance;
final Geoflutterfire geo = Geoflutterfire();

final CollectionReference clientsCollection = fireStore.collection('clients');
final CollectionReference pendingTransactionsCollection = fireStore.collection('pending_transactions');
final CollectionReference shoppersCollection = fireStore.collection('shoppers');
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:kompra/domain/location.dart';
import 'package:geoflutterfire/geoflutterfire.dart';

import 'client.dart';
import 'shopper.dart';

enum TransactionPhase {
  idle,
  finding,
  accepted,
  arrived,
  shopping,
  paying,
  coming,
  completed,
}

class Transaction {
  Transaction({
    this.client,
    this.shopper,
    this.location,
    this.locationName,
    this.timestamp,
    this.groceryList,
    this.phase,
    this.docID,
    this.totalPrice,
    this.serviceFee,
  });

  Client client;
  Shopper shopper;
  var location;
  Timestamp timestamp;
  List<Map> groceryList;
  String locationName;
  TransactionPhase phase;
  String docID;
  double totalPrice;
  double serviceFee;
}

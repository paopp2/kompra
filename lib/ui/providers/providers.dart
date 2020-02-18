import 'package:flutter/material.dart';
import 'package:kompra/domain/models/client.dart';
import 'package:kompra/domain/models/transaction.dart';

class CurrentUser extends ChangeNotifier {
  CurrentUser({
    this.client,
  });
  Client client;
  notifyListeners();
}

class PendingTransaction extends ChangeNotifier {
  PendingTransaction({
    this.transaction,
  });
  Transaction transaction;
  notifyListeners();
}
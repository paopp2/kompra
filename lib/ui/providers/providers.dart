import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:kompra/domain/models/client.dart';
import 'package:kompra/domain/models/grocery_cart.dart';
import 'package:kompra/domain/models/transaction.dart';
import 'package:kompra/domain/models/category.dart';
import 'package:kompra/domain/models/item.dart';

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
  Marker clientLocationMarker;

  void saveClientMarker(Marker m) {
    clientLocationMarker = m;
  }

  void resetTransaction(Transaction lastTransaction) {
    if(transaction.location != null && transaction.locationName != null){
      transaction = Transaction(
        locationName: lastTransaction.locationName,
        location: lastTransaction.location,
        phase: TransactionPhase.idle,
      );
    }
  }
  notifyListeners();
}

class ChosenCategory extends ChangeNotifier {
  ChosenCategory({
    this.category,
  });
  Category category;
  notifyListeners();
}

class ChosenItem extends ChangeNotifier {
  ChosenItem({
    this.item
  });
  Item item;
  notifyListeners();
}

class MyGroceryCart extends ChangeNotifier {

  List<Item> itemList = [];
  int totalNum = 0;
  double totalPrice = 0.00;

  void addItem(Item item) {
    int checkIndex = itemList.indexOf(item);
    if(checkIndex != -1) {
      itemList.removeAt(checkIndex);
      itemList.insert(checkIndex, item);
    } else {
      itemList.add(item);
    }
    totalNum+=item.quantity;
    totalPrice+=(item.quantity * item.itemPrice);
    notifyListeners();
  }

  void decrementItem(Item item) {
    totalNum-=(item.quantity);
    totalPrice-=(item.quantity * item.itemPrice);
  }

  void removeItem(Item item) {
    decrementItem(item);
    itemList.removeAt(itemList.indexOf(item));
  }

  void resetGroceryCart() {
    for(var item in itemList) {
      item.quantity = 0;
    }
    itemList = [];
    totalNum = 0;
    totalPrice = 0.00;
  }

//  void incrementToTotalNum(int increment) {
//    totalNum+=increment;
//  }
//
//  void addToTotalPrice(double subtotal) {
//    totalPrice+=subtotal;
//  }
}
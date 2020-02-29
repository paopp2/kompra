import 'package:kompra/domain/models/item.dart';

class GroceryCart {
  GroceryCart({
    this.itemList,
    this.totalNum,
    this.totalPrice,
  });
  List<Item> itemList;
  int totalNum;
  double totalPrice;
}
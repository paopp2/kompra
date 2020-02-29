import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:kompra/constants.dart';
import 'package:kompra/domain/models/category.dart';
import 'package:kompra/ui/providers/providers.dart';
import 'package:kompra/ui/screens/grocery_list_form_screen.dart';
import 'package:provider/provider.dart';
import 'package:kompra/domain/firebase_tasks.dart';
import 'package:kompra/domain/models/item.dart';
import 'package:kompra/ui/components/item_tile.dart';

class CategoryItemsScreen extends StatefulWidget {
  static String id = 'category_items_screen_id';

  @override
  _CategoryItemsScreenState createState() => _CategoryItemsScreenState();
}

class _CategoryItemsScreenState extends State<CategoryItemsScreen> {
  Category chosenCategory;
  Stream<QuerySnapshot> chosenCategoryStream;

  @override
  void initState() {
    super.initState();
    chosenCategory = Provider.of<ChosenCategory>(context, listen: false).category;
    switch(chosenCategory.categoryType) {
      case CategoryType.alcoholic: {
        chosenCategoryStream = FirebaseTasks.getAlcoholicDrinksStream();
      } break;
      case CategoryType.beverage: {
        //
      } break;
      case CategoryType.snacks: {
        //
      } break;
      case CategoryType.schoolOfficeSupplies: {
        //
      } break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: chosenCategoryStream,
      builder: (context, snapshot) {
        List<ItemTile> itemTileList = [];
        List<Item> itemList = [];
        if(snapshot.hasData) {
          final itemsData = snapshot.data.documents;
          for(var drink in itemsData) {
            Item item = Item(
              itemCode: drink.data['itemCode'],
              itemName: drink.data['itemName'],
              itemDetail: drink.data['itemDetail'],
              itemUnit: drink.data['itemUnit'],
              itemPrice: drink.data['itemPrice'].toDouble(),
              itemImageUrl: drink.data['itemImageUrl'],
              quantity: 0,
            );
            itemList.add(item);
          }
        } else {
          print('None');
        }

        return LayoutBuilder(
          builder: (context, constraints) {
            for(var item in itemList) {
              ItemTile itemTile = ItemTile(
                constraints: constraints,
                item: item,
              );
              itemTileList.add(itemTile);
            }
            return Scaffold(
              appBar: AppBar(
                title: Text(chosenCategory.categoryTitle),
                backgroundColor: kDarkerAccentColor,
                actions: <Widget>[
                  IconButton(
                    icon: Icon(Icons.local_grocery_store),
                    onPressed: () {
                      Navigator.pushNamed(context, GroceryListFormScreen.id);
                    },
                  ),
                ],
              ),
              body: ListView(
                children: itemTileList,
              ),
            );
          }
        );
      }
    );
  }
}

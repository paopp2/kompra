import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:kompra/constants.dart';

class GroceryItemsScreen extends StatelessWidget {
  static String id = 'grocery_items_screen_id';

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) =>
        Scaffold(
          appBar: AppBar(
            backgroundColor: kDarkerAccentColor,
            leading: IconButton(
              icon: Icon(
                Icons.menu,
              ),
              onPressed: () {
                //TODO: Implement home menu
              },
            ),
            title: SizedBox(
              height: 20,
              child: kKompraWordLogoWhite,
            ),
            actions: <Widget>[
              IconButton(
                icon: Icon(
                  Icons.local_grocery_store,
                  color: Colors.white,
                ),
                onPressed: () {
                  //TODO: Open grocery cart
                },
              ),
            ],
          ),
          body: GridView.count(
            crossAxisCount: 2,
            children: <Widget>[
              CategoryTile(
                image: AssetImage('images/category_background_images/liquor.jpg'),
              ),
              CategoryTile(
                image: AssetImage('images/category_background_images/beverages.jpg'),
              ),
              CategoryTile(
                image: AssetImage('images/category_background_images/snacks.jpg'),
              ),
              CategoryTile(
                image: AssetImage('images/category_background_images/school_and_office_supplies.jpg'),
              ),
            ],
          ),
        ),
    );
  }
}

class CategoryTile extends StatelessWidget {
  const CategoryTile({
    @required this.image,
  });

  final AssetImage image;

  @override
  Widget build(BuildContext context) {
//    return SizedBox.expand(
//      child: Stack(
//        children: <Widget>[
//          ClipRRect(
//            borderRadius: BorderRadius.circular(20),
//            child: FittedBox(
//              child: image,
//              fit: BoxFit.cover,
//            ),
//          ),
//        ],
//      ),
//    );
    return GridTile(
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: image,
                fit: BoxFit.cover,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

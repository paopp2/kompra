import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/rendering.dart';
import 'package:kompra/constants.dart';
import 'package:auto_size_text/auto_size_text.dart';

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
                categoryTitle: 'Wine and Liquor',
              ),
              CategoryTile(
                image: AssetImage('images/category_background_images/beverages.jpg'),
                categoryTitle: 'Juices and softdrinks',
              ),
              CategoryTile(
                image: AssetImage('images/category_background_images/snacks.jpg'),
                categoryTitle: 'Snacks and sweets',
              ),
              CategoryTile(
                image: AssetImage('images/category_background_images/school_and_office_supplies.jpg'),
                categoryTitle: 'School and office supplies',
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
    @required this.categoryTitle,
  });

  final AssetImage image;
  final String categoryTitle;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Material(
        elevation: 5,
        borderRadius: BorderRadius.circular(20),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Stack(
            children: <Widget>[
              Material(
                elevation: 5,
                child: Container(
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: image,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: AutoSizeText(
                    categoryTitle,
                    maxLines: 2,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 50,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

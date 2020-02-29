import 'package:flutter/material.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:kompra/domain/models/category.dart';
import 'package:kompra/ui/providers/providers.dart';
import 'package:kompra/ui/screens/category_items_screen.dart';
import 'package:provider/provider.dart';

class CategoryTile extends StatelessWidget {
  const CategoryTile({
    @required this.category,
  });

  final Category category;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: GestureDetector(
        onTap: () {
          Provider.of<ChosenCategory>(context, listen: false).category = category;
          Navigator.pushNamed(context, CategoryItemsScreen.id);
        },
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
                        image: category.image,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: AutoSizeText(
                      category.categoryTitle,
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
      ),
    );
  }
}
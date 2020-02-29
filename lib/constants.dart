import 'package:flutter/material.dart';
import 'package:google_maps_webservice/places.dart';
import 'package:kompra/domain/models/category.dart';
import 'package:kompra/ui/components/category_tile.dart';

const Color kPrimaryColor = Colors.green;
final Color kDarkerPrimaryColor = Colors.green[800];
final Color kAccentColor = Colors.blueGrey[700];
final Color kDarkerAccentColor = Colors.blueGrey[800];
const String kGoogleApiKey = 'AIzaSyB03Yont3Ggw2y-Pqf87o_RW4c083oJzqg';
final GoogleMapsPlaces kPlaces = GoogleMapsPlaces(apiKey: kGoogleApiKey);
const String kTegaioWordLogoHeroTag = 'tegaio_word_logo';

const Image kKompraWordLogo =
  Image(
    image: AssetImage('images/kompra_word_logo_1.png'),
  );

const Image kKompraWordLogoWhite =
Image(
  image: AssetImage('images/kompra_word_logo_1_white.png'),
);

const Text kSignUpText =
  Text(
    'Sign up',
    style: TextStyle(
        color: Colors.white,
        fontSize: 20
    ),
  );

final Text kLoginText =
  Text(
    'Login',
    style: TextStyle(
      color: kAccentColor,
      fontSize: 20,
    ),
  );

const InputDecoration kDefaultTextFieldFormDecoration =
  InputDecoration(
    hintText: 'Enter a value',
    labelText: 'label',
    hintStyle: TextStyle(
      color: Colors.grey,
    ),
    contentPadding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(32.0)),
    ),
    enabledBorder: OutlineInputBorder(
      borderSide:
      BorderSide(color: kPrimaryColor, width: 1.0),
      borderRadius: BorderRadius.all(Radius.circular(32.0)),
    ),
    disabledBorder: OutlineInputBorder(
      borderSide:
      BorderSide(color: kPrimaryColor, width: 1.0),
      borderRadius: BorderRadius.all(Radius.circular(32.0)),
    ),
    focusedBorder: OutlineInputBorder(
      borderSide:
      BorderSide(color: kPrimaryColor, width: 2.0),
      borderRadius: BorderRadius.all(Radius.circular(32.0)),
    ),
  );

const Border kDefaultRoundButtonBorder = Border.fromBorderSide(
  BorderSide(
    color: Colors.blueGrey,
    style: BorderStyle.solid,
    width: 1.5,
  ),
);

List<CategoryTile> kCategoriesTileList = [
  CategoryTile(
    category: _categoriesList[0]
  ),
  CategoryTile(
    category: _categoriesList[1]
  ),
  CategoryTile(
    category: _categoriesList[2]
  ),
  CategoryTile(
    category: _categoriesList[3]
  ),
];

List<Category> _categoriesList = [
  Category(
    categoryType: CategoryType.alcoholic,
    image: AssetImage('images/category_background_images/liquor.jpg'),
    categoryTitle: 'Wine and Liquor',
  ),
  Category(
    categoryType: CategoryType.beverage,
    image: AssetImage('images/category_background_images/beverages.jpg'),
    categoryTitle: 'Juices and Softdrinks',
  ),
  Category(
    categoryType: CategoryType.snacks,
    image: AssetImage('images/category_background_images/snacks.jpg'),
    categoryTitle: 'Snacks and Sweets',
  ),
  Category(
      categoryType: CategoryType.schoolOfficeSupplies,
      image: AssetImage('images/category_background_images/school_and_office_supplies.jpg'),
      categoryTitle: 'School and Office Supplies'
  ),
];


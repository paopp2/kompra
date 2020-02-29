import 'package:flutter/material.dart';

enum CategoryType {
  alcoholic,
  beverage,
  snacks,
  schoolOfficeSupplies,
}

class Category {
  Category({
    this.categoryType,
    this.categoryAddress,
    this.categoryTitle,
    this.image
  });

  final CategoryType categoryType;
  final AssetImage image;
  final String categoryTitle;
  final String categoryAddress;
}
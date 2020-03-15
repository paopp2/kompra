import 'package:flutter/material.dart';
import 'package:kompra/constants.dart';

class MenuOptionTile extends StatelessWidget {
  const MenuOptionTile({
    @required this.title,
    @required this.onPressed,
  });

  final String title;
  final Function onPressed;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(
        title,
        style: TextStyle(
          color: Colors.white,
        ),
      ),
      onTap: onPressed,
    );
  }
}
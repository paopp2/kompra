import 'package:flutter/material.dart';
import 'package:kompra/constants.dart';

class MakeAListButton extends StatelessWidget {
  const MakeAListButton({
    @required this.onPressed
  });

  final Function onPressed;

  @override
  Widget build(BuildContext context) {
    return RaisedButton(
      onPressed: onPressed,
      color: kDarkerAccentColor,
      splashColor: kPrimaryColor,
    padding: EdgeInsets.symmetric(
          vertical: 14,
      ),
      child: Text(
        'Make a list',
        style: TextStyle(
          fontSize: 25,
          color: Colors.white,
        ),
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
    );
  }
}
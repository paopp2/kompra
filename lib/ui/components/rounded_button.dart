import 'package:flutter/material.dart';
import 'package:kompra/constants.dart';

class RoundedButton extends StatelessWidget {
  const RoundedButton({
    @required this.colour,
    @required this.onPressed,
    @required this.text,
    this.border = defaultRoundButtonBorder,
  });

  final Color colour;
  final Function onPressed;
  final Text text;
  final Border border;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: 20,
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(
          vertical: 10,
          horizontal: 50,
        ),
        child: Material(
          elevation: 0,
          color: colour,
          borderRadius: BorderRadius.circular(30.0),
          child: Container(
            decoration: BoxDecoration(
              border: border,
              borderRadius: BorderRadius.circular(30.0),
            ),
            child: MaterialButton(
              onPressed: onPressed,
              minWidth: 200.0,
              height: 50,
              child: text,
            ),
          ),
        ),
      ),
    );
  }
}
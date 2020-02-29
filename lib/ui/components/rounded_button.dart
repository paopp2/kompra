import 'package:flutter/material.dart';
import 'package:kompra/constants.dart';

class RoundedButton extends StatelessWidget {
  const RoundedButton({
    @required this.colour,
    @required this.onPressed,
    @required this.child,
    this.border = kDefaultRoundButtonBorder,
    this.isDisabled = false,
  });

  final Color colour;
  final Function onPressed;
  final Widget child;
  final Border border;
  final bool isDisabled;

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
          elevation: (isDisabled) ? 0 : 4,
          color: (isDisabled) ? Colors.grey : colour,
          borderRadius: BorderRadius.circular(30.0),
          child: Container(
            decoration: BoxDecoration(
              border: isDisabled ? null : border,
              borderRadius: BorderRadius.circular(30.0),
            ),
            child: MaterialButton(
              onPressed: onPressed,
              minWidth: 200.0,
              height: 50,
              child: child,
            ),
          ),
        ),
      ),
    );
  }
}
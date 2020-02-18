import 'package:flutter/material.dart';
import 'package:kompra/constants.dart';

class DefaultExtendedFAB extends StatelessWidget {
  const DefaultExtendedFAB({
    @required this.onPressed,
    @required this.label,
    @required this.icon,
  });

  final Function onPressed;
  final String label;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton.extended(
      backgroundColor: kDarkerAccentColor,
      label: Text(
        label,
        style: TextStyle(
          color: Colors.white,
        ),
      ),
      icon: Icon(
        icon,
        color: Colors.white,
      ),
      onPressed: onPressed,
    );
  }
}

class DefaultFAB extends StatelessWidget {
  const DefaultFAB({
    @required this.icon,
    @required this.onPressed,
  });

  final IconData icon;
  final Function onPressed;

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      backgroundColor: kDarkerAccentColor,
      child: Icon(
        icon,
        color: Colors.white,
      ),
      onPressed: onPressed,
    );
  }
}
import 'dart:ffi';

import 'package:flutter/foundation.dart';
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

class MiniFAB extends StatelessWidget {
  const MiniFAB({
    @required this.icon,
    @required this.onPressed,
    this.backgroundColor = kPrimaryColor,
  });

  final IconData icon;
  final Function onPressed;
  final Color backgroundColor;

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      heroTag: null,
      elevation: 0,
      backgroundColor: backgroundColor,
      mini: true,
      child: Icon(
        icon,
        color: Colors.white,
      ),
      onPressed: onPressed,
    );
  }
}

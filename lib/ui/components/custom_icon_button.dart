import 'package:flutter/material.dart';

class CustomIconButton extends StatelessWidget {
  const CustomIconButton({
    @required this.iconData,
    @required this.onPressed,
    @required this.constraints,
  });

  final IconData iconData;
  final Function onPressed;
  final BoxConstraints constraints;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(
        iconData,
        color: Colors.white,
        size: constraints.maxWidth * 1/12
      ),
      onPressed: onPressed,
    );
  }
}
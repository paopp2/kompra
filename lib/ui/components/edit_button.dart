import 'package:flutter/material.dart';
import 'package:kompra/constants.dart';

class EditButton extends StatelessWidget {
  const EditButton({
    @required this.onPressed,
  });

  final Function onPressed;

  @override
  Widget build(BuildContext context) {
    return FlatButton(
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      textColor: kPrimaryColor,
      child: Text(
        'Edit',
      ),
      onPressed: onPressed,
    );
  }
}
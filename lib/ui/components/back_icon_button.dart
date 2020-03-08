import 'package:flutter/material.dart';
import 'package:kompra/ui/components/custom_icon_button.dart';

class BackIconButton extends StatelessWidget {
  const BackIconButton({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 8.0,
        vertical: 25,
      ),
      child: Row(
        children: <Widget>[
          CustomIconButton(
            iconData: Icons.arrow_back,
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }
}
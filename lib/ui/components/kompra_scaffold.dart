import 'package:flutter/material.dart';
import 'package:kompra/constants.dart';

class KompraScaffold extends StatelessWidget {
  const KompraScaffold({
    Key key,
    @required this.constraints,
    @required this.body,
    @required this.customAppbarRow,
  }) : super(key: key);

  final BoxConstraints constraints;
  final Widget body;
  final Row customAppbarRow;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: <Widget>[
          Container(
            color: kDarkerAccentColor,
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: ClipRRect(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(40),
                topRight: Radius.circular(40),
              ),
              child: Container(
                  height: constraints.maxHeight * (8.5 / 10),
                  padding: EdgeInsets.all(15),
                  color: Colors.white,
                  child: body
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: 15,
              vertical: 10,
            ),
            child: Container(
              height: constraints.maxHeight * 1.5/10,
              child: Center(
                child: customAppbarRow,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
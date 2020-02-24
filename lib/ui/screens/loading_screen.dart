import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:kompra/constants.dart';

class LoadingScreen extends StatelessWidget {
  static const String id = 'loading_screen';
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          SizedBox(
            width: 150,
            child: Image.asset('images/kompra_word_logo_1.png'),
          ),
          SizedBox(
            height: 20,
          ),
          SpinKitRing(
            size: 40,
            color: kDarkerPrimaryColor,
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:kompra/constants.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:kompra/domain/models/transaction.dart';
import 'package:cached_network_image/cached_network_image.dart';

class FoundShopperAlert {
  static void show(BuildContext context, Transaction transaction) {
    Alert(
      style: AlertStyle(
        isCloseButton: false,
        animationType: AnimationType.grow,
        animationDuration: Duration(milliseconds: 400),
      ),
      context: context,
      title: 'Found you a shopper!',
      content: Column(
        children: <Widget>[
          ListTile(
            leading: CircleAvatar(
              radius: 30,
              backgroundColor: Colors.white,
              backgroundImage: CachedNetworkImageProvider(
                transaction.shopper.shopperImageUrl
              ),
            ),
            title: Text((transaction == null) ? 'Getting info' : transaction.shopper.shopperName),
            subtitle: Text(
              (transaction == null) ? 'Getting info' : transaction.shopper.shopperPhoneNum,
              style: TextStyle(
                fontSize: 10,
              ),
            ),
          ),
        ],
      ),
      buttons: [
        DialogButton(
          color: kDarkerPrimaryColor,
          child: Text(
            'Continue',
            style: TextStyle(
                color: Colors.white
            ),
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        )
      ],
    ).show();
  }
}
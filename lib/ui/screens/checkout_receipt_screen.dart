import 'dart:async';
import 'dart:ui';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:kompra/domain/models/item.dart';
import 'package:kompra/domain/models/transaction.dart' as my;
import 'package:kompra/ui/components/custom_icon_button.dart';
import 'package:kompra/ui/components/floating_action_buttons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:kompra/constants.dart';
import 'package:kompra/ui/components/found_shopper_alert.dart';
import 'package:kompra/ui/providers/providers.dart';
import 'package:kompra/ui/screens/delivering_screen.dart';
import 'package:kompra/ui/screens/finding_shopper_screen.dart';
import 'package:kompra/ui/screens/location_chooser_screen.dart';
import 'package:provider/provider.dart';
import 'package:kompra/domain/firebase_tasks.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:kompra/ui/components/back_icon_button.dart';
import 'package:kompra/ui/components/order_summary_table.dart';
import 'package:kompra/ui/components/edit_button.dart';

class CheckoutReceiptScreen extends StatefulWidget {
  static String id = 'check_out_receipt_screen';
  @override
  _CheckoutReceiptScreenState createState() => _CheckoutReceiptScreenState();
}

class _CheckoutReceiptScreenState extends State<CheckoutReceiptScreen> {
  List<Map> _groceryList;
  double totalPrice;
  double serviceFee;

  @override
  Widget build(BuildContext context) {
    //initialize serviceFee and totalPrice
    if (serviceFee == null && totalPrice == null) {
      serviceFee = 50.0 +
          (Provider.of<MyGroceryCart>(context, listen: false).totalNum * 5);
      totalPrice =
          Provider.of<MyGroceryCart>(context, listen: false).totalPrice +
              serviceFee;
    }
    List<Widget> getGroceryListScreenBody(BoxConstraints constraints) {
      return <Widget>[
        Card(
          elevation: 10,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          child: Padding(
            padding: const EdgeInsets.all(15.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'Delivery',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                Text(Provider.of<PendingTransaction>(context, listen: false)
                    .transaction
                    .locationName),
                SizedBox(
                  height: 15,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: <Widget>[
                    EditButton(
                      onPressed: () {
                        Navigator.pushNamed(context, LocationChooserScreen.id);
                      },
                    ),
                  ],
                ),
                Divider(),
                Text(
                  'Order Summary',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                Container(
                  height: constraints.maxHeight * 1 / 3.2,
                  child: ListView(
                    children: <Widget>[
                      OrderSummaryTable(
                        itemList:
                            Provider.of<MyGroceryCart>(context, listen: false)
                                .itemList,
                      ),
                    ],
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: <Widget>[
                    EditButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ),
                  ],
                ),
                Divider(),
                Text(
                  'Service Fee',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                Center(
                  child: Text('₱$serviceFee'),
                ),
                Divider(),
                Text(
                  'Total',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                Center(
                  child: Text('₱$totalPrice'),
                ),
              ],
            ),
          ),
        ),
      ];
    }

    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
      return Scaffold(
        backgroundColor: Colors.blueGrey[100],
        body: Stack(
          children: <Widget>[
            Container(
              height: constraints.maxHeight * 1 / 5,
              color: kDarkerAccentColor,
              child: Center(
                child: Text(
                  'Checkout',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 35,
                  ),
                ),
              ),
            ),
            Container(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  SizedBox(
                    height: constraints.maxHeight * 1 / 10,
                  ),
                  Container(
                    height: constraints.maxHeight * 0.8,
                    width: constraints.maxWidth * 0.9,
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        vertical: 15,
                        horizontal: 30,
                      ),
                      child: ListView(
                          children: <Widget>[
                            Card(
                              elevation: 10,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(15.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Text(
                                      'Delivery',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    SizedBox(
                                      height: 10,
                                    ),
                                    Text(Provider.of<PendingTransaction>(
                                            context,
                                            listen: false)
                                        .transaction
                                        .locationName),
                                    SizedBox(
                                      height: 15,
                                    ),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: <Widget>[
                                        EditButton(
                                          onPressed: () {
                                            Navigator.pushNamed(context,
                                                LocationChooserScreen.id);
                                          },
                                        ),
                                      ],
                                    ),
                                    Divider(),
                                    Text(
                                      'Order Summary',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    SizedBox(
                                      height: 10,
                                    ),
                                    Container(
                                      height: constraints.maxHeight * 1 / 3.2,
                                      child: (_groceryList != null) ? ListView(
                                        children: <Widget>[
                                          OrderSummaryTable(
                                            itemList:
                                                Provider.of<MyGroceryCart>(
                                                        context,
                                                        listen: false)
                                                    .itemList,
                                          ),
                                        ],
                                      ) : Center(
                                        child: Text('No items in cart'),
                                      ),
                                    ),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: <Widget>[
                                        EditButton(
                                          onPressed: () {
                                            Navigator.pop(context);
                                          },
                                        ),
                                      ],
                                    ),
                                    Divider(),
                                    Text(
                                      'Service Fee',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    SizedBox(
                                      height: 10,
                                    ),
                                    Center(
                                      child: Text('₱$serviceFee'),
                                    ),
                                    Divider(),
                                    Text(
                                      'Total',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    SizedBox(
                                      height: 10,
                                    ),
                                    Center(
                                      child: Text('₱$totalPrice'),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 8.0,
                vertical: 25,
              ),
              child: CustomIconButton(
                constraints: constraints,
                iconData: Icons.arrow_back,
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ),
          ],
        ),
        floatingActionButton: DefaultExtendedFAB(
          icon: Icons.face,
          label: 'Find a shopper',
          onPressed: () {
            _groceryList = [];
            for (var item in Provider.of<MyGroceryCart>(context, listen: false)
                .itemList) {
              Map temp = {
                'itemName': item.itemName,
                'itemDetail': item.itemDetail,
                'itemUnit': item.itemUnit,
                'itemPrice': item.itemPrice,
                'quantity': item.quantity,
                'subtotal': item.subtotal,
              };
              _groceryList.add(temp);
            }
            if (_groceryList.length != 0) {
              Provider.of<PendingTransaction>(context, listen: false)
                  .transaction
                  .groceryList = _groceryList;
              Provider.of<PendingTransaction>(context, listen: false)
                  .transaction
                  .phase = my.TransactionPhase.finding;
              Provider.of<PendingTransaction>(context, listen: false)
                  .setTotalPriceAndServiceFee(
                totalPrice: totalPrice,
                serviceFee: serviceFee,
              );
              Provider.of<PendingTransaction>(context, listen: false)
                      .transaction
                      .client =
                  Provider.of<CurrentUser>(context, listen: false).client;
              my.Transaction temp =
                  Provider.of<PendingTransaction>(context, listen: false)
                      .transaction;
              Navigator.pushNamed(context, FindingShopperScreen.id);
            }
          },
        ),
      );
    });
  }
}

import 'dart:async';
import 'dart:ui';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:kompra/domain/models/item.dart';
import 'package:kompra/domain/models/transaction.dart' as my;
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

class GroceryListFormScreen extends StatefulWidget {
  static String id = 'issue_form_screen';
  @override
  _GroceryListFormScreenState createState() => _GroceryListFormScreenState();
}

class _GroceryListFormScreenState extends State<GroceryListFormScreen> {

  String _groceryList;
  String transactionPhase = 'Heading to grocery shop';
  final GlobalKey<FormBuilderState> _fbKey = GlobalKey<FormBuilderState>();
  bool isAccepted;
  String groceryList;
  double progress = 1/5;
  TextEditingController locationTextFieldFormController = TextEditingController();
  TextEditingController groceryListTextFieldController = TextEditingController();
  TextEditingController phaseTextFieldController = TextEditingController();
  TextEditingController serviceFeeTextFieldController = TextEditingController();
  //temp
  List<Widget> groceryWidgetsList = [];

  @override
  void initState() {
    super.initState();
    var temp = Provider.of<PendingTransaction>(context, listen: false).transaction;
    if(temp.phase == my.TransactionPhase.accepted) {
      isAccepted = true;
      groceryList = temp.groceryList;
      groceryListTextFieldController.text = groceryList;
      WidgetsBinding.instance
          .addPostFrameCallback((_) => FoundShopperAlert.show(context, temp),);
    } else {
      isAccepted = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    String docID = Provider.of<PendingTransaction>(context, listen: false).transaction.docID;
    StreamSubscription<DocumentSnapshot> sub;
    if(isAccepted) sub = FirebaseTasks.getTransactionDocumentSnapshot(docID).listen((documentSnapshot) {
      String phase = documentSnapshot.data['transactionPhase'];
      String tempPhase;
      double tempProgress;
      switch(phase) {
        case 'TransactionPhase.accepted' : {
          tempPhase = 'Heading to grocery store';
          tempProgress = 1/5;
        } break;
        case 'TransactionPhase.arrived' : {
          tempPhase = 'Arrived at the grocery shop';
          tempProgress = 2/5;
        } break;
        case 'TransactionPhase.shopping' : {
          tempPhase = 'Getting your groceries';
          tempProgress = 3/5;
        } break;
        case 'TransactionPhase.paying' : {
          tempPhase = 'Paying at counter';
          tempProgress = 4/5;
        } break;
        case 'TransactionPhase.coming' : {
          tempPhase = 'Coming to you';
          tempProgress = 5/5;
          Provider.of<PendingTransaction>(context, listen: false).transaction.phase = my.TransactionPhase.coming;
          sub.cancel();
          Navigator.popAndPushNamed(context, DeliveringScreen.id);
        }
      }
      setState(() {
        transactionPhase = tempPhase;
        progress = tempProgress;
      });
    });

    locationTextFieldFormController.text = Provider.of<PendingTransaction>(context, listen: false).transaction.locationName;
    if(transactionPhase != null && isAccepted) phaseTextFieldController.text = transactionPhase;
    List<Widget> getGroceryListScreenBody(BoxConstraints constraints) {
      double serviceFee = 50.0 + (Provider.of<MyGroceryCart>(context, listen: false).totalNum * 5);
      return <Widget>[
//      TextFormField(
//        maxLines: 2,
//        readOnly: true,
//        controller: locationTextFieldFormController,
//        decoration: kDefaultTextFieldFormDecoration.copyWith(
//            labelText: 'Address'
//        ),
//        onTap: () {
//          Navigator.pushNamed(context, MapScreen.id);
//        },
//      ),
//      SizedBox(height: 15,),
//      FormBuilderTextField(
//        onChanged: (value) {
//          _groceryList = value;
//        },
//        maxLines: 10,
//        controller: groceryListTextFieldController,
//        attribute: 'grocery_list',
//        readOnly: (isAccepted) ? true : false,
//        decoration: kDefaultTextFieldFormDecoration.copyWith(
//          labelText: 'Grocery List',
//          alignLabelWithHint: true,
//          hintText: 'Enter your grocery list in bullet form',
//        ),
//        style: TextStyle(
//          height: 1.5,
//        ),
//        validators: [
//          FormBuilderValidators.required(),
//        ],
//      ),
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
                SizedBox(height: 10,),
                Text(
                  Provider.of<PendingTransaction>(context, listen: false).transaction.locationName
                ),
                SizedBox(height: 15,),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: <Widget>[
                    FlatButton(
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      textColor: kPrimaryColor,
                      child: Text(
                        'Edit',
                      ),
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
                SizedBox(height: 10,),
                Container(
                  height: constraints.maxHeight * 1/3.2,
                  child: ListView(
                    children: <Widget>[
                      OrderSummaryTable(
                        itemList: Provider.of<MyGroceryCart>(context, listen: false).itemList,
                      ),
                    ],
                  ),
                ),
                Divider(),
                Text(
                  'Service Fee',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 10,),
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
                SizedBox(height: 10,),
                Center(
                  child: Text('₱${Provider.of<MyGroceryCart>(context, listen: false).totalPrice + serviceFee}'),
                ),
              ],
            ),
          ),
        ),
      ];
    }

    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {

        //TODO: Chnge to actual service fee
//        serviceFeeTextFieldController.text = 'Php50';
        groceryWidgetsList = getGroceryListScreenBody(constraints);
        if (isAccepted) {
          groceryWidgetsList.add(
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: 10,
                vertical: 15,
              ),
              child: LinearPercentIndicator(
                animation: true,
                lineHeight: 40,
                animationDuration: 500,
                animateFromLastPercent: true,
                percent: progress,
                center: Text(
                  transactionPhase,
                  style: TextStyle(
                    color: Colors.white,
                  ),
                ),
                linearStrokeCap: LinearStrokeCap.roundAll,
                progressColor: kPrimaryColor,
                backgroundColor: kAccentColor,
              ),
            ),
          );
//          getGroceryListScreenBody(constraints).addAll(
//              [
//                SizedBox(height: 15,),
//                TextFormField(
//                  readOnly: true,
//                  textAlign: TextAlign.center,
//                  controller: serviceFeeTextFieldController,
//                  decoration: kDefaultTextFieldFormDecoration.copyWith(
//                    labelText: 'Service fee',
//                  ),
//                  onTap: () {
//                    Navigator.pop(context);
//                  },
//                ),
//              ]
//          );
        }

        return Scaffold(
          backgroundColor: Colors.blueGrey[100],
          body: Stack(
            children: <Widget>[
              Container(
                height: constraints.maxHeight * 1/5,
                color: kDarkerAccentColor,
                child: Center(
                  child: Text(
                    (!isAccepted) ? 'Checkout' : 'Receipt',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 35,
                    ),
                  ),
                ),
              ),
              ListView(
                children: <Widget>[
                  SizedBox(height: constraints.maxHeight * 1/10,),
                  Container(
                    height: constraints.maxHeight * 0.7,
                    width: constraints.maxWidth * 0.9,
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        vertical: 15,
                        horizontal: 30,
                      ),
                      child: FormBuilder(
                        key: _fbKey,
                        child: ListView(
//                          children: getGroceryListScreenBody(constraints),
                            children: groceryWidgetsList,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              //SizedBox below essentially means show nothing instead of BackIconButton
              //Putting null there returns error
              (!isAccepted) ? BackIconButton() : SizedBox(height: 0,),
            ],
          ),
          floatingActionButton: (isAccepted) ? null : DefaultExtendedFAB(
            icon: Icons.face,
            label: 'Find a shopper',
            onPressed: () {
              _groceryList = '';
              for(var item in Provider.of<MyGroceryCart>(context, listen: false).itemList) {
                _groceryList = _groceryList + item.itemName + '    ';
              }
              if (_fbKey.currentState.saveAndValidate()) {
                Provider.of<PendingTransaction>(context, listen: false).transaction.groceryList = _groceryList;
                Provider.of<PendingTransaction>(context, listen: false).transaction.phase = my.TransactionPhase.finding;
                Provider.of<PendingTransaction>(context, listen: false).transaction.client =
                  Provider.of<CurrentUser>(context, listen: false).client;
                my.Transaction temp = Provider.of<PendingTransaction>(context, listen: false).transaction;
                print('Transaction details   : '
                    ' ${temp.location['geohash']}'
                    ' ${temp.client.clientEmail},'
                    ' ${temp.groceryList},'
                    ' ${temp.phase},'
                    ' ${temp.locationName}');
                Navigator.pushNamed(context, FindingShopperScreen.id);
              }
            },
          ),
        );
      }
    );
  }
}

import 'dart:async';
import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:kompra/domain/models/transaction.dart' as my;
import 'package:kompra/ui/components/floating_action_buttons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:kompra/constants.dart';
import 'package:kompra/ui/components/found_shopper_alert.dart';
import 'package:kompra/ui/providers/providers.dart';
import 'package:kompra/ui/screens/finding_shopper_screen.dart';
import 'package:kompra/ui/screens/home_screen.dart';
import 'package:provider/provider.dart';
import 'package:kompra/domain/firebase_tasks.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';

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

  @override
  void initState() {
    super.initState();
    var temp = Provider.of<PendingTransaction>(context, listen: false).transaction;
    print(temp.phase.toString());
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
          Navigator.popUntil(context, ModalRoute.withName(HomeScreen.id));
        }
      }
      setState(() {
        transactionPhase = tempPhase;
        progress = tempProgress;
      });
    });

    locationTextFieldFormController.text = Provider.of<PendingTransaction>(context, listen: false).transaction.locationName;
    if(transactionPhase != null && isAccepted) phaseTextFieldController.text = transactionPhase;
    List<Widget> groceryListScreenBody = <Widget>[
      TextFormField(
        maxLines: 2,
        readOnly: true,
        controller: locationTextFieldFormController,
        decoration: kDefaultTextFieldFormDecoration.copyWith(
            labelText: 'Address'
        ),
        onTap: () {
          Navigator.pop(context);
        },
      ),
      SizedBox(height: 15,),
      FormBuilderTextField(
        onChanged: (value) {
          _groceryList = value;
        },
        maxLines: 10,
        controller: groceryListTextFieldController,
        attribute: 'grocery_list',
        readOnly: (isAccepted) ? true : false,
        decoration: kDefaultTextFieldFormDecoration.copyWith(
          labelText: 'Grocery List',
          alignLabelWithHint: true,
          hintText: 'Enter your grocery list in bullet form',
        ),
        style: TextStyle(
          height: 1.5,
        ),
        validators: [
          FormBuilderValidators.required(),
        ],
      ),
    ];

    //TODO: Chnge to actual service fee
    serviceFeeTextFieldController.text = 'Php50';
    if (isAccepted) {
      groceryListScreenBody.insert(2,
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
      groceryListScreenBody.addAll(
        [
          SizedBox(height: 15,),
          TextFormField(
            readOnly: true,
            textAlign: TextAlign.center,
            controller: serviceFeeTextFieldController,
            decoration: kDefaultTextFieldFormDecoration.copyWith(
                labelText: 'Service fee',
            ),
            onTap: () {
              Navigator.pop(context);
            },
          ),
        ]
      );
    }

    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        return Scaffold(
          appBar: AppBar(
            backgroundColor: kDarkerAccentColor,
            title: Text(
              (!isAccepted) ? 'Tell us what to buy' : 'Grocery List',
            ),
          ),
          body: ListView(
            children: <Widget>[
              SizedBox(height: 30,),
              Container(
                height: constraints.maxHeight * 0.8,
                width: constraints.maxWidth * 0.9,
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    vertical: 15,
                    horizontal: 30,
                  ),
                  child: FormBuilder(
                    key: _fbKey,
                    child: ListView(
                      children: groceryListScreenBody,
                    ),
                  ),
                ),
              ),
            ],
          ),
          floatingActionButton: (isAccepted) ? null : DefaultExtendedFAB(
            icon: Icons.face,
            label: 'Find a shopper',
            onPressed: () {
              if (_fbKey.currentState.saveAndValidate()) {
                Provider.of<PendingTransaction>(context, listen: false).transaction.groceryList = _groceryList;
                Provider.of<PendingTransaction>(context, listen: false).transaction.phase = my.TransactionPhase.finding;
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

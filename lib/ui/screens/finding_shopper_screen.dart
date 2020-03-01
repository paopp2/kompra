import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:kompra/constants.dart';
import 'package:kompra/domain/models/shopper.dart';
import 'package:kompra/domain/models/transaction.dart' as my;
import 'package:kompra/ui/components/floating_action_buttons.dart';
import 'package:kompra/domain/firebase_tasks.dart';
import 'package:kompra/ui/providers/providers.dart';
import 'package:kompra/ui/screens/categories_screen.dart';
import 'package:kompra/ui/screens/checkout_receipt_screen.dart';
import 'package:provider/provider.dart';

class FindingShopperScreen extends StatefulWidget {
  static String id = 'finding_mechanic_screen_id';

  @override
  _FindingShopperScreenState createState() => _FindingShopperScreenState();
}

class _FindingShopperScreenState extends State<FindingShopperScreen> {
  my.Transaction transaction;
  String docID;
  bool foundShopperAlertShown = false;
  StreamSubscription<DocumentSnapshot> sub;

  @override
  void initState() {
    super.initState();
    sub = null;
    transaction = Provider.of<PendingTransaction>(context, listen: false).transaction;
    FirebaseTasks.postTransactionRequest(
      transaction,
    ).then((docRef) {
      setState(() {
        docID = docRef.documentID;
        print('Doc ID: $docID');
        Provider.of<PendingTransaction>(context, listen: false).transaction.docID = docID;
      });
    });
  }

//  (docID == null) ? LoadingScreen() :
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (docID != null) {
          if(sub == null) {
            sub = FirebaseTasks.getTransactionDocumentSnapshot(docID).listen(
                  (snapshot) {
                if(snapshot.data['transactionPhase'] == my.TransactionPhase.accepted.toString()
                    && snapshot.data['shopperName'] != null
                    && snapshot.data['shopperEmail'] != null
                    && snapshot.data['shopperPhoneNum'] != null
                    && snapshot.data['shopperImageUrl'] != null) {
                  Provider.of<PendingTransaction>(context, listen: false).transaction.phase = my.TransactionPhase.accepted;
                  Provider.of<PendingTransaction>(context, listen: false).transaction.shopper =
                      Shopper(
                        shopperName: snapshot.data['shopperName'],
                        shopperEmail: snapshot.data['shopperEmail'],
                        shopperPhoneNum: snapshot.data['shopperPhoneNum'],
                        shopperImageUrl: snapshot.data['shopperImageUrl'],
                      );
                  Navigator.pushReplacementNamed(context, CheckoutReceiptScreen.id);
                  sub.cancel();
                }
              },
            );
          }
        }

        return Scaffold(
          backgroundColor: Colors.blueGrey[900],
          floatingActionButton: DefaultExtendedFAB(
            onPressed: () {
              sub.cancel();
              Navigator.popUntil(context, ModalRoute.withName(CategoriesScreen.id));
              FirebaseTasks.deleteDocument(docID);
            },
            label: 'Cancel',
            icon: Icons.close,
          ),
          body: Stack(
            children: <Widget>[
              Center(
                child: SpinKitRipple(
                  borderWidth: 5,
                  color: kPrimaryColor,
                  size: constraints.maxHeight * 40,
                ),
              ),
              Center(
                child: SizedBox(
                  height: 50,
                  child: kKompraWordLogo,
                ),
              ),
            ],
          ),
        );
      }
    );
  }
}

import 'dart:async';
import 'dart:typed_data';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:kompra/constants.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:kompra/domain/distance_and_travel_time.dart';
import 'package:kompra/domain/firebase_tasks.dart';
import 'package:kompra/domain/models/transaction.dart';
import 'package:kompra/domain/delivering_screen_functions.dart';
import 'package:kompra/ui/components/found_shopper_alert.dart';
import 'package:kompra/ui/components/order_summary_table.dart';
import 'package:kompra/ui/components/rounded_button.dart';
import 'package:kompra/ui/providers/providers.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart' as fstore;
import 'categories_screen.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

class DeliveringScreen extends StatefulWidget {
  static String id = 'delivering_screen_id';
  @override
  _DeliveringScreenState createState() => _DeliveringScreenState();
}

class _DeliveringScreenState extends State<DeliveringScreen> {
  Completer<GoogleMapController> _controller = Completer();
  Transaction transaction;
  StreamSubscription<fstore.DocumentSnapshot> transactionPhaseSubStream;
  String minsAway;
  LatLng clientLocation;
  Map<MarkerId, Marker> markers = <MarkerId, Marker>{};
  BitmapDescriptor markerIcon;
  Uint8List shopperIcon;
  StreamSubscription myShopperStreamSubscription;
  String transactionPhase = 'Heading to grocery shop';
  double progress = 1/5;
  String myShopperEmail;

  @override
  void initState() {
    super.initState();
    getBytesFromAsset('images/shopper_marker_icon.png', 100).then((icon) {
      setState(() {
        shopperIcon = icon;
        markerIcon = BitmapDescriptor.fromBytes(shopperIcon);
      });
    });
    transaction = Provider.of<PendingTransaction>(context, listen: false).transaction;
    fstore.GeoPoint tempGeoPoint = transaction.location['geopoint'];
    clientLocation = LatLng(tempGeoPoint.latitude, tempGeoPoint.longitude);
    WidgetsBinding.instance
        .addPostFrameCallback((_) => FoundShopperAlert.show(context, transaction),);
  }

  Future zoomToTwoMarkers(Map<MarkerId, Marker> markers) async {
    final GoogleMapController controller = await _controller.future;
    List<LatLng> tempList = [];
    markers.forEach((markerId, marker) {
      double tempLat = marker.position.latitude;
      double tempLng = marker.position.longitude;
      tempList.add(LatLng(tempLat, tempLng));
    });
    controller.animateCamera(CameraUpdate.newLatLngBounds(boundsFromLatLngList(tempList), 100));
  }

  @override
  Widget build(BuildContext context) {

    Marker clientLocationMarker = Provider.of<PendingTransaction>(context, listen: false).clientLocationMarker;
    markers[clientLocationMarker.markerId] = clientLocationMarker;
    if(myShopperEmail == null) myShopperEmail = Provider.of<PendingTransaction>(context, listen: false).transaction.shopper.shopperEmail;
    Stream<fstore.DocumentSnapshot> myShopperStream = FirebaseTasks.getShopperDocumentSnapshot(myShopperEmail);

    String docID = Provider.of<PendingTransaction>(context, listen: false).transaction.docID;
    if(transactionPhaseSubStream == null) transactionPhaseSubStream =
        FirebaseTasks.getTransactionDocumentSnapshot(docID).listen((documentSnapshot) {
          String phase = documentSnapshot.data['transactionPhase'] ?? 'Transaction.completed';
          String tempPhase;
          double tempProgress;
          switch(phase) {
            case 'TransactionPhase.accepted' : {
              tempPhase = 'Heading to grocery store';
              tempProgress = 1/6;
            } break;
            case 'TransactionPhase.arrived' : {
              tempPhase = 'Arrived at the grocery shop';
              tempProgress = 2/6;
            } break;
            case 'TransactionPhase.shopping' : {
              tempPhase = 'Getting your groceries';
              tempProgress = 3/6;
            } break;
            case 'TransactionPhase.paying' : {
              tempPhase = 'Paying at counter';
              tempProgress = 4/6;
            } break;
            case 'TransactionPhase.coming' : {
              tempPhase = 'Coming to you';
              tempProgress = 5/6;
              Provider.of<PendingTransaction>(context, listen: false).transaction.phase = TransactionPhase.coming;
//              transactionPhaseSubStream.cancel();
            } break;
            case 'TransactionPhase.completed' : {
              tempPhase = 'Transaction completed';
              tempProgress = 6/6;
              Navigator.popUntil(context, ModalRoute.withName(CategoriesScreen.id));
              myShopperStreamSubscription.cancel();
              transactionPhaseSubStream.cancel();
              Transaction lastTransaction = Provider.of<PendingTransaction>(context, listen: false).transaction;
              Provider.of<PendingTransaction>(context, listen: false).resetTransaction(lastTransaction);
              Provider.of<MyGroceryCart>(context, listen: false).resetGroceryCart();
            } break;
      }
      setState(() {
        transactionPhase = tempPhase;
        progress = tempProgress;
      });
    });

    if(myShopperStreamSubscription == null) myShopperStreamSubscription = myShopperStream.listen((snapshot) async {
      fstore.GeoPoint geoPoint = snapshot.data['location']['geopoint'];
      Map<String, dynamic> map = await Distance.getDistance(
        origLat: clientLocation.latitude,
        origLng: clientLocation.longitude,
        destLat: geoPoint.latitude,
        destLng: geoPoint.longitude,
      );
      setState((){
        minsAway = map['duration']['text'];
        Marker myShopperLocationMarker = createMarker(
            doc: snapshot,
            geoPoint: geoPoint,
            markerIcon: markerIcon
        );
        markers[myShopperLocationMarker.markerId] = myShopperLocationMarker;
        if(markers.length == 2 && markerIcon != null) zoomToTwoMarkers(markers);
      });
    });

    return LayoutBuilder(
      builder: (context, constraints) =>
        Scaffold(
          body: SlidingUpPanel(
            color: kDarkerAccentColor,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(30),
              topRight: Radius.circular(30),
            ),
            minHeight: constraints.maxHeight * 1/8,
            panel: Container(
              height: constraints.maxHeight * 3/4,
              child: Column(
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 30,
                      vertical: 30,
                    ),
                    child: LinearPercentIndicator(
                      animation: true,
                      lineHeight: constraints.maxHeight * 1/18,
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
                      backgroundColor: Colors.blueGrey[500],
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 15,
                      ),
                      child: ListView(
                        children: <Widget>[
                          Text(
                            'Your shopper',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(height: 15,),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              CircleAvatar(
                                radius: 30,
                                backgroundColor: Colors.white,
                                backgroundImage: CachedNetworkImageProvider(
                                  transaction.shopper.shopperImageUrl,
                                ),
                              ),
                              SizedBox(width: 15,),
                              Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Text(
                                    transaction.shopper.shopperName,
                                    style: TextStyle(
                                      fontSize: constraints.maxHeight * 0.025,
                                      color: Colors.white,
                                    ),
                                  ),
                                  Text(
                                    transaction.shopper.shopperPhoneNum,
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: constraints.maxHeight * 0.015,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(width: 30,),
                              IconButton(
                                icon: Icon(
                                  Icons.message,
                                  color: Colors.white,
                                  size: 25,
                                ),
                                onPressed: () {
                                  //TODO: message shopper
                                },
                              ),
                              IconButton(
                                icon: Icon(
                                  Icons.phone,
                                  size: 25,
                                  color: Colors.white,
                                ),
                                onPressed: () {
                                  //TODO: Call shopper
                                },
                              ),
                            ],
                          ),
                          SizedBox(height: 45,),
                          Text(
                            'Your items',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(height: 15,),
                          Container(
                            height: constraints.maxHeight * 1/3.2,
                            child: ListView(
                              children: <Widget>[
                                Theme(
                                  data: Theme.of(context).copyWith(
                                    dividerColor: Colors.white,
                                  ),
                                  child: OrderSummaryTable(
                                    itemList: Provider.of<MyGroceryCart>(context, listen: false).itemList,
                                    textColor: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            body: SafeArea(
              child: GoogleMap(
                onMapCreated: (GoogleMapController controller) {
                  _controller.complete(controller);
                  controller.getVisibleRegion().then((bounds) {
                    controller.animateCamera(
                      CameraUpdate.newLatLngBounds(bounds, 30),
                    );
                  });
                },
                initialCameraPosition: CameraPosition(
                  target: clientLocation,
                  zoom: 15,
                ),
                markers: Set<Marker>.of(markers.values),
              ),
            ),
          ),
        ),
    );
  }
}

//                  Positioned(
//                    bottom: 0,
//                    left: 0,
//                    right: 0,
//                    child: Container(
//                      height: constraints.maxHeight * (1/3),
//                      decoration: BoxDecoration(
//                          color: kAccentColor,
//                          borderRadius: BorderRadius.only(
//                            topRight: Radius.circular(30),
//                            topLeft: Radius.circular(30),
//                          )
//                      ),
//                      child: Column(
//                        mainAxisAlignment: MainAxisAlignment.center,
//                        children: <Widget>[
//                          Padding(
//                            padding: EdgeInsets.symmetric(
//                              horizontal: 10,
//                              vertical: 15,
//                            ),
//                            child: LinearPercentIndicator(
//                              animation: true,
//                              lineHeight: 40,
//                              animationDuration: 500,
//                              animateFromLastPercent: true,
//                              percent: progress,
//                              center: Text(
//                                transactionPhase,
//                                style: TextStyle(
//                                  color: Colors.white,
//                                ),
//                              ),
//                              linearStrokeCap: LinearStrokeCap.roundAll,
//                              progressColor: kPrimaryColor,
//                              backgroundColor: kAccentColor,
//                            ),
//                          ),
//                          Row(
//                            mainAxisAlignment: MainAxisAlignment.center,
//                            children: <Widget>[
//                              CircleAvatar(
//                                radius: 30,
//                                backgroundColor: Colors.white,
//                                backgroundImage: CachedNetworkImageProvider(
//                                  transaction.shopper.shopperImageUrl,
//                                ),
//                              ),
//                              SizedBox(width: 15,),
//                              Column(
//                                mainAxisAlignment: MainAxisAlignment.center,
//                                crossAxisAlignment: CrossAxisAlignment.start,
//                                children: <Widget>[
//                                  Text(
//                                    transaction.shopper.shopperName,
//                                    style: TextStyle(
//                                      fontSize: constraints.maxHeight * 0.025,
//                                      color: Colors.white,
//                                    ),
//                                  ),
//                                  Text(
//                                    transaction.shopper.shopperPhoneNum,
//                                    style: TextStyle(
//                                      color: Colors.white,
//                                      fontSize: constraints.maxHeight * 0.015,
//                                    ),
//                                  ),
//                                ],
//                              ),
//                            ],
//                          ),
//                          SizedBox(height: constraints.maxHeight * 0.01,),
//                          Text(
//                            '$minsAway(s) away',
//                            style: TextStyle(
//                              fontSize: constraints.maxHeight * 0.015,
//                              color: kPrimaryColor,
//                            ),
//                          ),
//                          RoundedButton(
//                            child: Text(
//                              'Back to home',
//                              style: TextStyle(
//                                color: Colors.white,
//                                fontSize: constraints.maxHeight * 0.015,
//                              ),
//                            ),
//                            colour: kDarkerPrimaryColor,
//                            onPressed: () {
//                              Navigator.popUntil(context, ModalRoute.withName(CategoriesScreen.id));
//                              Transaction lastTransaction = Provider.of<PendingTransaction>(context, listen: false).transaction;
//                              Provider.of<PendingTransaction>(context, listen: false).resetTransaction(lastTransaction);
//                              Provider.of<MyGroceryCart>(context, listen: false).resetGroceryCart();
//                            },
//                          ),
//                        ],
//                      ),
//                    ),
//                  ),

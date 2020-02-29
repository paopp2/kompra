import 'dart:async';
import 'dart:typed_data';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:kompra/constants.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:kompra/domain/distance_and_travel_time.dart';
import 'package:kompra/domain/firebase_tasks.dart';
import 'package:kompra/domain/models/transaction.dart';
import 'package:kompra/domain/separable_map_screen_functions.dart';
import 'package:kompra/ui/components/rounded_button.dart';
import 'package:kompra/ui/providers/providers.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart' as fstore;
import 'categories_screen.dart';

class DeliveringScreen extends StatefulWidget {
  static String id = 'delivering_screen_id';
  @override
  _DeliveringScreenState createState() => _DeliveringScreenState();
}

class _DeliveringScreenState extends State<DeliveringScreen> {
  Completer<GoogleMapController> _controller = Completer();
  Transaction transaction;
  String minsAway;
  LatLng clientLocation;
  Map<MarkerId, Marker> markers = <MarkerId, Marker>{};
  BitmapDescriptor markerIcon;
  Uint8List shopperIcon;
  StreamSubscription myShopperStreamSubscription;

  @override
  void initState() {
    super.initState();
    getBytesFromAsset('images/shopper_marker_icon.png', 100).then((icon) {
      setState(() {
        shopperIcon = icon;
        print('Icon instantiated');
      });
    });
    transaction = Provider.of<PendingTransaction>(context, listen: false).transaction;
    fstore.GeoPoint tempGeoPoint = transaction.location['geopoint'];
    clientLocation = LatLng(tempGeoPoint.latitude, tempGeoPoint.longitude);
  }

  Marker createMarker({fstore.DocumentSnapshot doc, BitmapDescriptor markerIcon, fstore.GeoPoint geoPoint}) {
    var markerIdVal = 'shopper_${doc.data['shopperName']}';
    var markerId = MarkerId(markerIdVal);
    Marker marker = Marker(
      markerId: markerId,
      position: LatLng(geoPoint.latitude, geoPoint.longitude),
      infoWindow: InfoWindow(title: markerIdVal, snippet: '*'),
      icon: markerIcon,
    );
    return marker;
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
//    setState(() {
//      print('Total bullshit something: ${markers.length}');
//      isZoomedAlready = true;
//    });
  }

  LatLngBounds boundsFromLatLngList(List<LatLng> list) {
    assert(list.isNotEmpty);
    double x0, x1, y0, y1;
    for (LatLng latLng in list) {
      if (x0 == null) {
        x0 = x1 = latLng.latitude;
        y0 = y1 = latLng.longitude;
      } else {
        if (latLng.latitude > x1) x1 = latLng.latitude;
        if (latLng.latitude < x0) x0 = latLng.latitude;
        if (latLng.longitude > y1) y1 = latLng.longitude;
        if (latLng.longitude < y0) y0 = latLng.longitude;
      }
    }
    return LatLngBounds(northeast: LatLng(x1, y1), southwest: LatLng(x0, y0));
  }

  @override
  void dispose() {
    myShopperStreamSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    if(shopperIcon != null) markerIcon = BitmapDescriptor.fromBytes(shopperIcon);
    Marker clientLocationMarker = Provider.of<PendingTransaction>(context, listen: false).clientLocationMarker;
    markers[clientLocationMarker.markerId] = clientLocationMarker;
    String myShopperEmail = Provider.of<PendingTransaction>(context, listen: false).transaction.shopper.shopperEmail;
    Stream<fstore.DocumentSnapshot> myShopperStream = FirebaseTasks.getShopperDocumentSnapshot(myShopperEmail);

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
//            if(!isZoomedAlready && shoppersStreamSubscription.isPaused)
        zoomToTwoMarkers(markers);
      });
    });

    return LayoutBuilder(
      builder: (context, constraints) =>
        Scaffold(
          body: SafeArea(
            child: Stack(
              children: [
                GoogleMap(
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
                  markers: (markers != null) ? Set<Marker>.of(markers.values) : null,
                ),
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    height: constraints.maxHeight * (1/4),
                    decoration: BoxDecoration(
                        color: kAccentColor,
                        borderRadius: BorderRadius.only(
                          topRight: Radius.circular(30),
                          topLeft: Radius.circular(30),
                        )
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
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
                          ],
                        ),
                        SizedBox(height: constraints.maxHeight * 0.01,),
                        Text(
                          '$minsAway(s) away',
                          style: TextStyle(
                            fontSize: constraints.maxHeight * 0.015,
                            color: kPrimaryColor,
                          ),
                        ),
                        RoundedButton(
                          child: Text(
                            'Back to home',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: constraints.maxHeight * 0.015,
                            ),
                          ),
                          colour: kDarkerPrimaryColor,
                          onPressed: () {
                            Navigator.popUntil(context, ModalRoute.withName(CategoriesScreen.id));
                            Transaction lastTransaction = Provider.of<PendingTransaction>(context, listen: false).transaction;
                            Provider.of<PendingTransaction>(context, listen: false).resetTransaction(lastTransaction);
                            Provider.of<MyGroceryCart>(context, listen: false).resetGroceryCart();
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ]
            ),
          ),
        ),
    );
  }
}

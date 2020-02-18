import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart' as fstore;
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:ui' as ui;
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:kompra/constants.dart';
import 'package:kompra/domain/models/transaction.dart';
import 'package:kompra/ui/components/rounded_button.dart';
import 'package:kompra/ui/components/make_a_list_button.dart';

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

Future<Uint8List> getBytesFromAsset(String path, int width) async {
  ByteData data = await rootBundle.load(path);
  ui.Codec codec = await ui.instantiateImageCodec(data.buffer.asUint8List(), targetWidth: width);
  ui.FrameInfo fi = await codec.getNextFrame();
  return (await fi.image.toByteData(format: ui.ImageByteFormat.png)).buffer.asUint8List();
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

Iterable<Widget> getWidgetsWhenIdle({
    String clientAddress,
    Function onPlaceSearchTapped,
    Function onMakeAListButtonTapped,
  }) {
    return [
      Positioned(
        right: 15,
        left: 15,
        top: 30,
        child: Card(
          elevation: 5,
          child: ListTile(
            leading: Padding(
              padding: const EdgeInsets.symmetric(
                vertical: 15,
              ),
              child: Icon(
                  Icons.location_on,
                  color: kDarkerPrimaryColor
              ),
            ),
            title: Text(
              clientAddress,
              style: TextStyle(
                color: kDarkerPrimaryColor,
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
            onTap: onPlaceSearchTapped,
          ),
        ),
      ),
      Positioned(
        bottom: 15,
        left: 15,
        right: 15,
        child: MakeAListButton(
          onPressed: onMakeAListButtonTapped,
        ),
      ),
    ];
  }

Widget getWidgetsWhenShopperIsComing({Function onButtonPressed, double height, Transaction transaction, String minsAway}) {
  return Positioned(
    bottom: 0,
    left: 0,
    right: 0,
    child: Container(
      height: height * (1/4),
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
                      fontSize: height * 0.025,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    transaction.shopper.shopperPhoneNum,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: height * 0.015,
                    ),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: height * 0.01,),
          Text(
            '$minsAway(s) away',
            style: TextStyle(
              fontSize: height * 0.015,
              color: kPrimaryColor,
            ),
          ),
          RoundedButton(
            text: Text(
              'Back to home',
              style: TextStyle(
                color: Colors.white,
                fontSize: height * 0.015,
              ),
            ),
            colour: kDarkerPrimaryColor,
            onPressed: onButtonPressed,
          ),
        ],
      ),
    ),
  );
}
import 'package:cloud_firestore/cloud_firestore.dart' as fstore;
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:ui' as ui;
import 'dart:typed_data';

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
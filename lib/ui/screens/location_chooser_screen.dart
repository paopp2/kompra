import 'dart:async';
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart' as fstore;
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:kompra/domain/location.dart' as location;
import 'package:kompra/constants.dart';
import 'package:flutter_google_places/flutter_google_places.dart';
import 'package:kompra/domain/models/transaction.dart';
import 'package:google_maps_webservice/places.dart';
import 'package:kompra/domain/firebase_tasks.dart';
import 'package:kompra/ui/components/floating_action_buttons.dart';
import 'package:kompra/ui/providers/providers.dart';
import 'package:provider/provider.dart';

class LocationChooserScreen extends StatefulWidget {
  static String id = 'location_chooser_screen_id';
  @override
  _LocationChooserScreenState createState() => _LocationChooserScreenState();
}

class _LocationChooserScreenState extends State<LocationChooserScreen> {
  Map<MarkerId, Marker> markers = <MarkerId, Marker>{};
  Completer<GoogleMapController> _controller = Completer();
  List<PlacesSearchResult> nearbyPlaces = [];
  LatLng clientLocation;
  Stream<List<fstore.DocumentSnapshot>> shoppersStream;
  Uint8List shopperIcon;
  BitmapDescriptor markerIcon;
  String clientAddress = '...';
  bool shopperComing = false;
  String minsAway;
  bool isZoomedAlready = false;
  TransactionPhase phase;
  //temp
  List<Widget> widgetList = [];

  Future<Null> setClientLocation(Prediction p) async {
    final GoogleMapController controller = await _controller.future;
    if (p != null) {
      String placeId = p.placeId;
      PlacesDetailsResponse detail = await kPlaces.getDetailsByPlaceId(placeId);
      double lat = detail.result.geometry.location.lat;
      double lng = detail.result.geometry.location.lng;
      final clientLocationMarkerIdVal = 'client_location_marker_id_val';
      final clientLocationMarkerId = MarkerId(clientLocationMarkerIdVal);

      print(p.description);
      print(lat);
      print(lng);
      controller.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(
        target: LatLng(lat, lng),
        zoom: 18,
      )));
      setState(() {
        clientAddress = p.description;
        clientLocation = LatLng(lat, lng);
        final Marker clientCurrentLocationMarker = Marker(
          markerId: clientLocationMarkerId,
          position: LatLng(lat, lng),
          infoWindow:
          InfoWindow(title: clientLocationMarkerIdVal, snippet: '*'),
        );
        markers[clientLocationMarkerId] = clientCurrentLocationMarker;
        Provider.of<PendingTransaction>(context, listen: false).saveClientMarker(clientCurrentLocationMarker);
      });
    }
  }

  @override
  void initState() {
    super.initState();
    Marker clientLocationMarker = Provider.of<PendingTransaction>(context, listen: false).clientLocationMarker;
    markers[clientLocationMarker.markerId] = clientLocationMarker;
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if(clientLocation == null && phase == null) {
      setState(() {
        Transaction temp = Provider.of<PendingTransaction>(context, listen: false).transaction;
        clientAddress = temp.locationName;
        fstore.GeoPoint tempGeoPoint = temp.location['geopoint'];
        clientLocation = LatLng(tempGeoPoint.latitude, tempGeoPoint.longitude);
        phase = temp.phase;
      });
    }

    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            GoogleMap(
              onMapCreated: (GoogleMapController controller) {
                _controller.complete(controller);
              },
              initialCameraPosition: CameraPosition(
                target: clientLocation,
                zoom: 15,
              ),
              markers: Set<Marker>.of(markers.values),
            ),
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
                  onTap: () async {
                    Prediction p = await PlacesAutocomplete.show(
                        location: Location(clientLocation.latitude, clientLocation.longitude),
                        radius: 10000,
                        mode: Mode.overlay,
                        context: context,
                        apiKey: kGoogleApiKey,
                        onError: (response) {
                          print('myError : ${response.errorMessage}');
                        });
                    await setClientLocation(p);
                  },
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: DefaultFAB(
        icon: Icons.check,
        onPressed: () {
          Provider.of<PendingTransaction>(context, listen: false).transaction.locationName = clientAddress;
          Provider.of<PendingTransaction>(context, listen: false).transaction.location = FirebaseTasks.getGeoFlutterPoint(clientLocation);
          Navigator.pop(context);
        },
      ),
    );
  }
}

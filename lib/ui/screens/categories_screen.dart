import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kompra/constants.dart';
import 'package:kompra/domain/firebase_tasks.dart';
import 'package:kompra/domain/models/grocery_cart.dart';
import 'package:kompra/domain/models/transaction.dart';
import 'package:kompra/ui/providers/providers.dart';
import 'package:kompra/ui/screens/grocery_list_form_screen.dart';
import 'package:kompra/domain/location.dart' as location;
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_webservice/places.dart';
import 'package:kompra/ui/screens/map_screen.dart';
import 'package:kompra/ui/screens/welcome_screen.dart';
import 'package:provider/provider.dart';

class CategoriesScreen extends StatefulWidget {
  static String id = 'grocery_items_screen_id';

  @override
  _CategoriesScreenState createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  String clientAddress = 'Finding your location...';
  StreamSubscription transactionPhaseStreamSubscription;

  Future getClientCurrentLocation() async {
    location.Location loc = location.Location();
    location.LatLng tempLatLng = await loc.getClientCurrentLocation();
    LatLng tempGoogleLatLng = LatLng(tempLatLng.lat, tempLatLng.lng);
    final result = await kPlaces.searchNearbyWithRankBy(
      Location(tempGoogleLatLng.latitude, tempGoogleLatLng.longitude),
      'distance',
      type: 'point_of_interest',
    );
    String placeId;
    if (result.status == "OK") {
      PlacesSearchResult nearestPlace = result.results[0];
      print(nearestPlace.name);
      placeId = (nearestPlace.placeId);
    } else {
      print(result.errorMessage);
    }
    PlacesDetailsResponse detail = await kPlaces.getDetailsByPlaceId(placeId);
    String address = detail.result.formattedAddress;
    setState(() {
      Provider.of<PendingTransaction>(context, listen: false).transaction.location = FirebaseTasks.getGeoFlutterPoint(tempGoogleLatLng);
      Provider.of<PendingTransaction>(context, listen: false).transaction.locationName = address;

      final clientLocationMarkerIdVal = 'client_location_marker_id_val';
      final clientLocationMarkerId = MarkerId(clientLocationMarkerIdVal);
      final Marker clientLocationMarker = Marker(
        markerId: clientLocationMarkerId,
        position: tempGoogleLatLng,
        infoWindow:
        InfoWindow(title: clientLocationMarkerIdVal, snippet: '*'),
      );
      Provider.of<PendingTransaction>(context, listen: false).saveClientMarker(clientLocationMarker);
    });
  }

  @override
  void initState() {
    super.initState();
    Provider.of<PendingTransaction>(context, listen: false).transaction = Transaction();
    Provider.of<PendingTransaction>(context, listen: false).transaction.phase = TransactionPhase.idle;
    getClientCurrentLocation();
  }

  @override
  Widget build(BuildContext context) {
    if(Provider.of<PendingTransaction>(context, listen: false).transaction.locationName != null) {
      clientAddress = Provider.of<PendingTransaction>(context, listen: false).transaction.locationName;
    }
    return WillPopScope(
      onWillPop: () {
        SystemChannels.platform.invokeMethod('SystemNavigator.pop');
        return Future.value(true);
      },
      child: LayoutBuilder(
        builder: (context, constraints) =>
          Scaffold(
            appBar: AppBar(
              backgroundColor: kDarkerAccentColor,
              leading: IconButton(
                icon: Icon(
                  Icons.menu,
                ),
                onPressed: () {
                  //TODO: Implement home menu (temp: sign out currentUser)
                  FirebaseTasks.signOut();
                  Provider.of<CurrentUser>(context, listen: false).client = null;
                  print('Current user: ${Provider.of<CurrentUser>(context, listen: false).client}');
                  Navigator.pushNamed(context, WelcomeScreen.id);
                },
              ),
              title: SizedBox(
                height: 20,
                child: kKompraWordLogoWhite,
              ),
              actions: <Widget>[
                IconButton(
                  icon: Icon(
                    Icons.local_grocery_store,
                    color: Colors.white,
                  ),
                  onPressed: () {
                    Navigator.pushNamed(context, GroceryListFormScreen.id);
                  },
                ),
              ],
            ),
            body: Container(
              padding: EdgeInsets.all(15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    'Delivery Address',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 15,),
                  Card(
                    elevation: 5,
                    color: Colors.blueGrey[50],
                    child: ListTile(
                      leading: Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: 15,
                        ),
                        child: Icon(
                            Icons.location_on,
                            color: kDarkerAccentColor,
                        ),
                      ),
                      title: Text(
                        clientAddress,
                        style: TextStyle(
                          color: kDarkerAccentColor,
                        ),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                      onTap: () {
                        if(Provider.of<PendingTransaction>(context, listen: false).transaction.location != null)
                          Navigator.pushNamed(context, MapScreen.id);
                      },
                    ),
                  ),
                  SizedBox(height: 30,),
                  Text(
                    'Categories',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 15,),
                  Expanded(
                    child: GridView.count(
                      crossAxisCount: 2,
                      children: kCategoriesTileList,
                    ),
                  ),
                ],
              ),
            ),
          ),
      ),
    );
  }
}

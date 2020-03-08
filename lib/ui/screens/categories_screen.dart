import 'dart:async';
import 'package:kompra/ui/components/kompra_scaffold.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kompra/constants.dart';
import 'package:kompra/domain/firebase_tasks.dart';
import 'package:kompra/domain/models/grocery_cart.dart';
import 'package:kompra/domain/models/transaction.dart';
import 'package:kompra/ui/components/back_icon_button.dart';
import 'package:kompra/ui/components/custom_icon_button.dart';
import 'package:kompra/ui/providers/providers.dart';
import 'package:kompra/ui/screens/checkout_receipt_screen.dart';
import 'package:kompra/domain/location.dart' as location;
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_webservice/places.dart';
import 'package:kompra/ui/screens/location_chooser_screen.dart';
import 'package:kompra/ui/screens/welcome_screen.dart';
import 'package:provider/provider.dart';

class CategoriesScreen extends StatefulWidget {
  static String id = 'grocery_items_screen_id';

  @override
  _CategoriesScreenState createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  String clientAddress = 'Finding your location...';
//  StreamSubscription transactionPhaseStreamSubscription;

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
      Provider.of<PendingTransaction>(context, listen: false)
          .transaction
          .location = FirebaseTasks.getGeoFlutterPoint(tempGoogleLatLng);
      Provider.of<PendingTransaction>(context, listen: false)
          .transaction
          .locationName = address;

      final clientLocationMarkerIdVal = 'client_location_marker_id_val';
      final clientLocationMarkerId = MarkerId(clientLocationMarkerIdVal);
      final Marker clientLocationMarker = Marker(
        markerId: clientLocationMarkerId,
        position: tempGoogleLatLng,
        infoWindow: InfoWindow(title: clientLocationMarkerIdVal, snippet: '*'),
      );
      Provider.of<PendingTransaction>(context, listen: false)
          .saveClientMarker(clientLocationMarker);
    });
  }

  @override
  void initState() {
    super.initState();
    Provider.of<PendingTransaction>(context, listen: false).transaction =
        Transaction();
    Provider.of<PendingTransaction>(context, listen: false).transaction.phase =
        TransactionPhase.idle;
    getClientCurrentLocation();
  }

  @override
  Widget build(BuildContext context) {
    if (Provider.of<PendingTransaction>(context, listen: false)
            .transaction
            .locationName !=
        null) {
      clientAddress = Provider.of<PendingTransaction>(context, listen: false)
          .transaction
          .locationName;
    }
    return WillPopScope(
      onWillPop: () {
        SystemChannels.platform.invokeMethod('SystemNavigator.pop');
        return Future.value(true);
      },
      child: LayoutBuilder(
        builder: (context, constraints) =>
          KompraScaffold(
            constraints: constraints,
            customAppbarRow: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                CustomIconButton(
                  iconData: Icons.menu,
                  constraints: constraints,
                  onPressed: () {
                    //TODO: Implement home menu (temp: sign out currentUser)
                    FirebaseTasks.signOut();
                    Provider.of<CurrentUser>(context, listen: false)
                        .client = null;
                    print(
                        'Current user: ${Provider.of<CurrentUser>(context, listen: false).client}');
                    Navigator.pushNamed(context, WelcomeScreen.id);
                  },
                ),
                SizedBox(
                  height: 25,
                  child: kKompraWordLogoWhite,
                ),
                CustomIconButton(
                  iconData: Icons.local_grocery_store,
                  constraints: constraints,
                  onPressed: () {
                    Navigator.pushNamed(context, CheckoutReceiptScreen.id);
                  },
                )
              ],
            ),
            body: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                SizedBox(
                  height: 15,
                ),
                Text(
                  'Delivery Address',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: kDarkerAccentColor,
                  ),
                ),
                SizedBox(
                  height: 15,
                ),
                Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
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
                      if (Provider.of<PendingTransaction>(context,
                          listen: false)
                          .transaction
                          .location !=
                          null)
                        Navigator.pushNamed(
                            context, LocationChooserScreen.id);
                    },
                  ),
                ),
                SizedBox(
                  height: 30,
                ),
                Text(
                  'Categories',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: kDarkerAccentColor,
                  ),
                ),
                SizedBox(
                  height: 15,
                ),
                Expanded(
                  child: GridView.count(
                    crossAxisCount: 2,
                    children: kCategoriesTileList,
                  ),
//                            child: ListView(
//                              children: <Widget>[
//                                Image(
//                                  image: AssetImage('images/category_background_images/alcohol_category_design_3.png'),
//                                ),
//                                Image(
//                                  image: AssetImage('images/category_background_images/snacks_category_design_3.png'),
//                                )
//                              ],
//                            ),
                ),
              ],
            ),
          ),
      ),
    );
  }
}

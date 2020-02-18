import 'dart:async';
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart' as fstore;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:kompra/domain/location.dart' as location;
import 'package:kompra/constants.dart';
import 'package:flutter_google_places/flutter_google_places.dart';
import 'package:kompra/domain/models/transaction.dart';
import 'package:google_maps_webservice/places.dart';
import 'package:kompra/domain/firebase_tasks.dart';
import 'package:kompra/ui/providers/providers.dart';
import 'package:kompra/ui/screens/welcome_screen.dart';
import 'package:provider/provider.dart';
import 'package:kompra/ui/screens/grocery_list_form_screen.dart';
import 'package:kompra/domain/distance_and_travel_time.dart';
import 'package:kompra/domain/separable_home_screen_functions.dart';

class HomeScreen extends StatefulWidget {
  static const id = 'home_screen';
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Map<MarkerId, Marker> markers = <MarkerId, Marker>{};
  Completer<GoogleMapController> _controller = Completer();
  List<PlacesSearchResult> nearbyPlaces = [];
  LatLng clientLocation;
  Stream<List<fstore.DocumentSnapshot>> shoppersStream;
  StreamSubscription shoppersStreamSubscription;
  StreamSubscription transactionPhaseStreamSubscription;
  Uint8List shopperIcon;
  BitmapDescriptor markerIcon;
  String clientAddress = 'Finding your location...';
  bool shopperComing = false;
  String minsAway;
  bool isZoomedAlready = false;

  //Gets default client location
  Future getClientCurrentLocation() async {
    location.Location loc = location.Location();
    location.LatLng tempLatLng = await loc.getClientCurrentLocation();
    LatLng tempGoogleLatLng = LatLng(tempLatLng.lat, tempLatLng.lng);
    final GoogleMapController controller = await _controller.future;

    final String clientLocationMarkerIdVal =
        'client_location_marker_id_val';
    final currentLocationMarkerId = MarkerId(clientLocationMarkerIdVal);
    final result = await places.searchNearbyWithRankBy(
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
    PlacesDetailsResponse detail = await places.getDetailsByPlaceId(placeId);
    String address = detail.result.formattedAddress;
    setState(() {
      clientLocation = tempGoogleLatLng;
      clientAddress = address;
      controller.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(
        target: clientLocation,
        zoom: 18,
      )));
      final Marker clientCurrentLocationMarker = Marker(
        markerId: currentLocationMarkerId,
        position: clientLocation,
        infoWindow:
        InfoWindow(title: clientLocationMarkerIdVal, snippet: '*'),
      );
      markers[currentLocationMarkerId] = clientCurrentLocationMarker;
    });
  }

  Future<Null> setClientLocation(Prediction p) async {
    final GoogleMapController controller = await _controller.future;
    if (p != null) {
      String placeId = p.placeId;
      PlacesDetailsResponse detail = await places.getDetailsByPlaceId(placeId);
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
      });
    }
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
    setState(() {
      print('Total bullshit something: ${markers.length}');
      isZoomedAlready = true;
    });
  }

  @override
  void initState() {
    super.initState();
    Provider.of<PendingTransaction>(context, listen: false).transaction = Transaction();
    Provider.of<PendingTransaction>(context, listen: false).transaction.phase = TransactionPhase.idle;
    getClientCurrentLocation();
    getBytesFromAsset('images/shopper_marker_icon.png', 100).then((icon) {
      setState(() {
        shopperIcon = icon;
        print('Icon instantiated');
      });
    });
  }

  @override
  void dispose() {
    super.dispose();
    shoppersStreamSubscription.cancel();
    transactionPhaseStreamSubscription.cancel();
  }

  @override
  Widget build(BuildContext context) {
    if(shopperIcon != null) markerIcon = BitmapDescriptor.fromBytes(shopperIcon);

    Stream<TransactionPhase> transactionPhaseStream =
      Stream.value(Provider.of<PendingTransaction>(context,listen: false).transaction.phase);

    transactionPhaseStreamSubscription = transactionPhaseStream.listen((phase) {
      print('My stream: ${phase.toString()}');
      if(phase == TransactionPhase.coming && !shopperComing) {
        shoppersStreamSubscription.pause();
        MarkerId clientMarkerIdTemp = MarkerId('client_location_marker_id_val');
        Marker clientMarkerSaver = markers[MarkerId('client_location_marker_id_val')];
        markers.clear();
        setState(() {
          shopperComing = true;
          markers[clientMarkerIdTemp] = clientMarkerSaver;
        });
        String myShopperEmail = Provider.of<PendingTransaction>(context, listen: false).transaction.shopper.shopperEmail;
        Stream<fstore.DocumentSnapshot> myShopperStream = FirebaseTasks.getShopperDocumentSnapshot(myShopperEmail);

        myShopperStream.listen((snapshot) async {
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
            if(!isZoomedAlready && shoppersStreamSubscription.isPaused)
                zoomToTwoMarkers(markers);
          });
        });
      }
    });

    if(clientLocation != null && shoppersStream == null && markerIcon != null && !shopperComing) {
      shoppersStream = FirebaseTasks.getNearestShoppersStream(clientLocation);
      shoppersStreamSubscription = shoppersStream.listen((List<fstore.DocumentSnapshot> documentList) {
        for(var doc in documentList) {
          print('${doc.data['shopperName']}');
          fstore.GeoPoint geoPoint = doc.data['location']['geopoint'];
          Marker shopperLocationMarker = createMarker(
            doc: doc,
            markerIcon: markerIcon,
            geoPoint: geoPoint,
          );
          markers[shopperLocationMarker.markerId] = shopperLocationMarker;
        }
        setState((){});
      });
    }

    List<Widget> getMapScreenWidgets(bool isDelivering) {
      List<Widget> baseWidgetList = [
        GoogleMap(
          onMapCreated: (GoogleMapController controller) {
            _controller.complete(controller);
            if(isDelivering) {
              controller.getVisibleRegion().then((bounds) {
                controller.animateCamera(
                    CameraUpdate.newLatLngBounds(bounds, 30),
                );
              });
            }
          },
          initialCameraPosition: CameraPosition(
            target: LatLng(10.3831373, 123.9720752),
            zoom: 15,
          ),
          markers: Set<Marker>.of(markers.values),
        ),
      ];
      
      if(!isDelivering) {
        baseWidgetList.addAll(
          getWidgetsWhenIdle(
            clientAddress: clientAddress,
            onPlaceSearchTapped: () async {
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
            onMakeAListButtonTapped: () {
              Provider.of<PendingTransaction>(context, listen: false).transaction =
                  Transaction(
                    client: Provider.of<CurrentUser>(context, listen: false).client,
                    location: FirebaseTasks.getGeoFlutterPoint(clientLocation),
                    locationName: clientAddress,
                  );
              Navigator.pushNamed(context, GroceryListFormScreen.id);
            },
          ));
      } else {
        double height = MediaQuery.of(context).size.height;
        Transaction transaction = Provider.of<PendingTransaction>(context, listen: false).transaction;
        baseWidgetList.add(
          getWidgetsWhenShopperIsComing(
            height: height,
            transaction: transaction,
            minsAway: minsAway,
            onButtonPressed: () {
              setState(() {
                getClientCurrentLocation();
                shopperComing = false;
                isZoomedAlready = false;
                Provider.of<PendingTransaction>(context, listen: false).transaction = Transaction();
                Provider.of<PendingTransaction>(context, listen: false).transaction.phase = TransactionPhase.idle;
                shoppersStreamSubscription.resume();
              });
            },
          ),
        );
      }
      return baseWidgetList;
    }

    return WillPopScope(
      onWillPop: () {
        SystemChannels.platform.invokeMethod('SystemNavigator.pop');
        return Future.value(true);
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: kDarkerAccentColor,
          leading: IconButton(
            icon: Icon(
              Icons.menu,
              color: Colors.white,
            ),
            onPressed: () {
              //TODO: Open Navigation drawer
            },
          ),
          title: SizedBox(
            height: 20,
            child: kKompraWordLogoWhite,
          ),
          centerTitle: false,
          actions: <Widget>[
            IconButton(
              icon: Icon(
                Icons.more_vert,
                color: Colors.white,
              ),
              onPressed: () {
                //TODO: Do appbar three dots action (temp: sign out currentUser)
                FirebaseTasks.signOut();
                Provider.of<CurrentUser>(context, listen: false).client = null;
                print('Current user: ${Provider.of<CurrentUser>(context, listen: false).client}');
                Navigator.pushNamed(context, WelcomeScreen.id);
              },
            ),
          ],
        ),
        body: SafeArea(
          child: Stack(
            children: getMapScreenWidgets(shopperComing),
          ),
        ),
      ),
    );
  }
}

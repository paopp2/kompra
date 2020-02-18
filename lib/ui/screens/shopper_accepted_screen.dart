import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:kompra/constants.dart';

class ShopperAcceptedScreen extends StatefulWidget {
  static String id = 'mechanic_accepted_screen';
  @override
  _ShopperAcceptedScreenState createState() => _ShopperAcceptedScreenState();
}

class _ShopperAcceptedScreenState extends State<ShopperAcceptedScreen> {
  GoogleMapController mapController;

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: <Widget>[
          GoogleMap(
            onMapCreated: _onMapCreated,
            initialCameraPosition: CameraPosition(
              target: LatLng(10.3831373, 123.9720752),
              zoom: 5,
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 200,
              decoration: BoxDecoration(
                    color: Colors.white,
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
                        backgroundImage: AssetImage('images/temp_blithe_pic.jpg'),
                      ),
                      SizedBox(width: 15,),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            'Blithe Bahoten',
                            style: TextStyle(
                              fontSize: 20,
                            ),
                          ),
                          Text(
                            '09164531565',
                          ),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(height: 30,),
                  Text(
                    '2 mins away',
                    style: TextStyle(
                      fontSize: 20,
                      color: kPrimaryColor,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

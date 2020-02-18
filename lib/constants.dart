import 'package:flutter/material.dart';
import 'package:google_maps_webservice/places.dart';

const Color kPrimaryColor = Colors.green;
final Color kDarkerPrimaryColor = Colors.green[800];
final Color kAccentColor = Colors.blueGrey[700];
final Color kDarkerAccentColor = Colors.blueGrey[800];
const String kGoogleApiKey = 'AIzaSyB03Yont3Ggw2y-Pqf87o_RW4c083oJzqg';
final GoogleMapsPlaces places = GoogleMapsPlaces(apiKey: kGoogleApiKey);
const String kTegaioWordLogoHeroTag = 'tegaio_word_logo';

const Image kKompraWordLogo =
  Image(
    image: AssetImage('images/kompra_word_logo_1.png'),
  );

const Image kKompraWordLogoWhite =
Image(
  image: AssetImage('images/kompra_word_logo_1_white.png'),
);

const Text kSignUpText =
  Text(
    'Sign up',
    style: TextStyle(
        color: Colors.white,
        fontSize: 20
    ),
  );

final Text kLoginText =
  Text(
    'Login',
    style: TextStyle(
      color: kAccentColor,
      fontSize: 20,
    ),
  );

const InputDecoration kDefaultTextFieldFormDecoration =
  InputDecoration(
    hintText: 'Enter a value',
    labelText: 'label',
    hintStyle: TextStyle(
      color: Colors.grey,
    ),
    contentPadding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(32.0)),
    ),
    enabledBorder: OutlineInputBorder(
      borderSide:
      BorderSide(color: kPrimaryColor, width: 1.0),
      borderRadius: BorderRadius.all(Radius.circular(32.0)),
    ),
    disabledBorder: OutlineInputBorder(
      borderSide:
      BorderSide(color: kPrimaryColor, width: 1.0),
      borderRadius: BorderRadius.all(Radius.circular(32.0)),
    ),
    focusedBorder: OutlineInputBorder(
      borderSide:
      BorderSide(color: kPrimaryColor, width: 2.0),
      borderRadius: BorderRadius.all(Radius.circular(32.0)),
    ),
  );

const Border defaultRoundButtonBorder = Border.fromBorderSide(
  BorderSide(
    color: Colors.blueGrey,
    style: BorderStyle.solid,
    width: 1.5,
  ),
);


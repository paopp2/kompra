import 'package:kompra/domain/location.dart';

class Shopper {
  Shopper({
    this.shopperName,
    this.shopperEmail,
    this.shopperPhoneNum,
    this.shopperImageUrl,
    this.location,
  });

  String shopperName;
  String shopperEmail;
  String shopperPhoneNum;
  String shopperImageUrl;
  LatLng location;
}

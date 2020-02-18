import 'package:json_annotation/json_annotation.dart';
import 'package:geolocator/geolocator.dart';
part 'location.g.dart';


class Location {
  Location();

  double latitude;
  double longitude;

  Future<LatLng> getClientCurrentLocation() async{
    try {
      Position position = await Geolocator().getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      return LatLng(
        lat: position.latitude,
        lng: position.longitude,
      );
    } catch(e) {
      print(e);
    }
  }
}

@JsonSerializable()
class LatLng {
  LatLng({
    this.lat,
    this.lng,
  });

  factory LatLng.fromJson(Map<String, dynamic> json) => _$LatLngFromJson(json);
  Map<String, dynamic> toJson() => _$LatLngToJson(this);

  final double lat;
  final double lng;
}
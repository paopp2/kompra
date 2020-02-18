import 'package:kompra/data/google_data.dart';
import 'package:dio/dio.dart';
import 'package:kompra/constants.dart';

class Distance {
  static Future<Map<String, dynamic>> getDistance({double origLat, double origLng, double destLat, double destLng}) async {
    Dio dio = Dio();
    Response response = await dio.get(distanceRequest(
      apiKey: kGoogleApiKey,
      origLat: origLat.toString(),
      origLng: origLng.toString(),
      destLat: destLat.toString(),
      destLng: destLng.toString(),
    ));
    if (response.data != null) {
      var data = response.data;
      Map<String, dynamic> map = Map<String, dynamic>.from(data);
      print(map['rows'][0]['elements'][0]['distance']['text']);
      return map['rows'][0]['elements'][0];
    }
  }
}
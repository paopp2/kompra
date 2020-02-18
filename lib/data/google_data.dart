
String distanceRequest({String origLat, String origLng, String destLat, String destLng, String apiKey}) {
  return 'https://maps.googleapis.com/maps/api/distancematrix/json?units=metric&origins=$origLat,$origLng&destinations=$destLat,$destLng&key=$apiKey';
}
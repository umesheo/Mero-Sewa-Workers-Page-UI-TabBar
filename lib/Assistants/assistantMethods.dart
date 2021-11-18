import 'package:geolocator/geolocator.dart';
import 'package:merosewa_app/Assistants/requestAssistant.dart';

class AssistantMethods {
  //performing geocoding request
  static Future<String> searchCoordinateAddress(Position position) async {
    String placeAddress = "";
    String url =
        "https://maps.googleapis.com/maps/api/geocode/json?latlng=${position.latitude},${position.longitude}&key=AIzaSyDkdp-U3qIWREG4h0CpbApH40ahMNN2_4Q";

    //checking the request
    var response = await RequestAssistant.getRequest(url);

    if (response != "failed") {
      placeAddress = response["results"][0]["formatted_address"];
    }
    return placeAddress;
  }
}

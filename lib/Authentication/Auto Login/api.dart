import 'package:merosewa_app/Authentication/Auto%20Login/shared_pref_helper.dart';
import 'package:shared_preferences/shared_preferences.dart';

//class to assign the auth token
class Api {
  //Assigning a token when the user logs in
  //and storing in a local storage
  static Future<void> loginUser() async {
    String token = "adsadasdad";
    final pref = await SharedPreferencesHelper().setAuthToken(token);
  }

  //clearing the token once the user logs out
  static Future<void> logoutUser() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.clear();
  }
}

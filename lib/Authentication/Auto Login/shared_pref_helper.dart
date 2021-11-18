import 'package:shared_preferences/shared_preferences.dart';

//class to set and access the auth token
class SharedPreferencesHelper {
  //set -> setting data to local storage
  //get -> getting data from lcal storage

  Future<bool> setAuthToken(String token) async {
    //initiliazing shared preferences
    final pref = await SharedPreferences.getInstance();
    //setting the Auth Token to local storage
    return pref.setString(UserPref.AuthToken.toString(), token);
  }

  //getting and returning the auth AuthToken
  Future<String?> getAuthToken() async {
    //initiliazing shared preferences
    final pref = await SharedPreferences.getInstance();
    //getting and returning the Auth Token accessed from the local storage
    return pref.getString(UserPref.AuthToken.toString());
  }

  Future<bool> setUserName(String username) async {
    //initiliazing shared preferences
    final pref = await SharedPreferences.getInstance();
    //setting the user's name to local storage
    return pref.setString('username', username);
  }

  Future<bool> setEmail(String email) async {
    //initiliazing shared preferences
    final pref = await SharedPreferences.getInstance();
    //setting the user's name to local storage
    return pref.setString('email', email);
  }

  Future<bool> setPhotoURL(String photoURL) async {
    //initiliazing shared preferences
    final pref = await SharedPreferences.getInstance();
    //setting the user's name to local storage
    return pref.setString('photoURL', photoURL);
  }

  Future<String?> getUsername() async {
    //initiliazing shared preferences
    final pref = await SharedPreferences.getInstance();
    //getting and returning the user's name accessed from the local storage
    return pref.getString('username');
  }

  Future<String?> getEmail() async {
    //initiliazing shared preferences
    final pref = await SharedPreferences.getInstance();
    //getting returning the the user's email accessed from the local storage
    return pref.getString('email');
  }

  Future<String?> getPhotoURL() async {
    //initiliazing shared preferences
    final pref = await SharedPreferences.getInstance();
    //getting returning the the user's email accessed from the local storage
    return pref.getString('photoURL');
  }
}

enum UserPref {
  AuthToken,
}

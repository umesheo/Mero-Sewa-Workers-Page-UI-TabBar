import 'dart:convert';

import 'package:http/http.dart' as http;

class RequestAssistant {
  static Future<dynamic> getRequest(String url) async {
    http.Response response = await http.get(Uri.parse(url));

    try {
//if request is successful
      if (response.statusCode == 200) {
        //json data
        String jsonData = response.body;

        //decoding json data
        var decodeData = jsonDecode(jsonData);
        return decodeData;
      }
      //if request is not successful
      else {
        return "failed";
      }
    } catch (exception) {
      return "failed";
    }
  }
}

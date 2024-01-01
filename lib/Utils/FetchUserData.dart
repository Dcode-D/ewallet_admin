import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../Models/UserData.dart';
import '../configuration.dart';

class FetchUser {
  static Future<UserData> fetchUserData(String id) async {
    var prefs = await SharedPreferences.getInstance();
    var token = prefs.getString(Configuration.TOKEN_NAME) ?? '';
    final response = await http.get(Uri.parse(Configuration.API_URL+'/admin/get_user/'+'$id'),
      headers: {
        'Authorization': token,
      },);

    if (response.statusCode == 200) {
      // If server returns an OK response, parse the JSON
      return UserData.fromJson(json.decode(response.body));
    } else {
      // If the server did not return a 200 OK response,
      // throw an exception.
      throw Exception('Failed to load user data');
    }
  }
}
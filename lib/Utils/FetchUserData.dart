import 'package:mobile_admin/Models/TransactionData.dart';
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
  static Future<List<TransactionData>> fetchTransactions(String id, DateTime? from, DateTime? to) async {
    var prefs = await SharedPreferences.getInstance();
    var token = prefs.getString(Configuration.TOKEN_NAME) ?? '';
    var url = Configuration.API_URL+'/admin/get_user_transactions/'+'$id';
    if(from != null && to != null){
      url += '?from=${from.toIso8601String()}';
      url += '&to=${to.toIso8601String()}';
    }
    final response = await http.get(Uri.parse(url),
      headers: {
        'Authorization': token,
      },);

    if (response.statusCode == 200) {
      // If server returns an OK response, parse the JSON
      var data = json.decode(response.body);
      List<TransactionData> transactions = [];
      for(var i = 0; i < data.length; i++){
        transactions.add(TransactionData.fromJson(data[i]));
      }
      return transactions;
    } else {
      // If the server did not return a 200 OK response,
      // throw an exception.
      throw Exception('Failed to load user data');
    }
  }
}

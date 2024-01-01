import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:intl/intl.dart';
import 'package:mobile_admin/Models/UserData.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'Utils/FetchUserData.dart';
import 'configuration.dart';

class UserDetailPage extends StatefulWidget {
  final String userId;

  const UserDetailPage({Key? key, required this.userId}) : super(key: key);

  @override
  _UserDetailPageState createState() => _UserDetailPageState();
}

class _UserDetailPageState extends State<UserDetailPage> {
  late UserData _user;
  bool _isLoading = true;
  String _error = '';
  var _fetchUser = FetchUser.fetchUserData;

  void _fetchUserData() {
    setState(() {
      _isLoading = true;
    });

    try {
      _fetchUser(widget.userId).then((value) {
        setState(() {
          _user = value;
          _error = ''; // Clear error if fetching is successful
        });
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> setStatus(bool status) async {
    final prefs = await SharedPreferences.getInstance();
    var token = prefs.getString(Configuration.TOKEN_NAME) ?? '';
    final _url = Configuration.API_URL + '/admin/set_user_status/' +
        '${_user.id}';
    SmartDialog.showLoading(msg: 'Loading...');
    try {
      final response = await http.post(Uri.parse(_url),
        headers: {
          'Authorization': token,
        },
        body: {
          'status': status?'true':'false'
        },
      );
      // print(response.body);
      SmartDialog.dismiss();
      if (response.statusCode == 200) {
        setState(() {
          _user = new UserData(id: _user.id,
              fullName: _user.fullName,
              phoneNumber: _user.phoneNumber,
              identifyID: _user.identifyID,
              birthday: _user.birthday,
              isActive: status,
              city: _user.city,
              job: _user.job);
        });
      }
    } catch (e) {
      SmartDialog.dismiss();
      SmartDialog.showToast(e.toString());
    }
    finally{
      SmartDialog.dismiss();
    }
  }

  Future<void> activateUser() async {
    await setStatus(true);
  }

  Future<void> deactivateUser() async {
    await setStatus(false);
  }

  @override
  void initState() {
    super.initState();
    _isLoading = true;
    _user = UserData(id: 0, fullName:"", phoneNumber: "",identifyID: "",birthday: DateTime.now(), isActive: false,city: "", job: "" ); // Set a default value
    _fetchUserData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('User Details',
            style: TextStyle(color: Theme.of(context).primaryColor,
                fontSize: 25.0, fontWeight: FontWeight.bold)),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Theme.of(context).primaryColor),
          onPressed: () {
            // Handle back button press here
            Navigator.pop(context, _user);
          },
        ),
      ),

      body: _isLoading
          ? _buildLoading()
          : _error.isNotEmpty
          ? _buildError()
          : _buildUserDetails(),
    );
  }

  Widget _buildLoading() {
    return Center(
      child: CircularProgressIndicator(),
    );
  }

  Widget _buildError() {
    return Center(
      child: Text(
        _error,
        style: TextStyle(color: Colors.red),
      ),
    );
  }

  Widget _buildUserDetails() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 16.0),
          _buildDetailRow('ID', _user.id.toString()),
          _buildDetailRow('Full Name', _user.fullName),
          _buildDetailRow('Phone Number', _user.phoneNumber),
          _buildDetailRow('Identification', _user.identifyID),
          _buildDetailRow('Birthday', DateFormat('dd-MM-yyyy').format(_user.birthday)),
          _buildDetailRow('Active', _user.isActive ? 'Yes' : 'No',
              valueColor: _user.isActive ? Colors.green : Colors.red),
          if (_user.city != null) _buildDetailRow('City', _user.city!),
          if (_user.job != null) _buildDetailRow('Job', _user.job!),
          if (_user.isActive)
            Center(
              child: ElevatedButton(
                onPressed: deactivateUser,
                style: ElevatedButton.styleFrom(
                  primary: Colors.red, // Use red for deactivation
                  textStyle: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold, color: Colors.white),
                  padding: EdgeInsets.symmetric(vertical: 16.0, horizontal: 24.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0), // Adjust the value to make it more square
                  ),
                ),
                child: Text(
                  'Deactivate',
                  style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ),
            ),
          if (!_user.isActive)
            Center(
              child: ElevatedButton(
                onPressed: activateUser,
                style: ElevatedButton.styleFrom(
                  primary: Colors.green, // Use green for activation
                  textStyle: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
                  padding: EdgeInsets.symmetric(vertical: 16.0, horizontal: 24.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0), // Adjust the value to make it more square
                  ),
                ),
                child: Text('Activate'),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value,
      {Color? valueColor, double fontSize = 18.0}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 150.0,
            child: Text(
              '$label:',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: fontSize + 2.0, // Increase the font size
                color: Theme.of(context).primaryColor, // Use primary color
              ),
            ),
          ),
          SizedBox(width: 8.0),
          Expanded(
            child: Text(
              value,
              style: TextStyle(fontSize: fontSize, color: valueColor),
            ),
          ),
        ],
      ),
    );
  }
}

import 'dart:async';
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:mobile_admin/configuration.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'UserDetailPage.dart';
import 'Models/UserData.dart';
import 'Utils/FetchUserData.dart';

class UserInfoTags extends StatefulWidget {
  final String id;

  UserInfoTags({required this.id});

  @override
  _UserInfoTagsState createState() => _UserInfoTagsState();
}

class _UserInfoTagsState extends State<UserInfoTags> {
  late StreamController<UserData> _userDataController;
  var fetchUserData = FetchUser.fetchUserData;

  @override
  void initState() {
    super.initState();
    _userDataController = StreamController<UserData>.broadcast();
    _loadUserData();
  }

  @override
  void dispose() {
    _userDataController.close();
    super.dispose();
  }

  void _loadUserData() async {
    try {
      UserData data = await fetchUserData(widget.id);
      _userDataController.add(data);
    } catch (error) {
      print(error);
      // Handle error if needed
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<UserData>(
      stream: _userDataController.stream,
      initialData: null, // Initial data can be set based on your requirements
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          // Loading state
          return Center(
            child: CircularProgressIndicator(),
          );
        } else {
          // Data loaded successfully
          return buildUserInfo(snapshot.data!);
        }
      },
    );
  }

  Widget buildUserInfo(UserData userData) {
    return Card(
      elevation: 4,
      margin: EdgeInsets.all(5),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => UserDetailPage(
                userId: userData.id.toString(),
              ),
            ),
          );
          print(result);
          if (result != null) {
            _loadUserData(); // Reload user data when returning from UserDetailPage
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              buildUserInfoTag('Full Name', userData.fullName),
              buildUserInfoTag('Phone Number', userData.phoneNumber),
              userData.isActive
                  ? buildUserInfoTag('Status', 'Active', color: Colors.green)
                  : buildUserInfoTag('Status', 'Inactive', color: Colors.red),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildUserInfoTag(String label, String value, {Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '$label: ',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              color: color ?? Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}





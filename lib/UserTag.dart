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
  late Future<UserData> userData;
  var fetchUserData = FetchUser.fetchUserData;

  @override
  void initState() {
    super.initState();
    userData = fetchUserData(widget.id);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<UserData>(
      future: userData,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          // Loading state
          return Center(
            child: CircularProgressIndicator(),
          );
        } else if (snapshot.hasError) {
          print(snapshot.error);
          // Error state
          return Center(
            child: Icon(
              Icons.error_outline,
              color: Colors.red,
              size: 60,
            ),
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
              color: color??Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}

class UserInfoTag extends StatelessWidget {
  final String label;
  final String value;

  UserInfoTag({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(value),
          ),
        ],
      ),
    );
    }
}




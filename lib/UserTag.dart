import 'package:flutter/cupertino.dart';

import 'package:flutter/material.dart';

class UserInfoTags extends StatelessWidget {
  final String fullName;
  final String phoneNumber;
  final String identifyID;
  final DateTime birthday;
  final bool isActive;
  final String city;
  final String job;

  UserInfoTags({
    required this.fullName,
    required this.phoneNumber,
    required this.identifyID,
    required this.birthday,
    required this.isActive,
    required this.city,
    required this.job,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemCount: 7, // Number of tags
      itemBuilder: (context, index) {
        return buildUserInfoTag(context, index);
      },
    );
  }

  Widget buildUserInfoTag(BuildContext context, int index) {
    switch (index) {
      case 0:
        return UserInfoTag(label: 'Full Name', value: fullName);
      case 1:
        return UserInfoTag(label: 'Phone Number', value: phoneNumber);
      case 2:
        return UserInfoTag(label: 'Identify ID', value: identifyID);
      case 3:
        return UserInfoTag(label: 'Birthday', value: '${birthday.toLocal()}'); // Format as needed
      case 4:
        return UserInfoTag(label: 'Active', value: isActive ? 'Yes' : 'No');
      case 5:
        return UserInfoTag(label: 'City', value: city ?? 'Not specified');
      case 6:
        return UserInfoTag(label: 'Job', value: job ?? 'Not specified');
      default:
        return SizedBox.shrink();
    }
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
    return InkWell(
      onTap: () {
        // Handle tag tap, e.g., navigate to detail page
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => UserDetailsPage(label: label, value: value),
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '$label: ',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(value),
            Icon(Icons.arrow_forward_ios, size: 16),
          ],
        ),
      ),
    );
  }
}

class UserDetailsPage extends StatelessWidget {
  final String label;
  final String value;

  UserDetailsPage({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(label),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Text(value),
      ),
    );
  }
}
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:mobile_admin/configuration.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.background,
          title: Text('Home Page'),
          bottom: TabBar(
            tabs: [
              Tab(icon: Icon(Icons.people), text: 'Users'),
              Tab(icon: Icon(Icons.logout), text: 'Log Out'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            UsersTab(),
            LogOutTab(),
          ],
        ),
      ),
    );
  }
}

class UsersTab extends StatefulWidget {
  @override
  _UsersTabState createState() => _UsersTabState();
}

class _UsersTabState extends State<UsersTab> {
  List<String> users = [];
  int currentPage = 1;
  bool isError = false;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    // Call the API to fetch users when the tab is first displayed
    fetchUsers();
  }

  Future<void> fetchUsers() async {
    final apiUrl = Configuration.API_URL + "/admin/get_all_users/" + currentPage.toString();
    final prefs = await SharedPreferences.getInstance();
    var token = prefs.getString(Configuration.TOKEN_NAME) ?? '';
    try {
      setState(() {
        isLoading = true;
        isError = false;
      });

      final response = await http.get(
        Uri.parse(apiUrl),
        headers: {
          'Authorization': token,
        },
      );

      if (response.statusCode == 200) {
        // Parse the response and update the users list
        final List<dynamic> data = jsonDecode(response.body);
        setState(() {
          for (var user in data) {
            print(user);
            users.add(user['id'].toString());
          }
          currentPage++; // Increment page for next fetch
        });
      } else {
        // Handle error
        print('Failed to fetch users. Status code: ${response.body}');
        setState(() {
          isError = true;
        });
      }
    } catch (error) {
      // Handle network or other errors
      print('Error fetching users: $error');
      setState(() {
        isError = true;
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isError) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error,
              color: Colors.red,
              size: 48.0,
            ),
            SizedBox(height: 16.0),
            Text(
              'Error fetching users',
              style: TextStyle(color: Colors.red),
            ),
          ],
        ),
      );
    }

    return NotificationListener<ScrollEndNotification>(
      onNotification: (notification) {
        // Fetch more users when reaching the end of the list
        if (notification.metrics.pixels == notification.metrics.maxScrollExtent) {
          fetchUsers();
        }
        return true;
      },
      child: ListView.builder(
        itemCount: users.length + (isLoading ? 1 : 0), // +1 for loading indicator
        itemBuilder: (context, index) {
          if (index < users.length) {
            return ListTile(
              title: Text(users[index]),
            );
          } else {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
        },
      ),
    );
  }
}


class LogOutTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: ElevatedButton(
        onPressed: () {
          // Add your log-out logic here
          // For simplicity, it's not implemented in this example
        },
        child: Text('Log Out'),
      ),
    );
  }
}
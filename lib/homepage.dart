import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'UserTag.dart';
import 'configuration.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentPageIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _currentPageIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _buildBody(),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentPageIndex,
        onTap: _onItemTapped,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.people),
            label: 'Users',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.logout),
            label: 'Log Out',
          ),
        ],
      ),
    );
  }


  Widget _buildBody() {
    switch (_currentPageIndex) {
      case 0:
        return UsersTab();
      case 1:
        return LogOutTab();
      default:
        return Container();
    }
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
  TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  bool _isSearching = false;



  @override
  void initState() {
    super.initState();
    // Call the API to fetch users when the tab is first displayed
    fetchUsers();
    // _searchController.addListener(() {updateSearchQuery(_searchController.text);});
  }

  Future<void> fetchUsers() async {
    var apiUrl =
        Configuration.API_URL + "/admin/get_all_users/" + currentPage.toString();
    if(_searchQuery.isNotEmpty){
      apiUrl += '?name=$_searchQuery';
      apiUrl += '&phone=$_searchQuery';
      apiUrl += '&id=$_searchQuery';
    }
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
    return Scaffold(
        appBar: AppBar(
          leading: _isSearching ?  BackButton(
            onPressed: (){
              // if (_searchController == null ||
              //     _searchController.text.isEmpty) {
              //   Navigator.pop(context);
              //   return;
              // }
              setState(() {
                _isSearching = false;
              });
              fetchUsers();
            },
            ) : Icon(Icons.man,color: Theme.of(context).primaryColor,),
          title: _isSearching ? _buildSearchField() : Text('Users',
            style: TextStyle(
                color: Theme.of(context).primaryColor,
                fontWeight: FontWeight.bold,
                fontSize: 25),),
          actions: _buildActions(),
        ),
      body: _buildBody(),
    );
  }

  Widget _buildSearchField() {
    return TextField(
      controller: _searchController,
      autofocus: true,
      decoration: InputDecoration(
        hintText: "Search Data...",
        border: InputBorder.none,
      ),
      style: TextStyle(fontSize: 16.0),
      onChanged: (query) {
        updateSearchQuery(query);
        fetchUsers();
        },
    );
  }

  List<Widget> _buildActions() {
    if (_isSearching) {
      return <Widget>[
        IconButton(
          icon: const Icon(Icons.clear),
          onPressed: () {
            // if (_searchController == null ||
            //     _searchController.text.isEmpty) {
            //   Navigator.pop(context);
            //   return;
            // }
            setState(() {
              _isSearching = false;
            });
            _clearSearchQuery();
            fetchUsers();
          },
        ),
      ];
    }

    return <Widget>[
      IconButton(
        icon: const Icon(Icons.search),
        onPressed: _startSearch,
      ),
    ];
  }

  void _startSearch() {
    ModalRoute.of(context)
        ?.addLocalHistoryEntry(LocalHistoryEntry(onRemove: _stopSearching));

    setState(() {
      _isSearching = true;
    });
  }

  void updateSearchQuery(String newQuery) {
    setState(() {
      currentPage = 1;
      users.clear();
      _searchQuery = newQuery;
    });
  }

  void _stopSearching() {
    _clearSearchQuery();

    setState(() {
      _isSearching = false;
    });
  }

  void _clearSearchQuery() {
    setState(() {
      _searchController.clear();
      updateSearchQuery("");
    });
  }

  Widget _buildBody() {
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
        if (notification.metrics.pixels ==
            notification.metrics.maxScrollExtent) {
          fetchUsers();
        }
        return true;
      },
      child: ListView.builder(
        itemCount: users.length + (isLoading ? 1 : 0), // +1 for loading indicator
        itemBuilder: (context, index) {
          if (index < users.length) {
            return UserInfoTags(id: users[index]);
          } else {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
        },
      ),
    );
  }

  void _showSearchBar() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Search Users'),
          content: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Enter user name',
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _searchQuery = _searchController.text;
                // Perform search logic here based on _searchQuery
                // You can filter your users list using the search query
                // For simplicity, let's print the search query
                print('Search Query: $_searchQuery');
              },
              child: Text('Search'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
          ],
        );
      },
    );
  }
}


class LogOutTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: ElevatedButton(
        onPressed: () async{
          // Add your log-out logic here
          // For simplicity, it's not implemented in this example
          final prefs = await SharedPreferences.getInstance();
          prefs.remove(Configuration.TOKEN_NAME);
          Navigator.pushReplacementNamed(context, '/login');
        },
        child: Text('Log Out'),
      ),
    );
  }
}

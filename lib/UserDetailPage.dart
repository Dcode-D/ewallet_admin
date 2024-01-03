import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:intl/intl.dart';
import 'package:mobile_admin/Models/TransactionData.dart';
import 'package:mobile_admin/Models/UserData.dart';
import 'package:mobile_admin/Utils/DrawTransactionCharts.dart';
import 'package:mobile_admin/Utils/ShowTransactionDialog.dart';
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
  bool _isFetchingTrans = false;
  bool _isErrorTrans = false;
  var transactionList = List<TransactionData>.empty(growable: true);
  var _fetchUser = FetchUser.fetchUserData;
  var _fetchTransactions = FetchUser.fetchTransactions;
  DateTime startDate = DateTime.now().subtract(Duration(days: 30));
  DateTime endDate = DateTime.now();

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

  void _fetchUserTransactions(){
    setState(() {
      transactionList = [];
      _isFetchingTrans = true;
    });

    try {
      _fetchTransactions(widget.userId,startDate,endDate).then((value) {
        for(var i = 0; i < value.length; i++){
          transactionList.add(value[i]);
        }
        setState(() {
          transactionList = transactionList.reversed.toList();
          _isErrorTrans = false; // Clear error if fetching is successful
        });
      });
    } catch (e) {
      setState(() {
        _isErrorTrans = true;
      });
    } finally {
      setState(() {
        _isFetchingTrans = false;
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
    _fetchUserTransactions();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
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
          bottom: PreferredSize(
            preferredSize: Size.fromHeight(50.0),
            child: Container(
              child: TabBar(
                tabs: [
                  Tab(text: 'User Info'),
                  Tab(text: 'Transactions'),
                ],
              ),
            ),
          )
        ),

        body: TabBarView(children: [_isLoading
            ? _buildLoading()
            : _error.isNotEmpty
            ? _buildError()
            : _buildUserDetails(),
          _buildTransactionTab()
        ],)
          ,
      ),
    );
  }
  Widget _buildTransactionTab(){
    if(_isFetchingTrans){
      return _buildLoading();
    }
    else if(_isErrorTrans){
      return _buildError();
    }
    else{
      return _buildTransactionList();
    }
}
  Widget _buildDateFilter() {
    return Padding(
      padding: const EdgeInsets.all(3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildDateFilterButton(
            label: "Start Date",
            date: startDate,
            onPressed: () => _selectStartDate(context),
            icon: Icons.calendar_today,
          ),
          _buildDateFilterButton(
            label: "End Date",
            date: endDate,
            onPressed: () => _selectEndDate(context),
            icon: Icons.calendar_today,
          ),
      ElevatedButton(
        onPressed: () {
          // Call your function with selected start and end dates
          _fetchUserTransactions();
        },
        child: Text("Apply Filter"),
      ),
        ],
      )
    );
  }

  Widget _buildDateFilterButton({
    required String label,
    required DateTime date,
    required VoidCallback onPressed,
    required IconData icon,
  }) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon),
      label: Text(
        "$label: ${date.toLocal()}".split(' ')[0],
        style: TextStyle(fontSize: 14),
      ),
      style: ElevatedButton.styleFrom(
        primary: Theme.of(context).primaryColor,
        onPrimary: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.0),
        ),
      ),
    );
  }

  Future<void> _selectStartDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != startDate) {
      setState(() {
        startDate = picked;
      });
    }
  }

  Future<void> _selectEndDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != endDate) {
      setState(() {
        endDate = picked;
      });
    }
  }

  Widget _buildTotalMoney() {
    double totalMoneyIn = 0;
    double totalMoneyOut = 0;

    // Calculate total money in and total money out based on your transactionList
    for (TransactionData transaction in transactionList) {
      // Convert both type and transaction types to lowercase for case-insensitive comparison
      String transactionType = transaction.type?.toLowerCase() ?? '';

      if(transaction.status?.toLowerCase() != 'success'){
        continue;
      }
      if (transactionType == 'deposit' || transactionType == 'transfer_transaction') {
        // Check if 'To' is equal to _user.id (case-insensitive)
        if (transactionType == 'transfer_transaction' &&
            transaction.to_User?.toLowerCase() != _user.id) {
          continue; // Skip this transaction if 'To' is not equal to _user.id
        }

        totalMoneyIn += transaction.amount ?? 0;
      } else {
        totalMoneyOut += transaction.amount != null ? transaction.amount!.abs() : 0;
      }
    }
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total Money In:',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.green, // Adjust color as needed
                ),
              ),
              Text(
                NumberFormat.currency(locale: 'vi', symbol: '₫').format(totalMoneyIn),
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.green, // Adjust color as needed
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total Money Out:',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.red, // Adjust color as needed
                ),
              ),
              Text(
                NumberFormat.currency(locale: 'vi', symbol: '₫').format(totalMoneyOut),
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.red, // Adjust color as needed
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }


    Widget _buildTransactionList() {
    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          _buildDateFilter(),
          _buildTotalMoney(),
          TabBar(
            tabs: [
              Tab(text: 'All'),
              Tab(text: 'Diagram'),
            ],
          ),
          Expanded(
            child: TabBarView(
              children: [
                ListView.builder(
                  itemCount: transactionList.length,
                  itemBuilder: (context, index) {
                    final transaction = transactionList[index];
                    Color statusColor = Colors.black;

                    // Set active colors based on transaction status
                    if (transaction.status?.toLowerCase() == 'success') {
                      statusColor = Colors.green;
                    } else if (transaction.status?.toLowerCase() == 'pending') {
                      statusColor = Colors.orange;
                    } else if (transaction.status?.toLowerCase() == 'failed') {
                      statusColor = Colors.red;
                    }

                    Color typeColor = Colors.black;

                    // Customize colors based on transaction type
                    if (transaction.type?.toLowerCase() == 'deposit'|| transaction.type?.toLowerCase() == 'transfer_transaction') {
                      typeColor = Colors.green;
                    } else {
                      typeColor = Colors.red;
                    }

                    return InkWell(
                      onTap: () {
                        ShowTransactionDialog.showTransactionDetailsDialog(transaction, context);
                      },
                      child: Card(
                        elevation: 5,
                        margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: ListTile(
                          contentPadding: EdgeInsets.all(16),
                          leading: CircleAvatar(
                            backgroundColor: statusColor,
                            child: Text(transaction.id.toString(), style: TextStyle(color: Colors.white)),
                          ),
                          title: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'From: ${transaction.from_User}',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              Text(
                                'To: ${transaction.to_User}',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              Text(
                                'Type: ${transaction.type}',
                                style: TextStyle(fontWeight: FontWeight.bold, color: typeColor),
                              ),
                              Text(
                                'Status: ${transaction.status}',
                                style: TextStyle(fontWeight: FontWeight.bold, color: statusColor),
                              ),
                            ],
                          ),
                          subtitle: Text(
                            transaction.time != null ?
                            DateFormat('dd-MM-yyyy').format(transaction.time!):"",
                            style: TextStyle(fontSize: 12),
                          ),
                          trailing: Text(
                            '${NumberFormat.currency(locale: 'vi', symbol: '₫').format(transaction.amount)}',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: transaction.type == 'Deposit' ? Colors.green : Colors.red,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),

                DrawCharts.drawMoneyFlowChart(transactionList, _user.id.toString()),
              ],
            ),
          ),
        ],
      ),
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

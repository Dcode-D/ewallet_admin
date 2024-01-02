import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../Models/TransactionData.dart';

class ShowTransactionDialog {
  static void showTransactionDetailsDialog(TransactionData transaction, BuildContext context  ) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          elevation: 5,
          child: _buildTransactionDetailsDialogContent(transaction, context),
        );
      },
    );
  }

  static Widget _buildTransactionDetailsDialogContent(TransactionData transaction, BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Transaction ID: ${transaction.id}',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          Text('From: ${transaction.from_User}'),
          Text('To: ${transaction.to_User}'),
          Text('Type: ${transaction.type}', style: TextStyle(color: _getTypeColor(transaction.type??""))),
          Text('Status: ${transaction.status}', style: TextStyle(color: _getStatusColor(transaction.status??""))),
          Text('Date: ${transaction.time!=null? DateFormat('dd-MM-yyyy').format(transaction.time!):""}'),
          Text(
            'Amount: ${NumberFormat.currency(locale: 'vi', symbol: '₫').format(transaction.amount)}',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: transaction.type == 'Deposit' ? Colors.green : Colors.red,
            ),
          ),
          if (transaction.message != null) ...[
            SizedBox(height: 16),
            Text('Message: ${transaction.message}', style: TextStyle(fontStyle: FontStyle.italic)),
          ],
          SizedBox(height: 16),
          Align(
            alignment: Alignment.center,
            child: ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text('Close'),
            ),
          ),
        ],
      ),
    );
  }

  static Color _getTypeColor(String type) {
    return type == 'Deposit' ? Colors.green : Colors.red;
  }

  static Color _getStatusColor(String status) {
    if (status == 'Success') {
      return Colors.green;
    } else if (status == 'Pending') {
      return Colors.orange;
    } else if (status == 'Failed') {
      return Colors.red;
    } else {
      return Colors.black;
    }
  }

}
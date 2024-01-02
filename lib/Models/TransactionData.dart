import 'dart:ffi';

class TransactionData {
  int? id;
  String? type;
  double? amount;
  DateTime? time;
  String? status;
  String? message;
  String? from_User;
  String? to_User;

  TransactionData({
    this.id,
    this.type,
    this.amount,
    this.time,
    this.status,
    this.message,
    this.from_User,
    this.to_User,
  });

  factory TransactionData.fromJson(Map<String, dynamic> json) {
    return TransactionData(
      id: json['id'] ?? '',
      type: json['type'] ?? '',
      amount: double.parse(json['amount'].toString()),
      time: DateTime.parse(json['time']),
      status: json['status'] ?? '',
      message: json['message'] ?? '',
      from_User: json['from_User'] ?? '',
      to_User: json['to_User'] ?? '',
    );
  }

}
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../Models/TransactionData.dart';

class DrawCharts{
  static Widget drawMoneyFlowChart(List<TransactionData> transactionList, String currentId) {
    // Filter out unsuccessful transactions and sort by time
    List<TransactionData> successfulTransactions = transactionList
        .where((transaction) => transaction.status?.toLowerCase() == 'success')
        .toList()
      ..sort((a, b) => a.time!.compareTo(b.time!));

    // Extract time and amount data for money in and money out
    List<FlSpot> moneyInSpots = successfulTransactions
        .where((transaction) =>
    transaction.type?.toLowerCase() == 'deposit' ||
        transaction.type?.toLowerCase() == 'transfer_transaction'&& transaction.to_User == currentId.toString())
        .map((transaction) => FlSpot(
        transaction.time!.millisecondsSinceEpoch.toDouble(),
        transaction.amount ?? 0))
        .toList();

    List<FlSpot> moneyOutSpots = successfulTransactions
        .where((transaction) =>
    !(transaction.type?.toLowerCase() == 'deposit' ||
        (transaction.type?.toLowerCase() == 'transfer_transaction' &&
            transaction.to_User == currentId.toString())) ||
        !moneyInSpots.contains(FlSpot(
            transaction.time!.millisecondsSinceEpoch.toDouble(),
            transaction.amount ?? 0)))
        .map((transaction) => FlSpot(
        transaction.time!.millisecondsSinceEpoch.toDouble(),
        (transaction.amount ?? 0)))
        .toList();
    print("money out:");
    print(moneyOutSpots);

    return Padding(
      padding: const EdgeInsets.all(20),
      child: LineChart(
        LineChartData(
          gridData: FlGridData(show: false),
          titlesData: FlTitlesData(show: false),
          borderData: FlBorderData(
            show: true,
            border: Border.all(color: const Color(0xff37434d), width: 1),
          ),
          minX: successfulTransactions.isNotEmpty
              ? successfulTransactions.first.time!.millisecondsSinceEpoch.toDouble()
              : 0,
          maxX: successfulTransactions.isNotEmpty
              ? successfulTransactions.last.time!.millisecondsSinceEpoch.toDouble()
              : 1,
          minY: 0,
          maxY: calculateMaxY([...moneyInSpots, ...moneyOutSpots]),
          lineBarsData: [
            LineChartBarData(
              spots: moneyInSpots,
              isCurved: true,
              color: Colors.blue,
              belowBarData: BarAreaData(show: false),
              dotData: FlDotData(show: false),
            ),
            LineChartBarData(
              spots: moneyOutSpots,
              isCurved: true,
              color: Colors.red,
              belowBarData: BarAreaData(show: false),
              dotData: FlDotData(show: false),
            ),
          ],
        ),
      ),
    );
  }

  static double calculateMaxY(List<FlSpot> spots) {
    double maxY = 0;
    for (var spot in spots) {
      if (spot.y > maxY) {
        maxY = spot.y;
      }
    }
    return maxY;
  }
}
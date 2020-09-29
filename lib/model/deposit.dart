import 'dart:math';

import '../model/deposit_status.dart';
import 'package:uuid/uuid.dart';

class Deposit {
  final String depositAddress;
  final String keepAddress;
  final String transactionHash;
  final DateTime transactionDateTime;
  final double amount;
  final DepositStatus status;
  final int requiredConfirmations;
  final int confirmations;
  final String btcTransactionHash;

  Deposit(
      this.depositAddress,
      this.keepAddress,
      this.transactionHash,
      this.transactionDateTime,
      this.amount,
      this.status,
      this.requiredConfirmations,
      this.confirmations,
      this.btcTransactionHash);

  factory Deposit.fromJson(Map<String, dynamic> json) {
    return Deposit(
        json['depositAddress'],
        json['keepAddress'],
        json['txHash'],
        DateTime.fromMillisecondsSinceEpoch(json['timestamp'] * 1000),
        json['BTCamount'].toDouble(),
        DepositStatusParser.fromString(json['state']),
        json['requiredConfirmations'],
        json['nowConfirmations'],
        json['btcTransactionID']);
  }
}

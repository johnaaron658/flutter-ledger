
import 'package:ledger/models/account.dart';

class Transaction {
  int? id;
  final double value;
  final Account debit;
  final Account credit;
  final DateTime dateTime;
  final String details;

  Transaction({
    this.id,
    required this.value,
    required this.debit,
    required this.credit,
    required this.dateTime,
    required this.details
  });
}
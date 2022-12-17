import 'package:ledger/models/transaction.dart';
import 'package:rxdart/rxdart.dart';

import 'mock_data_src.dart';

class TransactionsRepo {
  final _transactions = BehaviorSubject<List<Transaction>>.seeded(List.empty());

  TransactionsRepo() {
    getAllTransactions();
  }

  ValueStream<List<Transaction>> get transactionStream => _transactions.stream;

  void getAllTransactions() async {
    _transactions.add(DataSource.transactions);
  }

  void addTransaction(Transaction transaction) async {
    DataSource.transactions.add(transaction);
    _transactions.add(DataSource.transactions);
  }

  void removeTransaction(int id) async {
    DataSource.transactions.removeWhere((element) => element.id == id);
    _transactions.add(DataSource.transactions);
  }
}

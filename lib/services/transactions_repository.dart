import 'dart:core';

import 'package:get_it/get_it.dart';
import 'package:ledger/services/accounts_repository.dart';
import 'package:ledger/services/app_database.dart';
import 'package:rxdart/rxdart.dart';
import 'package:sqflite/sqflite.dart';

class Transaction {
  static const String tbTransactions = 'transactions';
  static const String colId = 'id';
  static const String colAmount = 'amount';
  static const String colDebit = 'debit';
  static const String colCredit = 'credit';
  static const String colDateTime = 'datetime';
  static const String colDetails = 'details';
  static const String createTableSql = '''
                              CREATE TABLE IF NOT EXISTS ${Transaction.tbTransactions} ( 
                                ${Transaction.colId} INTEGER PRIMARY KEY AUTOINCREMENT, 
                                ${Transaction.colAmount} REAL,
                                ${Transaction.colDebit} INTEGER,
                                ${Transaction.colCredit} INTEGER,
                                ${Transaction.colDateTime} DATETIME,
                                ${Transaction.colDetails} STRING,
                                FOREIGN KEY (${Transaction.colDebit}) REFERENCES ${Account.tbAccounts} (${Account.colId}),
                                FOREIGN KEY (${Transaction.colCredit}) REFERENCES ${Account.tbAccounts} (${Account.colId})
                              );
                              ''';
  static const String queryTableSql =  '''
                              SELECT 
                              t.${Transaction.colId},
                              t.${Transaction.colAmount},
                              t.${Transaction.colDateTime},
                              t.${Transaction.colDetails},

                              da.${Account.colId} AS ${Transaction.colDebit}${Account.colId},
                              da.${Account.colBalance} AS ${Transaction.colDebit}${Account.colBalance},
                              da.${Account.colName} AS ${Transaction.colDebit}${Account.colName},
                              da.${Account.colCurrency} AS ${Transaction.colDebit}${Account.colCurrency},
                              da.${Account.colAccountType} AS ${Transaction.colDebit}${Account.colAccountType},
                              da.${Account.colLimit} AS ${Transaction.colDebit}${Account.colLimit},

                              ca.${Account.colId} AS ${Transaction.colCredit}${Account.colId},
                              ca.${Account.colBalance} AS ${Transaction.colCredit}${Account.colBalance},
                              ca.${Account.colName} AS ${Transaction.colCredit}${Account.colName},
                              ca.${Account.colCurrency} AS ${Transaction.colCredit}${Account.colCurrency},
                              ca.${Account.colAccountType} AS ${Transaction.colCredit}${Account.colAccountType},
                              ca.${Account.colLimit} AS ${Transaction.colCredit}${Account.colLimit}

                              from ${Transaction.tbTransactions} t
                              inner join ${Account.tbAccounts} da on t.${Transaction.colDebit} = da.${Account.colId}
                              inner join ${Account.tbAccounts} ca on t.${Transaction.colCredit} = ca.${Account.colId}
                              ORDER BY ${Transaction.colDateTime} ASC;
                              ''';

  late int id;
  late double amount;
  late Account debit;
  late Account credit;
  late DateTime dateTime;
  late String details;

  Account get accountFrom => credit;
  set accountFrom(value) => credit = value;
  Account get accountTo => debit;
  set accountTo(value) => debit = value;
  DateTime get date => dateTime;
  set date(value) => dateTime = value;

  Transaction() {
    amount = 0;
    debit = Account();
    credit = Account();
    dateTime = DateTime.now();
    details = '';
  }

  Transaction.fromFields(this.id, this.amount, this.debit, this.credit, this.dateTime, this.details);
  Transaction.fromValues(this.amount, this.debit, this.credit, this.dateTime, this.details);
  Transaction.fromMap(Map<String, Object?> map) {
    id = (map[colId] ?? 0) as int;
    amount = map[colAmount] as double;
    debit = Account.fromMap(map, colDebit);
    credit = Account.fromMap(map, colCredit);
    dateTime = DateTime.parse(map[colDateTime] as String);
    details = map[colDetails] as String;
  }

  Map<String, Object?> toMap() {
    return {
      colAmount: amount,
      colDebit: debit.id,
      colCredit: credit.id,
      colDateTime: dateTime.toString(),
      colDetails: details,
    };
  }
}


class TransactionsRepo {
  final _transactions = BehaviorSubject<List<Transaction>>.seeded(List.empty());
  final accountRepo = GetIt.instance.get<AccountsRepo>();

  ValueStream<List<Transaction>> get transactionStream => _transactions.stream;

  Future refreshTransactionList() async {
    Database db = await AppDatabase.instance.db;
    _transactions.add(await db.rawQuery(Transaction.queryTableSql)
                              .then((value) => value.map((e) => Transaction.fromMap(e)).toList()));
  }

  // for testing sql
  Future printSql() async {
    Database db = await AppDatabase.instance.db;
    print('printing values ----------------------');
    await db.rawQuery(Transaction.queryTableSql)
                              .then((value) => print(value));
  }

  Future addTransaction(Transaction transaction) async {
    Account? debitAccount = accountRepo.getAccountWithName(transaction.debit.name);
    Account? creditAccount = accountRepo.getAccountWithName(transaction.credit.name);
    if (debitAccount == null) {
      await accountRepo.addAccount(transaction.debit);
    }
    if (creditAccount == null) {
      await accountRepo.addAccount(transaction.credit);
    }
    transaction.debit.balance += transaction.amount;
    transaction.credit.balance -= transaction.amount;

    Database db = await AppDatabase.instance.db;
    transaction.id = await db.insert(Transaction.tbTransactions, transaction.toMap());

    // TODO: add updating account balances
    await refreshTransactionList();
  }

  void removeTransaction(int id) async {
    Database db = await AppDatabase.instance.db;
    await db.delete(Transaction.tbTransactions, where: '${Transaction.colId} = ?', whereArgs: [id]);

    // TODO: add updating account balances
    await refreshTransactionList();
  }

  Future updateTransaction(Transaction transaction) async {
    Database db = await AppDatabase.instance.db;
    await db.update(Transaction.tbTransactions, transaction.toMap(), where: '${Transaction.colId} = ?', whereArgs: [transaction.id]);

    // TODO: add updating account balances
    await refreshTransactionList();
  }
}

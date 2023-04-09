
import 'package:ledger/services/app_database.dart';
import 'package:rxdart/rxdart.dart';
import 'package:sqflite/sqflite.dart';

class Account {
  static const String tbAccounts = 'accounts';
  static const String colId = 'id';
  static const String colBalance = 'balance';
  static const String colName = 'name';
  static const String colCurrency = 'currency';
  static const String colAccountType = 'accountType';
  static const String colLimit = 'accountLimit';
  static const String createTableSql = '''
                              CREATE TABLE IF NOT EXISTS ${Account.tbAccounts} ( 
                                ${Account.colId} INTEGER PRIMARY KEY AUTOINCREMENT, 
                                ${Account.colBalance} REAL,
                                ${Account.colName} TEXT,
                                ${Account.colCurrency} TEXT,
                                ${Account.colAccountType} INTEGER,
                                ${Account.colLimit} REAL
                              );
                              ''';
  static const String defaultCurrency = 'PHP';
  static const AccountType defaultAccountType = AccountType.Asset;

  late int id;
  late double balance;
  late String name;
  late String currency;
  late AccountType accountType;
  late double limit;

  Account() {
    balance = 0;
    name = '';
    currency = Account.defaultCurrency;
    accountType = Account.defaultAccountType;
    limit = 0;
  }

  Account.fromName(this.name) {
    balance = 0;
    currency = Account.defaultCurrency;
    accountType = Account.defaultAccountType;
    limit = 0;
  }

  Account.fromFields(this.id, 
      this.balance, this.name, this.currency, this.accountType, this.limit,);

  Account.fromMap(Map<String, Object?> map, String key) {
    id = map[key + colId] as int;
    balance = map[key + colBalance] as double;
    name = map[key + colName] as String;
    currency = map[key + colCurrency] as String;
    accountType = intToAccountType(map[key + colAccountType] as int);
    limit = map[key + colLimit] as double;
  }

  Map<String, Object?> toMap() {
    return {
      colBalance: balance,
      colName: name,
      colCurrency: currency,
      colAccountType: accountTypeToInt(accountType),
      colLimit: limit,
    };
  }

  AccountType intToAccountType(int type) {
    switch (type) {
      case 0:
        return AccountType.Asset;
      case 1:
        return AccountType.Liability;
      case 2:
        return AccountType.Expense;
      case 3:
        return AccountType.Income;
      case 4:
        return AccountType.Equity;
      default:
        return AccountType.Asset;
    }
  }

  int accountTypeToInt(AccountType type) {
    switch (type) {
      case AccountType.Asset:
        return 0;
      case AccountType.Liability:
        return 1;
      case AccountType.Expense:
        return 2;
      case AccountType.Income:
        return 3;
      case AccountType.Equity:
        return 4;
      default:
        return 0;
    }
  }
}

enum AccountType {
  Asset,
  Liability,
  Expense,
  Income,
  Equity,
}

class AccountsRepo {
  final _accounts = BehaviorSubject<List<Account>>.seeded(List.empty());

  ValueStream<List<Account>> get accountStream => _accounts.stream;

  Future refreshAccountList() async {
    Database db = await AppDatabase.instance.db;
    _accounts.add(await db.query(Account.tbAccounts)
                          .then((res) => res.map((e) => Account.fromMap(e, '')).toList()));
  }

  Future addAccount(Account account) async {
    Database db = await AppDatabase.instance.db;
    account.id = await db!.insert(Account.tbAccounts, account.toMap());
    await refreshAccountList();
  }

  Account? getAccountWithName(String name) {
    List<Account> result = _accounts.value.where((element) => element.name == name).toList();
    
    return result.isEmpty ? null : result.first;
  }
}
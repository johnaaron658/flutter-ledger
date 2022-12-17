
import '../models/account.dart';
import '../models/transaction.dart';

class DataSource {
  static List<Account> accounts = [
    Account(
        id: 1,
        balance: 1000,
        name: 'BPI',
        currency: 'PHP',
        accountType: AccountType.Asset,
        subAccounts: List.empty(),
        limit: 0),
    Account(
        id: 2,
        balance: 1500,
        name: 'BDO',
        currency: 'PHP',
        accountType: AccountType.Asset,
        subAccounts: List.empty(),
        limit: 0),
    Account(
        id: 3,
        balance: 200,
        name: 'Cash',
        currency: 'PHP',
        accountType: AccountType.Asset,
        subAccounts: List.empty(),
        limit: 0),
    Account(
        id: 4,
        balance: 200,
        name: 'Daily',
        currency: 'PHP',
        accountType: AccountType.Expense,
        subAccounts: List.empty(),
        limit: 1000),
    Account(
        id: 5,
        balance: 200,
        name: 'Daily',
        currency: 'PHP',
        accountType: AccountType.Expense,
        subAccounts: List.empty(),
        limit: 1000),
    Account(
        id: 6,
        balance: 200,
        name: 'Salary',
        currency: 'PHP',
        accountType: AccountType.Income,
        subAccounts: List.empty(),
        limit: 0),
  ];

  static List<Transaction> transactions = [
    Transaction(
        id: 1,
        value: 100,
        credit: accounts[0],
        debit: accounts[1],
        dateTime: DateTime.now(),
        details: 'Transfer Sample 1'),
    Transaction(
        id: 2,
        value: 100,
        credit: accounts[0],
        debit: accounts[1],
        dateTime: DateTime.now(),
        details: 'Transfer Sample 2'),
  ];
}
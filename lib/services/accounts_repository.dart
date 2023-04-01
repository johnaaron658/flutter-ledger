
import 'package:ledger/models/account.dart';
import 'package:rxdart/rxdart.dart';

import 'mock_data_src.dart';

class AccountsRepo {
  final _accounts = BehaviorSubject<List<Account>>.seeded(List.empty());

  ValueStream<List<Account>> get accountStream => _accounts.stream;

  void getAllAccounts() async {
    _accounts.add(DataSource.accounts);
  }

  void addAccount(Account account) async {
    DataSource.accounts.add(account);
    _accounts.add(DataSource.accounts);
  }

  Account? getAccountWithName(String name) {
    return DataSource.accounts.where((element) => element.name == name).first;
  }

  void removeAccount(int id) async {
    DataSource.accounts.removeWhere(((element) => element.id == id));
    _accounts.add(DataSource.accounts);
  }
}
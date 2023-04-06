import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:ledger/pages/main_page.dart';
import 'package:ledger/services/accounts_repository.dart';
import 'package:ledger/services/transactions_repository.dart';

void main() {
  GetIt.instance.registerSingleton<MainPageState>(MainPageState());
  GetIt.instance.registerSingleton<AccountsRepo>(AccountsRepo());
  GetIt.instance.registerSingleton<TransactionsRepo>(TransactionsRepo());
  runApp(const LedgerApp());
}

class LedgerApp extends StatelessWidget {
  const LedgerApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Ledger',
      theme: ThemeData(
        primarySwatch: Colors.blueGrey,
      ),
      home: const MainPage(),
    );
  }
}


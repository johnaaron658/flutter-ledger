import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:ledger/components/transaction_list_item.dart';
import 'package:ledger/models/transaction.dart';
import 'package:ledger/services/transactions_repository.dart';

class TransactionList extends StatelessWidget {
  final Function transactionQuery;
  late final StreamSubscription transactionStreamSub;

  TransactionList({
    Key? key,
    required this.transactionQuery,
  }) : super(key: key) {
    transactionStreamSub = transactionRepo.transactionStream.listen((event) {
      scrollControl.animateTo(scrollControl.position.maxScrollExtent,
          duration: const Duration(milliseconds: 500),
          curve: Curves.fastOutSlowIn);
    });
  }

  final transactionRepo = GetIt.instance.get<TransactionsRepo>();
  final scrollControl = ScrollController();

  @override
  Widget build(BuildContext context) {
    transactionQuery();
    return StreamBuilder<List<Transaction>>(
      stream: transactionRepo.transactionStream,
      builder: (context, snapshot) {
        final transactions = snapshot.data;
        if (transactions != null && transactions.isNotEmpty) {
          return ListView.separated(
            controller: scrollControl,
            separatorBuilder: (context, index) => const Divider(),
            scrollDirection: Axis.vertical,
            addAutomaticKeepAlives: true,
            itemCount: transactions.length,
            itemBuilder: (context, index) => TransactionItem(
              transaction: transactions[index],
            ),
          );
        }
        return const Text('There are no transactions');
      },
    );
  }
}

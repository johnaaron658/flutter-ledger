import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:ledger/models/transaction.dart';
import 'package:ledger/pages/main_page.dart';
import 'package:ledger/services/mock_data_src.dart';
import 'package:ledger/services/transactions_repository.dart';

class TransactionsPage extends NavPage {
  final transactionRepo = GetIt.instance.get<TransactionsRepo>();

  TransactionsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Expanded(flex: 1, child: Text('')),
        Expanded(flex: 13, child: StreamBuilder<bool>(
          stream: super.isInView.stream,
          builder: (context, snapshot) {
            return TransactionList();
          }
        )),
        Expanded(
          flex: 2,
          child: ButtonBar(
            buttonPadding: const EdgeInsets.all(0),
            alignment: MainAxisAlignment.spaceAround,
            children: [
              TransactionButton(
                  icon: Icons.add, label: 'Income', onPressed: onIncomePressed),
              TransactionButton(
                icon: Icons.multiple_stop,
                label: 'Transfer',
                onPressed: onTransferPressed,
              ),
              TransactionButton(
                  icon: Icons.remove,
                  label: 'Expense',
                  onPressed: onExpensePressed),
            ],
          ),
        ),
      ],
    );
  }

  void onIncomePressed() {
    transactionRepo.addTransaction(Transaction(
        id: 3,
        value: 100.0,
        debit: DataSource.accounts[0],
        credit: DataSource.accounts[1],
        dateTime: DateTime.now(),
        details: 'details 1'));
  }

  void onTransferPressed() {
  }

  void onExpensePressed() {
    transactionRepo.removeTransaction(3);
  }
}

class TransactionList extends StatelessWidget {
  TransactionList({
    Key? key,
  }) : super(key: key);

  final transactionRepo = GetIt.instance.get<TransactionsRepo>();

  @override
  Widget build(BuildContext context) {
    transactionRepo.getAllTransactions();

    return StreamBuilder<List<Transaction>>(
      stream: transactionRepo.transactionStream,
      builder: (context, snapshot) {
        final transactions = snapshot.data;
        if (transactions != null && transactions!.isNotEmpty) {
          return ListView.builder(
            scrollDirection: Axis.vertical,
            addAutomaticKeepAlives: true,
            itemCount: transactions.length,
            itemBuilder: (context, index) => TransactionItem(transaction: transactions[index],),
          );
        }
        return const Text('There are no transactions');
      },
    );
  }
}

class TransactionItem extends StatelessWidget {
  final Transaction transaction;

  const TransactionItem({super.key, required this.transaction});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text('value: ${transaction.value}'),
        Text('debit: ${transaction.debit.name}'),
        Text('credit: ${transaction.credit.name}'),
      ],
    );
  }
}

class TransactionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final void Function() onPressed;

  const TransactionButton(
      {super.key,
      required this.label,
      required this.icon,
      required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        IconButton(
          onPressed: onPressed,
          icon: Icon(icon),
        ),
        Text(label),
      ],
    );
  }
}

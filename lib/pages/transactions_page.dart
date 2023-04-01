import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:ledger/components/transaction_form.dart';
import 'package:ledger/components/transaction_list.dart';
import 'package:ledger/models/transaction.dart';
import 'package:ledger/pages/main_page.dart';
import 'package:ledger/services/mock_data_src.dart';
import 'package:ledger/services/transactions_repository.dart';

class TransactionsPage extends NavPage {
  final transactionRepo = GetIt.instance.get<TransactionsRepo>();

  TransactionsPage({super.key});

  late BuildContext pageContext;

  @override
  Widget build(BuildContext context) {
    pageContext = context;
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Expanded(flex: 1, child: Text('')),
        Expanded(
            flex: 13,
            child: StreamBuilder<bool>(
                stream: super.isInView.stream,
                builder: (context, snapshot) {
                  return TransactionList(
                    transactionQuery: transactionRepo.getAllTransactions,
                  );
                })),
        Expanded(
          flex: 2,
          child: ButtonBar(
            buttonPadding: const EdgeInsets.all(0),
            alignment: MainAxisAlignment.spaceAround,
            children: [
              TransactionButton(
                  icon: Icons.add,
                  label: 'Income',
                  onPressed: onIncomePressed),
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
    showModal();
  }

  void onExpensePressed() {
    transactionRepo.removeTransaction(3);
  }

  void showModal() {
    showModalBottomSheet(
      isScrollControlled: true,
        builder: (context) {
          return TransactionInputModal(onModalClosed: () {
            Navigator.pop(context);
          },);
        },
        context: pageContext);
  }
}

class TransactionInputModal extends StatelessWidget {
  final Function onModalClosed;
  TransactionInputModal({
    Key? key,
    required this.onModalClosed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TransactionForm(onFormClosed: onModalClosed,);
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

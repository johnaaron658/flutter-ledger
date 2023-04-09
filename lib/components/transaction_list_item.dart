
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/intl.dart';
import 'package:ledger/components/transaction_form.dart';
import 'package:ledger/services/accounts_repository.dart';
import 'package:ledger/services/transactions_repository.dart';


class TransactionItem extends StatelessWidget {
  final Transaction transaction;
  final double primaryFontSize = 14;
  final double secondaryFontSize = 10;

  TransactionItem({super.key, required this.transaction});

  final transactionRepo = GetIt.instance.get<TransactionsRepo>();
  late BuildContext pageContext;

  @override
  Widget build(BuildContext context) {
    pageContext = context;
    return SizedBox(
      height: 48,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Expanded(
            flex: 1,
            child: Container(color: getTransactionColor()),
          ),
          Expanded(
            flex: 3,
            child: Container(),
          ),
          Expanded(
            flex: 70,
            child: mainContent(),
          ),
          Expanded(
            flex: 2,
            child: Container(),
          ),
          Expanded(
            flex: 3,
            child: transactionOptions(),
          ),
          Expanded(
            flex: 3,
            child: Container(),
          ),
        ],
      ),
    );
  }

  PopupMenuButton<int> transactionOptions() {
    return PopupMenuButton<int>(
      splashRadius: 1,
      padding: EdgeInsets.zero,
      onSelected: (value) {
        if (value == 0) {
          if (transaction.debit.accountType == AccountType.Expense)
          {
            showModal(TransactionType.Expense, transaction);
          }
          else if (transaction.credit.accountType == AccountType.Income)
          {
            showModal(TransactionType.Income, transaction);
          } else {
            showModal(TransactionType.Transfer, transaction);
          }
        }
        if (value == 1) {
          transactionRepo.removeTransaction(transaction.id);
        }
      },
      itemBuilder: (context) => <PopupMenuEntry<int>>[
        const PopupMenuItem(
          value: 0,
          child: Text('Edit'),
        ),
        const PopupMenuItem(
          value: 1,
          child: Text('Remove'),
        ),
      ],
    );
  }

  Column mainContent() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(flex: 16, child: transactionAccounts()),
            Expanded(
              flex: 13,
              child: transactionAmount(),
            ),
          ],
        ),
        Row(
          children: [
            Expanded(
                child: Text(
              formatDate(transaction.dateTime),
              style: TextStyle(fontSize: secondaryFontSize),
            )),
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(transaction.details,
                      style: TextStyle(fontSize: secondaryFontSize)),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Row transactionAmount() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Text(
          '${NumberFormat.decimalPattern('en_us').format(transaction.amount)} ${transaction.debit.currency}',
          style:
              TextStyle(fontSize: primaryFontSize, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Row transactionAccounts() {
    double arrowMargin = 5;
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Flexible(
          child: Text(
            transaction.credit.name,
            style: TextStyle(
              fontSize: primaryFontSize,
              fontWeight: FontWeight.bold,
            ),
            overflow: TextOverflow.ellipsis,
            maxLines: 2,
          ),
        ),
        Container(
          margin: EdgeInsets.fromLTRB(arrowMargin, 0, arrowMargin, 0),
          child: Icon(
            Icons.arrow_forward,
            size: primaryFontSize,
          ),
        ),
        Flexible(
          child: Text(
            transaction.debit.name,
            style: TextStyle(
              fontSize: primaryFontSize,
              fontWeight: FontWeight.bold,
            ),
            overflow: TextOverflow.ellipsis,
            maxLines: 2,
          ),
        )
      ],
    );
  }

  String formatDate(DateTime datetime) {
    DateTime now = DateTime.now();
    Duration relativeTime = now.difference(datetime);
    List<TimeDurationMap> timeDurationMapList = [
      TimeDurationMap(
          'second', relativeTime.inSeconds, 60, 'A second ago', 'seconds ago'),
      TimeDurationMap(
          'minute', relativeTime.inMinutes, 60, 'A minute ago', 'minutes ago'),
      TimeDurationMap(
          'hour', relativeTime.inHours, 24, 'An hour ago', 'hours ago'),
      TimeDurationMap('day', relativeTime.inDays, 7, 'Yesterday', 'days ago'),
      TimeDurationMap(
          'week', relativeTime.inDays ~/ 7, 4, 'Last week', 'weeks ago'),
      TimeDurationMap(
          'month', now.month - datetime.month, 12, 'Last month', 'months ago'),
      TimeDurationMap(
          'year', now.year - datetime.year, 100, 'Last year', 'years ago'),
    ];

    var timeAgo = timeDurationMapList
        .firstWhere((element) => element.duration < element.upperLimit);
    if (timeAgo.duration == 1) {
      return timeAgo.singular;
    }
    if (timeAgo.duration == 0) {
      return 'Just Now';
    }
    return '${timeAgo.duration} ${timeAgo.plural}';
  }

  Color getTransactionColor() {
    AccountType debitAccountType = transaction.debit.accountType;
    AccountType creditAccountType = transaction.credit.accountType;
    Color color = Colors.amber;

    if (debitAccountType == AccountType.Expense) {
      color = Colors.red;
    } else if (creditAccountType == AccountType.Income) {
      color = Colors.green;
    }

    return color;
  }

  void showModal(TransactionType type, Transaction transaction) {
    showModalBottomSheet(
      isScrollControlled: true,
        builder: (context) {
          return TransactionForm(onFormClosed: () {
            Navigator.pop(context);
          },
          transactionType: type, transaction: transaction,);
        },
        context: pageContext);
  }
}

class TimeDurationMap {
  final String unit;
  final int duration;
  final int upperLimit;
  final String singular;
  final String plural;

  TimeDurationMap(
      this.unit, this.duration, this.upperLimit, this.singular, this.plural);
}
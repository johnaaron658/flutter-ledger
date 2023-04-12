import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fuzzywuzzy/fuzzywuzzy.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/intl.dart';
import 'package:ledger/services/accounts_repository.dart';
import 'package:ledger/services/transactions_repository.dart';

enum TransactionType {
  Transfer,
  Income,
  Expense,
}

class TransactionForm extends StatefulWidget {
  final Function onFormClosed;
  final TransactionType transactionType;
  final Transaction? transaction;

  const TransactionForm(
      {super.key,
      required this.onFormClosed,
      required this.transactionType,
      required this.transaction});

  @override
  State<TransactionForm> createState() => _TransactionFormState();
}

class _TransactionFormState extends State<TransactionForm> {
  final transactionRepo = GetIt.instance.get<TransactionsRepo>();
  TextEditingController detailsController = TextEditingController();

  late Account? accountFrom;
  late Account? accountTo;
  double amount = 0;
  DateTime date = DateTime.now();
  String details = '';

  @override
  void initState() {
    super.initState();
    if (widget.transaction != null) {
      accountFrom = widget.transaction!.accountFrom;
      accountTo = widget.transaction!.accountTo;
      amount = widget.transaction!.amount;
      date = widget.transaction!.date;
      details = widget.transaction!.details;
      detailsController.value = TextEditingValue(text: details);
    } else {
      accountFrom = null;
      accountTo = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    TransactionType type = widget.transactionType;
    return Container(
      height: MediaQuery.of(context).size.height * 0.5 +
          MediaQuery.of(context).viewInsets.bottom * 0.7,
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                flex: 1,
                child: AccountField(
                  labelText: type == TransactionType.Income
                      ? 'Income From'
                      : 'From Account',
                  onAccountChanged: ((account) => accountFrom = account),
                  transactionType: type,
                  isCredit: true,
                  initialValue: accountFrom != null ? accountFrom!.name : '',
                ),
              ),
              Expanded(
                flex: 1,
                child: AccountField(
                    labelText: type == TransactionType.Expense
                        ? 'Expense To'
                        : 'To Account',
                    onAccountChanged: ((account) => accountTo = account),
                    transactionType: type,
                    isCredit: false,
                    initialValue: accountTo != null ? accountTo!.name : ''),
              ),
            ],
          ),
          Row(
            children: [
              Expanded(
                flex: 6,
                child: AmountField(
                    labelText: 'Amount',
                    initialValue: amount,
                    onAmountChanged: ((amt) => amount = amt)),
              ),
              Expanded(
                  flex: 4,
                  child: DateField(
                      labelText: 'Date',
                      initialDate: date,
                      onDateChanged: (dt) {
                        date = dt;
                      })),
            ],
          ),
          TextField(
            controller: detailsController,
            decoration: const InputDecoration(
              labelText: 'Details',
            ),
            onChanged: (value) {
              details = value;
            },
          ),
          ElevatedButton(
            onPressed: () async {
              if (widget.transaction == null) {
                await transactionRepo.addTransaction(Transaction.fromValues(
                    amount, accountTo!, accountFrom!, date, details));
              } else {
                widget.transaction!.amount = amount;
                widget.transaction!.accountFrom = accountFrom!;
                widget.transaction!.accountTo = accountTo!;
                widget.transaction!.date = date;
                widget.transaction!.details = details;
                await transactionRepo.updateTransaction(widget.transaction!);
              }
              widget.onFormClosed();
            },
            child: Text(getButtonText(type, widget.transaction)),
          ),
        ],
      ),
    );
  }

  String getButtonText(TransactionType type, Transaction? transaction) {
    // when editing
    if (transaction != null) {
      return 'Update';
    }
    switch (type) {
      case TransactionType.Income:
        return 'Cash In';
      case TransactionType.Expense:
        return 'Spend';
      default:
        return 'Transfer';
    }
  }
}

class AmountField extends StatefulWidget {
  final String labelText;
  final double initialValue;
  final Function(double) onAmountChanged;

  const AmountField({
    super.key,
    required this.labelText,
    required this.initialValue,
    required this.onAmountChanged,
  });

  @override
  _AmountFieldState createState() => _AmountFieldState();
}

class _AmountFieldState extends State<AmountField> {
  late double amount;
  TextEditingController controller = TextEditingController();
  final formatter = NumberFormat('#,###.##', 'en_US');

  @override
  void initState() {
    super.initState();
    amount = widget.initialValue;
    controller.value = TextEditingValue(text: formatter.format(amount));
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: widget.labelText,
      ),
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      onChanged: (value) {
        amount = double.tryParse(value) ?? 0.00;
        widget.onAmountChanged(amount);
      },
    );
  }
}

class DateField extends StatefulWidget {
  final String labelText;
  final DateTime initialDate;
  final Function(DateTime) onDateChanged;

  const DateField({
    super.key,
    required this.labelText,
    required this.initialDate,
    required this.onDateChanged,
  });

  @override
  _DateFieldState createState() => _DateFieldState();
}

class _DateFieldState extends State<DateField> {
  late TextEditingController _controller;
  late DateTime _selectedDate;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(
      text: DateFormat('yyyy-MM-dd').format(widget.initialDate),
    );
    _selectedDate = widget.initialDate;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _controller.text = DateFormat('yyyy-MM-dd').format(picked);
        widget.onDateChanged(picked);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: _controller,
      readOnly: true,
      onTap: () => _selectDate(context),
      decoration: InputDecoration(
        labelText: widget.labelText,
        suffixIcon: const Icon(Icons.calendar_today),
        border: const OutlineInputBorder(),
        contentPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      ),
    );
  }
}

class AccountField extends StatelessWidget {
  final String labelText;
  final Function(Account) onAccountChanged;
  final TransactionType transactionType;
  final bool isCredit;
  final String initialValue;

  AccountField({
    super.key,
    required this.labelText,
    required this.onAccountChanged,
    required this.transactionType,
    required this.isCredit,
    required this.initialValue,
  });

  final accountsRepo = GetIt.instance.get<AccountsRepo>();

  @override
  Widget build(BuildContext context) {
    accountsRepo.refreshAccountList();

    return StreamBuilder<List<Account>>(
        stream: accountsRepo.accountStream,
        builder: (context, snapshot) => Autocomplete<String>(
              initialValue: TextEditingValue(text: initialValue),
              optionsBuilder: (textEditingValue) async {
                final accounts = snapshot.data;
                if (accounts != null) {
                  if (isCredit) {
                    switch (transactionType) {
                      case TransactionType.Transfer:
                      case TransactionType.Expense:
                        return filterOptions(accounts, textEditingValue,
                            [AccountType.Asset, AccountType.Liability]);
                      case TransactionType.Income:
                        return filterOptions(
                            accounts, textEditingValue, [AccountType.Income]);
                    }
                  } else {
                    switch (transactionType) {
                      case TransactionType.Expense:
                        return filterOptions(
                            accounts, textEditingValue, [AccountType.Expense]);
                      case TransactionType.Income:
                      case TransactionType.Transfer:
                        return filterOptions(accounts, textEditingValue,
                            [AccountType.Asset, AccountType.Liability]);
                    }
                  }
                }
                return [];
              },
              fieldViewBuilder: (context, textEditingController, focusNode,
                  onFieldSubmitted) {
                return TextField(
                  controller: textEditingController,
                  focusNode: focusNode,
                  decoration: InputDecoration(
                    labelText: labelText,
                  ),
                  onChanged: (value) {
                    onAccountChanged(
                        getAccountWithName(value, transactionType));
                  },
                );
              },
              onSelected: (value) =>
                  onAccountChanged(getAccountWithName(value, transactionType)),
            ));
  }

  Account getAccountWithName(String name, TransactionType type) {
    Account? account = accountsRepo.getAccountWithName(name);
    if (account == null) {
      account = Account.fromName(name);
      switch (type) {
        case TransactionType.Expense:
          account.accountType = AccountType.Expense;
          break;
        case TransactionType.Income:
          account.accountType = AccountType.Income;
          break;
        case TransactionType.Transfer:
          account.accountType = Account.defaultAccountType;
          break;
      }
    }
    return account;
  }

  List<String> filterOptions(List<Account> accounts,
      TextEditingValue textEditingValue, List<AccountType> types) {
    final filteredAccounts =
        accounts.where((account) => types.contains(account.accountType));
    final searchResults = extractAllSorted(
        query: textEditingValue.text,
        choices: filteredAccounts.map((account) => account.name).toList());
    return searchResults
        .map(
          (e) => e.choice,
        )
        .toList();
  }
}

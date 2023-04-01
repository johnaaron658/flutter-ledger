import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/intl.dart';
import 'package:ledger/models/account.dart';
import 'package:ledger/models/transaction.dart';
import 'package:ledger/services/accounts_repository.dart';
import 'package:ledger/services/transactions_repository.dart';

class TransactionForm extends StatefulWidget {
  final Function onFormClosed;


  const TransactionForm({super.key, required this.onFormClosed}); 

  @override
  State<TransactionForm> createState() => _TransactionFormState();
}

class _TransactionFormState extends State<TransactionForm> {

  final transactionRepo = GetIt.instance.get<TransactionsRepo>();

  TextEditingController amountController = TextEditingController();

  Account accountFrom = const Account(balance: 0, name: '', currency: '', accountType: AccountType.Asset, subAccounts: [], limit: 0);
  Account accountTo = const Account(balance: 0, name: '', currency: '', accountType: AccountType.Asset, subAccounts: [], limit: 0);
  double amount = 0;
  DateTime date = DateTime.now();
  String details = '';

  @override
  Widget build(BuildContext context) {
    return Container(
            height: MediaQuery.of(context).size.height * 0.5 + MediaQuery.of(context).viewInsets.bottom * 0.7,
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
                            child: AccountField(labelText: 'Account From', onAccountChanged: ((account) => accountFrom = account)),
                          ),
                          Expanded(
                            flex: 1,
                            child: AccountField(labelText: 'Account To', onAccountChanged: ((account) => accountTo = account)),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Expanded(
                            flex: 6,
                            child: TextField(
                              controller: amountController,
                              decoration: const InputDecoration(
                                labelText: 'Amount',
                              ),
                              keyboardType: const TextInputType.numberWithOptions(decimal: true),
                              inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),],
                              onChanged: (value) {
                                final formatter = NumberFormat('#,###.##', 'en_US');
                                amount = double.tryParse(value) ?? 0.00;
                                final text = formatter.format(amount);
                                if (text != value) {
                                  // Set the formatted text back to the TextField
                                  final valueToSet = value.substring(value.length - 1) == '.' ? value : text;
                                  amountController.value = TextEditingValue(
                                    text:  valueToSet,
                                    selection: TextSelection.collapsed(offset: valueToSet.length),
                                  );
                                } 
                              },
                            ),
                          ), 
                          Expanded(flex: 4, child: DateField(labelText: 'Date', initialDate: DateTime.now(), onDateChanged: (date) {})),
                        ],
                      ),
                      TextField(
                        decoration: const InputDecoration(
                          labelText: 'Details',
                        ),
                        onChanged: (value) {
                          details = value;
                        },
                      ),
                      ElevatedButton(
                        onPressed: () {
                          widget.onFormClosed();
                          transactionRepo.addTransaction(Transaction(
                            debit: accountTo,
                            credit: accountFrom,
                            value: amount,
                            dateTime: date,
                            details: details,
                          ));
                        },
                        child: const Text('Transfer'),
                      ),
                    ],
                ),
          );
  }

}

class DateField extends StatefulWidget {
  final String labelText;
  final DateTime initialDate;
  final Function(DateTime) onDateChanged;

  const DateField({super.key, 
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

  AccountField({super.key, 
    required this.labelText,
    required this.onAccountChanged,
  });

  final accountsRepo = GetIt.instance.get<AccountsRepo>();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Account>>(
      stream: accountsRepo.accountStream,
      builder: (context, snapshot) => Autocomplete<String>(
        optionsBuilder: (textEditingValue) {
          final accounts = snapshot.data;
          if (accounts != null) {
            return filterOptions(accounts, textEditingValue);
          }
          return [];
        } , 
        fieldViewBuilder: (context, textEditingController, focusNode, onFieldSubmitted) {
          return TextField(
            controller: textEditingController,
            focusNode: focusNode,
            decoration: InputDecoration(
              labelText: labelText,
            ),
            onChanged: (value) {
              onAccountChanged(getAccountWithName(value));
            },
          );
        },
        onSelected: (value) => onAccountChanged(getAccountWithName(value)),
      )
    );
  }

  Account getAccountWithName(String name) {
    return accountsRepo.getAccountWithName(name) ?? Account(balance: 0, name: name, currency: '', accountType: AccountType.Asset, subAccounts: [], limit: 0);
  }

  List<String> filterOptions(List<Account> accounts, TextEditingValue textEditingValue) => 
      accounts
      .map((e) => e.name)
      .where((element) => element.toLowerCase().startsWith(textEditingValue.text.toLowerCase()))
      .toList();
}
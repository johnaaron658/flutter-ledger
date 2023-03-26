import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

class TransactionForm extends StatefulWidget {
  const TransactionForm({super.key});

  @override
  State<TransactionForm> createState() => _TransactionFormState();
}

class _TransactionFormState extends State<TransactionForm> {

  TextEditingController amountController = TextEditingController();

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
                    Autocomplete<String>(optionsBuilder: ((textEditingValue) {
                      return [];
                    }), onSelected: (value) {

                    },
                    fieldViewBuilder: ((context, textEditingController, focusNode, onFieldSubmitted) {
                      return TextField(
                        controller: textEditingController,
                        focusNode: focusNode,
                        decoration: const InputDecoration(
                          labelText: 'Account From',
                        ),
                      );
                    })),
                    Autocomplete<String>(optionsBuilder: ((textEditingValue) {
                      return [];
                    }), onSelected: (value) {

                    },
                    fieldViewBuilder: ((context, textEditingController, focusNode, onFieldSubmitted) {
                      return TextField(
                        controller: textEditingController,
                        focusNode: focusNode,
                        decoration: const InputDecoration(
                          labelText: 'Account To',
                        ),
                      );
                    })),
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
                              final text = formatter.format(double.tryParse(value) ?? 0.00);
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
                    const TextField(
                      decoration: InputDecoration(
                        labelText: 'Details',
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {},
                      child: const Text('Add'),
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

  const DateField({
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



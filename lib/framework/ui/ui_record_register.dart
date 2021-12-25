import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:household_accounts/adapter/controller/ctl_record_register.dart';
import 'package:household_accounts/entity/record.dart';

class RecordRegisterPage extends StatefulWidget {
  final RecordRegisterController _controller;

  RecordRegisterPage(this._controller);

  @override
  _RecordRegisterPageState createState() => _RecordRegisterPageState();
}

class _RecordRegisterPageState extends State<RecordRegisterPage> {
  late DateTime _dateOfRecord;
  late int _amount;
  late RecordType _type;
  late String _note;
  late List<String> _categories;
  late String _category;

  @override
  void initState() {
    super.initState();
    _dateOfRecord = DateTime.now();
    _type = RecordType.expense;
    _categories = expenseCategories;
    _category = expenseCategories[0];
  }

  final _formKey = GlobalKey<FormState>();

  String _formatDateTime(DateTime dateTime) =>
      '${dateTime.year}-${dateTime.month}-${dateTime.day}';

  @override
  Widget build(BuildContext context) {
    final amountFormField = TextFormField(
      decoration: InputDecoration(
        labelText: '金額',
        border: UnderlineInputBorder(),
      ),
      keyboardType: TextInputType.number,
      textAlign: TextAlign.end,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      onSaved: (value) {
        _amount = int.parse(value!);
      },
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter some value.';
        }
        return null;
      },
    );

    final typeFormField = _RecordTypeFormField(
      initialValue: RecordType.expense,
      onPressed: (type) => setState(() {
        if (_type == type) {
          return;
        }

        _type = type;
        switch (type) {
          case RecordType.expense:
            _categories = expenseCategories;
            break;
          case RecordType.income:
            _categories = incomeCategories;
            break;
          default:
            assert(false);
        }
        _category = _categories[0];
      }),
    );

    final memoFormField = TextFormField(
      decoration: InputDecoration(
        labelText: 'メモ',
        border: UnderlineInputBorder(),
      ),
      keyboardType: TextInputType.text,
      onSaved: (value) {
        if (value == null) {
          _note = '';
        } else {
          _note = value;
        }
      },
    );

    final expenseCategoryFormField =
        _CategoryFormField(_categories, onChanged: (value) {
      if (value != null) {
        _category = value;
      }
    });

    return Form(
      key: _formKey,
      child: ListView(
        children: [
          amountFormField,
          typeFormField,
          memoFormField,
          expenseCategoryFormField,
          ElevatedButton(
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                _formKey.currentState!.save();
                final currentDate = DateTime.now();
                final record = Record.emptyId(
                  currentDate,
                  _dateOfRecord,
                  _amount,
                  _type,
                  _note,
                  _category,
                );
                widget._controller.register(record);
              }
            },
            child: Text('Submit'),
          ),
        ],
      ),
    );
    // return Scaffold(
    //   appBar: AppBar(
    //     leading: const Icon(Icons.account_circle_outlined),
    //     title: Center(
    //       child: Text(_formatDateTime(_dateOfRecord)),
    //     ),
    //     actions: [
    //       _RRPDatePicker(
    //           (pickedDate) => setState(() => _dateOfRecord = pickedDate)),
    //     ],
    //   ),
    //   body: Form(
    //     key: _formKey,
    //     // child: Column(
    //     child: ListView(
    //       children: [
    //         amountFormField,
    //         typeFormField,
    //         memoFormField,
    //         expenseCategoryFormField,
    //         ElevatedButton(
    //           onPressed: () {
    //             if (_formKey.currentState!.validate()) {
    //               _formKey.currentState!.save();
    //               final currentDate = DateTime.now();
    //               final record = Record(currentDate, _dateOfRecord, _amount,
    //                   _type, _note, _category);
    //               widget._controller.register(record);
    //             }
    //           },
    //           child: Text('Submit'),
    //         ),
    //       ],
    //     ),
    //   ),
    // );
  }
}

class _CategoryFormField extends StatelessWidget {
  final List<String> _categories;
  final void Function(String?) onChanged;

  _CategoryFormField(this._categories, {required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      items: _categories.map<DropdownMenuItem<String>>((item) {
        return DropdownMenuItem<String>(
          value: item,
          child: Text(item),
        );
      }).toList(),
      value: _categories[0],
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: 'カテゴリ',
        border: UnderlineInputBorder(),
      ),
    );
  }
}

class _RecordTypeFormField extends FormField<RecordType> {
  _RecordTypeFormField(
      {Key? key,
      required void Function(RecordType) onPressed,
      FormFieldSetter<RecordType>? onSaved,
      FormFieldValidator<RecordType>? validator,
      RecordType? initialValue,
      bool enabled = true,
      AutovalidateMode? autovalidateMode})
      : super(
          key: key,
          onSaved: onSaved,
          validator: validator,
          initialValue: initialValue,
          enabled: enabled,
          autovalidateMode: autovalidateMode,
          builder: (FormFieldState<RecordType> state) {
            return Row(
              children: [
                Text('Debug Info: ${state.value.toString()}'),
                OutlinedButton(
                  onPressed: () {
                    state.didChange(RecordType.income);
                    onPressed(RecordType.income);
                  },
                  child: Text("収入"),
                ),
                OutlinedButton(
                  onPressed: () {
                    state.didChange(RecordType.expense);
                    onPressed(RecordType.expense);
                  },
                  child: Text("支出"),
                ),
              ],
            );
          },
        );
}

class _RRPDatePicker extends StatelessWidget {
  final void Function(DateTime pickedDate) _setDate;

  _RRPDatePicker(this._setDate);

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.calendar_today),
      onPressed: () {
        showDatePicker(
          context: context,
          initialDate: DateTime.now(),
          firstDate: DateTime.utc(2019),
          lastDate: DateTime.utc(2022),
        ).then((pickedDate) {
          if (pickedDate != null) _setDate(pickedDate);
        });
      },
    );
  }
}

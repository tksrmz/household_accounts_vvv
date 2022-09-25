import 'package:dartz/dartz.dart' as dartz;
import 'package:flutter/material.dart';
import 'package:household_accounts/entity/category_entity.dart';
import 'package:household_accounts/entity/property_entity.dart';
import 'package:household_accounts/entity/record_entity.dart';
import 'package:household_accounts/feature/category_retrieve/retrieve_categories_use_case.dart';
import 'package:household_accounts/feature/property_retrieve/property_retrieve_use_case.dart';
import 'package:household_accounts/feature/record_register/record_register_use_case.dart';
import 'package:household_accounts/presentation/common_widget/number_text_form_field.dart';
import 'package:household_accounts/util/extension/string.dart';
import 'package:household_accounts/util/service_locator/service_locator.dart';

import '../../util/type/exception_or.dart';

class RecordInputPage extends StatelessWidget {
  const RecordInputPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return _PageContents();
  }
}

class _PageContents extends StatefulWidget {
  const _PageContents({Key? key}) : super(key: key);

  @override
  _PageContentsState createState() => _PageContentsState();
}

class _PageContentsState extends State<_PageContents> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  DateTime _recordDate = DateTime.now();
  String _amount = '';
  RecordType _recordType = RecordType.income;
  Category2? _category;
  Property? _srcProperty;
  Property? _destProperty;
  String _note = '';

  late final Future<ExceptionOr<List<IncomeCategory>>> _incomeCategoriesFuture;
  late final Future<ExceptionOr<List<ExpenseCategory>>>
      _expenseCategoriesFuture;
  late final Future<ExceptionOr<List<Property>>> _propertiesFuture;

  @override
  void initState() {
    super.initState();
    _incomeCategoriesFuture = sl<RetrieveIncomeCategoriesUseCase>()(dartz.unit);
    _expenseCategoriesFuture =
        sl<RetrieveExpenseCategoriesUseCase>()(dartz.unit);
    _propertiesFuture = sl<RetrievePropertiesUseCase>()(dartz.unit);
  }

  void _setRecordDateState(DateTime value) {
    setState(() {
      _recordDate = value;
      print('record date: $_recordDate');
    });
  }

  void _setAmountState(String value) {
    setState(() {
      _amount = value;
      print('amount: $_amount');
    });
  }

  void _setRecordTypeState(RecordType value) {
    setState(() {
      _recordType = value;
      // Inorder to avoid an error, _categoryValue must be set to null.
      // If _categoryValue isn't null and the value is not in _CategoryDropDownMenu.items, Flutter throws an error (an exception?).
      // This behavior is mentioned in the Flutter document of DropdownButton class.
      _category = null;
      // Destination property selector may be disappeared.
      _destProperty = null;
      print('record type: $_recordType');
    });
  }

  void _setCategoryState(Category2? value) {
    setState(() {
      _category = value;
      print('category name: $_category');
    });
  }

  void _setSrcPropertyState(Property? value) {
    setState(() {
      _srcProperty = value;
      print('source property: $_srcProperty');
    });
  }

  void _setDestPropertyState(Property? value) {
    setState(() {
      _destProperty = value;
      print('destination property: $_destProperty');
    });
  }

  void _setNoteState(String value) {
    setState(() {
      _note = value;
      print('note: $_note');
    });
  }

  void _submitIncomeRecord(AddIncomeRecordUseCase useCase) {
    if (_category != null && _srcProperty != null) {
      useCase(
        AddIncomeRecordInput(
          _recordDate,
          _amount.tryToInt() | 0,
          _note,
          _category!.id,
          _srcProperty!.id,
        ),
      );
    }
  }

  void _submitExpenseRecord(AddExpenseRecordUseCase useCae) {
    if (_category != null && _srcProperty != null) {
      useCae(
        AddExpenseRecordInput(
          _recordDate,
          _amount.tryToInt() | 0,
          _note,
          _category!.id,
          _srcProperty!.id,
        ),
      );
    }
  }

  void _submitTransferRecord(AddTransferRecordUseCase useCase) {
    if (_srcProperty != null && _destProperty != null) {
      useCase(
        AddTransferRecordInput(
          _recordDate,
          _amount.tryToInt() | 0,
          _note,
          _srcProperty!.id,
          _destProperty!.id,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: ListView(
        children: [
          _RecordDatePicker(
            value: _recordDate,
            recordDateUpdater: _setRecordDateState,
          ),
          _AmountTextField(
            onSaved: (String? value) {
              assert(value != null, 'amount value is null!');
              _setAmountState(value!);
            },
          ),
          _RecordTypeSelector(
            incomeButtonOnPressed: _recordType == RecordType.income
                ? null
                : () => _setRecordTypeState(RecordType.income),
            expenseButtonOnPressed: _recordType == RecordType.expense
                ? null
                : () => _setRecordTypeState(RecordType.expense),
            transferButtonOnPressed: _recordType == RecordType.transfer
                ? null
                : () => _setRecordTypeState(RecordType.transfer),
          ),
          _PropertyDropDownMenu(
            properties: _propertiesFuture,
            value: _srcProperty,
            onChanged: _setSrcPropertyState,
          ),
          _recordType == RecordType.transfer
              ? _PropertyDropDownMenu(
                  properties: _propertiesFuture,
                  value: _destProperty,
                  onChanged: _setDestPropertyState,
                )
              : _CategoryDropDownMenu(
                  categories: _recordType == RecordType.income
                      ? _incomeCategoriesFuture
                      : _expenseCategoriesFuture,
                  value: _category,
                  categoryType: _recordType == RecordType.income
                      ? CategoryType.income
                      : CategoryType.expense,
                  onChanged: _setCategoryState,
                ),
          _NoteTextField(
            onSaved: (String? value) {
              assert(value != null, 'note value is null');
              _setNoteState(value!);
            },
          ),
          _SubmitButton(
            onPressed: () {
              print('Current state');
              print('amount: $_amount');
              print('record date: $_recordDate');
              print('category type: $_recordType');
              print('category name: $_category');
              print('source property: $_srcProperty');
              print('destination property: $_destProperty');
              print('note: $_note');

              if (!_formKey.currentState!.validate()) {
                // Tell the user that the input data is invalid.
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('Invalid input.'),
                  ),
                );
                return;
              }

              // Updates states
              _formKey.currentState!.save();
              // Process data
              switch (_recordType) {
                case RecordType.income:
                  _submitIncomeRecord(sl<AddIncomeRecordUseCase>());
                  break;
                case RecordType.expense:
                  _submitExpenseRecord(sl<AddExpenseRecordUseCase>());
                  break;
                case RecordType.transfer:
                  _submitTransferRecord(sl<AddTransferRecordUseCase>());
                  break;
              }
              // Reset states
              _formKey.currentState!.reset();

              // Tell the user that the record has been created
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Record created!'),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _RecordDatePicker extends StatelessWidget {
  final DateTime _selectedDate;
  final void Function(DateTime) _updateRecordDate;

  const _RecordDatePicker({
    required DateTime value,
    required void Function(DateTime) recordDateUpdater,
    Key? key,
  })  : _selectedDate = value,
        _updateRecordDate = recordDateUpdater,
        super(key: key);

  @override
  Widget build(BuildContext context) {
    const daysInYear = 365;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          '${_selectedDate.year}/${_selectedDate.month}/${_selectedDate.day}',
        ),
        IconButton(
          onPressed: () async {
            final pickedDate = await showDatePicker(
              context: context,
              initialDate: _selectedDate,
              firstDate: _selectedDate.subtract(
                const Duration(days: daysInYear),
              ),
              lastDate: _selectedDate.add(
                const Duration(days: daysInYear),
              ),
            );
            if (pickedDate != null) {
              _updateRecordDate(pickedDate);
            }
          },
          icon: Icon(Icons.edit),
        ),
      ],
    );
  }
}

class _AmountTextField extends StatelessWidget {
  final FormFieldSetter<String>? _onSaved;

  _AmountTextField({
    FormFieldSetter<String>? onSaved,
    Key? key,
  })  : _onSaved = onSaved,
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return NumberTextFormField(
      decoration: InputDecoration(
        labelText: 'Amount',
        border: OutlineInputBorder(),
      ),
      initialValue: '',
      onSaved: _onSaved,
    );
  }
}

class _RecordTypeSelector extends StatelessWidget {
  final VoidCallback? _incomeButtonOnPressed;
  final VoidCallback? _expenseButtonOnPressed;
  final VoidCallback? _transferButtonOnPressed;

  const _RecordTypeSelector({
    VoidCallback? incomeButtonOnPressed,
    VoidCallback? expenseButtonOnPressed,
    VoidCallback? transferButtonOnPressed,
    Key? key,
  })  : _incomeButtonOnPressed = incomeButtonOnPressed,
        _expenseButtonOnPressed = expenseButtonOnPressed,
        _transferButtonOnPressed = transferButtonOnPressed,
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: _incomeButtonOnPressed,
            child: const Text('Income'),
          ),
        ),
        Expanded(
          child: OutlinedButton(
            onPressed: _expenseButtonOnPressed,
            child: const Text('Expense'),
          ),
        ),
        Expanded(
          child: OutlinedButton(
            onPressed: _transferButtonOnPressed,
            child: const Text('Transfer'),
          ),
        ),
      ],
    );
  }
}

class _CategoryDropDownMenu extends StatelessWidget {
  final Future<ExceptionOr<List<Category2>>> _categories;
  final Category2? _value;
  final CategoryType _displayedType;
  final ValueChanged<Category2?>? _onChanged;

  const _CategoryDropDownMenu({
    Key? key,
    required Future<ExceptionOr<List<Category2>>> categories,
    Category2? value,
    required CategoryType categoryType,
    required ValueChanged<Category2?>? onChanged,
  })  : _categories = categories,
        _value = value,
        _displayedType = categoryType,
        _onChanged = onChanged,
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<ExceptionOr<List<Category2>>>(
      future: _categories,
      builder: (context, snapshot) {
        Category2? value;
        Text? disabledHint;
        List<DropdownMenuItem<Category2>>? items;
        if (snapshot.hasData) {
          // succeeded, but there may be a failure
          snapshot.data!.fold(
            (failure) {
              // When there is a failure, [items] is set to null to disable [DropdownButton].
              // Then, [value] is set to null to display [disabledHint].
              value = null;
              disabledHint = Text('Error: ${snapshot.error}');
              items = null;
            },
            (categories) {
              value = _value;
              disabledHint = null;
              items = categories
                  .where((category) => category.type == _displayedType)
                  .map<DropdownMenuItem<Category2>>(
                    (category) => DropdownMenuItem(
                      value: category,
                      child: Text(category.name),
                    ),
                  )
                  .toList();
            },
          );
        } else if (snapshot.hasError) {
          // When an error was occurred, [items] is set to null to disable [DropdownButton].
          // Then, [value] is set to null to display [disabledHint].
          value = null;
          disabledHint = Text('Error: ${snapshot.error}');
          items = null;
        } else {
          // While loading, [items] is set to null to disable [DropdownButton].
          // Then, [value] is set to null to display [disabledHint].
          value = null;
          disabledHint = Text('Loading...');
          items = null;
        }

        return DropdownButton<Category2>(
          value: value,
          hint: const Text('Select category'),
          disabledHint: disabledHint,
          icon: const Icon(Icons.arrow_downward),
          elevation: 16,
          style: const TextStyle(color: Colors.deepPurple),
          underline: Container(
            height: 2,
            color: Colors.deepPurpleAccent,
          ),
          items: items,
          onChanged: _onChanged,
        );
      },
    );
  }
}

class _PropertyDropDownMenu extends StatelessWidget {
  final Future<ExceptionOr<List<Property>>> _properties;
  final Property? _value;
  final ValueChanged<Property?>? _onChanged;

  const _PropertyDropDownMenu({
    Key? key,
    required Future<ExceptionOr<List<Property>>> properties,
    Property? value,
    required ValueChanged<Property?>? onChanged,
  })  : _properties = properties,
        _value = value,
        _onChanged = onChanged,
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<ExceptionOr<List<Property>>>(
      future: _properties,
      builder: (context, snapshot) {
        Property? value;
        Text? disabledHint;
        List<DropdownMenuItem<Property>>? items;
        if (snapshot.hasData) {
          // succeeded, but there may be a failure
          snapshot.data!.fold(
            (failure) {
              // When there is a failure, [items] is set to null to disable [DropdownButton].
              // Then, [value] is set to null to display [disabledHint].
              value = null;
              disabledHint = Text('Error: ${snapshot.error}');
              items = null;
            },
            (properties) {
              value = _value;
              disabledHint = null;
              items = properties
                  .map<DropdownMenuItem<Property>>(
                    (property) => DropdownMenuItem(
                      value: property,
                      child: Text(property.name),
                    ),
                  )
                  .toList();
            },
          );
        } else if (snapshot.hasError) {
          // When an error was occurred, [items] is set to null to disable [DropdownButton].
          // Then, [value] is set to null to display [disabledHint].
          value = null;
          disabledHint = Text('Error: ${snapshot.error}');
          items = null;
        } else {
          // While loading, [items] is set to null to disable [DropdownButton].
          // Then, [value] is set to null to display [disabledHint].
          value = null;
          disabledHint = Text('Loading...');
          items = null;
        }

        return DropdownButton<Property>(
          value: value,
          hint: const Text('Select property'),
          disabledHint: disabledHint,
          icon: const Icon(Icons.arrow_downward),
          elevation: 16,
          style: const TextStyle(color: Colors.deepPurple),
          underline: Container(
            height: 2,
            color: Colors.deepPurpleAccent,
          ),
          items: items,
          onChanged: _onChanged,
        );
      },
    );
  }
}

class _NoteTextField extends StatelessWidget {
  final FormFieldSetter<String>? _onSaved;

  const _NoteTextField({
    FormFieldSetter<String>? onSaved,
    Key? key,
  })  : _onSaved = onSaved,
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextFormField(
        decoration: InputDecoration(
          labelText: 'Note',
          border: OutlineInputBorder(),
        ),
        initialValue: '',
        keyboardType: TextInputType.text,
        onSaved: _onSaved,
        validator: (String? value) {
          if (value == null) {
            return 'Please input some value.';
          }

          return null;
        });
  }
}

class _SubmitButton extends StatelessWidget {
  final VoidCallback? _onPressed;

  const _SubmitButton({
    VoidCallback? onPressed,
    Key? key,
  })  : _onPressed = onPressed,
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: _onPressed,
      child: const Text('Submit'),
    );
  }
}

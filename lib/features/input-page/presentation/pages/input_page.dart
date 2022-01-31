import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:household_accounts/features/category-page/domain/entities/category.dart';
import 'package:household_accounts/features/input-page/domain/entities/record.dart';
import 'package:household_accounts/features/input-page/domain/use-cases/add_record.dart';
import 'package:household_accounts/features/property-viewer/domain/entities/property.dart';
import 'package:household_accounts/util/presentation/states/category_list.dart';
import 'package:household_accounts/util/presentation/states/property_list.dart';
import 'package:household_accounts/util/string-parser.dart';
import 'package:provider/provider.dart';

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
  DateTime _recordDate = DateTime.now();
  String _amount = '';
  RecordType _recordType = RecordType.income;
  Category? _category;
  Property? _srcProperty;
  Property? _destProperty;
  String _note = '';

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

  void _setCategoryState(Category? value) {
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
      useCase.handle(
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
      useCae.handle(
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
      useCase.handle(
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
    return ListView(
      children: [
        _RecordDatePicker(
          value: _recordDate,
          recordDateUpdater: _setRecordDateState,
        ),
        _AmountTextField(
          onChanged: _setAmountState,
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
          value: _srcProperty,
          onChanged: _setSrcPropertyState,
        ),
        _recordType == RecordType.transfer
            ? _PropertyDropDownMenu(
                value: _destProperty,
                onChanged: _setDestPropertyState,
              )
            : _CategoryDropDownMenu(
          value: _category,
                categoryType: _recordType == RecordType.income
                    ? CategoryType.income
                    : CategoryType.expense,
                onChanged: _setCategoryState,
              ),
        _NoteTextField(
          onChanged: _setNoteState,
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

            switch (_recordType) {
              case RecordType.income:
                _submitIncomeRecord(context.read<AddIncomeRecordUseCase>());
                break;
              case RecordType.expense:
                _submitExpenseRecord(context.read<AddExpenseRecordUseCase>());
                break;
              case RecordType.transfer:
                _submitTransferRecord(context.read<AddTransferRecordUseCase>());
                break;
            }
          },
        ),
      ],
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
  final ValueChanged<String>? _onChanged;

  _AmountTextField({
    ValueChanged<String>? onChanged,
    Key? key,
  })  : _onChanged = onChanged,
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextField(
      decoration: InputDecoration(
        labelText: 'Amount',
        border: OutlineInputBorder(),
      ),
      keyboardType: TextInputType.number,
      onChanged: _onChanged,
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
  final Category? _dropdownValue;
  final CategoryType _displayedType;
  final ValueChanged<Category?>? _onChanged;

  const _CategoryDropDownMenu({
    Category? value,
    required CategoryType categoryType,
    required ValueChanged<Category?>? onChanged,
    Key? key,
  })  : _dropdownValue = value,
        _displayedType = categoryType,
        _onChanged = onChanged,
        super(key: key);

  @override
  Widget build(BuildContext context) {
    final state = context.watch<CategoryListState>();

    final Text? disabledHint;
    final List<DropdownMenuItem<Category>>? items;
    if (state.hasFailure) {
      disabledHint = Text(state.failure!.toString());
      items = null;
    } else if (state.isLoading) {
      disabledHint = Text('Loading category settings...');
      items = null;
    } else {
      disabledHint = null;

      final UnmodifiableListView<Category> categories;
      switch (_displayedType) {
        case CategoryType.income:
          categories = state.incomeCategories;
          break;
        case CategoryType.expense:
          categories = state.expenseCategories;
          break;
      }
      items = categories.map<DropdownMenuItem<Category>>((Category value) {
        return DropdownMenuItem<Category>(
          value: value,
          child: Text(value.name),
        );
      }).toList();
    }

    return DropdownButton<Category>(
      // [value] should be null to display [disabledHint]
      // when failure has occurred or loading categories.
      value: disabledHint != null ? null : _dropdownValue,
      hint: const Text('Select category'),
      disabledHint: disabledHint,
      icon: const Icon(Icons.arrow_downward),
      elevation: 16,
      style: const TextStyle(color: Colors.deepPurple),
      underline: Container(
        height: 2,
        color: Colors.deepPurpleAccent,
      ),
      // When failure has occurred or loading categories,
      // [items] becomes null to disable this widget.
      items: items,
      onChanged: _onChanged,
    );
  }
}

class _PropertyDropDownMenu extends StatelessWidget {
  final Property? _dropdownValue;
  final ValueChanged<Property?>? _onChanged;

  const _PropertyDropDownMenu({
    Property? value,
    required ValueChanged<Property?>? onChanged,
    Key? key,
  })  : _dropdownValue = value,
        _onChanged = onChanged,
        super(key: key);

  @override
  Widget build(BuildContext context) {
    final state = context.watch<PropertyListState>();

    final Text? disabledHint;
    if (state.hasFailure) {
      disabledHint = Text(state.failure!.toString());
    } else if (state.isLoading) {
      disabledHint = Text('Loading property settings...');
    } else {
      disabledHint = null;
    }

    return DropdownButton<Property>(
      // [value] should be null to display [disabledHint]
      // when failure has occurred or loading properties.
      value: disabledHint != null ? null : _dropdownValue,
      hint: const Text('Select property'),
      disabledHint: disabledHint,
      icon: const Icon(Icons.arrow_downward),
      elevation: 16,
      style: const TextStyle(color: Colors.deepPurple),
      underline: Container(
        height: 2,
        color: Colors.deepPurpleAccent,
      ),
      // When failure has occurred or loading categories,
      // [items] becomes null to disable this widget.
      items: disabledHint != null
          ? null
          : state.properties
              .map(
                (value) => DropdownMenuItem<Property>(
                  value: value,
                  child: Text(value.name),
                ),
              )
              .toList(),
      onChanged: _onChanged,
    );
  }
}

class _NoteTextField extends StatelessWidget {
  final ValueChanged<String>? _onChanged;

  const _NoteTextField({
    ValueChanged<String>? onChanged,
    Key? key,
  })  : _onChanged = onChanged,
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextField(
      decoration: InputDecoration(
        labelText: 'Note',
        border: OutlineInputBorder(),
      ),
      keyboardType: TextInputType.text,
      onChanged: _onChanged,
    );
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

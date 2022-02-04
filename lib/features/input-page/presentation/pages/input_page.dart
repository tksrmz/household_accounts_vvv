import 'package:dartz/dartz.dart' as dartz;
import 'package:flutter/material.dart';
import 'package:household_accounts/features/property-viewer/domain/entities/property.dart';
import 'package:household_accounts/features/property-viewer/domain/use-cases/retrieve_properties.dart';
import 'package:household_accounts/util/domain/entities/category.dart';
import 'package:household_accounts/features/input-page/domain/entities/record.dart';
import 'package:household_accounts/features/input-page/domain/use-cases/add_record.dart';
import 'package:household_accounts/util/domain/use-cases/retrieve_categories.dart';
import 'package:household_accounts/util/failures/failure.dart';
import 'package:household_accounts/util/string-parser.dart';
import 'package:household_accounts/util/use_case.dart';
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
  String? _srcProperty;
  String? _destProperty;
  String _note = '';

  late final Future<dartz.Either<Failure, List<Category>>> _categoriesFuture;
  late final Future<dartz.Either<Failure, List<Property>>> _propertiesFuture;

  @override
  void initState() {
    super.initState();
    _categoriesFuture =
        context.read<RetrieveCategoriesUseCase>().handle(const NoParam());
    _propertiesFuture =
        context.read<RetrievePropertiesUseCase>().handle(const NoParam());
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

  void _setCategoryState(Category? value) {
    setState(() {
      _category = value;
      print('category name: $_category');
    });
  }

  void _setSrcPropertyState(String? value) {
    setState(() {
      _srcProperty = value;
      print('source property: $_srcProperty');
    });
  }

  void _setDestPropertyState(String? value) {
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
          _srcProperty!,
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
          _srcProperty!,
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
          _srcProperty!,
          _destProperty!,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // dummy data
    List<String> dummyProperties = [
      'bank',
      'cash',
      'credit',
    ];

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
          items: dummyProperties,
          onChanged: _setSrcPropertyState,
        ),
        _recordType == RecordType.transfer
            ? _PropertyDropDownMenu(
          value: _destProperty,
          items: dummyProperties,
          onChanged: _setDestPropertyState,
        )
            : _CategoryDropDownMenu(
          categories: _categoriesFuture,
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
  final Future<dartz.Either<Failure, List<Category>>> _categories;
  final Category? _value;
  final CategoryType _displayedType;
  final ValueChanged<Category?>? _onChanged;

  const _CategoryDropDownMenu({
    Key? key,
    required Future<dartz.Either<Failure, List<Category>>> categories,
    Category? value,
    required CategoryType categoryType,
    required ValueChanged<Category?>? onChanged,
  })  : _categories = categories,
        _value = value,
        _displayedType = categoryType,
        _onChanged = onChanged,
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<dartz.Either<Failure, List<Category>>>(
      future: _categories,
      builder: (context, snapshot) {
        Category? value;
        Text? disabledHint;
        List<DropdownMenuItem<Category>>? items;
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
                  .map<DropdownMenuItem<Category>>(
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

        return DropdownButton<Category>(
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
  final String? _dropdownValue;
  final List<String>? _items;
  final ValueChanged<String?>? _onChanged;

  const _PropertyDropDownMenu({
    String? value,
    required List<String>? items,
    required ValueChanged<String?>? onChanged,
    Key? key,
  })  : _dropdownValue = value,
        _items = items,
        _onChanged = onChanged,
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return DropdownButton<String>(
      value: _dropdownValue,
      hint: const Text('Select property'),
      icon: const Icon(Icons.arrow_downward),
      elevation: 16,
      style: const TextStyle(color: Colors.deepPurple),
      underline: Container(
        height: 2,
        color: Colors.deepPurpleAccent,
      ),
      items: _items?.map<DropdownMenuItem<String>>((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value),
        );
      }).toList(),
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

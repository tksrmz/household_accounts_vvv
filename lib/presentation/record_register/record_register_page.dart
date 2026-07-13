import 'package:flutter/material.dart';
import 'package:household_accounts/util/extension/string.dart';
import 'package:provider/provider.dart';

import '../../entity/category.dart';
import '../../entity/property.dart';
import '../../entity/record.dart';
import '../../feature/category_retrieve/retrieve_expense_category_use_case.dart';
import '../../feature/category_retrieve/retrieve_income_category_use_case.dart';
import '../../feature/property_retrieve/property_retrieve_use_case.dart';
import '../../feature/record_register/use_case.dart';
import '../../util/service_locator/main.dart';
import '../../util/type/exception_or.dart';
import '../../util/uuid/uuid.dart';
import '../../v2/presentation/pages/state_managements/selected_note_state.dart';
import '../common_widget/number_text_form_field.dart';
import '../util/model/user_info.dart';
import '../util/repository_selector.dart';

class RecordInputPage extends StatelessWidget {
  const RecordInputPage({super.key});

  @override
  Widget build(BuildContext context) {
    return _PageContents(
      singleOrPair: context.watch<SelectedNoteState>().value,
    );
  }
}

class _PageContents extends StatefulWidget {
  const _PageContents({
    required SelectedNote singleOrPair,
  }) : _singleOrPair = singleOrPair;

  final SelectedNote _singleOrPair;

  @override
  _PageContentsState createState() => _PageContentsState();
}

class _PageContentsState extends State<_PageContents> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  DateTime _recordDate = DateTime.now();
  String _amount = '';
  RecordType _recordType = RecordType.income;
  CategoryBase? _category;
  Property? _srcProperty;
  Property? _destProperty;
  String _note = '';

  late Future<ExceptionOr<List<IncomeCategory>>> _incomeCategoriesFuture;
  late Future<ExceptionOr<List<ExpenseCategory>>> _expenseCategoriesFuture;
  late Future<ExceptionOr<List<Property>>> _propertiesFuture;
  late String _repoId;
  late SelectedNote _sop;

  @override
  void initState() {
    super.initState();
    _setFutures();
  }

  @override
  void didUpdateWidget(_PageContents oldWidget) {
    super.didUpdateWidget(oldWidget);
    _setDropDownValueNull();
    _setFutures();
  }

  void _setDropDownValueNull() {
    // Inorder to avoid an error, _categoryValue must be set to null.
    // If _categoryValue isn't null and the value is not in _CategoryDropDownMenu.items, Flutter throws an error (an exception?).
    // This behavior is mentioned in the Flutter document of DropdownButton class.
    _category = null;
    _srcProperty = null;
    _destProperty = null;
  }

  void _setFutures() {
    _sop = widget._singleOrPair;
    _repoId = context.read<UserInfo>().repoId(_sop);
    _incomeCategoriesFuture = sl<RetrieveIncomeCategoryUseCase>()(
      RetrieveIncomeCategoryInput(
        uid: _repoId,
        repository: selectIncomeCategoryRepository(_sop),
      ),
    );
    _expenseCategoriesFuture = sl<RetrieveExpenseCategoryUseCase>()(
      RetrieveExpenseCategoryInput(
        uid: _repoId,
        repository: selectExpenseCategoryRepository(_sop),
      ),
    );
    _propertiesFuture = sl<RetrievePropertiesUseCase>()(
      RetrievePropertiesInput(
        uid: _repoId,
        repository: selectPropertyRepository(_sop),
      ),
    );
  }

  void _setRecordDateState(DateTime value) {
    setState(() {
      _recordDate = value;
      debugPrint('record date: $_recordDate');
    });
  }

  void _setAmountState(String value) {
    setState(() {
      _amount = value;
      debugPrint('amount: $_amount');
    });
  }

  void _setRecordTypeState(RecordType value) {
    setState(() {
      _recordType = value;
      _setDropDownValueNull();
      debugPrint('record type: $_recordType');
    });
  }

  void _setCategoryState(CategoryBase? value) {
    setState(() {
      _category = value;
      debugPrint('category name: $_category');
    });
  }

  void _setSrcPropertyState(Property? value) {
    setState(() {
      _srcProperty = value;
      debugPrint('source property: $_srcProperty');
    });
  }

  void _setDestPropertyState(Property? value) {
    setState(() {
      _destProperty = value;
      debugPrint('destination property: $_destProperty');
    });
  }

  void _setNoteState(String value) {
    setState(() {
      _note = value;
      debugPrint('note: $_note');
    });
  }

  void _submitIncomeRecord(AddRecordUseCase<IncomeRecord> useCase) {
    if (_category != null && _srcProperty != null) {
      useCase(
        AddRecordInput<IncomeRecord>(
          uid: _repoId,
          record: IncomeRecord(
            id: UUID.generate(),
            recordDate: _recordDate,
            amount: _amount.tryToInt() | 0,
            note: _note,
            category: _category! as IncomeCategory,
            property: _srcProperty!,
            hasCheckedOut: true,
          ),
          repository: selectIncomeRecordRepository(_sop),
        ),
      );
    }
  }

  void _submitExpenseRecord(AddRecordUseCase<ExpenseRecord> useCae) {
    if (_category != null && _srcProperty != null) {
      useCae(
        AddRecordInput<ExpenseRecord>(
          uid: _repoId,
          record: ExpenseRecord(
            id: UUID.generate(),
            recordDate: _recordDate,
            amount: _amount.tryToInt() | 0,
            note: _note,
            category: _category! as ExpenseCategory,
            property: _srcProperty!,
            hasCheckedOut: true,
          ),
          repository: selectExpenseRecordRepository(_sop),
        ),
      );
    }
  }

  void _submitTransferRecord(AddRecordUseCase<TransferRecord> useCase) {
    if (_srcProperty != null && _destProperty != null) {
      useCase(
        AddRecordInput<TransferRecord>(
          uid: _repoId,
          record: TransferRecord(
            id: UUID.generate(),
            recordDate: _recordDate,
            amount: _amount.tryToInt() | 0,
            note: _note,
            source: _srcProperty!,
            destination: _destProperty!,
            hasCheckedOut: true,
          ),
          repository: selectTransferRecordRepository(_sop),
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
              debugPrint('Current state');
              debugPrint('amount: $_amount');
              debugPrint('record date: $_recordDate');
              debugPrint('category type: $_recordType');
              debugPrint('category name: $_category');
              debugPrint('source property: $_srcProperty');
              debugPrint('destination property: $_destProperty');
              debugPrint('note: $_note');

              if (!_formKey.currentState!.validate()) {
                // Tell the user that the input data is invalid.
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('入力が正しくありません'),
                  ),
                );
                return;
              }
              if (_srcProperty == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('資産を選択してください'),
                  ),
                );
                return;
              }
              switch (_recordType) {
                case RecordType.income:
                case RecordType.expense:
                  if (_category == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text('カテゴリを選択してください'),
                      ),
                    );
                    return;
                  }
                  break;

                case RecordType.transfer:
                  if (_destProperty == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text('転送先資産を選択してください'),
                      ),
                    );
                    return;
                  }
                  break;
              }

              // Updates states
              _formKey.currentState!.save();
              // Process data
              switch (_recordType) {
                case RecordType.income:
                  _submitIncomeRecord(sl<AddRecordUseCase<IncomeRecord>>());
                  break;
                case RecordType.expense:
                  _submitExpenseRecord(sl<AddRecordUseCase<ExpenseRecord>>());
                  break;
                case RecordType.transfer:
                  _submitTransferRecord(sl<AddRecordUseCase<TransferRecord>>());
                  break;
              }
              // Reset states
              _formKey.currentState!.reset();

              // Tell the user that the record has been created
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('レコードを登録しました'),
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
  })  : _selectedDate = value,
        _updateRecordDate = recordDateUpdater;

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

  const _AmountTextField({
    FormFieldSetter<String>? onSaved,
  }) : _onSaved = onSaved;

  @override
  Widget build(BuildContext context) {
    return NumberTextFormField(
      decoration: InputDecoration(
        labelText: '金額',
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
  })  : _incomeButtonOnPressed = incomeButtonOnPressed,
        _expenseButtonOnPressed = expenseButtonOnPressed,
        _transferButtonOnPressed = transferButtonOnPressed;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: _incomeButtonOnPressed,
            child: const Text('収入'),
          ),
        ),
        Expanded(
          child: OutlinedButton(
            onPressed: _expenseButtonOnPressed,
            child: const Text('支出'),
          ),
        ),
        Expanded(
          child: OutlinedButton(
            onPressed: _transferButtonOnPressed,
            child: const Text('振替'),
          ),
        ),
      ],
    );
  }
}

class _CategoryDropDownMenu extends StatelessWidget {
  final Future<ExceptionOr<List<CategoryBase>>> _categories;
  final CategoryBase? _value;
  final CategoryType _displayedType;
  final ValueChanged<CategoryBase?>? _onChanged;

  const _CategoryDropDownMenu({
    required Future<ExceptionOr<List<CategoryBase>>> categories,
    CategoryBase? value,
    required CategoryType categoryType,
    required ValueChanged<CategoryBase?>? onChanged,
  })  : _categories = categories,
        _value = value,
        _displayedType = categoryType,
        _onChanged = onChanged;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<ExceptionOr<List<CategoryBase>>>(
      future: _categories,
      builder: (context, snapshot) {
        CategoryBase? value;
        Text? disabledHint;
        List<DropdownMenuItem<CategoryBase>>? items;
        final hasConnected = snapshot.connectionState == ConnectionState.done;

        if (hasConnected && snapshot.hasData) {
          // succeeded, but there may be a failure
          snapshot.data!.fold(
            (failure) {
              // When there is a failure, [items] is set to null to disable [DropdownButton].
              // Then, [value] is set to null to display [disabledHint].
              value = null;
              disabledHint = Text('エラー: ${snapshot.error}');
              items = null;
            },
            (categories) {
              value = _value;
              disabledHint = null;
              items = categories
                  .where((category) => category.type == _displayedType)
                  .map<DropdownMenuItem<CategoryBase>>(
                    (category) => DropdownMenuItem(
                      value: category,
                      child: Text(category.name),
                    ),
                  )
                  .toList();
            },
          );
        } else if (hasConnected && snapshot.hasError) {
          // When an error was occurred, [items] is set to null to disable [DropdownButton].
          // Then, [value] is set to null to display [disabledHint].
          value = null;
          disabledHint = Text('エラー: ${snapshot.error}');
          items = null;
        } else {
          // While loading, [items] is set to null to disable [DropdownButton].
          // Then, [value] is set to null to display [disabledHint].
          value = null;
          disabledHint = Text('ロード中…');
          items = null;
        }

        return DropdownButton<CategoryBase>(
          value: value,
          hint: const Text('カテゴリを選択'),
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
    required Future<ExceptionOr<List<Property>>> properties,
    Property? value,
    required ValueChanged<Property?>? onChanged,
  })  : _properties = properties,
        _value = value,
        _onChanged = onChanged;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<ExceptionOr<List<Property>>>(
      future: _properties,
      builder: (context, snapshot) {
        Property? value;
        Text? disabledHint;
        List<DropdownMenuItem<Property>>? items;
        final hasConnected = snapshot.connectionState == ConnectionState.done;

        if (hasConnected && snapshot.hasData) {
          // succeeded, but there may be a failure
          snapshot.data!.fold(
            (failure) {
              // When there is a failure, [items] is set to null to disable [DropdownButton].
              // Then, [value] is set to null to display [disabledHint].
              value = null;
              disabledHint = Text('エラー: ${snapshot.error}');
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
        } else if (hasConnected && snapshot.hasError) {
          // When an error was occurred, [items] is set to null to disable [DropdownButton].
          // Then, [value] is set to null to display [disabledHint].
          value = null;
          disabledHint = Text('エラー: ${snapshot.error}');
          items = null;
        } else {
          // While loading, [items] is set to null to disable [DropdownButton].
          // Then, [value] is set to null to display [disabledHint].
          value = null;
          disabledHint = Text('ロード中…');
          items = null;
        }

        return DropdownButton<Property>(
          value: value,
          hint: const Text('資産を選択'),
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
  }) : _onSaved = onSaved;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
        decoration: InputDecoration(
          labelText: 'ノート',
          border: OutlineInputBorder(),
        ),
        initialValue: '',
        keyboardType: TextInputType.text,
        onSaved: _onSaved,
        validator: (String? value) {
          if (value == null) {
            return 'ノートを入力してください';
          }

          return null;
        });
  }
}

class _SubmitButton extends StatelessWidget {
  final VoidCallback? _onPressed;

  const _SubmitButton({
    VoidCallback? onPressed,
  }) : _onPressed = onPressed;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: _onPressed,
      child: const Text('登録'),
    );
  }
}

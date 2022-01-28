import 'package:household_accounts/util/domain/entities/identifiable.dart';

class RecordOld extends Identifiable {
  final DateTime dateOfInput;
  final DateTime dateOfRecord;
  final int amount;
  final String note;
  final String categoryId;

  RecordOld(
    String id,
    this.dateOfInput,
    this.dateOfRecord,
    this.amount,
    this.note,
    this.categoryId,
  )   : assert(amount >= 0, 'Record amount is negative.'),
        super(id);

  @override
  List<Object> get props =>
      [id, dateOfInput, dateOfRecord, amount, note, categoryId];
}

enum RecordType { income, expense, transfer }

abstract class Record extends Identifiable {
  final DateTime recordDate;
  final int amount;
  final String note;
  final RecordType type;

  Record(
    String id,
    this.recordDate,
    int amount,
    this.note,
    this.type,
  )   : this.amount = _assertAmount(amount),
        super(id);

  @override
  List<Object> get props => super.props
    ..add(recordDate)
    ..add(amount)
    ..add(note)
    ..add(type);

  // Check amount because this property value depends on user input
  // and the value should be verified.
  static int _assertAmount(int amount) {
    if (amount < 0) {
      throw ArgumentError.value(
        amount,
        'amount',
        'Negative value is not allowed.',
      );
    }
    return amount;
  }
}

abstract class _IncomeOrExpenseRecordBase extends Record {
  final String categoryId;
  final String propertyId;

  _IncomeOrExpenseRecordBase(
    String id,
    DateTime recordDate,
    int amount,
    String note,
    RecordType type,
    this.categoryId,
    this.propertyId,
  )   : assert(categoryId.isNotEmpty, 'Category ID is empty.'),
        assert(propertyId.isNotEmpty, 'Property ID is empty.'),
        super(
          id,
          recordDate,
          amount,
          note,
          type,
        );

  @override
  List<Object> get props => super.props
    ..add(categoryId)
    ..add(propertyId);
}

class IncomeRecord extends _IncomeOrExpenseRecordBase {
  IncomeRecord(
    String id,
    DateTime recordDate,
    int amount,
    String note,
    String categoryId,
    String propertyId,
  ) : super(
          id,
          recordDate,
          amount,
          note,
          RecordType.income,
          categoryId,
          propertyId,
        );
}

class ExpenseRecord extends _IncomeOrExpenseRecordBase {
  ExpenseRecord(
    String id,
    DateTime recordDate,
    int amount,
    String note,
    String categoryId,
    String propertyId,
  ) : super(
          id,
          recordDate,
          amount,
          note,
          RecordType.expense,
          categoryId,
          propertyId,
        );
}

class TransferRecord extends Record {
  final String srcPropertyId;
  final String destPropertyId;

  TransferRecord(
    String id,
    DateTime recordDate,
    int amount,
    String note,
    this.srcPropertyId,
    this.destPropertyId,
  )   : assert(srcPropertyId.isNotEmpty, 'Source property ID is empty.'),
        assert(destPropertyId.isNotEmpty, 'Destination property ID is empty.'),
        super(
          id,
          recordDate,
          amount,
          note,
          RecordType.transfer,
        );

  @override
  List<Object> get props => super.props
    ..add(srcPropertyId)
    ..add(destPropertyId);
}

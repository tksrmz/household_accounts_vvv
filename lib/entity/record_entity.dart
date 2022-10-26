import 'package:household_accounts/util/type/identifiable.dart';

enum RecordType { income, expense, transfer }

extension RecordTypeParsing on RecordType {
  String toShortString() => this.toString().split('.').last;
}

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

class IncomeRecord extends Record {
  IncomeRecord(
    String id,
    DateTime recordDate,
    int amount,
    String note,
    this.categoryId,
    this.propertyId,
  )   : assert(categoryId.isNotEmpty, 'Category ID is empty.'),
        assert(propertyId.isNotEmpty, 'Property ID is empty.'),
        super(
          id,
          recordDate,
          amount,
          note,
          RecordType.income,
        );

  final String categoryId;
  final String propertyId;

  @override
  List<Object> get props => super.props
    ..add(categoryId)
    ..add(propertyId);
}

class ExpenseRecord extends Record {
  ExpenseRecord(
    String id,
    DateTime recordDate,
    int amount,
    String note,
    this.categoryId,
    this.propertyId,
  )   : assert(categoryId.isNotEmpty, 'Category ID is empty.'),
        assert(propertyId.isNotEmpty, 'Property ID is empty.'),
        super(
          id,
          recordDate,
          amount,
          note,
          RecordType.expense,
        );

  final String categoryId;
  final String propertyId;

  @override
  List<Object> get props => super.props
    ..add(categoryId)
    ..add(propertyId);
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

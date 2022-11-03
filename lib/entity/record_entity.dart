import 'package:household_accounts/util/type/identifiable.dart';

import 'category_entity.dart';
import 'property_entity.dart';

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
    this.category,
    this.property,
  ) : super(
          id,
          recordDate,
          amount,
          note,
          RecordType.income,
        );

  final IncomeCategory category;
  final Property property;

  @override
  List<Object> get props => super.props
    ..add(category)
    ..add(property);
}

class ExpenseRecord extends Record {
  ExpenseRecord(
    String id,
    DateTime recordDate,
    int amount,
    String note,
    this.category,
    this.property,
  ) : super(
          id,
          recordDate,
          amount,
          note,
          RecordType.expense,
        );

  final ExpenseCategory category;
  final Property property;

  @override
  List<Object> get props => super.props
    ..add(category)
    ..add(property);
}

class TransferRecord extends Record {
  TransferRecord(
    String id,
    DateTime recordDate,
    int amount,
    String note,
    this.source,
    this.destination,
  ) : super(
          id,
          recordDate,
          amount,
          note,
          RecordType.transfer,
        );

  final Property source;
  final Property destination;

  @override
  List<Object> get props => super.props
    ..add(source)
    ..add(destination);
}

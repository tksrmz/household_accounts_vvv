import '../util/type/identifiable.dart';
import 'category_entity.dart';
import 'property_entity.dart';

enum RecordType { income, expense, transfer }

extension RecordTypeParsing on RecordType {
  String toShortString() => this.toString().split('.').last;
}

@deprecated
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

@deprecated
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

@deprecated
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

@deprecated
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

abstract class Record2 extends Identifiable {
  /// Date that this transaction is happen.
  final DateTime recordDate;

  /// Amount of this record.
  final int amount;

  /// A comment.
  final String note;

  /// Whether an amount of associated property must be modified or not.
  final bool hasCheckedOut;

  final RecordType type;

  Record2({
    required String id,
    required this.recordDate,
    required int amount,
    required this.note,
    required this.hasCheckedOut,
    required this.type,
  })  : this.amount = _assertAmount(amount),
        super(id);

  @override
  List<Object> get props => super.props
    ..add(recordDate)
    ..add(amount)
    ..add(note)
    ..add(hasCheckedOut)
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

class IncomeRecord2 extends Record2 {
  IncomeRecord2({
    required String id,
    required DateTime recordDate,
    required int amount,
    required String note,
    required this.category,
    required this.property,
    required bool hasCheckedOut,
  }) : super(
          id: id,
          recordDate: recordDate,
          amount: amount,
          note: note,
          type: RecordType.income,
          hasCheckedOut: hasCheckedOut,
        );

  final IncomeCategory category;

  /// A property that [amount] will be added to.
  final Property property;

  @override
  List<Object> get props => super.props
    ..add(category)
    ..add(property);
}

class ExpenseRecord2 extends Record2 {
  ExpenseRecord2({
    required String id,
    required DateTime recordDate,
    required int amount,
    required String note,
    required this.category,
    required this.property,
    required bool hasCheckedOut,
  }) : super(
          id: id,
          recordDate: recordDate,
          amount: amount,
          note: note,
          type: RecordType.expense,
          hasCheckedOut: hasCheckedOut,
        );

  final ExpenseCategory category;

  /// A property that [amount] will be subtracted from.
  final Property property;

  @override
  List<Object> get props => super.props
    ..add(category)
    ..add(property);
}

class TransferRecord2 extends Record2 {
  TransferRecord2({
    required String id,
    required DateTime recordDate,
    required int amount,
    required String note,
    required this.source,
    required this.destination,
    required bool hasCheckedOut,
  }) : super(
          id: id,
          recordDate: recordDate,
          amount: amount,
          note: note,
          type: RecordType.transfer,
          hasCheckedOut: hasCheckedOut,
        );

  /// A property that [amount] will be subtracted from.
  final Property source;

  /// A property that [amount] will be added to.
  final Property destination;

  @override
  List<Object> get props => super.props
    ..add(source)
    ..add(destination);
}

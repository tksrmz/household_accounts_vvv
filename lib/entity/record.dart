import '../util/type/identifiable.dart';
import 'category.dart';
import 'property.dart';

enum RecordType { income, expense, transfer }

extension RecordTypeParsing on RecordType {
  String toShortString() => this.toString().split('.').last;
}

abstract class RecordBase extends Identifiable {
  /// Date that this transaction is happen.
  final DateTime recordDate;

  /// Amount of this record.
  final int amount;

  /// A comment.
  final String note;

  /// Whether an amount of associated property must be modified or not.
  final bool hasCheckedOut;

  final RecordType type;

  RecordBase({
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

class IncomeRecord extends RecordBase {
  IncomeRecord({
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

class ExpenseRecord extends RecordBase {
  ExpenseRecord({
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

class TransferRecord extends RecordBase {
  TransferRecord({
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

import 'package:household_accounts/util/domain/entities/identifiable.dart';

class Record extends Identifiable {
  final DateTime dateOfInput;
  final DateTime dateOfRecord;
  final int amount;
  final String note;
  final String categoryId;

  Record(
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

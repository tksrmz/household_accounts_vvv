import 'package:equatable/equatable.dart';

class Budget extends Equatable {
  final int amount;

  const Budget(this.amount) : assert(amount >= 0, 'amount is negative.');

  @override
  List<Object> get props => [
        amount,
      ];

  @override
  bool? get stringify => true;
}

import 'package:equatable/equatable.dart';
import 'package:household_accounts/util/type/use_case.dart';

typedef RetrieveBudgetStateUseCase
    = UseCase<RetrieveBudgetStateInput, RetrieveBudgetStateOutput>;

class RetrieveBudgetStateInput extends Equatable {
  const RetrieveBudgetStateInput({
    required this.begin,
    required this.end,
  });

  /// From when to retrieve budget state(included)
  final DateTime begin;

  /// To when to retrieve budget state(excluded)
  final DateTime end;

  @override
  List<Object?> get props => [
        begin,
        end,
      ];
}

class BudgetState extends Equatable {
  const BudgetState({
    required this.name,
    required this.totalAmount,
    required this.spentAmount,
  });

  /// Name of the category that this budget is related to.
  final String name;

  /// Total budget amount.
  final int totalAmount;

  /// Spent amount.
  final int spentAmount;

  @override
  List<Object?> get props => [
        name,
        totalAmount,
        spentAmount,
      ];
}

class RetrieveBudgetStateOutput extends Equatable {
  const RetrieveBudgetStateOutput({
    required this.begin,
    required this.end,
    required this.states,
  });

  /// From when to retrieve budget state(included)
  final DateTime begin;

  /// To when to retrieve budget state(excluded)
  final DateTime end;
  final List<BudgetState> states;

  @override
  List<Object?> get props => [
        begin,
        end,
        states,
      ];
}

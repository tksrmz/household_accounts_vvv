import '../../entity/category.dart';
import '../../entity/record.dart';
import '../../util/type/repository.dart';
import '../../util/type/use_case.dart';
import '../repository/record_repository.dart';

typedef RetrieveBudgetStateUseCase
    = UseCase<RetrieveBudgetStateInput, RetrieveBudgetStateOutput>;

class RetrieveBudgetStateInput {
  const RetrieveBudgetStateInput({
    required this.uid,
    required this.begin,
    required this.end,
    required this.recordRepository,
    required this.categoryRepository,
  });

  /// Use ID or pair ID.
  final String uid;

  /// From when to retrieve budget state(included)
  final DateTime begin;

  /// To when to retrieve budget state(excluded)
  final DateTime end;

  /// Record repository
  final RecordRepository<ExpenseRecord> recordRepository;

  /// Expense category repository
  final Repository<ExpenseCategory> categoryRepository;
}

class BudgetState {
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
}

class RetrieveBudgetStateOutput {
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
}

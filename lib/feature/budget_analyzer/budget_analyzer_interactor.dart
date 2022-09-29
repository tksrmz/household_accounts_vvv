import 'package:dartz/dartz.dart';
import 'package:household_accounts/entity/category_entity.dart';
import 'package:household_accounts/entity/record_entity.dart';
import 'package:household_accounts/feature/budget_analyzer/budget_analyzer_use_case.dart';
import 'package:household_accounts/feature/repository/category_repository.dart';
import 'package:household_accounts/feature/repository/record_repository.dart';

import '../../util/type/exception_or.dart';

class RetrieveBudgetStateInteractor extends RetrieveBudgetStateUseCase {
  RetrieveBudgetStateInteractor(
    this._recordRepository,
    this._expenseCategoryRepository,
  );

  final RecordRepositoryNew _recordRepository;
  final ExpenseCategoryRepository _expenseCategoryRepository;

  @override
  Future<ExceptionOr<RetrieveBudgetStateOutput>> call(
    RetrieveBudgetStateInput input,
  ) async {
    final ExceptionOr<List<Record>> failureOrRecords =
        await _recordRepository.retrieveRecordsOf(
      input.begin,
      input.end,
    );
    if (failureOrRecords.isLeft()) {
      return failureOrRecords as ExceptionOr<RetrieveBudgetStateOutput>;
    }

    final failureOrCategories = await _expenseCategoryRepository.retrieveAll();
    if (failureOrCategories.isLeft()) {
      return failureOrCategories as ExceptionOr<RetrieveBudgetStateOutput>;
    }

    final List<ExpenseRecord> records = _extractExpenseRecord(
      (failureOrRecords as Right).value,
    );
    final List<ExpenseCategory> categories =
        (failureOrCategories as Right).value;

    final categoryIdToSpentAmount = <String, int>{
      for (var v in categories) v.id: 0
    };
    records.forEach((record) {
      final current = categoryIdToSpentAmount[record.categoryId];
      assert(current != null, '${record.categoryId}');
      final updated = current! + record.amount;
      categoryIdToSpentAmount[record.categoryId] = updated;
    });

    final List<BudgetState> states = List.of(
      categories.map(
        (e) => BudgetState(
          name: e.name,
          totalAmount: e.totalBudget,
          spentAmount: categoryIdToSpentAmount[e.id]!,
        ),
      ),
    );
    return Right(
      RetrieveBudgetStateOutput(
        begin: input.begin,
        end: input.end,
        states: states,
      ),
    );
  }

  List<ExpenseRecord> _extractExpenseRecord(List<Record> records) => List.of(
        records
            .where((element) => element.type == RecordType.expense)
            .map((e) => e as ExpenseRecord),
      );
}

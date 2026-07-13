import 'package:dartz/dartz.dart';

import '../../entity/category.dart';
import '../../entity/record.dart';
import '../../util/type/exception_or.dart';
import 'budget_analyzer_use_case.dart';

class RetrieveBudgetStateInteractor extends RetrieveBudgetStateUseCase {
  @override
  Future<ExceptionOr<RetrieveBudgetStateOutput>> call(
    RetrieveBudgetStateInput input,
  ) async {
    final recordRepository = input.recordRepository;
    final expenseCategoryRepository = input.categoryRepository;

    final ExceptionOr<List<RecordBase>> failureOrRecords =
        await recordRepository.retrieveRecordsOf(
      repoId: input.uid,
      begin: input.begin,
      end: input.end,
    );
    if (failureOrRecords.isLeft()) {
      return failureOrRecords as ExceptionOr<RetrieveBudgetStateOutput>;
    }

    final failureOrCategories = await expenseCategoryRepository.retrieveAll(
      repoId: input.uid,
    );
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
    for (var record in records) {
      final current = categoryIdToSpentAmount[record.category.id];
      assert(current != null, record.category.id);
      final updated = current! + record.amount;
      categoryIdToSpentAmount[record.category.id] = updated;
    }

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

  List<ExpenseRecord> _extractExpenseRecord(List<RecordBase> records) =>
      List.of(
        records
            .where((element) => element.type == RecordType.expense)
            .map((e) => e as ExpenseRecord),
      );
}

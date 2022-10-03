import '../../entity/category_entity.dart';
import '../../util/type/exception_or.dart';
import 'retrieve_expense_category_use_case.dart';

class RetrieveExpenseCategoryInteractor
    implements RetrieveExpenseCategoryUseCase {
  @override
  Future<ExceptionOr<List<ExpenseCategory>>> call(
    RetrieveExpenseCategoryInput input,
  ) {
    final repository = input.repository;

    return repository.retrieveAll(repoId: input.uid);
  }
}

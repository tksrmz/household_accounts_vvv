import '../../entity/category.dart';
import '../../util/type/exception_or.dart';
import 'retrieve_income_category_use_case.dart';

class RetrieveIncomeCategoryInteractor
    implements RetrieveIncomeCategoryUseCase {
  @override
  Future<ExceptionOr<List<IncomeCategory>>> call(
    RetrieveIncomeCategoryInput input,
  ) {
    final repository = input.repository;

    return repository.retrieveAll(repoId: input.uid);
  }
}

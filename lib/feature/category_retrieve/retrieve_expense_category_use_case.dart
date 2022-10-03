import '../../entity/category_entity.dart';
import '../../util/type/repository.dart';
import '../../util/type/use_case.dart';

typedef RetrieveExpenseCategoryUseCase
    = UseCase2<RetrieveExpenseCategoryInput, List<ExpenseCategory>>;

class RetrieveExpenseCategoryInput {
  /// User ID or pair ID.
  final String uid;

  final Repository2<ExpenseCategory> repository;

  const RetrieveExpenseCategoryInput({
    required this.uid,
    required this.repository,
  });
}

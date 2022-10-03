import '../../entity/category_entity.dart';
import '../../util/type/repository.dart';
import '../../util/type/use_case.dart';

typedef RetrieveIncomeCategoryUseCase
    = UseCase2<RetrieveIncomeCategoryInput, List<IncomeCategory>>;

class RetrieveIncomeCategoryInput {
  /// User ID or pair ID.
  final String uid;

  final Repository2<IncomeCategory> repository;

  const RetrieveIncomeCategoryInput({
    required this.uid,
    required this.repository,
  });
}

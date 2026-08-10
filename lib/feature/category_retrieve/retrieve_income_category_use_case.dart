import '../../entity/category.dart';
import '../../util/type/repository.dart';
import '../../util/type/use_case.dart';

typedef RetrieveIncomeCategoryUseCase =
    UseCase<RetrieveIncomeCategoryInput, List<IncomeCategory>>;

class RetrieveIncomeCategoryInput {
  /// User ID or pair ID.
  final String uid;

  final Repository<IncomeCategory> repository;

  const RetrieveIncomeCategoryInput({
    required this.uid,
    required this.repository,
  });
}

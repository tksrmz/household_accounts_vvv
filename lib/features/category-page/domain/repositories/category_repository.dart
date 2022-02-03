import 'package:dartz/dartz.dart';
import 'package:household_accounts/util/domain/entities/category.dart';
import 'package:household_accounts/util/domain/repositories/repository.dart';
import 'package:household_accounts/util/failures/failure.dart';

abstract class CategoryRepository extends Repository<Category> {
  /// Retrieves all categories.
  ///
  /// The list order has no meanings.
  /// Fails if something goes wrong with the repository.
  Future<Either<Failure, List<Category>>> retrieveCategories();
}

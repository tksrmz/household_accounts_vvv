import 'package:household_accounts/entity/property_entity.dart';
import 'package:household_accounts/util/type/repository.dart';

import '../../util/type/exception_or.dart';

abstract class PropertyRepository extends Repository2<Property> {
  /// Retrieves all properties.
  ///
  /// The list order has no meanings.
  /// Fails when something goes wrong with the repository.
  Future<ExceptionOr<List<Property>>> retrieveProperties();
}

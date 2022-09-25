import 'package:dartz/dartz.dart';
import 'package:household_accounts/entity/property_entity.dart';
import 'package:household_accounts/feature/repository/property_repository.dart';

import '../../util/type/exception_or.dart';

/// Although this class is not used, I won't delete this.
/// There is a chance to use this as mock in tests.
class InMemoryPropertyRepository implements PropertyRepository {
  /*
  final _repository = <Property>[
    Property('id1', 'Cash', 100),
    Property('id2', 'Bank', 200),
  ];
  */

  @override
  Future<ExceptionOr<Unit>> deleteById(String id) async {
    throw UnimplementedError();
  }

  @override
  Future<ExceptionOr<Unit>> register(Property property) async {
    throw UnimplementedError();
  }

  @override
  Future<ExceptionOr<List<Property>>> retrieveProperties() async {
    throw UnimplementedError();
  }

  @override
  Future<ExceptionOr<Unit>> update(Property newValue) async {
    throw UnimplementedError();
  }

  @override
  Future<ExceptionOr<Property>> retrieveById(String id) async {
    throw UnimplementedError();
  }
}

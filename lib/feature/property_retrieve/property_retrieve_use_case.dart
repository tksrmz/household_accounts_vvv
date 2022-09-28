import 'package:dartz/dartz.dart';
import 'package:household_accounts/entity/property_entity.dart';
import 'package:household_accounts/util/type/use_case.dart';

typedef RetrievePropertiesUseCase = UseCase2<Unit, List<Property>>;

typedef RetrievePersonalPropertiesUseCase
    = UseCase2<RetrievePersonalPropertiesInput, List<Property>>;

class RetrievePersonalPropertiesInput {
  /// User ID.
  final String uid;

  RetrievePersonalPropertiesInput({
    required this.uid,
  });
}

typedef RetrieveSharedPropertiesUseCase
    = UseCase2<RetrieveSharedPropertiesInput, List<Property>>;

class RetrieveSharedPropertiesInput {
  /// Pair ID.
  final String pairId;

  RetrieveSharedPropertiesInput({
    required this.pairId,
  });
}

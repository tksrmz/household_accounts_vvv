import 'package:dartz/dartz.dart';

import '../../entity/property_entity.dart';
import '../../util/type/exception_or.dart';
import '../../util/type/repository.dart';
import '../../util/type/use_case.dart';
import '../repository/property_repository.dart';

typedef UpdatePersonalPropertyUseCase
    = UseCase2<UpdatePersonalPropertyInput, Property>;

@deprecated
class UpdatePersonalPropertyInput {
  /// User ID.
  final String uid;

  /// ID of the property to be updated.
  final String propertyId;

  /// New property name.
  ///
  /// If this value is null, the property name will not change.
  final String? name;

  /// New property amount.
  ///
  /// If this value is null, the property amount will not change.
  final int? amount;

  const UpdatePersonalPropertyInput({
    required this.uid,
    required this.propertyId,
    this.name,
    this.amount,
  });
}

@deprecated
class UpdatePersonalPropertyInteractor
    implements UpdatePersonalPropertyUseCase {
  final PropertyRepository2 _repository;

  UpdatePersonalPropertyInteractor(this._repository);

  @override
  Future<ExceptionOr<Property>> call(UpdatePersonalPropertyInput input) async {
    final failureOrCurrentValue = await _repository.retrieveById(
      repoId: input.uid,
      id: input.propertyId,
    );
    final failureOrNewValue = failureOrCurrentValue.map(
      (currentValue) => currentValue.copyWith(
        name: input.name,
        amount: input.amount,
      ),
    );

    return await failureOrNewValue.fold(
      (failure) async => Left(failure),
      (newValue) async {
        final failureOrSuccess = await _repository.update(
          repoId: input.uid,
          newValue: newValue,
        );
        return failureOrSuccess.map((_) => newValue);
      },
    );
  }
}

typedef UpdateSharedPropertyUseCase
    = UseCase2<UpdateSharedPropertyInput, Property>;

@deprecated
class UpdateSharedPropertyInput {
  /// User ID.
  final String pairId;

  /// ID of the property to be updated.
  final String propertyId;

  /// New property name.
  ///
  /// If this value is null, the property name will not change.
  final String? name;

  /// New property amount.
  ///
  /// If this value is null, the property amount will not change.
  final int? amount;

  const UpdateSharedPropertyInput({
    required this.pairId,
    required this.propertyId,
    this.name,
    this.amount,
  });
}

@deprecated
class UpdateSharedPropertyInteractor implements UpdateSharedPropertyUseCase {
  final PropertyRepository2 _repository;

  UpdateSharedPropertyInteractor(this._repository);

  @override
  Future<ExceptionOr<Property>> call(UpdateSharedPropertyInput input) async {
    final failureOrCurrentValue = await _repository.retrieveById(
      repoId: input.pairId,
      id: input.propertyId,
    );
    final failureOrNewValue = failureOrCurrentValue.map(
      (currentValue) => currentValue.copyWith(
        name: input.name,
        amount: input.amount,
      ),
    );

    return await failureOrNewValue.fold(
      (failure) async => Left(failure),
      (newValue) async {
        final failureOrSuccess = await _repository.update(
          repoId: input.pairId,
          newValue: newValue,
        );
        return failureOrSuccess.map((_) => newValue);
      },
    );
  }
}

typedef UpdatePropertyUseCase = UseCase2<UpdatePropertyInput, Unit>;

class UpdatePropertyInput {
  /// User ID or pair ID.
  final String uid;

  /// ID of the property to be updated.
  final String propertyId;

  /// New property name.
  ///
  /// If this value is null, the property name will not change.
  final String? name;

  /// New property amount.
  ///
  /// If this value is null, the property amount will not change.
  final int? amount;

  /// Repository where the target property exists.
  final Repository2<Property> repository;

  const UpdatePropertyInput({
    required this.uid,
    required this.propertyId,
    this.name,
    this.amount,
    required this.repository,
  });
}

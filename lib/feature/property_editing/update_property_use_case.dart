import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:household_accounts/entity/property_entity.dart';
import 'package:household_accounts/feature/repository/property_repository.dart';
import 'package:household_accounts/util/type/use_case.dart';

import '../../util/type/exception_or.dart';

@deprecated
typedef UpdatePropertyUseCase = UseCase2<UpdatePropertyInput, Property>;

@deprecated
class UpdatePropertyInput extends Equatable {
  final String id;
  final String? newPropertyName;
  final int? newPropertyAmount;

  const UpdatePropertyInput({
    required String id,
    String? newPropertyName,
    int? newPropertyAmount,
  })  : this.id = id,
        this.newPropertyName = newPropertyName,
        this.newPropertyAmount = newPropertyAmount;

  @override
  List<Object> get props {
    final props = <Object>[id];
    if (newPropertyName != null) {
      props.add(newPropertyName!);
    }
    if (newPropertyAmount != null) {
      props.add(newPropertyAmount!);
    }
    return props;
  }
}

@deprecated
class UpdatePropertyInteractor extends UpdatePropertyUseCase {
  final PropertyRepository _repository;

  UpdatePropertyInteractor(this._repository);

  @override
  Future<ExceptionOr<Property>> call(UpdatePropertyInput input) async {
    final failureOrCurrentValue = await _repository.retrieveById(input.id);
    final failureOrNewValue = failureOrCurrentValue.map((currentValue) {
      final name = input.newPropertyName ?? currentValue.name;
      final amount = input.newPropertyAmount ?? currentValue.amount;
      return Property(input.id, name, amount);
    });

    return await failureOrNewValue.fold(
      (failure) async => Left(failure),
      (newValue) async {
        final failureOrSuccess = await _repository.update(newValue);
        return failureOrSuccess.map((_) => newValue);
      },
    );
  }
}

typedef UpdatePersonalPropertyUseCase
    = UseCase2<UpdatePersonalPropertyInput, Property>;

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

class UpdatePersonalPropertyInteractor extends UpdatePersonalPropertyUseCase {
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

class UpdateSharedPropertyInteractor extends UpdateSharedPropertyUseCase {
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

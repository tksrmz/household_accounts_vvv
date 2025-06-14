import 'package:dartz/dartz.dart';
import 'package:household_accounts/v2/data/services/firestore/personal/personal_property_service.dart';
import 'package:household_accounts/v2/data/models/property_model.dart' as data;

import '../../../domain/models/property.dart';
import '../../../domain/models/vo/property_amount.dart';
import '../../../domain/models/vo/property_id.dart';
import '../../../domain/models/vo/property_name.dart';
import '../../../domain/models/vo/user_id.dart';
import '../../../domain/repositories/property_repository.dart';

class FirestorePropertyRepository implements PropertyRepository {
  const FirestorePropertyRepository(
    this._personalPropertyService,
    this._uid,
  );

  final PersonalPropertyService _personalPropertyService;
  final UserIdVo _uid;

  @override
  Future<Either<Exception, List<PropertyModel>>> fetchAll() async {
    final result = await _personalPropertyService.fetchAll(_uid);
    return result.map((propertyModels) => 
      propertyModels.map((model) => PropertyModel(
        id: PropertyIdVo(model.id),
        name: PropertyNameVo(model.name),
        amount: PropertyAmountVo(model.amount),
      )).toList(growable: false)
    );
  }

  @override
  Future<Either<Exception, Unit>> add(PropertyModel property) async {
    final model = data.PropertyModel(
      id: property.id.value,
      name: property.name.value,
      amount: property.amount.value,
    );
    return _personalPropertyService.add(_uid, model);
  }

  @override
  Future<Either<Exception, Unit>> update(PropertyIdVo id, PropertyModel property) async {
    final model = data.PropertyModel(
      id: property.id.value,
      name: property.name.value,
      amount: property.amount.value,
    );
    return _personalPropertyService.update(_uid, model);
  }

  @override
  Future<Either<Exception, Unit>> delete(PropertyIdVo id) async {
    return _personalPropertyService.delete(_uid, id.value);
  }
}
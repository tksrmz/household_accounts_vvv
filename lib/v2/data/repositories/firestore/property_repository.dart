import 'package:dartz/dartz.dart';
import 'package:household_accounts/v2/data/services/firestore_service.dart';
import 'package:household_accounts/v2/data/models/property_model.dart';

import '../../../domain/models/property.dart';
import '../../../domain/models/vo/property_amount.dart';
import '../../../domain/models/vo/property_id.dart';
import '../../../domain/models/vo/property_name.dart';
import '../../../domain/models/vo/user_id.dart';
import '../../../domain/repositories/property_repository.dart';

class FirestorePropertyRepository implements PropertyRepository {
  const FirestorePropertyRepository(
    this._firestoreService,
    this._uid,
  );

  final FirestoreService _firestoreService;
  final UserIdVo _uid;

  @override
  Future<Either<Exception, List<PropertyVo>>> fetchAll() async {
    final result = await _firestoreService.fetchPersonalProperties(_uid);
    return result.map((propertyModels) => 
      propertyModels.map((model) => PropertyVo(
        id: PropertyIdVo(model.id),
        name: PropertyNameVo(model.name),
        amount: PropertyAmountVo(model.amount),
      )).toList(growable: false)
    );
  }

  @override
  Future<Either<Exception, Unit>> add(PropertyVo property) async {
    final model = PropertyModel(
      id: property.id.value,
      name: property.name.value,
      amount: property.amount.value,
    );
    return _firestoreService.addPersonalProperty(_uid, model);
  }

  @override
  Future<Either<Exception, Unit>> update(PropertyIdVo id, PropertyVo property) async {
    final model = PropertyModel(
      id: property.id.value,
      name: property.name.value,
      amount: property.amount.value,
    );
    return _firestoreService.updatePersonalProperty(_uid, id.value, model);
  }

  @override
  Future<Either<Exception, Unit>> delete(PropertyIdVo id) async {
    return _firestoreService.deletePersonalProperty(_uid, id.value);
  }
}
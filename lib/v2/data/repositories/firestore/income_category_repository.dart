import 'package:dartz/dartz.dart';
import 'package:household_accounts/v2/data/services/firestore_service.dart';
import 'package:household_accounts/v2/data/models/income_category_model.dart' as data;

import '../../../domain/models/income_category.dart';
import '../../../domain/models/vo/category_id.dart';
import '../../../domain/models/vo/category_name.dart';
import '../../../domain/models/vo/user_id.dart';
import '../../../domain/repositories/income_category_repository.dart';

class FirestoreIncomeCategoryRepository implements IncomeCategoryRepository {
  const FirestoreIncomeCategoryRepository(
    this._firestoreService,
    this._uid,
  );

  final FirestoreService _firestoreService;
  final UserIdVo _uid;

  @override
  Future<Either<Exception, List<IncomeCategoryModel>>> fetchAll() async {
    final result = await _firestoreService.fetchPersonalIncomeCategories(_uid);
    return result.map((categoryModels) => 
      categoryModels.map((model) => IncomeCategoryModel(
        id: CategoryIdVo(model.id),
        name: CategoryNameVo(model.name),
      )).toList(growable: false)
    );
  }

  @override
  Future<Either<Exception, Unit>> add(IncomeCategoryModel category) async {
    final model = data.IncomeCategoryModel(
      id: category.id.value,
      name: category.name.value,
    );
    return _firestoreService.addPersonalIncomeCategory(_uid, model);
  }

  @override
  Future<Either<Exception, Unit>> update(CategoryIdVo id, IncomeCategoryModel category) async {
    final model = data.IncomeCategoryModel(
      id: category.id.value,
      name: category.name.value,
    );
    return _firestoreService.updatePersonalIncomeCategory(_uid, id.value, model);
  }

  @override
  Future<Either<Exception, Unit>> delete(CategoryIdVo id) async {
    return _firestoreService.deletePersonalIncomeCategory(_uid, id.value);
  }
}
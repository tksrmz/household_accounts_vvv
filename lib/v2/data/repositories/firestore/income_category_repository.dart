import 'package:dartz/dartz.dart';
import 'package:household_accounts/v2/data/services/firestore/personal/personal_income_category_service.dart';
import 'package:household_accounts/v2/data/models/income_category_model.dart' as data;

import '../../../domain/models/income_category.dart';
import '../../../domain/models/vo/category_id.dart';
import '../../../domain/models/vo/category_name.dart';
import '../../../domain/models/vo/user_id.dart';
import '../../../domain/repositories/income_category_repository.dart';

class FirestoreIncomeCategoryRepository implements IncomeCategoryRepository {
  const FirestoreIncomeCategoryRepository(
    this._personalIncomeCategoryService,
    this._uid,
  );

  final PersonalIncomeCategoryService _personalIncomeCategoryService;
  final UserIdVo _uid;

  @override
  Future<Either<Exception, List<IncomeCategoryModel>>> fetchAll() async {
    final result = await _personalIncomeCategoryService.fetchAll(_uid);
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
    return _personalIncomeCategoryService.add(_uid, model);
  }

  @override
  Future<Either<Exception, Unit>> update(CategoryIdVo id, IncomeCategoryModel category) async {
    final model = data.IncomeCategoryModel(
      id: category.id.value,
      name: category.name.value,
    );
    return _personalIncomeCategoryService.update(_uid, model);
  }

  @override
  Future<Either<Exception, Unit>> delete(CategoryIdVo id) async {
    return _personalIncomeCategoryService.delete(_uid, id.value);
  }
}
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:household_accounts/features/category-page/data/models/category.dart';
import 'package:household_accounts/features/category-page/domain/repositories/category_repository.dart';
import 'package:household_accounts/util/domain/entities/category.dart';
import 'package:household_accounts/util/failures/failure.dart';

import '../../../../constants/firebase/firebase_constant.dart';

class FirebaseCategoryRepository implements CategoryRepository {
  late final _categoriesCollectionRef;

  FirebaseCategoryRepository.of(String uid)
      : _categoriesCollectionRef = FirebaseFirestore.instance
            .collection(
                '/$FIREBASE_COLLECTION_PERSONAL_NOTES/$uid/$FIREBASE_COLLECTION_CATEGORIES')
            .withConverter<CategoryModel>(
              fromFirestore: (snapshot, _) {
                final json = snapshot.data()!;
                return CategoryModel.fromIdAndJson(snapshot.id, json);
              },
              toFirestore: (categoryModel, _) => categoryModel.toJson(),
            );

  @override
  Future<Either<Failure, Unit>> deleteById(String id) {
    // TODO: implement deleteById
    throw UnimplementedError();
  }

  @override
  Future<Either<Failure, Unit>> register(Category value) {
    // TODO: implement register
    throw UnimplementedError();
  }

  @override
  Future<Either<Failure, Category>> retrieveById(String id) {
    // TODO: implement retrieveById
    throw UnimplementedError();
  }

  @override
  Future<Either<Failure, List<Category>>> retrieveCategories() async {
    List<QueryDocumentSnapshot<Category>> categories =
        await _categoriesCollectionRef
            .orderBy('name')
            .get()
            .then((snapshot) => snapshot.docs);
    return Right(
      List.of(
        categories.map((element) => element.data()),
      ),
    );
  }

  @override
  Future<Either<Failure, Unit>> update(Category newValue) {
    // TODO: implement update
    throw UnimplementedError();
  }
}

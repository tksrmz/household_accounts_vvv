import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:household_accounts/features/category-page/data/models/category.dart';
import 'package:household_accounts/features/category-page/domain/repositories/category_repository.dart';
import 'package:household_accounts/util/domain/entities/category.dart';
import 'package:household_accounts/util/failures/failure.dart';

import '../../../../constants/firebase/firebase_constant.dart';

class FirebaseCategoryRepository implements CategoryRepository {
  late final CollectionReference<Category> _categoriesCollectionRef;

  FirebaseCategoryRepository.of(String uid)
      : _categoriesCollectionRef = FirebaseFirestore.instance
            .collection(
                '/$FIREBASE_COLLECTION_PERSONAL_NOTES/$uid/$FIREBASE_COLLECTION_CATEGORIES')
            .withConverter<Category>(
              fromFirestore: (snapshot, _) {
                final json = snapshot.data()!;
                return CategoryModel.fromIdAndJson(snapshot.id, json);
              },
              toFirestore: (category, _) =>
                  CategoryModel.fromCategory(category).toJson(),
            );

  @override
  Future<Either<Failure, Unit>> deleteById(String id) async {
    await _categoriesCollectionRef.doc(id).delete();
    return Right(unit);
  }

  @override
  Future<Either<Failure, Unit>> register(Category value) async {
    await _categoriesCollectionRef.doc(value.id).set(value);
    return Right(unit);
  }

  @override
  Future<Either<Failure, Category>> retrieveById(String id) async {
    DocumentSnapshot<Category> snapshot =
        await _categoriesCollectionRef.doc(id).get();
    if (!snapshot.exists) {
      return Left(RepositoryFailure());
    }

    return Right(snapshot.data()!);
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
  Future<Either<Failure, Unit>> update(Category newValue) async {
    // TODO: Add error handling in the case a document with [newValue.id] doesn't exist.
    await _categoriesCollectionRef
        .doc(newValue.id)
        .update(CategoryModel.fromCategory(newValue).toJson());
    return Right(unit);
  }
}

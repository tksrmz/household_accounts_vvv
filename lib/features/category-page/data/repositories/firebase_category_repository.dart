import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:household_accounts/features/category-page/data/models/category.dart';
import 'package:household_accounts/features/category-page/domain/repositories/category_repository.dart';
import 'package:household_accounts/util/domain/entities/category.dart';
import 'package:household_accounts/util/failures/failure.dart';

import '../../../../constants/firebase/firebase_constant.dart';

class FirebaseIncomeCategoryRepository implements IncomeCategoryRepository {
  late final CollectionReference<IncomeCategoryModel> _categoriesCollectionRef;

  FirebaseIncomeCategoryRepository.personal(String uid)
      : _categoriesCollectionRef = FirebaseFirestore.instance
            .collection(
                '/$FIREBASE_COLLECTION_PERSONAL_NOTES/$uid/$FIREBASE_COLLECTION_INCOME_CATEGORIES')
            .withConverter<IncomeCategoryModel>(
              fromFirestore: (snapshot, _) {
                final json = snapshot.data()!;
                return IncomeCategoryModel.fromIdAndJson(snapshot.id, json);
              },
              toFirestore: (categoryModel, _) => categoryModel.toJson(),
            );

  FirebaseIncomeCategoryRepository.shared(String pairId)
      : _categoriesCollectionRef = FirebaseFirestore.instance
            .collection(
                '/$FIREBASE_COLLECTION_SHARED_NOTES/$pairId/$FIREBASE_COLLECTION_INCOME_CATEGORIES')
            .withConverter<IncomeCategoryModel>(
              fromFirestore: (snapshot, _) {
                final json = snapshot.data()!;
                return IncomeCategoryModel.fromIdAndJson(snapshot.id, json);
              },
              toFirestore: (categoryModel, _) => categoryModel.toJson(),
            );

  @override
  Future<Either<Failure, Unit>> deleteById(String id) async {
    await _categoriesCollectionRef.doc(id).delete();
    return Right(unit);
  }

  @override
  Future<Either<Failure, Unit>> register(IncomeCategory value) async {
    await _categoriesCollectionRef
        .doc(value.id)
        .set(IncomeCategoryModel.fromIncomeCategory(value));
    return Right(unit);
  }

  @override
  Future<Either<Failure, IncomeCategory>> retrieveById(String id) async {
    DocumentSnapshot<IncomeCategoryModel> snapshot =
        await _categoriesCollectionRef.doc(id).get();
    if (!snapshot.exists) {
      return Left(RepositoryFailure());
    }

    return Right(snapshot.data()!);
  }

  @override
  Future<Either<Failure, List<IncomeCategory>>>
      retrieveIncomeCategories() async {
    List<QueryDocumentSnapshot<IncomeCategoryModel>> categories =
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
  Future<Either<Failure, Unit>> update(IncomeCategory newValue) async {
    // TODO: Add error handling in the case a document with [newValue.id] doesn't exist.
    await _categoriesCollectionRef
        .doc(newValue.id)
        .update(IncomeCategoryModel.fromIncomeCategory(newValue).toJson());
    return Right(unit);
  }
}

class FirebaseExpenseCategoryRepository implements ExpenseCategoryRepository {
  late final CollectionReference<ExpenseCategoryModel> _categoriesCollectionRef;

  FirebaseExpenseCategoryRepository.personal(String uid)
      : _categoriesCollectionRef = FirebaseFirestore.instance
            .collection(
                '/$FIREBASE_COLLECTION_PERSONAL_NOTES/$uid/$FIREBASE_COLLECTION_EXPENSE_CATEGORIES')
            .withConverter<ExpenseCategoryModel>(
              fromFirestore: (snapshot, _) {
                final json = snapshot.data()!;
                return ExpenseCategoryModel.fromIdAndJson(snapshot.id, json);
              },
              toFirestore: (categoryModel, _) => categoryModel.toJson(),
            );

  FirebaseExpenseCategoryRepository.shared(String pairId)
      : _categoriesCollectionRef = FirebaseFirestore.instance
            .collection(
                '/$FIREBASE_COLLECTION_SHARED_NOTES/$pairId/$FIREBASE_COLLECTION_EXPENSE_CATEGORIES')
            .withConverter<ExpenseCategoryModel>(
              fromFirestore: (snapshot, _) {
                final json = snapshot.data()!;
                return ExpenseCategoryModel.fromIdAndJson(snapshot.id, json);
              },
              toFirestore: (categoryModel, _) => categoryModel.toJson(),
            );

  @override
  Future<Either<Failure, Unit>> deleteById(String id) async {
    await _categoriesCollectionRef.doc(id).delete();
    return Right(unit);
  }

  @override
  Future<Either<Failure, Unit>> register(ExpenseCategory value) async {
    await _categoriesCollectionRef
        .doc(value.id)
        .set(ExpenseCategoryModel.fromExpenseCategory(value));
    return Right(unit);
  }

  @override
  Future<Either<Failure, ExpenseCategory>> retrieveById(String id) async {
    DocumentSnapshot<ExpenseCategoryModel> snapshot =
        await _categoriesCollectionRef.doc(id).get();
    if (!snapshot.exists) {
      return Left(RepositoryFailure());
    }

    return Right(snapshot.data()!);
  }

  @override
  Future<Either<Failure, List<ExpenseCategory>>>
      retrieveExpenseCategories() async {
    List<QueryDocumentSnapshot<ExpenseCategoryModel>> categories =
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
  Future<Either<Failure, Unit>> update(ExpenseCategory newValue) async {
    // TODO: Add error handling in the case a document with [newValue.id] doesn't exist.
    await _categoriesCollectionRef
        .doc(newValue.id)
        .update(ExpenseCategoryModel.fromExpenseCategory(newValue).toJson());
    return Right(unit);
  }
}

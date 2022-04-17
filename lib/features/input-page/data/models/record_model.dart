import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:household_accounts/features/input-page/domain/entities/record.dart';

import '../../../category-page/data/models/category.dart';
import '../../../property-viewer/data/models/property.dart';

final FromFirestore<CategoryModel> _categoryModelFromFirestore =
    (snapshot, _) => CategoryModel.fromIdAndJson(snapshot.id, snapshot.data()!);
final ToFirestore<CategoryModel> _categoryModelToFirestore =
    (categoryModel, _) => categoryModel.toJson();

final FromFirestore<PropertyModel> _propertyModelFromFirestore =
    (snapshot, _) => PropertyModel.fromIdAndJson(snapshot.id, snapshot.data()!);
final ToFirestore<PropertyModel> _propertyModelToFirestore =
    (propertyModel, _) => propertyModel.toJson();

DocumentReference<CategoryModel> _createCategoryDocumentReference({
  required String categoryId,
  required String categoryCollectionPath,
}) =>
    FirebaseFirestore.instance
        .collection(categoryCollectionPath)
        .doc(categoryId)
        .withConverter<CategoryModel>(
          fromFirestore: _categoryModelFromFirestore,
          toFirestore: _categoryModelToFirestore,
        );

DocumentReference<PropertyModel> _createPropertyDocumentReference({
  required String propertyId,
  required String propertyCollectionPath,
}) =>
    FirebaseFirestore.instance
        .collection(propertyCollectionPath)
        .doc(propertyId)
        .withConverter<PropertyModel>(
          fromFirestore: _propertyModelFromFirestore,
          toFirestore: _propertyModelToFirestore,
        );

class IncomeRecordModel extends IncomeRecord {
  IncomeRecordModel.fromIncomeRecord({
    required IncomeRecord record,
    required String categoryCollectionPath,
    required String propertyCollectionPath,
  })  : categoryRef = _createCategoryDocumentReference(
    categoryId: record.categoryId,
          categoryCollectionPath: categoryCollectionPath,
        ),
        propertyRef = _createPropertyDocumentReference(
          propertyId: record.propertyId,
          propertyCollectionPath: propertyCollectionPath,
        ),
        _createdAt = DateTime.now(),
        super(
          record.id,
          record.recordDate,
          record.amount,
          record.note,
          record.categoryId,
          record.propertyId,
        );

  IncomeRecordModel.fromIdAndJson({
    required String id,
    required Map<String, dynamic> json,
  })  : categoryRef =
            (json['category']!['ref'] as DocumentReference).withConverter(
          fromFirestore: _categoryModelFromFirestore,
          toFirestore: _categoryModelToFirestore,
        ),
        propertyRef =
            (json['property']!['ref'] as DocumentReference).withConverter(
          fromFirestore: _propertyModelFromFirestore,
          toFirestore: _propertyModelToFirestore,
        ),
        _createdAt = (json['createdAt'] as Timestamp).toDate(),
        super(
          id,
          (json['date'] as Timestamp).toDate(),
          json['amount'] as int,
          json['note'] as String,
          (json['category']!['ref'] as DocumentReference).id,
          (json['property']!['ref'] as DocumentReference).id,
        );

  final DocumentReference<CategoryModel> categoryRef;
  final DocumentReference<PropertyModel> propertyRef;
  final DateTime _createdAt;

  Map<String, dynamic> toJson() => {
        'date': recordDate,
        'type': type.toShortString(),
        'amount': amount,
        'property': {
          'ref': propertyRef,
        },
        'category': {
          'ref': categoryRef,
        },
        'note': note,
        'createdAt': _createdAt,
      };
}

class ExpenseRecordModel extends ExpenseRecord {
  ExpenseRecordModel.fromExpenseRecord({
    required ExpenseRecord record,
    required String categoryCollectionPath,
    required String propertyCollectionPath,
  })  : categoryRef = _createCategoryDocumentReference(
    categoryId: record.categoryId,
          categoryCollectionPath: categoryCollectionPath,
        ),
        propertyRef = _createPropertyDocumentReference(
          propertyId: record.propertyId,
          propertyCollectionPath: propertyCollectionPath,
        ),
        _createdAt = DateTime.now(),
        super(
          record.id,
          record.recordDate,
          record.amount,
          record.note,
          record.categoryId,
          record.propertyId,
        );

  ExpenseRecordModel.fromIdAndJson({
    required String id,
    required Map<String, dynamic> json,
  })  : categoryRef =
            (json['category']!['ref'] as DocumentReference).withConverter(
          fromFirestore: _categoryModelFromFirestore,
          toFirestore: _categoryModelToFirestore,
        ),
        propertyRef =
            (json['property']!['ref'] as DocumentReference).withConverter(
          fromFirestore: _propertyModelFromFirestore,
          toFirestore: _propertyModelToFirestore,
        ),
        _createdAt = (json['createdAt'] as Timestamp).toDate(),
        super(
          id,
          (json['date'] as Timestamp).toDate(),
          json['amount'] as int,
          json['note'] as String,
          (json['category']!['ref'] as DocumentReference).id,
          (json['property']!['ref'] as DocumentReference).id,
        );

  final DocumentReference<CategoryModel> categoryRef;
  final DocumentReference<PropertyModel> propertyRef;
  final DateTime _createdAt;

  Map<String, dynamic> toJson() => {
        'date': recordDate,
        'type': type.toShortString(),
        'amount': amount,
        'property': {
          'ref': propertyRef,
        },
        'category': {
          'ref': categoryRef,
        },
        'note': note,
        'createdAt': _createdAt,
      };
}

class TransferRecordModel extends TransferRecord {
  TransferRecordModel.fromTransferRecord({
    required TransferRecord record,
    required String propertyCollectionPath,
  })  : fromPropertyRef = _createPropertyDocumentReference(
    propertyId: record.srcPropertyId,
          propertyCollectionPath: propertyCollectionPath,
        ),
        toPropertyRef = _createPropertyDocumentReference(
          propertyId: record.destPropertyId,
          propertyCollectionPath: propertyCollectionPath,
        ),
        _createdAt = DateTime.now(),
        super(
          record.id,
          record.recordDate,
          record.amount,
          record.note,
          record.srcPropertyId,
          record.destPropertyId,
        );

  TransferRecordModel.fromIdAndJson({
    required String id,
    required Map<String, dynamic> json,
  })  : fromPropertyRef =
            (json['fromProperty']!['ref'] as DocumentReference).withConverter(
          fromFirestore: _propertyModelFromFirestore,
          toFirestore: _propertyModelToFirestore,
        ),
        toPropertyRef =
            (json['toProperty']!['ref'] as DocumentReference).withConverter(
          fromFirestore: _propertyModelFromFirestore,
          toFirestore: _propertyModelToFirestore,
        ),
        _createdAt = (json['createdAt'] as Timestamp).toDate(),
        super(
          id,
          (json['date'] as Timestamp).toDate(),
          json['amount'] as int,
          json['note'] as String,
          (json['fromProperty']!['ref'] as DocumentReference).id,
          (json['toProperty']!['ref'] as DocumentReference).id,
        );

  final DocumentReference<PropertyModel> fromPropertyRef;
  final DocumentReference<PropertyModel> toPropertyRef;
  final DateTime _createdAt;

  Map<String, dynamic> toJson() => {
        'date': recordDate,
        'type': type.toShortString(),
        'amount': amount,
        'fromProperty': {
          'ref': fromPropertyRef,
        },
        'toProperty': {
          'ref': toPropertyRef,
        },
        'note': note,
        'createdAt': _createdAt,
      };
}

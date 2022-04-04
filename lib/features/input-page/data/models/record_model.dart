import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:household_accounts/features/input-page/domain/entities/record.dart';

import '../../../../constants/firebase/firebase_constant.dart';
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
  required String uid,
}) =>
    FirebaseFirestore.instance
        .collection(
            '/$FIREBASE_COLLECTION_PERSONAL_NOTES/$uid/$FIREBASE_COLLECTION_CATEGORIES')
        .doc(categoryId)
        .withConverter<CategoryModel>(
          fromFirestore: _categoryModelFromFirestore,
          toFirestore: _categoryModelToFirestore,
        );

DocumentReference<PropertyModel> _createPropertyDocumentReference({
  required String propertyId,
  required String uid,
}) =>
    FirebaseFirestore.instance
        .collection(
            '/$FIREBASE_COLLECTION_PERSONAL_NOTES/$uid/$FIREBASE_COLLECTION_PROPERTIES')
        .doc(propertyId)
        .withConverter<PropertyModel>(
          fromFirestore: _propertyModelFromFirestore,
          toFirestore: _propertyModelToFirestore,
        );

class IncomeRecordModel extends IncomeRecord {
  IncomeRecordModel.fromIncomeRecord({
    required IncomeRecord record,
    required String uid,
  })  : categoryRef = _createCategoryDocumentReference(
          categoryId: record.categoryId,
          uid: uid,
        ),
        propertyRef = _createPropertyDocumentReference(
          propertyId: record.propertyId,
          uid: uid,
        ),
        _createdAt = FieldValue.serverTimestamp(),
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
    required Map<String, Object?> json,
    required String uid,
  })  : categoryRef =
            (json['category'] as Map<String, DocumentReference>)['ref']!
                .withConverter(
          fromFirestore: _categoryModelFromFirestore,
          toFirestore: _categoryModelToFirestore,
        ),
        propertyRef =
            (json['property'] as Map<String, DocumentReference>)['ref']!
                .withConverter(
          fromFirestore: _propertyModelFromFirestore,
          toFirestore: _propertyModelToFirestore,
        ),
        _createdAt = json['createdAt'] as FieldValue,
        super(
          id,
          (json['date'] as Timestamp).toDate(),
          json['amount'] as int,
          json['note'] as String,
          (json['category'] as Map<String, DocumentReference>)['ref']!.id,
          (json['property'] as Map<String, DocumentReference>)['ref']!.id,
        );

  final DocumentReference<CategoryModel> categoryRef;
  final DocumentReference<PropertyModel> propertyRef;
  final FieldValue _createdAt;

  Map<String, Object?> toJson() =>
      {
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
    required String uid,
  })  : categoryRef = _createCategoryDocumentReference(
          categoryId: record.categoryId,
          uid: uid,
        ),
        propertyRef = _createPropertyDocumentReference(
          propertyId: record.propertyId,
          uid: uid,
        ),
        _createdAt = FieldValue.serverTimestamp(),
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
    required Map<String, Object?> json,
    required String uid,
  })  : categoryRef =
            (json['category'] as Map<String, DocumentReference>)['ref']!
                .withConverter(
          fromFirestore: _categoryModelFromFirestore,
          toFirestore: _categoryModelToFirestore,
        ),
        propertyRef =
            (json['property'] as Map<String, DocumentReference>)['ref']!
                .withConverter(
          fromFirestore: _propertyModelFromFirestore,
          toFirestore: _propertyModelToFirestore,
        ),
        _createdAt = json['createdAt'] as FieldValue,
        super(
        id,
          (json['date'] as Timestamp).toDate(),
          json['amount'] as int,
          json['note'] as String,
          (json['category'] as Map<String, DocumentReference>)['ref']!.id,
          (json['property'] as Map<String, DocumentReference>)['ref']!.id,
        );

  final DocumentReference<CategoryModel> categoryRef;
  final DocumentReference<PropertyModel> propertyRef;
  final FieldValue _createdAt;

  Map<String, Object?> toJson() =>
      {
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
    required String uid,
  })  : fromPropertyRef = _createPropertyDocumentReference(
          propertyId: record.srcPropertyId,
          uid: uid,
        ),
        toPropertyRef = _createPropertyDocumentReference(
          propertyId: record.destPropertyId,
          uid: uid,
        ),
        _createdAt = FieldValue.serverTimestamp(),
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
    required Map<String, Object?> json,
    required String uid,
  })  : fromPropertyRef =
            (json['fromProperty'] as Map<String, DocumentReference>)['ref']!
                .withConverter(
          fromFirestore: _propertyModelFromFirestore,
          toFirestore: _propertyModelToFirestore,
        ),
        toPropertyRef =
            (json['toProperty'] as Map<String, DocumentReference>)['ref']!
                .withConverter(
          fromFirestore: _propertyModelFromFirestore,
          toFirestore: _propertyModelToFirestore,
        ),
        _createdAt = json['createdAt'] as FieldValue,
        super(
        id,
          (json['date'] as Timestamp).toDate(),
          json['amount'] as int,
          json['note'] as String,
          (json['fromProperty'] as Map<String, DocumentReference>)['ref']!.id,
          (json['toProperty'] as Map<String, DocumentReference>)['ref']!.id,
        );

  final DocumentReference<PropertyModel> fromPropertyRef;
  final DocumentReference<PropertyModel> toPropertyRef;
  final FieldValue _createdAt;

  Map<String, Object?> toJson() =>
      {
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

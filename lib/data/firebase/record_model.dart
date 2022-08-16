import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:household_accounts/entity/record_entity.dart';

import 'category_model.dart';
import 'property_model.dart';

final FromFirestore<IncomeCategoryModel> _incomeCategoryModelFromFirestore =
    (snapshot, _) => IncomeCategoryModel.fromIdAndJson(
          snapshot.id,
          snapshot.data()!,
        );
final ToFirestore<IncomeCategoryModel> _incomeCategoryModelToFirestore =
    (model, _) => model.toJson();

final FromFirestore<ExpenseCategoryModel> _expenseCategoryModelFromFirestore =
    (snapshot, _) => ExpenseCategoryModel.fromIdAndJson(
          snapshot.id,
          snapshot.data()!,
        );
final ToFirestore<ExpenseCategoryModel> _expenseCategoryModelToFirestore =
    (model, _) => model.toJson();

final FromFirestore<PropertyModel> _propertyModelFromFirestore =
    (snapshot, _) => PropertyModel.fromIdAndJson(snapshot.id, snapshot.data()!);
final ToFirestore<PropertyModel> _propertyModelToFirestore =
    (propertyModel, _) => propertyModel.toJson();

DocumentReference<IncomeCategoryModel> _createIncomeCategoryDocumentReference({
  required String categoryId,
  required String categoryCollectionPath,
}) =>
    FirebaseFirestore.instance
        .collection(categoryCollectionPath)
        .doc(categoryId)
        .withConverter<IncomeCategoryModel>(
          fromFirestore: _incomeCategoryModelFromFirestore,
          toFirestore: _incomeCategoryModelToFirestore,
        );

DocumentReference<ExpenseCategoryModel>
    _createExpenseCategoryDocumentReference({
  required String categoryId,
  required String categoryCollectionPath,
}) =>
        FirebaseFirestore.instance
            .collection(categoryCollectionPath)
            .doc(categoryId)
            .withConverter<ExpenseCategoryModel>(
              fromFirestore: _expenseCategoryModelFromFirestore,
              toFirestore: _expenseCategoryModelToFirestore,
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
  })  : categoryRef = _createIncomeCategoryDocumentReference(
          categoryId: record.categoryId,
          categoryCollectionPath: categoryCollectionPath,
        ),
        propertyRef = _createPropertyDocumentReference(
          propertyId: record.propertyId,
          propertyCollectionPath: propertyCollectionPath,
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
    required Map<String, dynamic> json,
  })  : categoryRef =
            (json['category']!['ref'] as DocumentReference).withConverter(
          fromFirestore: _incomeCategoryModelFromFirestore,
          toFirestore: _incomeCategoryModelToFirestore,
        ),
        propertyRef =
            (json['property']!['ref'] as DocumentReference).withConverter(
          fromFirestore: _propertyModelFromFirestore,
          toFirestore: _propertyModelToFirestore,
        ),
        _createdAt = json['createdAt'] as Timestamp,
        super(
          id,
          (json['date'] as Timestamp).toDate(),
          json['amount'] as int,
          json['note'] as String,
          (json['category']!['ref'] as DocumentReference).id,
          (json['property']!['ref'] as DocumentReference).id,
        );

  final DocumentReference<IncomeCategoryModel> categoryRef;
  final DocumentReference<PropertyModel> propertyRef;
  final dynamic _createdAt;

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
  })  : categoryRef = _createExpenseCategoryDocumentReference(
          categoryId: record.categoryId,
          categoryCollectionPath: categoryCollectionPath,
        ),
        propertyRef = _createPropertyDocumentReference(
          propertyId: record.propertyId,
          propertyCollectionPath: propertyCollectionPath,
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
    required Map<String, dynamic> json,
  })  : categoryRef =
            (json['category']!['ref'] as DocumentReference).withConverter(
          fromFirestore: _expenseCategoryModelFromFirestore,
          toFirestore: _expenseCategoryModelToFirestore,
        ),
        propertyRef =
            (json['property']!['ref'] as DocumentReference).withConverter(
          fromFirestore: _propertyModelFromFirestore,
          toFirestore: _propertyModelToFirestore,
        ),
        _createdAt = json['createdAt'] as Timestamp,
        super(
          id,
          (json['date'] as Timestamp).toDate(),
          json['amount'] as int,
          json['note'] as String,
          (json['category']!['ref'] as DocumentReference).id,
          (json['property']!['ref'] as DocumentReference).id,
        );

  final DocumentReference<ExpenseCategoryModel> categoryRef;
  final DocumentReference<PropertyModel> propertyRef;
  final dynamic _createdAt;

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
        _createdAt = json['createdAt'] as Timestamp,
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
  final dynamic _createdAt;

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

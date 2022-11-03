import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:household_accounts/entity/record_entity.dart';

import '../../entity/category_entity.dart';
import '../../util/type/json.dart';
import 'category_model.dart';
import 'data_model.dart';
import 'property_model.dart';
import 'util/document_snapshot.dart';
import 'util/get_entity.dart';

final FromFirestore<IncomeCategoryModel> _incomeCategoryModelFromFirestore =
    (snapshot, _) => IncomeCategoryModel.fromJson(snapshot.toJsonWithId());
final ToFirestore<IncomeCategoryModel> _incomeCategoryModelToFirestore =
    (model, _) => model.toJson();

final FromFirestore<ExpenseCategoryModel> _expenseCategoryModelFromFirestore =
    (snapshot, _) => ExpenseCategoryModel.fromJson(snapshot.toJsonWithId());
final ToFirestore<ExpenseCategoryModel> _expenseCategoryModelToFirestore =
    (model, _) => model.toJson();

final FromFirestore<PropertyModel> _propertyModelFromFirestore =
    (snapshot, _) => PropertyModel.fromJson(snapshot.toJsonWithId());
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

abstract class RecordModel extends DataModel<Record> {
  RecordModel.fromEntity(Record entity)
      : id = entity.id,
        recordDate = entity.recordDate,
        amount = entity.amount,
        note = entity.note,
        createdAt = FieldValue.serverTimestamp();

  RecordModel.fromJson(Json json)
      : id = json['id'] as String,
        recordDate = (json['date'] as Timestamp).toDate(),
        amount = json['amount'] as int,
        note = json['note'] as String,
        createdAt = json['createdAt'] as Timestamp;

  final String id;
  final DateTime recordDate;
  final int amount;
  final String note;
  final dynamic createdAt; // type is [FieldValue] or [Timestamp]

  /// DO NOT call this method.
  Record toEntity() {
    throw UnsupportedError('Record cannot be instantiated as it is abstract');
  }

  Json toJson() => {
        'date': recordDate,
        'amount': amount,
        'note': note,
        'createdAt': createdAt,
      };
}

class IncomeRecordModel extends RecordModel {
  IncomeRecordModel.fromEntity({
    required IncomeRecord record,
    required String categoryCollectionPath,
    required String propertyCollectionPath,
  })  : categoryRef = _createIncomeCategoryDocumentReference(
          categoryId: record.category.id,
          categoryCollectionPath: categoryCollectionPath,
        ),
        propertyRef = _createPropertyDocumentReference(
          propertyId: record.property.id,
          propertyCollectionPath: propertyCollectionPath,
        ),
        super.fromEntity(record);

  IncomeRecordModel.fromJson(Json json)
      : categoryRef =
            (json['category']!['ref'] as DocumentReference).withConverter(
          fromFirestore: _incomeCategoryModelFromFirestore,
          toFirestore: _incomeCategoryModelToFirestore,
        ),
        propertyRef =
            (json['property']!['ref'] as DocumentReference).withConverter(
          fromFirestore: _propertyModelFromFirestore,
          toFirestore: _propertyModelToFirestore,
        ),
        super.fromJson(json);

  final DocumentReference<IncomeCategoryModel> categoryRef;
  final DocumentReference<PropertyModel> propertyRef;

  IncomeRecord toEntity() {
    throw UnsupportedError(
      'This class contains DocumentReference. Use [toEntityAsync] instead.',
    );
  }

  Future<IncomeRecord> toEntityAsync() async {
    final category = await _getCategory(categoryRef);
    final property = await getPropertyOrDeletedProperty(propertyRef);
    return IncomeRecord(
      id,
      recordDate,
      amount,
      note,
      category,
      property,
    );
  }

  Future<IncomeCategory> _getCategory(
    DocumentReference<IncomeCategoryModel> ref,
  ) async {
    final snapshot = await ref.get();
    return snapshot.exists
        ? snapshot.data()!.toEntity()
        : deletedIncomeCategory;
  }

  Json toJson() => super.toJson()
    ..addAll({
      'property': {
        'ref': propertyRef,
      },
      'category': {
        'ref': categoryRef,
      },
      'type': 'income',
    });
}

class ExpenseRecordModel extends RecordModel {
  ExpenseRecordModel.fromEntity({
    required ExpenseRecord record,
    required String categoryCollectionPath,
    required String propertyCollectionPath,
  })  : categoryRef = _createExpenseCategoryDocumentReference(
          categoryId: record.category.id,
          categoryCollectionPath: categoryCollectionPath,
        ),
        propertyRef = _createPropertyDocumentReference(
          propertyId: record.property.id,
          propertyCollectionPath: propertyCollectionPath,
        ),
        super.fromEntity(record);

  ExpenseRecordModel.fromJson(Json json)
      : categoryRef =
            (json['category']!['ref'] as DocumentReference).withConverter(
          fromFirestore: _expenseCategoryModelFromFirestore,
          toFirestore: _expenseCategoryModelToFirestore,
        ),
        propertyRef =
            (json['property']!['ref'] as DocumentReference).withConverter(
          fromFirestore: _propertyModelFromFirestore,
          toFirestore: _propertyModelToFirestore,
        ),
        super.fromJson(json);

  final DocumentReference<ExpenseCategoryModel> categoryRef;
  final DocumentReference<PropertyModel> propertyRef;

  ExpenseRecord toEntity() {
    throw UnsupportedError(
      'This class contains DocumentReference. Use [toEntityAsync] instead.',
    );
  }

  Future<ExpenseRecord> toEntityAsync() async {
    final category = await _getCategory(categoryRef);
    final property = await getPropertyOrDeletedProperty(propertyRef);
    return ExpenseRecord(
      id,
      recordDate,
      amount,
      note,
      category,
      property,
    );
  }

  Future<ExpenseCategory> _getCategory(
    DocumentReference<ExpenseCategoryModel> ref,
  ) async {
    final snapshot = await ref.get();
    return snapshot.exists
        ? snapshot.data()!.toEntity()
        : deletedExpenseCategory;
  }

  Json toJson() => super.toJson()
    ..addAll({
      'property': {
        'ref': propertyRef,
      },
      'category': {
        'ref': categoryRef,
      },
      'type': 'expense',
    });
}

class TransferRecordModel extends RecordModel {
  TransferRecordModel.fromEntity({
    required TransferRecord record,
    required String propertyCollectionPath,
  })  : fromPropertyRef = _createPropertyDocumentReference(
          propertyId: record.source.id,
          propertyCollectionPath: propertyCollectionPath,
        ),
        toPropertyRef = _createPropertyDocumentReference(
          propertyId: record.destination.id,
          propertyCollectionPath: propertyCollectionPath,
        ),
        super.fromEntity(record);

  TransferRecordModel.fromJson(Json json)
      : fromPropertyRef =
            (json['fromProperty']!['ref'] as DocumentReference).withConverter(
          fromFirestore: _propertyModelFromFirestore,
          toFirestore: _propertyModelToFirestore,
        ),
        toPropertyRef =
            (json['toProperty']!['ref'] as DocumentReference).withConverter(
          fromFirestore: _propertyModelFromFirestore,
          toFirestore: _propertyModelToFirestore,
        ),
        super.fromJson(json);

  final DocumentReference<PropertyModel> fromPropertyRef;
  final DocumentReference<PropertyModel> toPropertyRef;

  ExpenseRecord toEntity() {
    throw UnsupportedError(
        'This class contains DocumentReference. Use [toEntityAsync] instead.');
  }

  Future<TransferRecord> toEntityAsync() async {
    final source = await getPropertyOrDeletedProperty(fromPropertyRef);
    final destination = await getPropertyOrDeletedProperty(toPropertyRef);
    return TransferRecord(
      id,
      recordDate,
      amount,
      note,
      source,
      destination,
    );
  }

  Json toJson() => super.toJson()
    ..addAll({
      'fromProperty': {
        'ref': fromPropertyRef,
      },
      'toProperty': {
        'ref': toPropertyRef,
      },
      'type': 'transfer',
    });
}

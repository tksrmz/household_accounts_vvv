import 'package:cloud_firestore/cloud_firestore.dart';

import '../../entity/category_entity.dart';
import '../../entity/record_entity.dart';
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

abstract class RecordBaseModel implements DataModel<RecordBase> {
  RecordBaseModel.fromEntity(RecordBase entity)
      : id = entity.id,
        recordDate = entity.recordDate,
        amount = entity.amount,
        note = entity.note,
        hasCheckedOut = entity.hasCheckedOut,
        createdAt = FieldValue.serverTimestamp();

  RecordBaseModel.fromJson(Json json)
      : id = json['id'] as String,
        recordDate = (json['date'] as Timestamp).toDate(),
        amount = json['amount'] as int,
        note = json['note'] as String,
        hasCheckedOut = (json['hasCheckedOut'] ?? true) as bool,
        createdAt = json['createdAt'] as Timestamp;

  final String id;
  final DateTime recordDate;
  final int amount;
  final String note;
  final bool hasCheckedOut;
  final dynamic createdAt; // type is [FieldValue] or [Timestamp]

  @override
  Json toJson() => {
        'date': recordDate,
        'amount': amount,
        'note': note,
        'hasCheckedOut': hasCheckedOut,
        'createdAt': createdAt,
      };
}

class IncomeRecordModel extends RecordBaseModel {
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

  @override
  IncomeRecord toEntity() {
    throw UnsupportedError(
      'This class contains DocumentReference. Use [toEntityAsync] instead.',
    );
  }

  Future<IncomeRecord> toEntityAsync() async => IncomeRecord(
        id: id,
        recordDate: recordDate,
        amount: amount,
        note: note,
        category: await _getCategory(),
        property: await getPropertyOrDeletedProperty(propertyRef),
        hasCheckedOut: hasCheckedOut,
      );

  Future<IncomeCategory> _getCategory() async {
    final snapshot = await categoryRef.get();
    return snapshot.exists
        ? snapshot.data()!.toEntity()
        : deletedIncomeCategory;
  }

  @override
  Json toJson() => super.toJson()
    ..addAll(
      {
        'property': {
          'ref': propertyRef,
        },
        'category': {
          'ref': categoryRef,
        },
        'type': 'income',
      },
    );
}

class ExpenseRecordModel extends RecordBaseModel {
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

  @override
  ExpenseRecord toEntity() {
    throw UnsupportedError(
      'This class contains DocumentReference. Use [toEntityAsync] instead.',
    );
  }

  Future<ExpenseRecord> toEntityAsync() async => ExpenseRecord(
        id: id,
        recordDate: recordDate,
        amount: amount,
        note: note,
        category: await _getCategory(),
        property: await getPropertyOrDeletedProperty(propertyRef),
        hasCheckedOut: hasCheckedOut,
      );

  Future<ExpenseCategory> _getCategory() async {
    final snapshot = await categoryRef.get();
    return snapshot.exists
        ? snapshot.data()!.toEntity()
        : deletedExpenseCategory;
  }

  @override
  Json toJson() => super.toJson()
    ..addAll(
      {
        'property': {
          'ref': propertyRef,
        },
        'category': {
          'ref': categoryRef,
        },
        'type': 'expense',
      },
    );
}

class TransferRecordModel extends RecordBaseModel {
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

  @override
  TransferRecord toEntity() {
    throw UnsupportedError(
        'This class contains DocumentReference. Use [toEntityAsync] instead.');
  }

  Future<TransferRecord> toEntityAsync() async {
    return TransferRecord(
      id: id,
      recordDate: recordDate,
      amount: amount,
      note: note,
      source: await getPropertyOrDeletedProperty(fromPropertyRef),
      destination: await getPropertyOrDeletedProperty(toPropertyRef),
      hasCheckedOut: hasCheckedOut,
    );
  }

  Json toJson() => super.toJson()
    ..addAll(
      {
        'fromProperty': {
          'ref': fromPropertyRef,
        },
        'toProperty': {
          'ref': toPropertyRef,
        },
        'type': 'transfer',
      },
    );
}

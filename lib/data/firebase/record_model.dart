import 'package:cloud_firestore/cloud_firestore.dart';

import '../../entity/category.dart';
import '../../entity/record.dart';
import '../../util/type/json.dart';
import 'category_model.dart';
import 'data_model.dart';
import 'property_model.dart';
import 'util/document_snapshot.dart';
import 'util/get_entity.dart';

IncomeCategoryModel _incomeCategoryModelFromFirestore(
  DocumentSnapshot<Json> snapshot,
  SnapshotOptions? _,
) => IncomeCategoryModel.fromJson(snapshot.toJsonWithId());
Json _incomeCategoryModelToFirestore(
  IncomeCategoryModel model,
  SetOptions? _,
) => model.toJson();

ExpenseCategoryModel _expenseCategoryModelFromFirestore(
  DocumentSnapshot<Json> snapshot,
  SnapshotOptions? _,
) => ExpenseCategoryModel.fromJson(snapshot.toJsonWithId());
Json _expenseCategoryModelToFirestore(
  ExpenseCategoryModel model,
  SetOptions? _,
) => model.toJson();

PropertyModel _propertyModelFromFirestore(
  DocumentSnapshot<Json> snapshot,
  SnapshotOptions? _,
) => PropertyModel.fromJson(snapshot.toJsonWithId());
Json _propertyModelToFirestore(PropertyModel propertyModel, SetOptions? _) =>
    propertyModel.toJson();

abstract class RecordBaseModel implements DataModel<RecordBase> {
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
  IncomeRecordModel.fromJson(super.json)
    : categoryRef = (json['category']!['ref'] as DocumentReference)
          .withConverter(
            fromFirestore: _incomeCategoryModelFromFirestore,
            toFirestore: _incomeCategoryModelToFirestore,
          ),
      propertyRef = (json['property']!['ref'] as DocumentReference)
          .withConverter(
            fromFirestore: _propertyModelFromFirestore,
            toFirestore: _propertyModelToFirestore,
          ),
      super.fromJson();

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
    ..addAll({
      'property': {'ref': propertyRef},
      'category': {'ref': categoryRef},
      'type': 'income',
    });
}

class ExpenseRecordModel extends RecordBaseModel {
  ExpenseRecordModel.fromJson(super.json)
    : categoryRef = (json['category']!['ref'] as DocumentReference)
          .withConverter(
            fromFirestore: _expenseCategoryModelFromFirestore,
            toFirestore: _expenseCategoryModelToFirestore,
          ),
      propertyRef = (json['property']!['ref'] as DocumentReference)
          .withConverter(
            fromFirestore: _propertyModelFromFirestore,
            toFirestore: _propertyModelToFirestore,
          ),
      super.fromJson();

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
    ..addAll({
      'property': {'ref': propertyRef},
      'category': {'ref': categoryRef},
      'type': 'expense',
    });
}

class TransferRecordModel extends RecordBaseModel {
  TransferRecordModel.fromJson(super.json)
    : fromPropertyRef = (json['fromProperty']!['ref'] as DocumentReference)
          .withConverter(
            fromFirestore: _propertyModelFromFirestore,
            toFirestore: _propertyModelToFirestore,
          ),
      toPropertyRef = (json['toProperty']!['ref'] as DocumentReference)
          .withConverter(
            fromFirestore: _propertyModelFromFirestore,
            toFirestore: _propertyModelToFirestore,
          ),
      super.fromJson();

  final DocumentReference<PropertyModel> fromPropertyRef;
  final DocumentReference<PropertyModel> toPropertyRef;

  @override
  TransferRecord toEntity() {
    throw UnsupportedError(
      'This class contains DocumentReference. Use [toEntityAsync] instead.',
    );
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

  @override
  Json toJson() => super.toJson()
    ..addAll({
      'fromProperty': {'ref': fromPropertyRef},
      'toProperty': {'ref': toPropertyRef},
      'type': 'transfer',
    });
}

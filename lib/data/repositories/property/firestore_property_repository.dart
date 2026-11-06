import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../domain/models/notebook.dart';
import '../../../domain/models/property.dart';
import '../../../domain/models/property_id.dart';
import '../../../domain/models/property_name.dart';
import '../../../utils/result.dart';
import '../firestore_shared/notebook_paths.dart';
import 'property_dto.dart';
import 'property_repository.dart';

// このRepositoryの単体テストは書かない。ドキュメント変換・書き込みJSONは
// property_dto_test.dartで担保しており、Firestoreの購読・書き込みそのものは
// フェイクでは検証にならないためintegrationテストで担保する。

class FirestorePropertyRepository implements PropertyRepository {
  FirestorePropertyRepository(this._db, this._notebook);

  final FirebaseFirestore _db;
  final Notebook _notebook;

  @override
  Stream<List<Property>> watchAll() =>
      // 名前順は旧実装(retrieveAllのorderBy('name'))の踏襲。ドキュメントID順に
      // すると選択肢の並びが実質ランダムになってしまう
      _collection
          .orderBy('name')
          .snapshots()
          .map(
            (snapshot) => snapshot.docs
                .map((doc) => PropertyDto.fromSnapshot(doc).toDomain())
                .toList(),
          );

  @override
  Future<Result<void>> add({
    required PropertyName name,
    required int balance,
  }) => Result.guard(
    () => _collection.add(propertyCreateJson(name: name, balance: balance)),
  );

  @override
  Future<Result<void>> update(
    PropertyId id, {
    PropertyName? name,
    int? balance,
  }) => Result.guard(() => _update(id, name: name, balance: balance));

  // ArgumentErrorはExceptionではないためResult.guardに捕捉されず、
  // 呼び出し側の不具合としてそのまま伝播する(fail fast)。
  Future<void> _update(PropertyId id, {PropertyName? name, int? balance}) {
    if (name == null && balance == null) {
      throw ArgumentError('nameとbalanceの少なくとも一方を指定してください');
    }
    return _collection
        .doc(id.value)
        .update(propertyUpdateJson(name: name, balance: balance));
  }

  @override
  Future<Result<void>> delete(PropertyId id) =>
      Result.guard(() => _collection.doc(id.value).delete());

  CollectionReference<Map<String, dynamic>> get _collection =>
      _db.collection('${notebookPath(_notebook)}/properties');
}

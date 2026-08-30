import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../domain/models/notebook.dart';
import '../../../domain/models/property.dart';
import '../firestore_shared/notebook_paths.dart';
import 'property_dto.dart';
import 'property_repository.dart';

// このRepositoryの単体テストは書かない。ドキュメント変換はproperty_dto_test.dartで
// 担保しており、Firestoreの購読そのものはフェイクでは検証にならないため
// integrationテストで担保する。

class FirestorePropertyRepository implements PropertyRepository {
  FirestorePropertyRepository(this._db, this._notebook);

  final FirebaseFirestore _db;
  final Notebook _notebook;

  @override
  Stream<List<Property>> watchAll() =>
      // 名前順は旧実装(retrieveAllのorderBy('name'))の踏襲。ドキュメントID順に
      // すると選択肢の並びが実質ランダムになってしまう
      _db
          .collection('${notebookPath(_notebook)}/properties')
          .orderBy('name')
          .snapshots()
          .map(
            (snapshot) => snapshot.docs
                .map((doc) => PropertyDto.fromSnapshot(doc).toDomain())
                .toList(),
          );
}

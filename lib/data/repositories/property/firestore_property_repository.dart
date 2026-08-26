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
      // orderByは付けない: 旧実装もクエリの既定順(ドキュメントID順)のまま
      // 扱っており、挙動変更を増やさないため踏襲する。
      _db
          .collection('${notebookPath(_notebook)}/properties')
          .snapshots()
          .map(
            (snapshot) => snapshot.docs
                .map((doc) => PropertyDto.fromSnapshot(doc).toDomain())
                .toList(),
          );
}

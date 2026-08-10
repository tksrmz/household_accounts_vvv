import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../util/type/json.dart';

extension ToJson on DocumentSnapshot<Json> {
  Json toJsonWithId() => exists ? (data()!..addAll({'id': id})) : {};
}

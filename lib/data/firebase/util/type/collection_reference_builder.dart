import 'package:cloud_firestore/cloud_firestore.dart';

typedef CollectionReferenceBuilder<T> = CollectionReference<T> Function(
  String repoId,
);

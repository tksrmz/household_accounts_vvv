import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../entity/property_entity.dart';
import '../property_model.dart';

/// Get [Property] related to [ref].
///
/// When the referenced document does not exist,
/// the returned [Future] will resolve to [null].
Future<Property?> getProperty(DocumentReference<PropertyModel> ref) async {
  final snapshot = await ref.get();
  return snapshot.data()?.toEntity();
}

/// Same to [getProperty] except that this returns [deletedProperty] instead of [null].
Future<Property> getPropertyOrDeletedProperty(
        DocumentReference<PropertyModel> ref) =>
    getProperty(ref).then((data) => data ?? deletedProperty);

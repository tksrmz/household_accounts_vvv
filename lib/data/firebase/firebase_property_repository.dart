import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:household_accounts/data/firebase/property_model.dart';
import 'package:household_accounts/feature/repository/property_repository.dart';
import 'package:household_accounts/entity/property_entity.dart';
import 'package:household_accounts/util/type/failure.dart';
import 'package:household_accounts/util/constant/firebase_constant.dart';

class FirebasePropertyRepository implements PropertyRepository {
  late final CollectionReference<PropertyModel> _propertiesCollectionRef;

  FirebasePropertyRepository.personal(String uid)
      : _propertiesCollectionRef = FirebaseFirestore.instance
            .collection(
                '/$FIREBASE_COLLECTION_PERSONAL_NOTES/$uid/$FIREBASE_COLLECTION_PROPERTIES')
            .withConverter<PropertyModel>(
              fromFirestore: (snapshot, _) {
                final json = snapshot.data()!;
                return PropertyModel.fromIdAndJson(snapshot.id, json);
              },
              toFirestore: (propertyModel, _) => propertyModel.toJson(),
            );

  FirebasePropertyRepository.shared(String pairId)
      : _propertiesCollectionRef = FirebaseFirestore.instance
            .collection(
                '/$FIREBASE_COLLECTION_SHARED_NOTES/$pairId/$FIREBASE_COLLECTION_PROPERTIES')
            .withConverter<PropertyModel>(
              fromFirestore: (snapshot, _) {
                final json = snapshot.data()!;
                return PropertyModel.fromIdAndJson(snapshot.id, json);
              },
              toFirestore: (propertyModel, _) => propertyModel.toJson(),
            );

  @override
  Future<Either<Failure, Unit>> deleteById(String id) async {
    await _propertiesCollectionRef.doc(id).delete();
    return Right(unit);
  }

  @override
  Future<Either<Failure, Unit>> register(Property value) async {
    await _propertiesCollectionRef
        .doc(value.id)
        .set(PropertyModel.fromProperty(value));
    return Right(unit);
  }

  @override
  Future<Either<Failure, Property>> retrieveById(String id) async {
    DocumentSnapshot<PropertyModel> snapshot =
        await _propertiesCollectionRef.doc(id).get();
    if (!snapshot.exists) {
      return Left(RepositoryFailure());
    }

    return Right(snapshot.data()!);
  }

  @override
  Future<Either<Failure, List<Property>>> retrieveProperties() async {
    List<QueryDocumentSnapshot<PropertyModel>> properties =
        await _propertiesCollectionRef
            .orderBy('name')
            .get()
            .then((snapshot) => snapshot.docs);
    return Right(List.of(properties.map((prop) => prop.data())));
  }

  @override
  Future<Either<Failure, Unit>> update(Property newValue) async {
    // TODO: Add error handling in the case a document with [newValue.id] doesn't exist.
    await _propertiesCollectionRef
        .doc(newValue.id)
        .update(PropertyModel.fromProperty(newValue).toJson());
    return Right(unit);
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/models/vo/user_id.dart';
import '../../domain/models/vo/user_name.dart';
import '../../domain/repositories/public_profile_repository.dart';

class FirebasePublicProfileRepository implements PublicProfileRepository {
  const FirebasePublicProfileRepository(this.db);

  final FirebaseFirestore db;

  @override
  Future<UserNameVo> fetchUserName(UserIdVo userId) {
    // TODO: implement fetchUserName
    throw UnimplementedError();
  }
}

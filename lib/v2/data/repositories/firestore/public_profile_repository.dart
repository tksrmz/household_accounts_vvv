import 'package:household_accounts/v2/data/services/firestore_service.dart';

import '../../../domain/models/vo/user_id.dart';
import '../../../domain/models/vo/user_name.dart';
import '../../../domain/repositories/public_profile_repository.dart';

class FirestorePublicProfileRepository implements PublicProfileRepository {
  const FirestorePublicProfileRepository(this._firestoreService);

  final FirestoreService _firestoreService;

  @override
  Future<UserNameVo> fetchUserName(UserIdVo userId) async {
    final profileData = await _firestoreService.fetchPublicProfileOf(userId);
    return UserNameVo(profileData['name']! as String);
  }

  @override
  Future<void> updateUserName(UserIdVo userId, UserNameVo userName) async {
    await _firestoreService.updatePublicProfileNameOf(userId, userName);
  }
}

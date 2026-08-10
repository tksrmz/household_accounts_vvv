import 'package:dartz/dartz.dart';
import 'package:household_accounts/v2/data/services/firestore/profile/public_profile_service.dart';

import '../../../domain/models/vo/user_id.dart';
import '../../../domain/models/vo/user_name.dart';
import '../../../domain/repositories/public_profile_repository.dart';

class FirestorePublicProfileRepository implements PublicProfileRepository {
  const FirestorePublicProfileRepository(this._publicProfileService);

  final PublicProfileService _publicProfileService;

  @override
  Future<Either<Exception, UserNameVo>> fetchUserName(UserIdVo userId) async {
    final result = await _publicProfileService.fetchPublicProfileOf(userId);
    return result.map(
      (profileData) => UserNameVo(profileData['name']! as String),
    );
  }

  @override
  Future<Either<Exception, Unit>> updateUserName(
    UserIdVo userId,
    UserNameVo userName,
  ) async {
    return await _publicProfileService.updatePublicProfileNameOf(
      userId,
      userName,
    );
  }
}

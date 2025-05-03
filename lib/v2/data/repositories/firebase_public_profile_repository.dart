import 'package:household_accounts/v2/domain/models/vo/user_id.dart';
import 'package:household_accounts/v2/domain/models/vo/user_name.dart';
import 'package:household_accounts/v2/domain/repositories/public_profile_repository.dart';

class FirebasePublicProfileRepository implements PublicProfileRepository {
  const FirebasePublicProfileRepository();

  @override
  Future<UserNameVo> fetchUserName(UserIdVo userId) {
    // TODO: implement fetchUserName
    throw UnimplementedError();
  }
}

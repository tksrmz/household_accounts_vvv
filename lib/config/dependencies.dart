import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

import '../data/repositories/auth/auth_repository.dart';
import '../data/repositories/category/category_repository.dart';
import '../data/repositories/category/firestore_category_repository.dart';
import '../data/repositories/profile/firestore_profile_repository.dart';
import '../data/repositories/profile/profile_repository.dart';
import '../data/repositories/property/firestore_property_repository.dart';
import '../data/repositories/property/property_repository.dart';
import '../data/repositories/record/firestore_record_repository.dart';
import '../data/repositories/record/record_repository.dart';
import '../domain/models/notebook.dart';
import '../domain/models/user_auth.dart';
import '../domain/models/user_id.dart';
import '../ui/core/selected_notebook.dart';

/// アプリ全域・長寿命の依存(Repository・共有状態)のProvider登録一覧。
///
/// AuthRepositoryインスタンスを先に生成する方式で1段に平坦化した。
List<SingleChildWidget> appProviders(AuthRepository authRepository) => [
  ChangeNotifierProvider(create: (_) => SelectedNotebook()),
  Provider<AuthRepository>.value(value: authRepository),
  Provider<FirebaseFirestore>.value(value: FirebaseFirestore.instance),
  Provider<ProfileRepository>(
    create: (context) => FirestoreProfileRepository(context.read()),
  ),
  StreamProvider<UserAuth>(
    // lazy: false は必須。旧実装はAuthGateが起動直後からwatchしていたため
    // 常に購読済みだったが、新実装のredirectはAuthRepositoryを直接読むので
    // 誰も読まないままだと、最初にreadされた瞬間に古いinitialData
    // (起動時の未サインイン状態)が返り、ダッシュボードのRepositoryが
    // 誤ったuidで生成されてしまう。
    lazy: false,
    initialData: authRepository.getCurrentUser(),
    create: (_) => authRepository.authStateChanges(),
  ),
  ProxyProvider2<SelectedNotebook, UserAuth, RecordRepository>(
    update: (context, selectedNotebook, user, _) => FirestoreRecordRepository(
      context.read<FirebaseFirestore>(),
      _resolveNotebook(selectedNotebook, user),
    ),
  ),
  ProxyProvider2<SelectedNotebook, UserAuth, CategoryRepository>(
    update: (context, selectedNotebook, user, _) => FirestoreCategoryRepository(
      context.read<FirebaseFirestore>(),
      _resolveNotebook(selectedNotebook, user),
    ),
  ),
  ProxyProvider2<SelectedNotebook, UserAuth, PropertyRepository>(
    update: (context, selectedNotebook, user, _) => FirestorePropertyRepository(
      context.read<FirebaseFirestore>(),
      _resolveNotebook(selectedNotebook, user),
    ),
  ),
];

/// 現在の選択状態と認証状態から、Repositoryが読み書きするノートを決める。
Notebook _resolveNotebook(SelectedNotebook selectedNotebook, UserAuth user) =>
    switch (user) {
      UserAuthSignedIn(:final uid) => selectedNotebook.resolve(uid),
      // サインイン前もProviderの評価自体は走るが、routerのredirectにより
      // 画面がこのRepositoryを購読する前にサインイン画面へ遷移する。
      // 使われない間のプレースホルダとして無害な個人ノートを与える
      UserAuthNotSignedIn() => Notebook.personal(UserId('not-signed-in')),
    };

import 'dart:collection';

import 'package:flutter/widgets.dart';

import '../../entity/property_entity.dart';
import '../../feature/property_retrieve/property_retrieve_use_case.dart';
import '../../util/service_locator/main.dart';
import '../../util/type/single_or_pair.dart';
import '../util/model/user_info.dart';
import '../util/repository_selector.dart';

class PropertyListState2 with ChangeNotifier {
  // States
  List<Property> _properties = [];
  bool _isLoading = false;
  Exception? _failure;

  UnmodifiableListView<Property> get properties =>
      UnmodifiableListView(_properties);

  bool get isLoading => _isLoading;

  bool get hasFailure => _failure != null;

  Exception? get failure => _failure;

  Future<void> fetch({
    required SingleOrPair singleOrPair,
    required UserInfo userInfo,
  }) async {
    print('$PropertyListState2#$fetch(${singleOrPair.name}, $userInfo)');
    _isLoading = true;
    _failure = null;
    notifyListeners();

    final retrieve = sl<RetrievePropertiesUseCase>();
    final failureOrProperties = await retrieve(
      RetrievePropertiesInput(
        uid: userInfo.repoId(singleOrPair),
        repository: selectPropertyRepository(singleOrPair),
      ),
    );
    failureOrProperties.fold(
      (failure) {
        print(
            '$PropertyListState2#$fetch: retrieve use case failed. $_failure');
        _failure = failure;
        _properties = [];
      },
      (props) {
        print('$PropertyListState2#$fetch: retrieve use case succeeded.');
        _properties = props;
      },
    );
    _isLoading = false;
    notifyListeners();
  }
}

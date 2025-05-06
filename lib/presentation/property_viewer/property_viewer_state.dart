import 'dart:collection';

import 'package:flutter/widgets.dart';

import '../../entity/property.dart';
import '../../feature/property_retrieve/property_retrieve_use_case.dart';
import '../../util/service_locator/main.dart';
import '../../v2/presentation/pages/state_managements/selected_note_state.dart';
import '../util/model/user_info.dart';
import '../util/repository_selector.dart';

class PropertyListState with ChangeNotifier {
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
    required SelectedNote singleOrPair,
    required UserInfo userInfo,
  }) async {
    print('$PropertyListState#$fetch(${singleOrPair.name}, $userInfo)');
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
        print('$PropertyListState#$fetch: retrieve use case failed. $_failure');
        _failure = failure;
        _properties = [];
      },
      (props) {
        print('$PropertyListState#$fetch: retrieve use case succeeded.');
        _properties = props;
      },
    );
    _isLoading = false;
    notifyListeners();
  }
}

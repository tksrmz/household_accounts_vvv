import 'dart:collection';

import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../entity/property_entity.dart';
import '../../feature/property_deletion/delete_property_use_case.dart';
import '../../feature/property_register/property_register_use_case.dart';
import '../../util/service_locator/main.dart';
import '../../util/type/exception_or.dart';
import '../../util/type/single_or_pair.dart';
import '../common_widget/delete_icon_button.dart';
import '../common_widget/failure.dart';
import '../common_widget/loading.dart';
import '../property_editor/edit_property_page.dart';
import '../property_editor/property_editor_page.dart';
import '../util/model/user_info.dart';
import '../util/repository_selector.dart';
import 'property_viewer_state.dart';

class PropertyListBody extends StatelessWidget {
  const PropertyListBody({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProxyProvider<SingleOrPair, PropertyListState>(
      create: (context) => PropertyListState(),
      update: (context, singleOrPair, state) {
        return state!
          ..fetch(
            singleOrPair: singleOrPair,
            userInfo: context.read<UserInfo>(),
          );
      },
      child: _PageContents(),
    );
  }
}

class _PageContents extends StatelessWidget {
  const _PageContents({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final state = context.watch<PropertyListState>();

    if (state.hasFailure) {
      return Center(
        child: FailureDisplayWidget(failure: state.failure!),
      );
    }

    if (state.isLoading) {
      return Center(
        child: LoadingWidget(),
      );
    }

    return Column(
      children: [
        Expanded(
          child: _PropertyListView(properties: state.properties),
        ),
        _AddPropertyButton(),
      ],
    );
  }
}

class _PropertyListView extends StatelessWidget {
  final UnmodifiableListView<Property> _properties;

  const _PropertyListView({
    required UnmodifiableListView<Property> properties,
    Key? key,
  })  : _properties = properties,
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(8),
      children: _properties
          .map((e) => _PropertyListItem(property: e))
          .toList(growable: false),
    );
  }
}

class _PropertyListItem extends StatelessWidget {
  final Property _property;

  const _PropertyListItem({
    required Property property,
    Key? key,
  })  : _property = property,
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _propertyInfo(),
        Spacer(),
        _EditPropertyButton(propertyId: _property.id),
        DeleteIconButton(
          onPressed: () => _deleteProperty(context),
        ),
      ],
    );
  }

  Widget _propertyInfo() => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _property.name,
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          Text(_property.amount.toString()),
        ],
      );

  Future<void> _deleteProperty(BuildContext context) async {
    final input = _generateInput(context);
    final delete = sl<DeletePropertyUseCase>();
    final result = await delete(input);
    result.fold(
      (exception) => _showDialog(context, exception),
      (_) => _reloadState(context),
    );
  }

  Future<void> _showDialog(BuildContext context, Exception exception) =>
      showDialog<void>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Deleting Property Failed'),
          content: Text('$exception'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        ),
      );

  DeletePropertyInput _generateInput(BuildContext context) {
    final sop = context.read<SingleOrPair>();
    return DeletePropertyInput(
      propertyId: _property.id,
      repository: selectPropertyRepository(sop),
      uid: context.read<UserInfo>().repoId(sop),
    );
  }
}

class _EditPropertyButton extends StatelessWidget {
  final String _propertyId;

  const _EditPropertyButton({required String propertyId, Key? key})
      : _propertyId = propertyId,
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: () async {
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (newContext) => EditPropertyPage(
              targetPropertyId: _propertyId,
              singleOrPair: context.read<SingleOrPair>(),
              userInfo: context.read<UserInfo>(),
            ),
          ),
        );
        _reloadState(context);
      },
      icon: const Icon(Icons.edit),
    );
  }
}

class _AddPropertyButton extends StatelessWidget {
  const _AddPropertyButton({Key? key}) : super(key: key);

  static const String ADD_PROPERTY_TITLE = 'Add a new property';

  @override
  Widget build(BuildContext context) {
    final buildPropertyEditorPage =
        (BuildContext anotherContext) => PropertyEditorPage(
              title: ADD_PROPERTY_TITLE,
              onSubmit: (name, amount) async {
                await _addProperty(
                  name: name,
                  amount: amount,
                  sop: context.read<SingleOrPair>(),
                  uinfo: context.read<UserInfo>(),
                );
                Navigator.pop(anotherContext);
              },
            );

    return OutlinedButton(
      onPressed: () async {
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: buildPropertyEditorPage,
          ),
        );
        _reloadState(context);
      },
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.add_circle_outline),
          const Text(ADD_PROPERTY_TITLE),
        ],
      ),
    );
  }

  Future<ExceptionOr<Unit>> _addProperty({
    required String name,
    required int amount,
    required SingleOrPair sop,
    required UserInfo uinfo,
  }) {
    return sl<AddPropertyUseCase>()(
      AddPropertyInput(
        uid: uinfo.repoId(sop),
        name: name,
        amount: amount,
        repository: selectPropertyRepository(sop),
      ),
    );
  }
}

Future<void> _reloadState(BuildContext context) =>
    context.read<PropertyListState>().fetch(
          singleOrPair: context.read<SingleOrPair>(),
          userInfo: context.read<UserInfo>(),
        );

import 'dart:collection';

import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:household_accounts/common/logic/formatter.dart';
import 'package:provider/provider.dart';

import '../../entity/property.dart';
import '../../feature/property_deletion/delete_property_use_case.dart';
import '../../feature/property_editing/update_property_use_case.dart';
import '../../feature/property_register/property_register_use_case.dart';
import '../../util/service_locator/main.dart';
import '../../util/type/exception_or.dart';
import '../../v2/presentation/pages/state_managements/selected_note_state.dart';
import '../common_widget/delete_icon_button.dart';
import '../common_widget/failure.dart';
import '../common_widget/loading.dart';
import '../property_editor/property_editor_page.dart';
import '../util/model/user_info.dart';
import '../util/repository_selector.dart';
import 'property_viewer_state.dart';

class PropertyListBody extends StatelessWidget {
  const PropertyListBody({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProxyProvider<SelectedNoteState, PropertyListState>(
      create: (context) => PropertyListState(),
      update: (context, singleOrPair, state) {
        return state!..fetch(
          singleOrPair: singleOrPair.value,
          userInfo: context.read<UserInfo>(),
        );
      },
      child: _PageContents(),
    );
  }
}

class _PageContents extends StatelessWidget {
  const _PageContents();

  @override
  Widget build(BuildContext context) {
    final state = context.watch<PropertyListState>();

    if (state.hasFailure) {
      return Center(child: FailureDisplayWidget(failure: state.failure!));
    }

    if (state.isLoading) {
      return Center(child: LoadingWidget());
    }

    return Column(
      children: [
        Expanded(child: _PropertyListView(properties: state.properties)),
        _AddPropertyButton(),
      ],
    );
  }
}

class _PropertyListView extends StatelessWidget {
  final UnmodifiableListView<Property> _properties;

  const _PropertyListView({required UnmodifiableListView<Property> properties})
    : _properties = properties;

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

  const _PropertyListItem({required Property property}) : _property = property;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _propertyInfo(),
        Spacer(),
        _EditPropertyButton(property: _property),
        DeleteIconButton(onPressed: () => _deleteProperty(context)),
      ],
    );
  }

  Widget _propertyInfo() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(_property.name, style: TextStyle(fontWeight: FontWeight.bold)),
      Text(Formatter.simpleCurrency(_property.amount)),
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
          title: const Text('資産の削除に失敗しました'),
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
    final sop = context.read<SelectedNoteState>().value;
    return DeletePropertyInput(
      propertyId: _property.id,
      repository: selectPropertyRepository(sop),
      uid: context.read<UserInfo>().repoId(sop),
    );
  }
}

class _EditPropertyButton extends StatelessWidget {
  final Property _property;

  const _EditPropertyButton({required Property property})
    : _property = property;

  @override
  Widget build(BuildContext context) {
    PropertyEditorPage buildPropertyEditorPage(BuildContext anotherContext) =>
        PropertyEditorPage(
          title: '編集',
          initialName: _property.name,
          initialAmount: _property.amount,
          onSubmit: (name, amount) async {
            await _updateProperty(
              propertyId: _property.id,
              name: name,
              amount: amount,
              sop: context.read<SelectedNoteState>().value,
              uinfo: context.read<UserInfo>(),
            );
            if (anotherContext.mounted) {
              Navigator.pop(anotherContext);
            }
          },
        );

    return IconButton(
      onPressed: () async {
        // ブランチNavigatorではなくルートNavigatorへpushし、編集画面がボトムナビを覆う従来挙動を維持する
        await Navigator.of(
          context,
          rootNavigator: true,
        ).push(MaterialPageRoute(builder: buildPropertyEditorPage));
        if (context.mounted) {
          _reloadState(context);
        }
      },
      icon: const Icon(Icons.edit),
    );
  }

  Future<ExceptionOr<Unit>> _updateProperty({
    required String propertyId,
    String? name,
    int? amount,
    required SelectedNote sop,
    required UserInfo uinfo,
  }) {
    return sl<UpdatePropertyUseCase>()(
      UpdatePropertyInput(
        propertyId: propertyId,
        uid: uinfo.repoId(sop),
        name: name,
        amount: amount,
        repository: selectPropertyRepository(sop),
      ),
    );
  }
}

class _AddPropertyButton extends StatelessWidget {
  const _AddPropertyButton();

  static const String addPropertyTitle = '資産の追加';

  @override
  Widget build(BuildContext context) {
    PropertyEditorPage buildPropertyEditorPage(BuildContext anotherContext) =>
        PropertyEditorPage(
          title: addPropertyTitle,
          onSubmit: (name, amount) async {
            await _addProperty(
              name: name,
              amount: amount,
              sop: context.read<SelectedNoteState>().value,
              uinfo: context.read<UserInfo>(),
            );
            if (anotherContext.mounted) {
              Navigator.pop(anotherContext);
            }
          },
        );

    return OutlinedButton(
      onPressed: () async {
        // ブランチNavigatorではなくルートNavigatorへpushし、編集画面がボトムナビを覆う従来挙動を維持する
        await Navigator.of(
          context,
          rootNavigator: true,
        ).push(MaterialPageRoute(builder: buildPropertyEditorPage));
        if (context.mounted) {
          _reloadState(context);
        }
      },
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.add_circle_outline),
          const Text(addPropertyTitle),
        ],
      ),
    );
  }

  Future<ExceptionOr<Unit>> _addProperty({
    required String name,
    required int amount,
    required SelectedNote sop,
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
      singleOrPair: context.read<SelectedNoteState>().value,
      userInfo: context.read<UserInfo>(),
    );

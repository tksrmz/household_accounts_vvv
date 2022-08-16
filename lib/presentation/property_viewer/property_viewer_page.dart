import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:household_accounts/util/service_locator/service_locator.dart';
import 'package:household_accounts/entity/property_entity.dart';
import 'package:household_accounts/feature/property_register/property_register_use_case.dart';
import 'package:household_accounts/feature/property_deletion/delete_property_use_case.dart';
import 'package:household_accounts/feature/property_retrieve/property_retrieve_use_case.dart';
import 'package:household_accounts/feature/property_editing/update_property_use_case.dart';
import 'package:household_accounts/presentation/property_viewer/property_viewer_state.dart';
import 'package:household_accounts/presentation/common_widget/delete_icon_button.dart';
import 'package:household_accounts/presentation/common_widget/failure.dart';
import 'package:household_accounts/presentation/common_widget/loading.dart';
import 'package:provider/provider.dart';

import '../property_editor/add_property_page.dart';
import '../property_editor/edit_property_page.dart';

class PropertyListPage extends StatelessWidget {
  const PropertyListPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (ctx) => PropertyListState(
        sl<RetrievePropertiesUseCase>(),
        sl<AddPropertiesUseCase>(),
        sl<UpdatePropertyUseCase>(),
        sl<DeletePropertiesUseCase>(),
      )..loadProperties(),
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
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
      children: List.of(
        _properties.map(
          (e) => _PropertyListItem(property: e),
        ),
      ),
    );
  }
}

class _PropertyListItem extends StatelessWidget {
  final Property _property;

  const _PropertyListItem({required Property property, Key? key})
      : _property = property,
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        Text(_property.name),
        Text(_property.amount.toString()),
        _EditPropertyButton(propertyId: _property.id),
        DeleteIconButton(
          onPressed: () {
            context.read<PropertyListState>().deleteProperty(_property.id);
          },
        ),
      ],
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
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (newContext) => EditPropertyPage(
              state: context.read<PropertyListState>(),
              targetPropertyId: _propertyId,
            ),
          ),
        );
      },
      icon: const Icon(Icons.edit),
    );
  }
}

class _AddPropertyButton extends StatelessWidget {
  const _AddPropertyButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (newContext) => AddPropertyPage(
              state: context.read<PropertyListState>(),
            ),
          ),
        );
      },
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.add_circle_outline),
          const Text('Add a new property.'),
        ],
      ),
    );
  }
}

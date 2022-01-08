import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:household_accounts/features/property-viewer/domain/entities/property.dart';
import 'package:household_accounts/features/property-viewer/domain/use-cases/add_properties.dart';
import 'package:household_accounts/features/property-viewer/domain/use-cases/retrieve_properties.dart';
import 'package:household_accounts/features/property-viewer/domain/use-cases/update_property.dart';
import 'package:household_accounts/features/property-viewer/presentation/states/property_list.dart';
import 'package:household_accounts/util/presentation/widgets/failure.dart';
import 'package:household_accounts/util/presentation/widgets/loading.dart';
import 'package:provider/provider.dart';

import 'add_property.dart';

class PropertyListPage extends StatelessWidget {
  const PropertyListPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (ctx) => PropertyListState(
        context.read<RetrievePropertiesUseCase>(),
        context.read<AddPropertiesUseCase>(),
        context.read<UpdatePropertyUseCase>(),
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
          (e) => Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Text(e.name),
              Text(e.amount.toString()),
              ElevatedButton(
                onPressed: null,
                child: const Text('Edit'),
              )
            ],
          ),
        ),
      ),
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
            builder: (newContext) => ChangeNotifierProvider.value(
              value: context.read<PropertyListState>(),
              child: AddPropertyPage(),
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

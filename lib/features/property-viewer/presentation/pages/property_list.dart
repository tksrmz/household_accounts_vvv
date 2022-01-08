import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:household_accounts/features/property-viewer/domain/use-cases/retrieve_properties.dart';
import 'package:household_accounts/features/property-viewer/presentation/states/property_list.dart';
import 'package:household_accounts/util/presentation/widgets/failure.dart';
import 'package:household_accounts/util/presentation/widgets/loading.dart';
import 'package:provider/provider.dart';

class PropertyListPage extends StatelessWidget {
  const PropertyListPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (ctx) => PropertyListState(
        context.read<RetrievePropertiesUseCase>(),
        context.read<AddPropertiesUseCase>(),
      )..loadProperties(),
      child: _PageContents(),
    );
  }
}

class _PageContents extends StatelessWidget {
  const _PageContents({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isLoading =
        context.select<PropertyListState, bool>((state) => state.isLoading);
    final hasFailure =
        context.select<PropertyListState, bool>((state) => state.hasFailure);

    if (hasFailure) {
      return Center(
        child: FailureDisplayWidget(
          failure: context.read<PropertyListState>().failure!,
        ),
      );
    }

    if (isLoading) {
      return Center(
        child: LoadingWidget(),
      );
    }

    return _PropertyListView();
  }
}

class _PropertyListView extends StatelessWidget {
  const _PropertyListView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final properties = context.select<PropertyListState, UnmodifiableListView>(
      (state) => state.properties,
    );

    return ListView(
      children: List.of(
        properties.map(
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

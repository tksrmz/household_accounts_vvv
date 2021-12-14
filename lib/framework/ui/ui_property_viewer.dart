import 'package:flutter/material.dart';
import 'package:household_accounts/adapter/controller/ctl_property_viewer.dart';
import 'package:household_accounts/adapter/presenter/prs_property_viewer.dart';
import 'package:provider/provider.dart';

class PropertyViewerPage extends StatelessWidget {
  final PropertyViewerController _controller;
  final PropertyViewerPresenter _presenter;

  const PropertyViewerPage(this._controller, this._presenter, {Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    _controller.retrieveProperties();

    return ChangeNotifierProvider.value(
      value: _presenter,
      child: PropertyListWidget(),
    );
  }
}

class PropertyListWidget extends StatelessWidget {
  const PropertyListWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final presenter = context.watch<PropertyViewerPresenter>();

    return ListView(
      children: List.of(
        presenter.viewModel.properties.map(
          (e) => Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Text(e.name),
              Text(e.amount.toString()),
              ElevatedButton(
                onPressed: () {},
                child: const Text('Edit'),
              )
            ],
          ),
        ),
      ),
    );
  }
}

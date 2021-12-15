import 'package:flutter/material.dart';
import 'package:household_accounts/adapter/controller/ctl_property_viewer.dart';
import 'package:household_accounts/adapter/presenter/prs_property_viewer.dart';
import 'package:household_accounts/entity/property.dart';
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
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (ctx) => _PropertyEditorPage(e),
                    ),
                  );
                },
                child: const Text('Edit'),
              )
            ],
          ),
        ),
      ),
    );
  }
}

class _PropertyEditorPage extends StatelessWidget {
  final Property _property;

  const _PropertyEditorPage(this._property, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit ${_property.name}'),
      ),
      body: Center(
        child: _PropertyAmountEditorWidget(_property.amount),
      ),
    );
  }
}

class _PropertyAmountEditorWidget extends StatefulWidget {
  final int _amount;

  const _PropertyAmountEditorWidget(this._amount, {Key? key}) : super(key: key);

  @override
  _PropertyAmountEditorWidgetState createState() =>
      _PropertyAmountEditorWidgetState();
}

class _PropertyAmountEditorWidgetState
    extends State<_PropertyAmountEditorWidget> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget._amount.toString());
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _AmountInputWidget(_controller),
          ElevatedButton(
            onPressed: () {
              // TODO: Add code to update property
              Navigator.pop(context);
            },
            child: const Text('Edit'),
          )
        ],
      ),
    );
  }
}

class _AmountInputWidget extends StatelessWidget {
  final TextEditingController _controller;

  const _AmountInputWidget(this._controller, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _controller,
      decoration: const InputDecoration(
        border: OutlineInputBorder(),
        labelText: 'Amount',
      ),
    );
  }
}

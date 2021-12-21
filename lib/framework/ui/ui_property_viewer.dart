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

    return MultiProvider(
      providers: [
        Provider<PropertyViewerController>.value(value: _controller),
        ChangeNotifierProvider<PropertyViewerPresenter>.value(
            value: _presenter),
      ],
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
                  final ctrl = context.read<PropertyViewerController>();
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (ctx) => _PropertyEditorPage(e, ctrl),
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
  final PropertyViewerController _controller;

  const _PropertyEditorPage(this._property, this._controller, {Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit ${_property.name}'),
      ),
      body: Center(
        child: _PropertyAmountEditorWidget(_property, _controller),
      ),
    );
  }
}

class _PropertyAmountEditorWidget extends StatefulWidget {
  final Property _property;
  final PropertyViewerController _controller;

  const _PropertyAmountEditorWidget(this._property, this._controller,
      {Key? key})
      : super(key: key);

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
    _controller = TextEditingController(text: '${widget._property.amount}');
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ctrl = widget._controller;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _AmountInputWidget(_controller),
          ElevatedButton(
            onPressed: () {
              ctrl
                  .updateProperty(
                    Property(
                      widget._property.name,
                      int.parse(_controller.text),
                    ),
                  )
                  .then((_) => ctrl.retrieveProperties());

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

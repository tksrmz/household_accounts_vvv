import 'package:flutter/material.dart';

class PropertyViewerPage extends StatefulWidget {
  const PropertyViewerPage({Key? key}) : super(key: key);

  @override
  _PropertyViewerPageState createState() => _PropertyViewerPageState();
}

class _PropertyViewerPageState extends State<PropertyViewerPage> {
  late int _carried;
  late int _income;
  late int _expense;
  late int _balance;

  @override
  void initState() {
    super.initState();
    _carried = 0;
    _income = 1;
    _expense = 2;
    _balance = 3;
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            const Text("繰越"),
            Text(_carried.toString()),
            ElevatedButton(
              onPressed: () {},
              child: const Text('Edit'),
            )
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            const Text("収入"),
            Text(_income.toString()),
            ElevatedButton(
              onPressed: () {},
              child: const Text('Edit'),
            )
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            const Text("支出"),
            Text(_expense.toString()),
            ElevatedButton(
              onPressed: () {},
              child: const Text('Edit'),
            )
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            const Text("残高"),
            Text(_balance.toString()),
            ElevatedButton(
              onPressed: () {},
              child: const Text('Edit'),
            )
          ],
        )
      ],
    );
  }
}

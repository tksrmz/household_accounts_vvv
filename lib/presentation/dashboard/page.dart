import 'package:flutter/material.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key, required this.viewModel});

  final SummaryViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return CircularProgressIndicator();
  }
}

class SummaryViewModel extends ChangeNotifier {}

class SummaryModel {}

class Summary {}

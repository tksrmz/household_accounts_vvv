import 'package:flutter/material.dart';

import '../../entity/expense.dart';
import '../../entity/income.dart';
import 'widget/summary_panel.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SummaryPanel(Income(100), Expense(60));
  }
}

import 'package:flutter/material.dart';

import 'widget/summary_panel.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SummaryPanel(income: 100, expense: 200);
  }
}

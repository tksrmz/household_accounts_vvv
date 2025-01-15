import 'package:flutter/material.dart';

import '../../entity/expense.dart';
import '../../entity/income.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key, required this.viewModel});

  final SummaryViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return CircularProgressIndicator();
  }
}

class SummaryViewModel extends ChangeNotifier {
  /// 当該月の総収入
  Income? income;

  /// 当該月の総支出
  Expense? expense;

  /// ローディング中かどうか
  bool get isLoading => (income == null) && (expense == null);

  /// エラーが発生したかどうか
  bool get hasError => (income == null) ^ (expense == null);

  Future<void> init() async {
    return;
  }
}

class SummaryModel {}

class Summary {}

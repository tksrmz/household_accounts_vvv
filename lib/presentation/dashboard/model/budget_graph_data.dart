import '../../../vo/budget_amount.dart';
import '../../../vo/budget_spent.dart';
import '../vo/budget_name.dart';

class BudgetGraphData {
  final BudgetName name;
  final BudgetSpent spent;
  final BudgetAmount budget;

  const BudgetGraphData({
    required this.name,
    required this.spent,
    required this.budget,
  });
}

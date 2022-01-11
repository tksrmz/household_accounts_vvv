import 'package:household_accounts/util/domain/entities/identifiable.dart';

class Category extends Identifiable {
  static const int maxNameLength = 20;

  final String name;
  final int budget;

  Category(String id, this.name, this.budget)
      : assert(name.length > 0, 'Category name is empty string.'),
        assert(name.length <= Category.maxNameLength,
            'Category name is too long.'),
        assert(budget >= 0, 'Category budget is negative.'),
        super(id);

  @override
  List<Object> get props => [id, name, budget];
}

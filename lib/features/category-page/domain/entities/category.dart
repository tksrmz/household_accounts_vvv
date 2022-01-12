import 'package:household_accounts/util/domain/entities/identifiable.dart';

class Category extends Identifiable {
  static const int maxNameLength = 20;

  final String name;
  final CategoryType type;

  Category(String id, this.name, this.type)
      : assert(name.length > 0, 'Category name is empty string.'),
        assert(name.length <= Category.maxNameLength,
            'Category name is too long.'),
        super(id);

  @override
  List<Object> get props => [id, name, type];
}

enum CategoryType { income, expense }

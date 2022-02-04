import 'package:household_accounts/util/domain/entities/identifiable.dart';

class Property extends Identifiable {
  static const int maxNameLength = 20;

  final String name;
  final int amount;

  Property(String id, this.name, this.amount)
      : assert(name.length > 0, 'Property name is empty string.'),
        assert(name.length <= Property.maxNameLength,
            'Property name is too long.'),
        super(id);

  @override
  List<Object> get props => [id, name, amount];
}

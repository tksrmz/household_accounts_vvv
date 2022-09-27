import 'package:household_accounts/util/type/identifiable.dart';

class Property extends Identifiable {
  static const int maxNameLength = 20;

  final String name;
  final int amount;

  Property(String id, this.name, this.amount)
      : assert(name.length > 0, 'Property name is empty string.'),
        assert(name.length <= Property.maxNameLength,
            'Property name is too long.'),
        super(id);

  Property copyWith({String? id, String? name, int? amount}) =>
      Property(id ?? this.id, name ?? this.name, amount ?? this.amount);

  @override
  List<Object> get props => [id, name, amount];
}

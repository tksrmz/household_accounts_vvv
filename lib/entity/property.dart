import '../util/type/identifiable.dart';

class Property extends Identifiable {
  static const int maxNameLength = 20;

  final String name;
  final int amount;

  const Property(super.id, this.name, this.amount)
    : assert(name.length > 0, 'Property name is empty string.'),
      assert(
        name.length <= Property.maxNameLength,
        'Property name is too long.',
      );

  Property copyWith({String? id, String? name, int? amount}) =>
      Property(id ?? this.id, name ?? this.name, amount ?? this.amount);

  @override
  List<Object> get props => [id, name, amount];
}

const deletedProperty = Property('deleted-property', '削除済み', 0);

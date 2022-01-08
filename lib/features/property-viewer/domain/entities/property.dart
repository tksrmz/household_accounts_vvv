import 'package:equatable/equatable.dart';

class Property extends Equatable {
  static const int maxNameLength = 20;

  final String id;
  final String name;
  final int amount;

  Property(this.id, this.name, this.amount)
      : assert(id.length > 0, 'Property ID is empty string.'),
        assert(name.length > 0, 'Property name is empty string.'),
        assert(name.length <= Property.maxNameLength,
            'Property name is too long.');

  @override
  List<Object> get props => [id, name, amount];

  @override
  bool get stringify => true;
}

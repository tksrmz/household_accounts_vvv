import 'package:equatable/equatable.dart';

/// Base class for entities that have ID.
abstract class Identifiable extends Equatable {
  final String id;

  const Identifiable(this.id) : assert(id.length > 0, 'ID is empty string.');

  @override
  List<Object> get props => [id];

  @override
  bool get stringify => true;
}

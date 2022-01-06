import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {
  final List<Object> _properties;

  const Failure([this._properties = const []]);

  @override
  List<Object> get props => _properties;

  @override
  bool get stringify => true;
}

class RepositoryFailure extends Failure {
  @override
  String toString() => 'RepositoryFailure';
}

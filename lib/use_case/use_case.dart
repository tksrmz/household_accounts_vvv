/// Base class for all use cases.
///
/// Use case accepts input class T, then returns output of Future<R>.
abstract class UseCase<T, R> {
  Future<R> handle(T input);
}

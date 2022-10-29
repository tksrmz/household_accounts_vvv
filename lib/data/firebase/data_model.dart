import '../../util/type/identifiable.dart';
import '../../util/type/json.dart';

abstract class DataModel<T extends Identifiable> {
  T toEntity();

  Json toJson();
}

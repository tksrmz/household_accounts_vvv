import 'package:uuid/uuid.dart' as pkg;

class UUID {
  static String generate([int version = 1]) {
    const uuid = pkg.Uuid();
    if (version == 1) {
      return uuid.v1();
    }
    if (version == 4) {
      return uuid.v4();
    }

    return '';
  }
}

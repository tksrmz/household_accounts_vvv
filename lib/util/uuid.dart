class UUID {
  static int _id = 1;

  static String generate([int version = 4]) {
    // Mock
    final stringId = _id.toString();
    _id++;
    return stringId;
  }
}

import 'package:flutter/foundation.dart';

class SelectedNoteState extends ChangeNotifier {
  SelectedNoteState() : _value = SelectedNote.personal;

  SelectedNote _value;

  SelectedNote get value => _value;

  bool get isPersonal => _value == SelectedNote.personal;

  void select(SelectedNote newValue) {
    _value = newValue;
    notifyListeners();
  }
}

enum SelectedNote {
  personal,
  shared,
}

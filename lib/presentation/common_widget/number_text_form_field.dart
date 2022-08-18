import 'package:flutter/material.dart';

class NumberTextFormField extends TextFormField {
  NumberTextFormField({
    Key? key,
    InputDecoration? decoration,
    String? initialValue,
    FormFieldSetter<String>? onSaved,
  }) : super(
          key: key,
          decoration: decoration,
          initialValue: initialValue,
          onSaved: onSaved,
          keyboardType: TextInputType.number,
          validator: (String? value) {
            if (value == null) {
              return 'Please input some value.';
            }

            final num = int.tryParse(value);
            if (num == null) {
              return 'Pleas input valid string.';
            }
            if (num < 0) {
              return 'Please input non-negative value.';
            }
            return null;
          },
        );
}

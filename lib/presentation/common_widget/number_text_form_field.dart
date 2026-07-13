import 'package:flutter/material.dart';

class NumberTextFormField extends TextFormField {
  NumberTextFormField({
    super.key,
    super.decoration = null,
    super.initialValue,
    super.onSaved,
  }) : super(
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

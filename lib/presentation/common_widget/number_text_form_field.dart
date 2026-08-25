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
           // 金額は1以上(レコードのドメイン制約)。0で保存できてしまうと、
           // 一覧側の読み取り検証がそのレコードを不正として扱いエラー表示になる
           if (num <= 0) {
             return 'Please input positive value.';
           }
           return null;
         },
       );
}

import 'package:flutter_test/flutter_test.dart';
import 'package:household_accounts/v2/domain/models/property.dart';
import 'package:household_accounts/v2/domain/models/transfer_record.dart';
import 'package:household_accounts/v2/domain/models/vo/property_amount.dart';
import 'package:household_accounts/v2/domain/models/vo/property_id.dart';
import 'package:household_accounts/v2/domain/models/vo/property_name.dart';
import 'package:household_accounts/v2/domain/models/vo/record_amount.dart';
import 'package:household_accounts/v2/domain/models/vo/record_date.dart';
import 'package:household_accounts/v2/domain/models/vo/record_id.dart';
import 'package:household_accounts/v2/domain/models/vo/record_note.dart';

void main() {
  group('TransferRecordModel', () {
    late PropertyModel sourceProperty;
    late PropertyModel destinationProperty;

    setUp(() {
      sourceProperty = PropertyModel(
        id: PropertyIdVo('property-1'),
        name: PropertyNameVo('現金'),
        amount: PropertyAmountVo(50000),
      );
      destinationProperty = PropertyModel(
        id: PropertyIdVo('property-2'),
        name: PropertyNameVo('銀行口座'),
        amount: PropertyAmountVo(100000),
      );
    });

    test('有効な値で作成できること', () {
      final transferRecord = TransferRecordModel(
        id: RecordIdVo('transfer-1'),
        recordDate: RecordDateVo(DateTime(2025, 1, 10)),
        amount: RecordAmountVo(10000),
        note: RecordNoteVo('ATM入金'),
        source: sourceProperty,
        destination: destinationProperty,
        hasCheckedOut: false,
      );

      expect(transferRecord.id.value, 'transfer-1');
      expect(transferRecord.recordDate.value, DateTime(2025, 1, 10));
      expect(transferRecord.amount.value, 10000);
      expect(transferRecord.note.value, 'ATM入金');
      expect(transferRecord.source, sourceProperty);
      expect(transferRecord.destination, destinationProperty);
      expect(transferRecord.hasCheckedOut, false);
    });

    test('チェックアウト済みの振替レコードを作成できること', () {
      final transferRecord = TransferRecordModel(
        id: RecordIdVo('transfer-2'),
        recordDate: RecordDateVo(DateTime(2025, 1, 12)),
        amount: RecordAmountVo(5000),
        note: RecordNoteVo('口座振替'),
        source: sourceProperty,
        destination: destinationProperty,
        hasCheckedOut: true,
      );

      expect(transferRecord.hasCheckedOut, true);
    });

    test('移動元と移動先の資産が正しく設定されること', () {
      final transferRecord = TransferRecordModel(
        id: RecordIdVo('transfer-3'),
        recordDate: RecordDateVo(DateTime(2025, 1, 15)),
        amount: RecordAmountVo(20000),
        note: RecordNoteVo('貯金'),
        source: sourceProperty,
        destination: destinationProperty,
        hasCheckedOut: false,
      );

      expect(transferRecord.source.id.value, 'property-1');
      expect(transferRecord.source.name.value, '現金');
      expect(transferRecord.destination.id.value, 'property-2');
      expect(transferRecord.destination.name.value, '銀行口座');
    });

    test('移動元と移動先が異なる資産であること', () {
      final transferRecord = TransferRecordModel(
        id: RecordIdVo('transfer-4'),
        recordDate: RecordDateVo(DateTime(2025, 1, 20)),
        amount: RecordAmountVo(15000),
        note: RecordNoteVo('資金移動'),
        source: sourceProperty,
        destination: destinationProperty,
        hasCheckedOut: false,
      );

      expect(transferRecord.source.id.value,
          isNot(equals(transferRecord.destination.id.value)));
    });
  });
}

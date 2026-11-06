import 'package:household_accounts/domain/models/property.dart';
import 'package:household_accounts/domain/models/property_id.dart';
import 'package:household_accounts/domain/models/property_name.dart';
import 'package:test/test.dart';

Property _property({int balance = 1000}) => Property(
  id: PropertyId('property-id'),
  name: PropertyName('財布'),
  balance: balance,
);

void main() {
  test('Propertyを生成したとき、指定したフィールドを持つこと', () {
    final property = _property();

    expect(property.id, PropertyId('property-id'));
    expect(property.name, PropertyName('財布'));
    expect(property.balance, 1000);
  });

  test('残高が負のとき、そのまま保持できること', () {
    expect(_property(balance: -500).balance, -500);
  });

  test('同じフィールドを持つProperty同士は等価であること', () {
    expect(_property(), _property());
  });

  test('残高が異なるProperty同士は等価でないこと', () {
    expect(_property(balance: 1), isNot(_property(balance: 2)));
  });
}

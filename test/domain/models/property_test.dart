import 'package:household_accounts/domain/models/property.dart';
import 'package:household_accounts/domain/models/property_id.dart';
import 'package:test/test.dart';

void main() {
  test('Propertyを生成したとき、指定したフィールドを持つこと', () {
    final property = Property(id: PropertyId('property-id'), name: '財布');

    expect(property.id, PropertyId('property-id'));
    expect(property.name, '財布');
  });

  test('同じフィールドを持つProperty同士は等価であること', () {
    final a = Property(id: PropertyId('property-id'), name: '財布');
    final b = Property(id: PropertyId('property-id'), name: '財布');

    expect(a, b);
  });
}

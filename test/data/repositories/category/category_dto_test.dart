import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:household_accounts/data/repositories/category/category_dto.dart';
import 'package:household_accounts/domain/models/budget.dart';
import 'package:household_accounts/domain/models/category.dart';
import 'package:household_accounts/domain/models/category_id.dart';
import 'package:household_accounts/domain/models/category_name.dart';
import 'package:test/test.dart';

void main() {
  group('IncomeCategoryDto', () {
    test('正常なドキュメントのとき、変換できること', () {
      final doc = _fakeDoc('category-1', {'type': 'income', 'name': '給与'});

      final dto = IncomeCategoryDto.fromSnapshot(doc);

      expect(dto.id, 'category-1');
      expect(dto.name, '給与');
      expect(dto.toDomain(), isA<IncomeCategory>());
    });

    test('typeがincomeでないとき、FormatExceptionが送出されること(コレクション所属だけで種別を決めないこと)', () {
      final doc = _fakeDoc('category-1', {'type': 'expense', 'name': '給与'});

      expect(() => IncomeCategoryDto.fromSnapshot(doc), throwsFormatException);
    });

    test('typeが欠損しているとき、FormatExceptionが送出されること', () {
      final doc = _fakeDoc('category-1', {'name': '給与'});

      expect(() => IncomeCategoryDto.fromSnapshot(doc), throwsFormatException);
    });

    test('nameが欠損しているとき、FormatExceptionが送出されること', () {
      final doc = _fakeDoc('category-1', {'type': 'income'});

      expect(() => IncomeCategoryDto.fromSnapshot(doc), throwsFormatException);
    });

    test('nameが文字列でないとき、FormatExceptionが送出されること', () {
      final doc = _fakeDoc('category-1', {'type': 'income', 'name': 123});

      expect(() => IncomeCategoryDto.fromSnapshot(doc), throwsFormatException);
    });

    test('nameが21文字のとき、toDomainでFormatExceptionが送出されること', () {
      final doc = _fakeDoc('category-1', {'type': 'income', 'name': 'a' * 21});

      final dto = IncomeCategoryDto.fromSnapshot(doc);

      expect(() => dto.toDomain(), throwsFormatException);
    });
  });

  group('ExpenseCategoryDto', () {
    test('正常なドキュメントのとき、予算を含めて変換できること', () {
      final doc = _fakeDoc('category-2', {
        'type': 'expense',
        'name': '食費',
        'totalBudget': 30000,
      });

      final dto = ExpenseCategoryDto.fromSnapshot(doc);

      expect(dto.id, 'category-2');
      expect(dto.name, '食費');
      expect(dto.budget, 30000);
      expect(
        dto.toDomain(),
        ExpenseCategory(
          id: CategoryId('category-2'),
          name: CategoryName('食費'),
          budget: Budget(30000),
        ),
      );
    });

    test('typeがexpenseでないとき、FormatExceptionが送出されること', () {
      final doc = _fakeDoc('category-2', {
        'type': 'income',
        'name': '食費',
        'totalBudget': 0,
      });

      expect(() => ExpenseCategoryDto.fromSnapshot(doc), throwsFormatException);
    });

    test('nameが文字列でないとき、FormatExceptionが送出されること', () {
      final doc = _fakeDoc('category-2', {
        'type': 'expense',
        'name': null,
        'totalBudget': 0,
      });

      expect(() => ExpenseCategoryDto.fromSnapshot(doc), throwsFormatException);
    });

    test('nameが空文字のとき、toDomainでFormatExceptionが送出されること', () {
      final doc = _fakeDoc('category-2', {
        'type': 'expense',
        'name': '',
        'totalBudget': 0,
      });

      final dto = ExpenseCategoryDto.fromSnapshot(doc);

      expect(() => dto.toDomain(), throwsFormatException);
    });

    test('totalBudgetが欠損しているとき、FormatExceptionが送出されること', () {
      final doc = _fakeDoc('category-2', {'type': 'expense', 'name': '食費'});

      expect(() => ExpenseCategoryDto.fromSnapshot(doc), throwsFormatException);
    });

    test('totalBudgetが整数でないとき、FormatExceptionが送出されること', () {
      final doc = _fakeDoc('category-2', {
        'type': 'expense',
        'name': '食費',
        'totalBudget': 1.5,
      });

      expect(() => ExpenseCategoryDto.fromSnapshot(doc), throwsFormatException);
    });

    test('totalBudgetが負数のとき、toDomainでFormatExceptionが送出されること', () {
      final doc = _fakeDoc('category-2', {
        'type': 'expense',
        'name': '食費',
        'totalBudget': -1,
      });

      final dto = ExpenseCategoryDto.fromSnapshot(doc);

      expect(() => dto.toDomain(), throwsFormatException);
    });

    test('totalBudgetが0のとき、予算0として変換できること', () {
      final doc = _fakeDoc('category-2', {
        'type': 'expense',
        'name': '食費',
        'totalBudget': 0,
      });

      expect(ExpenseCategoryDto.fromSnapshot(doc).toDomain().budget, Budget(0));
    });
  });

  group('incomeCategoryCreateJson', () {
    test('名前を渡したとき、nameとtype(income)の2フィールドになること', () {
      expect(incomeCategoryCreateJson(name: CategoryName('給与')), {
        'name': '給与',
        'type': 'income',
      });
    });
  });

  group('expenseCategoryCreateJson', () {
    test('名前と予算を渡したとき、nameとtype(expense)とtotalBudgetの3フィールドになること', () {
      expect(
        expenseCategoryCreateJson(
          name: CategoryName('食費'),
          budget: Budget(30000),
        ),
        {'name': '食費', 'type': 'expense', 'totalBudget': 30000},
      );
    });
  });

  group('incomeCategoryUpdateJson', () {
    test('名前を渡したとき、nameのみを含むこと', () {
      expect(incomeCategoryUpdateJson(name: CategoryName('賞与')), {
        'name': '賞与',
      });
    });
  });

  group('expenseCategoryUpdateJson', () {
    test('名前だけを渡したとき、nameのみを含むこと', () {
      expect(expenseCategoryUpdateJson(name: CategoryName('外食')), {
        'name': '外食',
      });
    });

    test('予算だけを渡したとき、totalBudgetのみを含むこと', () {
      expect(expenseCategoryUpdateJson(budget: Budget(0)), {'totalBudget': 0});
    });

    test('名前と予算の両方を渡したとき、nameとtotalBudgetの両方を含むこと', () {
      expect(
        expenseCategoryUpdateJson(
          name: CategoryName('外食'),
          budget: Budget(5000),
        ),
        {'name': '外食', 'totalBudget': 5000},
      );
    });
  });
}

QueryDocumentSnapshot<Map<String, dynamic>> _fakeDoc(
  String id,
  Map<String, dynamic> data,
) => _FakeQueryDocumentSnapshot(id, data);

// ignore: subtype_of_sealed_class
/// mocktail/mockitoを使わない手書きFake。実際に使うメンバ([id]/[data])のみ
/// overrideし、それ以外はテストで呼ばれないためnoSuchMethodへ委譲する。
///
/// [QueryDocumentSnapshot]([DocumentSnapshot]も含め)はcloud_firestore
/// パッケージが`@sealed`を付けている(外部実装を非推奨とするための注釈であり、
/// 言語レベルのsealedではない)ため`subtype_of_sealed_class`が警告として
/// 出るが、テスト用のFakeとして意図的にimplementsしている。
class _FakeQueryDocumentSnapshot
    implements QueryDocumentSnapshot<Map<String, dynamic>> {
  _FakeQueryDocumentSnapshot(this.id, this._data);

  @override
  final String id;

  final Map<String, dynamic> _data;

  @override
  Map<String, dynamic> data() => _data;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

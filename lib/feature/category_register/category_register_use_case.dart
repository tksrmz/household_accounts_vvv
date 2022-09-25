import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:household_accounts/entity/category_entity.dart';
import 'package:household_accounts/util/type/use_case.dart';

typedef AddCategoryUseCase2 = UseCase2<AddCategoryInput2, Unit>;

class AddCategoryInput2 extends Equatable {
  final String name;
  final CategoryType type;
  final int budgetAmount;

  const AddCategoryInput2({
    required this.name,
    required this.type,
    this.budgetAmount = 0,
  }) : assert(budgetAmount >= 0, 'budgetAmount has a negative value.');

  @override
  List<Object?> get props => [
        name,
        type,
        budgetAmount,
      ];

  @override
  bool? get stringify => true;
}

import 'package:household_accounts/features/category-page/domain/entities/category.dart';
import 'package:household_accounts/util/use_case.dart';

typedef RetrieveCategoriesUseCase = UseCase<NoParam, List<Category>>;

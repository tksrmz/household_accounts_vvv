import 'package:get_it/get_it.dart';

import '../../feature/budget_analyzer/budget_analyzer_interactor.dart';
import '../../feature/budget_analyzer/budget_analyzer_use_case.dart';

void initBudgetUseCase(GetIt sl) {
  sl.registerFactory<RetrieveBudgetStateUseCase>(
    () => RetrieveBudgetStateInteractor(),
  );
}

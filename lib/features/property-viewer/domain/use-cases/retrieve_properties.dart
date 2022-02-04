import 'package:household_accounts/features/property-viewer/domain/entities/property.dart';
import 'package:household_accounts/util/use_case.dart';

typedef RetrievePropertiesUseCase = UseCase<NoParam, List<Property>>;

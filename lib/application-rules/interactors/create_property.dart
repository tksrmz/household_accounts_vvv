import 'package:household_accounts/application-rules/use-cases/create_property.dart';
import 'package:household_accounts/entity/property.dart';
import 'package:household_accounts/features/record-calendar-page/domain/repositories/uc_repository.dart';
import 'package:household_accounts/util/uuid.dart';

class CreatePropertyInteractor implements CreatePropertyUseCase {
  final PropertyRepository _repository;

  const CreatePropertyInteractor(this._repository);

  @override
  Future<CreatePropertyOutput> handle(CreatePropertyInput input) async {
    print(
        'Creating new property "${input.propertyName}" that has ${input.initialAmount} yen');

    final property = Property(
      UUID.generate(),
      input.propertyName,
      input.initialAmount,
    );
    final succeeded = await _repository.register(property);
    return CreatePropertyOutput(succeeded ? property : null);
  }
}

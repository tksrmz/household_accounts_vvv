import 'package:household_accounts/v2/presentation/pages/settings/widgets/error_message.dart';

import '../../../../../util/golden_helper.dart';

void main() {
  testGoldens(
    'エラーメッセージを表示する',
    goldenFileName: 'settings_error_message',
    builder: () => const ErrorMessage(),
  );
}

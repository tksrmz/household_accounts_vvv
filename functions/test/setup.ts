import * as fs from "fs";
import * as os from "os";
import * as path from "path";

// secrets の置き場所は新旧環境とも ~/ws/secrets という規約。
// キーファイルが存在しない場合は環境変数を設定せず、
// ADC (Application Default Credentials) にフォールバックする。
// 環境変数はデフォルトを上書きしたい場合にのみ設定する。
if (!process.env.HOUSEHOLD_ACCOUNTS_DEV_SERVICE_ACCOUNT_KEY) {
  const defaultKeyPath = path.join(
    os.homedir(),
    "ws",
    "secrets",
    "household-accounts-dev-service-account-key.json",
  );
  if (fs.existsSync(defaultKeyPath)) {
    process.env.HOUSEHOLD_ACCOUNTS_DEV_SERVICE_ACCOUNT_KEY = defaultKeyPath;
  }
}

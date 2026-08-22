# アーキテクチャ移行計画

- ステータス: **実行中**(計画はv1.1でレビュー反映済み。進捗は§3の各PRチェックボックスを正とする)
- 作成日: 2026-08-19
- 親ドキュメント: [202608_architecture_redesign.md](./202608_architecture_redesign.md)(コミット e84adff で確定した設計に従う)
- 注記: `docs/features/` はスナップショット型だが、本ドキュメントは進捗管理を兼ねるため**例外的にライブ運用**する(各PRマージ時にチェックボックスと特記を更新)

## 0. 合意済みの前提(2026-08-19の会話で決定)

- **場所**: このモノレポ(`household_accounts_claude`)で実施する。開発のホームをここに移す。旧リポジトリからのIssue移管などのフォローアップは後回しでよい
- **単位**: 「機能(フィーチャー)単位」の縦切り。1機能 = 1〜2画面 + その機能が必要とするRepositoryメソッド + テスト + 旧実装削除。1機能 = 1ブランチ = 1PR
- **共存方法**: 土台PRでシェル(タブ+Drawer)をgo_router化し、**旧画面Widgetは一時的にそのままルートへぶら下げる**。新旧機能がタブ単位で混在する期間を許容する
- **計画の軽さ**: 工数見積もりはしない。固定するのは**順番とDoDだけ**、進捗はPR単位で見る(前回計画がウォーターフォール化して破綻した反省)
- **体制**: 実装はサブエージェントへ委譲(分析・定型はSonnet、統合判断はOpus)、メインエージェントがレビュー・検収、ユーザーがPRレビュー
- **共有振替の旧バグ**: 対処不要(未公開機能・実データ影響なし)。新設計で構造的に再発しない

## 1. 原則

1. **ストラングラー方式**: 移行した機能の旧実装は同じPR内で削除する。「あとでまとめて消す」を作らない
2. **レイヤー横断の一斉移行フェーズを組まない**: データ層は機能PRが必要とするメソッドだけを都度実装して育てる
3. **移行中の新機能開発は原則凍結**。やむを得ず追加する場合は新アーキテクチャ側に書く(「動く標的」の再発防止)
4. 各PRは `flutter analyze` / `dart format` / 既存テストすべて緑を維持する
5. ブランチ命名: `dev/arch-01-foundation` のように連番+機能名

## 2. 完了条件(DoD、全機能PR共通)

1. ViewModelユニットテスト(FakeRepository注入)が緑
2. 対象画面のgoldenテストが緑(UI変更時はgolden更新を含む)
3. 該当ユーザーストーリーのintegrationテストが緑(既存シードデータ流用)
4. 旧実装(該当機能のページ・UseCase・Interactor・旧Repository配線)の削除完了

## 3. PR分解

### PR1: 土台 `dev/arch-01-foundation`

- [x] 完了(2026-08-21、PR #9)

| 項目 | 内容 |
|---|---|
| 目的 | 新アーキテクチャの骨格を敷き、以降の機能PRが「型に沿って書くだけ」の状態を作る |
| 追加 | `utils/result.dart`(Result<T>) / `utils/command.dart`(Command0/1。シェルのログアウトCommandが最初の利用者) / `routing/`(go_router、StatefulShellRouteで6タブ+設定+認証redirect) / `ui/shell/`(タブ+Drawer+ノート切替) / `ui/core/`(テーマ骨格) / `data/repositories/auth/`(v2から移設。**土台で作る唯一のRepository**) / `config/dependencies.dart` |
| 削除 | `lib/presentation/app_home_page/` `lib/presentation/main_page/` `lib/feature/auth_gate/`(シェルとredirectで置換) |
| 特記 | **YAGNI徹底**: `domain/models/` や他のRepositoryはここでは作らない(Period/Notebook/RecordモデルはPR3、transaction_runnerはPR4で初出)。ペア検知は旧app_home_pageのStreamBuilder相当をシェル内部へ一時移植し、ProfileRepositoryへの昇格はPR2で行う。切替状態は既存 `SelectedNoteState` を続用。旧画面は当面 `SelectedNoteState` と `UserInfo` をProviderから読むため、**シェルが旧来どおり `UserInfo` を互換供給し続ける**(PR9で削除)。ログアウト処理(`sl.reset()` + signOut)はシェルのCommandへ移植し、get_it初期化も当面残す。サインインはfirebase_ui_authのまま(O4)。DoDのうちVMテストはShellViewModel(ペア検知・ノート切替)、integrationはタブ遷移スモーク |

### PR2: 設定 `dev/arch-02-settings`

- [ ] 完了

| 項目 | 内容 |
|---|---|
| 画面 | settings |
| データ層 | **ProfileRepositoryを新設**(ペア検知watch + ユーザー名read/update)。PR1でシェルに一時移植したペア検知をここで置換 |
| 移設・改修 | `lib/v2/presentation/pages/settings/` → `lib/ui/settings/`。AsyncCommand→Command、Either→Result化の最初の実例を作る |
| 削除 | v2のsettings一式、`FirestorePublicProfileRepository`・`PublicProfileService`・`PrivateProfileService` の旧配線、シェル内の一時ペア検知実装 |
| 特記 | 最小画面で「移行の型」(ファイル配置・テスト構成・PR体裁)を確立する。以降のPRはこれを踏襲 |

### PR3: ダッシュボード `dev/arch-03-dashboard`

- [ ] 完了

| 項目 | 内容 |
|---|---|
| 画面 | dashboard |
| データ層 | **`Period` / `Notebook` 型と `notebook_paths` をここで初出**。Record sealed union + RecordId等のドメインモデル本体、RecordDto、`RecordRepository.watchPeriod(Period)`(incomes/expenses/transfersの3 snapshots結合) |
| 移設・改修 | DashboardViewModelをwatch購読型に書き換え、月次集計をドメイン純粋関数化 |
| 削除 | v2のpersonal/shared income・expense Repository+Service群、`ProxyProvider2` 2本(新RecordRepositoryの単一ProxyProviderへ) |
| 特記 | **リアルタイム反映がここから始まる**(挙動変更一覧参照)。切替状態は移行期間中も既存 `SelectedNoteState` を共用し(旧画面が依存)、新側はProxyProvider内で `Notebook` を導出する(改名・整理はPR9)。未配線だったbudget_graph/summary_panelは触らずPR8で判断 |

### PR4: 記録入力 `dev/arch-04-record-entry`

- [ ] 完了

| 項目 | 内容 |
|---|---|
| 画面 | entry |
| データ層 | `transaction_runner` をここで初出。`RecordRepository.add`(runTransaction + `record.balanceEffects` による残高増減)、`CategoryRepository.watchAll`(収入/支出)、`PropertyRepository.watchAll`、検証付き値型(Amount, RecordNote, RecordDate=未来禁止, 振替の同一資産禁止Assert) |
| 削除 | `lib/presentation/record_register/` `lib/feature/record_register/` と該当service_locator登録 |
| 特記 | **移行の山場**。挙動変更3点が入る: 未来日付入力の禁止(O1)、共有ノートでの記録入力の解禁(O5)、残高の自動増減開始(O6/D7)。着手前に「横断の確認事項」のRules確認を済ませること |

### PR5: カレンダー `dev/arch-05-calendar`

- [ ] 完了

| 項目 | 内容 |
|---|---|
| 画面 | 月次カレンダー + 日次明細 |
| データ層 | `RecordRepository.delete`(残高打ち消しトランザクション) |
| 移設・改修 | 月次VM(watchPeriodを日別に畳み込み)、日次VM(その日のwatch + 削除Command) |
| 削除 | `lib/presentation/monthly_record_viewer/` `lib/presentation/daily_record_viewer/` `lib/feature/record_retrieve/` `lib/feature/record_deletion/` と該当登録 |

### PR6: 資産 `dev/arch-06-properties`

- [ ] 完了

| 項目 | 内容 |
|---|---|
| 画面 | 資産一覧 + 資産エディタ |
| データ層 | `PropertyRepository` CRUD + 削除ガード(参照レコード存在チェック → `Result.error`) |
| 削除 | `lib/presentation/property_viewer/` `lib/presentation/property_editor/` `lib/feature/property_*/` と該当登録 |
| 特記 | 残高の直接編集は仕様として維持。`deletedProperty` センチネル相当のフォールバック表示も新実装で維持 |

### PR7: カテゴリ `dev/arch-07-categories`

- [ ] 完了

| 項目 | 内容 |
|---|---|
| 画面 | カテゴリ一覧(収入/支出) + カテゴリエディタ(予算含む) |
| データ層 | `CategoryRepository` CRUD + 削除ガード |
| 削除 | `lib/presentation/category_viewer/` `lib/presentation/category_editor/` `lib/feature/category_*/` と該当登録 |
| 特記 | `deletedCategory` フォールバック維持 |

### PR8: 予算 `dev/arch-08-budget`

- [ ] 完了

| 項目 | 内容 |
|---|---|
| 画面 | budget |
| 実装 | BudgetViewModel(`Period` 切替: 暦月/月度16日始まり)、カテゴリ別集計の純粋関数(BudgetSummary)。未配線だったfl_chart予算グラフ(golden完備)の再配線をここで判断 |
| 削除 | `lib/presentation/budget_viewer/` `lib/feature/budget_analyzer/` `lib/presentation/util/custom_cycle.dart`(Period型へ置換) |
| 特記 | 実装済みの月度集計(002-bikini)の挙動を`Period`で完全に引き継ぐこと(既存の budget_viewer テストを仕様として参照) |

### PR9: 後始末 `dev/arch-09-cleanup`

- [ ] 完了

| 項目 | 内容 |
|---|---|
| 削除 | 残存する旧世代すべて: `lib/feature/`(repository含む) `lib/util/service_locator/` `lib/data/` `lib/entity/` `lib/vo/` `lib/util/type/` ほか未使用ユーティリティ、`lib/v2/` ディレクトリの解消(空化)、シェルの `UserInfo` 互換供給・get_it初期化の除去、`SelectedNoteState` の最終形(`SelectedNotebook`)への改名整理 |
| pubspec | `dartz` `get_it` `equatable` `uuid` `result_dart` を除去。`mocktail` は必要になった時点(それまでのPR)で追加済みの想定 |
| ドキュメント | `docs/architecture.md` `docs/style_guide.md` `CLAUDE.md` を新アーキテクチャに合わせて全面改訂(現行の「get_itは不使用」等の乖離も解消) |
| 特記 | ここで「新アーキテクチャ100%」宣言。mockitoテストの全面置き換えはしない(既存テストは触るときに移行、の方針を継続) |

## 4. 横断の確認事項(PR1着手前後に実施)

- [x] **CIと生成コード**: 確認済み(2026-08-19、ユーザー確認): `pr-ci.yml` はbuild_runnerを実行している。生成コードは当面**非コミット運用を継続**(移行中のPRレビューを手書きコードに集中させるため。方針を変える場合はここを更新)。再検討時の材料(2026-08-19調査): build_runner公式は「チェックインは選択でよい、pub公開時は同梱必須」、公式サンプルcompass_appは `*.freezed.dart`/`*.g.dart` をコミット、GitHub公式Dart.gitignoreテンプレートも生成物を除外していない
- [x] **Firestore Rules(共有write)**: 確認済み(2026-08-19): `firebase/firestore.rules` の `sharedNotes/{pairId}` 配下は全サブコレクション(incomeCategories/expenseCategories/properties/incomes/expenses/transfers)とも `isOwner` 検証付きで create/update/delete を許可しており、O5の前提を満たす。PR4向けの追記: レコードcreateは `createdAt == request.time`(serverTimestamp必須)と8フィールド版スキーマ(`hasCheckedOut` 含む)を要求し、参照先property/categoryの存在チェックもRules側で行われる
- [x] **goldenワークフロー**: 対応済み(2026-08-19): `update-canonical-goldens.yml` はファイルとしてはmasterに存在するがGitHubに未登録だった(`gh workflow list` に非表示。release.yml等も同様)。登録を発火させるtouch変更をPR #8として作成し、PR1のgolden dispatch前にマージする運び。マージ後に `gh workflow list` で登録を確認すること
- [ ] エミュレータポート(Firestore 8081 / Auth 9099、`firebase/firebase.json`)と `lib` 側接続設定の同期維持

## 5. 挙動変更の一覧(ユーザー影響、いずれも合意済み)

| PR | 変更 | 内容 |
|---|---|---|
| PR3〜 | リアルタイム反映 | 一覧系画面が他端末・ペア相手の変更を自動反映するようになる(従来は画面再訪まで反映されない) |
| PR4 | 未来日付の禁止 | 記録入力の日付が当日までに制限される(従来は+365日先まで入力可能だった)(O1) |
| PR4 | 共有ノートの書き込み解禁 | 共有ノート選択時も記録入力が可能になる(O5) |
| PR4〜5 | 残高の自動増減 | レコード作成/削除で資産残高が自動的に増減する。従来は `hasCheckedOut=false` 固定のため実質増減していなかった(O6)。**過去レコード分の遡及反映はしない**(必要なら資産編集で手動調整) |
| PR1〜PR8 | タブ再訪時の自動再読込の一時停止 | StatefulShellRoute(IndexedStack)のステート保持により、旧実装のままのタブはアプリ再起動まで他タブでの変更を反映しなくなる(従来はタブ切替のたびに画面を作り直して再読込していた)。各画面のwatch化(PR3〜PR8)ごとに順次解消し、以後はリアルタイム反映に置き換わる |
| PR1 | ログアウト処理からget_itリセットを除去 | 旧実装の `sl.reset()` は再登録経路がなく、同一セッションでの再ログイン後に旧画面が `sl<T>()` でクラッシュする潜在バグの原因だった。登録は全てステートレスな `registerFactory` でresetに実益がないため廃止 |

## 6. 進捗管理の運用

- 各PRマージ時: 本ドキュメントのチェックボックス更新 + 特記事項があれば当該PR欄に追記
- 順番の入れ替え・スコープ変更が必要になったら、変更理由を「変更履歴」に1行残して更新する(会話ログではなくここが正)

## 変更履歴

- 2026-08-19: v1.0 作成(方針合意: 場所=このモノレポ / 機能単位 / 共存方法 / DoD / 体制 / 共有振替バグ対処不要)
- 2026-08-19: v1.1 レビュー反映 — PR1をYAGNIで最小化(domain/models・profile系Repository・notebook_paths・transaction_runnerを各初出PRへ後送。土台のRepositoryはauthのみ)、CI項目を確認済み化(pr-ci.ymlはbuild_runner実行済み)
- 2026-08-19: PR1詳細化に伴う決定を反映 — タブ鮮度は移行期間中の低下を受容(挙動変更一覧に追加) / logoutの `sl.reset()` 廃止(同) / goldenワークフロー登録はマイクロPR(#8)先行で対応 / Rules確認・golden登録の§4を消化。mockitoはResultを返すinterfaceをモック生成できないため、以後の新規テストは手書きFake(D10方針)を使うこと
- 2026-08-19: Repository実装の `Future<Result>` を返すメソッドは本体を `Result.guard(() => ...)` の1行にする規約を導入(PR1)。メソッドごとのtry/catch手書きによるcatch漏れを構造的に防ぐ。custom_lintによる機械検証(CI組み込み)はPR2着手前の別マイクロPRで導入予定
- 2026-08-20: Result.guard規約の機械検証を導入(`repository_must_use_result_guard`ルール、`packages/household_lints`、CI組み込み)。custom_lintは2026-03-24付けでarchived(開発終了)されており後継はDartネイティブのanalyzer plugin機構のため、実装は当初想定のcustom_lintではなく`analysis_server_plugin`(analyzer 14.1.0)ベースで行った。`flutter analyze`の一発実行はプラグイン診断を取りこぼす既知の制約があるため、CIの機械的検証は`dart analyze`で行う(`.github/workflows/pr-ci.yml`参照)

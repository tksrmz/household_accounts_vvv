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
4. 各PRは `flutter analyze` / `dart analyze`(Repository規約lint含む) / `dart format` / 既存テストすべて緑を維持する
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

- [x] 完了(2026-08-23、PR #15)

| 項目 | 内容 |
|---|---|
| 画面 | settings |
| データ層 | **ProfileRepositoryを新設**(`lib/data/repositories/profile/`。ペア検知watch + ユーザー名read/update。Service層・DTOは作らずFirestore直アクセス)。PR1でシェルに一時移植したペア検知をここで置換。**`lib/domain/models/` はここで初出**: `PairStatus`(sealed)・`PairId`・`UserId`・`UserName`(1〜20文字検証+static validate)の4型を1型1ファイルで新設し、`Stream<PairStatus> watchPairStatus(UserId)` を最終形のAPIとする(v2 `UserIdVo` との変換はシェル/VM境界で行う) |
| 移設・改修 | `lib/v2/presentation/pages/settings/` → `lib/ui/settings/`。AsyncCommand→Command、Either→Result化の最初の実例を作る |
| 削除 | v2のsettings一式(page/view_model/widgets/spec.md+テスト・golden)、シェル内の一時ペア検知実装(`lib/ui/shell/pair_id_stream.dart`)。**旧profile系データ層(`FirestorePublicProfileRepository`・`PublicProfileService`・`PrivateProfileService`)の削除はPR3へ後送**(v2 dashboardと共有income/expense Repositoryが現役依存しており、PR2で消すとコンパイル不能。2026-08-22のコード調査で判明) |
| 特記 | 最小画面で「移行の型」(ファイル配置・テスト構成・PR体裁)を確立する。以降のPRはこれを踏襲。ペア検知watchは当面 `authStateChanges` と同じ素の `Stream<T>` 形を踏襲する(watchのエラー表現の体系的決定は、より複雑なwatchPeriodが初出するPR3で行う。本watch 1本のみのため決定後の追随コストは小さい)。goldenはPR1の3幅ヘルパー(`testGoldens`)でv2の全シナリオを移植する。あわせて、ペア解消時に `SelectedNoteState` がsharedのまま取り残される既存の潜在不整合を修正し、notPaired検知時にpersonalへ強制リセットする(挙動変更一覧参照)。**マージ後・PR3着手前のフォローアップ(マイクロPR)**: 設定画面の検証タイミングを旧spec.mdの記載(不正入力の時点でValidationError遷移+保存ボタン押下不可=ライブ検証)に合わせる。PR2自体は現行実装の観察可能な挙動(保存押下時に検証)を忠実移植するため、spec.mdとの乖離はPR2では解消されない(spec.mdはPR2で削除されるため、状態遷移の意図はこの記録が引き継ぐ)。**→ このフォローアップはPR #19で実施済み(2026-08-23)** |

### PR3: ダッシュボード `dev/arch-03-dashboard`

- [x] 完了(2026-08-25、PR #20)

| 項目 | 内容 |
|---|---|
| 画面 | dashboard |
| データ層 | **`Period` / `Notebook` 型と `notebook_paths` をここで初出**。Record sealed union + RecordId等のドメインモデル本体、RecordDto、`RecordRepository.watchPeriod(Period)`(incomes/expenses/transfersの3 snapshots結合)。あわせて `UserAuth` を `lib/domain/models/` へ移設し新 `UserId` へ切替(主要な消費者のProxyProvider2・v2 income/expense Repository群がこのPRで消滅するため移設の最適点。遅くともPR9)。pairId供給は`SelectedNoteState`の拡張(pairId保持+`updatePairId`で原子的にpersonal復帰+`resolve(uid)`→`Notebook`導出)で行う。検証付き値型のうち`Amount`・`RecordNote`はPR4から前倒しして本PRで導入し、**`RecordDate`は無検証のまま**とする(integrationテストのシードデータが月末23:59:59を持ち、実行日によっては意図的に未来日付になるため。未来日付の拒否はPR4の入力境界(DatePicker制限+ドラフト検証)で行う) |
| 移設・改修 | DashboardViewModelをwatch購読型に書き換え、月次集計をドメイン純粋関数化 |
| 削除 | v2のpersonal/shared income・expense Repository+Service群、`ProxyProvider2` 2本(新RecordRepositoryの単一ProxyProviderへ)、**PR2から後送した旧profile系データ層**(`FirestorePublicProfileRepository`・`PublicProfileService`・`PrivateProfileService`・`PrivateProfile`モデル・`private_profile_util`。dashboard移行と共有Repository削除で依存が外れるため) |
| 特記 | **リアルタイム反映がここから始まる**(挙動変更一覧参照)。切替状態は移行期間中も既存 `SelectedNoteState` を共用し(旧画面が依存)、新側はProxyProvider内で `Notebook` を導出する(改名・整理はPR9)。watchのエラー表現は素の `Stream<T>` に決定(2026-08-24)。Streamのエラーは購読側(ViewModel)が `listen(onError:)` で受け、onErrorハンドラ内でException(エラー状態化)とError(`Error.throwWithStackTrace` で再送出=fail fast)を区別する規約とする(`Result.guard` の区分と一貫)。`Stream<Result<T>>` 化はせず、刷新案D6の記述は現行のまま、lintの新ルールも設けない。「未配線だったbudget_graph/summary_panel」のうちsummary_panelは実際には現役表示中だったため、PR3で `lib/ui/dashboard/widgets/` へ移設した。真に未配線なのはbudget_graph(+BudgetGraphData/BudgetGraphDataList/golden 27枚)のみで、これらはv2に残置しPR8で判断する。RecordDtoはwithConverterを使わない(読み取り専用の本PRでは`toFirestore`が書けない: `createdAt`はserverTimestamp必須等。D6のwithConverter方針自体は維持し、`add`を実装するPR4で再評価)。DTOはIncome/Expense/Transferの3クラス(ドキュメント形が同一でもドメイン的に別物のため共用しない)。`FirestoreRecordRepository`自体の単体テストは書かない(パス解決=`notebook_paths_test`、変換=`record_dto_test`、結合=`combine_latest_test`で担保し、期間フィルタの実効性はintegrationテストで担保。エミュレータ結合テスト基盤の検討はPR4へ) |

### PR4: 記録入力 `dev/arch-04-record-entry`

- [x] 完了(2026-08-30、PR #24)

| 項目 | 内容 |
|---|---|
| 画面 | entry(`lib/ui/record_entry/`) |
| データ層 | `RecordRepository.add(NewRecord)`: **WriteBatch**でレコード作成と `NewRecord.balanceEffects` による資産残高incrementを原子的に実行(addは読み取りを伴わないためrunTransactionでなくバッチ。オフライン時もローカル適用され復帰時に同期される。読みのあるdelete(PR5)はrunTransaction、という「読みの有無」を使い分け基準とする)。`CategoryRepository`(`watchIncomeCategories`/`watchExpenseCategories` の2メソッド。watchAll(type)形は支出だけが予算を持つ将来と両立しないため不採用)・`PropertyRepository.watchAll`。ドメインは `NewRecord`(sealed union。保存済み`Record`とはIDの有無で型を分ける)+`BalanceEffect`(named record)を新設し、Category/PropertyモデルはYAGNI最小(id+名前。名前は`CategoryName`/`PropertyName`の検証付き値型(1〜20文字)とする=PRレビューで決定。totalBudget・Property.amountはPR6〜8の初出時)。**transaction_runnerは作らない(恒久方針)**。入力境界: DatePickerのlastDate=当日+submit時の防御検証で未来日付を禁止(`RecordDate`型は無検証を維持) |
| 削除 | `lib/presentation/record_register/` `lib/feature/record_register/` `AddRecordUseCase`のservice_locator登録3本、`NumberTextFormField`、`lib/util/extension/string.dart`、旧record系Repositoryの`register`実装(抽象宣言は共通基底`Repository<T>`にありカテゴリ/資産登録が現役のため、具象6クラスをUnsupportedError化)、`RecordBaseModel.fromEntity`系、`config/dependencies.dart`の消費者ゼロだったv2サービス登録5本(PersonalIncomeCategoryService等。ファイル本体の削除はPR9) |
| 特記 | **移行の山場**(実装済み・2026-08-26)。挙動変更で実際に入るのは未来日付入力の禁止(O1)と**共有振替の正パス化**のみ(O5/O6の計画時記述は事実誤認だった。挙動変更一覧の訂正参照)。**hasCheckedOutは恒久的にtrueを書く**(旧カレンダー削除がtrueのレコードだけ残高を打ち消すため、falseを書くとPR5までの間に残高不整合窓が生じる。ユーザー決定)。withConverterはレコードについて不採用に確定(読み取り=id付き/参照String、書き込み=idなし/DocumentReference/serverTimestampセンチネルで型が一致しない。書き込みはDTOファイル内のトップレベル関数)。刷新案§6の`RecordDraft`は不採用: 検証はUI層の関心事のためVM状態で表現し、Commandは`Command1<void, NewRecord>`で検証済み型だけを受ける(settingsの`Command1<void, UserName>`と同型)。`balanceEffects`は`NewRecord`側に置き、PR5の削除打ち消しは`Record.withoutIdentity()`(PR5で新設)+符号反転で同じ定義を再利用する予定。integrationテストは6シナリオを新UI向けに刷新し、スナックバーに加えFirestore実データ(8フィールド・参照先・当日日付)と資産残高の前後差分、共有振替がsharedNotes配下に書かれること(旧バグの構造的解消)を検証する。**budget_feature_testの境界日シードはREST化**(`record_seeding.createExpenseRecord`。月度境界の2日付がほぼ必ず未来日付になり、新UIの当日制限でUI投入が不可能になったため。REST共通部は`integration_test/util/firestore_rest.dart`へ抽出し`seed_record_dates.dart`と共用)。goldenは9シナリオ×3幅 |

### PR5: カレンダー `dev/arch-05-calendar`

- [ ] 完了

| 項目 | 内容 |
|---|---|
| 画面 | 月次カレンダー + 日次明細(`lib/ui/calendar/` に2画面を同居)。ルートは月次=`/calendar`(シェル内ブランチ、他タブ同様 `_notebookScoped` + Host再生成へ改修)、日次=`/calendar/:date`(**シェル外ルートレベル** + `context.push`。旧実装のrootNavigator push=「ボトムナビを覆う」挙動とsettingsの前例に一致。日付パラメータは `yyyy-MM-dd`) |
| データ層 | `RecordRepository.delete(Record record)`(刷新案§5の `delete(RecordId)` はIDだけでは3コレクションを特定できず実装不能のため `Record` を受ける形に変更=ユーザー決定。sealed型switchでコレクション解決)。runTransactionで対象レコードを再読し(打ち消し金額は再読値が正)、再読レコードの `content.balanceEffects` の符号反転で資産残高を打ち消してからレコードを削除。**打ち消しは旧実装同様 `hasCheckedOut == true` のときのみ**(ユーザー決定。falseの実データ有無が未確認のため安全側。フィールド廃止の判断はPR9以降へ)。存在しないIDの削除は成功扱い(旧契約踏襲)。**参照先資産が既に存在しない場合は当該incrementをスキップしレコード削除は成功させる**(旧実装はトランザクション失敗で参照切れレコードが削除不能だった。挙動変更一覧参照)。domainは「レコード内容」を具象化: `NewRecord` を `RecordContent` へ改名して残高への寄与(`balanceEffects`)の定義を1箇所にし、`Record.content` で保存済みレコードから内容を取り出す(PR4予告の `Record.withoutIdentity()`=Record→NewRecord変換は「保存済みを『これから登録される』へ変換する」意味的転倒のためレビューで不採用。ミラーゲッター案も「内容」概念の欠落が残るため不採用)。あわせて `Period.day(y, m, d)` を追加 |
| 移設・改修 | CalendarViewModel: 月の `watchPeriod(Period.calendarMonth)` を日別畳み込み(収入/支出/振替の3合計。`RecordSummary` 同様domainの純粋関数化)。**月切替はVM内で購読を張り替える**(Period切替の初の前例=PR8の下敷き。notebook切替は従来どおりHost再生成)。右矢印は当月まで・左矢印は無制限の旧挙動を維持。カレンダーUIは旧の手組みTable(曜日ヘッダ月〜日、日セルに収入緑/支出橙/振替灰の3行)を忠実移植。DailyRecordsViewModel: `watchPeriod(Period.day)` + カテゴリ2本・資産1本のwatch(record_entryのper-source管理を踏襲)からID→名前の逆引きMapを構築し、参照切れIDは「削除済み」フォールバック表示(旧センチネル相当をUI層で再現)。表示形式は旧踏襲(収入/支出=`カテゴリ名@メモ`+金額(収入のみ`+`)、振替=`from→to`)。`delete = Command1<void, Record>`、**確認ダイアログなし**(忠実移植=ユーザー決定) |
| 削除 | 計画の4ディレクトリ(`lib/presentation/monthly_record_viewer/` `lib/presentation/daily_record_viewer/` `lib/feature/record_retrieve/` `lib/feature/record_deletion/`)に加え、実態調査で判明した波及分: `lib/util/service_locator/record_use_case.dart`(UseCase登録6本)+`main.dart` の `initRecordUseCase` 呼出し / `lib/presentation/util/date.dart` / `lib/presentation/util/use_case_wrapper/fetch_records.dart` / `lib/data/firebase/firebase_income_record_repository.dart`・`firebase_transfer_record_repository.dart` 全体+Income/Transfer系sl登録4本 / `repository_selector.dart` の `selectIncomeRecordRepository`・`selectTransferRecordRepository`。**Expense系チェーン(`PersonalExpenseRecordRepository`/`SharedExpenseRecordRepository`+Firebase実装+sl登録+`selectExpenseRecordRepository`)はbudget_viewer(PR8)が現役依存のため残す** |
| 特記 | watch化により旧実装の「日次から戻ったら月次を再取得」「削除後にsetStateで再取得」は自動リアルタイム反映へ置き換わる。日次の並び順は種別グループ順→日時昇順へ変わる(挙動変更一覧参照)。日次はdate同値レコードが多くDartのsortは不安定のため、二次キー(id)で並びを決定的にする。旧カレンダー系の既存テストはゼロ・`calendar_feature_test.dart` は空スタブのため、integrationは全面新規作成: シードレコードは他テストが依存するため**削除シナリオはUIで作成したレコードを削除する**(残高の往復差分+ドキュメント消滅をfirestore_probeで検証)。共有ノートでの削除(共有振替の正パス読み取りの検証を兼ねる)を含める。**実装時の判明事項(2026-08-31)**: (1) `cloud_firestore` 6.8.0の `runTransaction` は完了のたびにプラグイン内部(`method_channel_firestore.dart` の `whenComplete(snapshotStreamSubscription.cancel)`)が無害な `MissingPluginException` を `FlutterError` へ報告する。トランザクション自体は成功しており実害はないが、integrationテストではこの例外のみを除外する限定フィルタを入れた。恒久対処(プラグイン更新)は依存更新のタイミングで再確認 (2) integrationシードの `properties`/`incomeCategories`/`expenseCategories` コレクションは空で、シードレコードの参照は最初から参照切れ=日次明細では「削除済み」表示になる(参照切れフォールバックの検証に利用。将来シードへカテゴリを足すと該当アサーションの更新が必要) (3) 記録入力フォームのUI操作を `integration_test/util/record_entry_operations.dart` へ集約(record_creating_feature_testと共用) |

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
| pubspec | `dartz` `get_it` `equatable` `uuid` `result_dart` を除去。`mocktail` は必要になった時点(それまでのPR)で追加済みの想定(実態注記: PR3時点でも未導入。DocumentReference等のフェイクはnoSuchMethodを自前宣言した手書きFakeで足りたため) |
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
| PR4 | 未来日付の禁止 | 記録入力の日付が当日までに制限される(従来は選択中日付±365日の範囲で未来も入力可能だった)(O1) |
| PR4 | 共有振替の正パス化 | 共有ノートでの振替レコードが正しく `sharedNotes/{pairId}/transfers` へ書かれるようになる(旧実装は誤って個人パスへ書く既知バグがあった)。**訂正(2026-08-26)**: 計画時の「共有ノートの書き込み解禁(O5)」は事実誤認。旧実装に共有ノート時の入力禁止は存在せず、共有ノートへの記録入力は従来から可能だった。あわせて**旧カレンダー側の共有振替リポジトリ(読み取り・削除)にも同じパス誤りが残っていたため正パスへ修正**(§0の「対処不要」は旧ライターについての決定。新ライターが正パスへ書き始めたことで、修正しないとPR5までの間、作成した共有振替がカレンダーで見えず削除もできない整合窓が生じるため。PR #24レビュー指摘) |
| PR4〜5 | (訂正)残高の自動増減は既存挙動 | **訂正(2026-08-26)**: 「従来は `hasCheckedOut=false` 固定のため実質増減していなかった」は事実誤認。旧入力UIは常に `hasCheckedOut: true` を設定し、登録時の残高増減は従来から毎回発生していた。新実装はこの挙動を維持する(O6の「falseを書き込むのみ」は撤回し、**今後も常にtrueを書く**。旧カレンダー削除の打ち消し条件との整合のため)。過去レコード分の遡及反映をしない点は従来どおり |
| PR1〜PR8 | タブ再訪時の自動再読込の一時停止 | StatefulShellRoute(IndexedStack)のステート保持により、旧実装のままのタブはアプリ再起動まで他タブでの変更を反映しなくなる(従来はタブ切替のたびに画面を作り直して再読込していた)。各画面のwatch化(PR3〜PR8)ごとに順次解消し、以後はリアルタイム反映に置き換わる |
| PR1 | ログアウト処理からget_itリセットを除去 | 旧実装の `sl.reset()` は再登録経路がなく、同一セッションでの再ログイン後に旧画面が `sl<T>()` でクラッシュする潜在バグの原因だった。登録は全てステートレスな `registerFactory` でresetに実益がないため廃止 |
| PR2 | ペア解消時の個人ノートへの自動復帰 | ペア解消(pairId消失)を検知したとき、選択中ノートが共有のままでも個人ノートへ強制リセットするようになる(従来は切替UIが消えるだけでshared表示が継続する潜在不整合があった) |
| PR2後続 | 設定画面のライブ検証 | ユーザー名の不正入力(0文字)を入力した時点で検証エラーを表示し保存ボタンを押下不可にする(従来は保存押下時に検証)。旧spec.mdの状態遷移への準拠(PR #19) |
| PR3 | データ不正時のエラー表示 | 期間内に1件でもドメイン制約を満たさないレコード(金額0以下・メモ101文字以上・ドキュメント形の不正)があると、ダッシュボード全体がエラー表示になる(従来は検証せず合計していた)。正常なスナップショットが届けば自動回復する |
| PR5 | 参照切れレコードの削除可能化 | 参照先資産が既に削除されているレコードを削除できるようになる(旧実装は残高打ち消しの`transaction.update`が存在しない資産で失敗し、レコード自体が削除不能だった)。残高打ち消しは存在する資産にのみ適用する |
| PR5 | 日次明細の並び順 | 日次明細の表示順が種別グループ順(収入→支出→振替)から日時昇順の混在リスト(同時刻はID順)へ変わる |

## 6. 進捗管理の運用

- 各PRマージ時: 本ドキュメントのチェックボックス更新 + 特記事項があれば当該PR欄に追記
- 順番の入れ替え・スコープ変更が必要になったら、変更理由を「変更履歴」に1行残して更新する(会話ログではなくここが正)

## 変更履歴

- 2026-08-19: v1.0 作成(方針合意: 場所=このモノレポ / 機能単位 / 共存方法 / DoD / 体制 / 共有振替バグ対処不要)
- 2026-08-19: v1.1 レビュー反映 — PR1をYAGNIで最小化(domain/models・profile系Repository・notebook_paths・transaction_runnerを各初出PRへ後送。土台のRepositoryはauthのみ)、CI項目を確認済み化(pr-ci.ymlはbuild_runner実行済み)
- 2026-08-19: PR1詳細化に伴う決定を反映 — タブ鮮度は移行期間中の低下を受容(挙動変更一覧に追加) / logoutの `sl.reset()` 廃止(同) / goldenワークフロー登録はマイクロPR(#8)先行で対応 / Rules確認・golden登録の§4を消化。mockitoはResultを返すinterfaceをモック生成できないため、以後の新規テストは手書きFake(D10方針)を使うこと
- 2026-08-19: Repository実装の `Future<Result>` を返すメソッドは本体を `Result.guard(() => ...)` の1行にする規約を導入(PR1)。メソッドごとのtry/catch手書きによるcatch漏れを構造的に防ぐ。custom_lintによる機械検証(CI組み込み)はPR2着手前の別マイクロPRで導入予定
- 2026-08-20: Result.guard規約の機械検証を導入(`repository_must_use_result_guard`ルール、`packages/household_lints`、CI組み込み)。custom_lintは2026-03-24付けでarchived(開発終了)されており後継はDartネイティブのanalyzer plugin機構のため、実装は当初想定のcustom_lintではなく`analysis_server_plugin`(analyzer 14.1.0)ベースで行った。`flutter analyze`の一発実行はプラグイン診断を取りこぼす既知の制約があるため、CIの機械的検証は`dart analyze`で行う(`.github/workflows/pr-ci.yml`参照)
- 2026-08-22: Repository公開APIの形を検証するルールを追加(`repository_no_bare_future`=素のFuture/FutureOr禁止、`repository_no_public_properties`=公開getter/setter/フィールド禁止)。既存ルール含め対象を「lib/data/repositories/配下かつクラス名が*Repository」に統一(将来のDTO誤検知防止)。同期読み取りが素のT(例: getCurrentUser)を返すのは規約適合(Resultは失敗しうる操作のマーカー)
- 2026-08-22: lint整備の持ち越し事項をPR3特記へ明文化(watchのエラー表現: `Stream<T>` か `Stream<Result<T>>` かの決定)。あわせてCLAUDE.mdへ「規約lintの検証は `dart analyze` を使う」旨を追記(flutter analyzeはプラグイン診断の検知を保証しないため)。レビュー反映: 原則4の必須チェックにも `dart analyze` を追加し、PR2のペア検知watchは素の `Stream<T>` 形を踏襲(決定はPR3)である旨をPR2特記に明記
- 2026-08-22: PR2詳細化(コード実態調査に基づくスコープ訂正、ユーザー決定4件) — (1)旧profile系データ層の削除はdashboard・共有Repositoryの現役依存によりPR3へ後送 (2)`lib/domain/models/` の初出をPR2に前倒し(PairStatus・PairId・UserId・UserNameの4型。D9の検証付き値型リストにUserNameを追加解釈) (3)設定画面goldenは3幅ヘルパーで全シナリオ移植 (4)ペア解消時のSelectedNoteState強制リセット修正をPR2に含める(挙動変更一覧に追加)
- 2026-08-22: バリデーションの層分担を明確化 — バリデーション(ドメインルール未達の入力)はUI層の関心事としてVM状態で表現し、Command/Result.errorはData層由来の失敗のみを表す。保存Commandの引数は検証済み値型(`Command1<void, UserName>`)とし境界を型で強制する。検証タイミングのspec.md準拠化(ライブ検証)はPR2マージ後・PR3着手前のマイクロPRとして実施(PR2特記参照)
- 2026-08-23: PR #15レビュー反映 — 検証付き値型の方針を「@Assert + static validate」からコンストラクタでの全ビルド検証+throwへ変更(ユーザー入力由来=`FormatException`(VMが捕捉し検証状態へ)、システム内不変条件=`ArgumentError`(fail fast)。`Result.guard` のException/Error区分と対応)。UI文言はWidget層へ戻す。ShellViewModelはStream関数注入をやめProfileRepository注入へ(VMはRepositoryインターフェースを受け取る規約)。`UserAuth` のdomain移設をPR3へ追記
- 2026-08-23: PR2フォローアップのマイクロPR(設定画面のライブ検証化)を実施(PR #19)。`UserName.isValid` を新設しコンストラクタの検証条件と判定を一本化。挙動変更一覧に追加
- 2026-08-24: integrationシードデータの参照フィールドを修正 — シードレコードの `property.ref`/`category.ref` が文字列パスで保存されており、本番の正(アプリはDocumentReferenceを書き込み、Rulesも `is path` を要求)と乖離していた(旧ダッシュボードはamountしか読まず露見せず、新RecordDtoの形検証で発覚。エミュレータのimportはRulesを迂回するためシードにだけ存在できていた)。エミュレータ+REST APIでreferenceValueへ一括変換し再export。変換手段は `integration_test/util/patch_seed_record_refs.cjs` として保存
- 2026-08-25: PR #20(PR3)レビュー反映を経てマージ — `UserAuth`をsealed union化(サインイン未済を番兵値でなく`UserAuthNotSignedIn`型で表現。認証済み文脈専用の`signedInUid`は未サインインでStateError=fail fast)/ watchPeriodの契約docから実装詳細(サーバー側クエリ・リスナー解除)を除去 / combineLatest3はエラーを起こしたソースの最新値を無効化し、そのソースが回復するまで出力を止める(古い値の組で「正常に見える」出力をしない)/ RecordDtoが`type`フィールドを期待種別と突き合わせて検証 / 旧記録入力の0円入力を拒否(金額1以上のドメイン制約。PR4で旧入力UIごと消えるまでの暫定ガード)
- 2026-08-30: PR #24レビュー反映 — カテゴリ名・資産名を検証付き値型(`CategoryName`/`PropertyName`、1〜20文字)へ前倒し(YAGNI最小の範囲をユーザーレビューで訂正。D9の検証付き値型リストに沿う)/ VM内の入力判定を状態依存getterでなく入力を引数に取る純粋関数にする方針を確認(`_isAmountValid`)/ integrationテスト共通のUI操作(タブ移動・共有ノート切替)を `integration_test/util/ui_operations.dart` へ集約
- 2026-08-26: PR4詳細化と実装の決定を反映 — コード実態調査で計画の事実誤認2件を訂正(O5: 共有ノートの記録入力は従来から可能。O6: 残高増減はhasCheckedOut=true固定により従来から発生)/ hasCheckedOutは恒久的にtrueを書く(旧カレンダー削除の打ち消し条件との不整合窓を作らない。ユーザー決定)/ addの原子性はWriteBatch(読みなし操作。読みのあるdelete=PR5はrunTransaction。「読みの有無」を使い分け基準に)/ transaction_runnerは恒久不採用(必要時も各Repositoryへ直書き。v2のFirestoreTransactionServiceも未使用だった)/ withConverterはレコードについて不採用確定 / RecordDraft不採用(Command1<void, NewRecord>。検証はUI層)/ Category・PropertyモデルはYAGNI最小(id+name)/ balanceEffectsはNewRecord側(PR5はRecord.withoutIdentity()で反転予定)/ budget_feature_testの境界日シードはREST化(月度境界シードがほぼ必ず未来日付を含み、O1の当日制限とUI投入が両立しないため。計画外の依存としてbudget→旧入力UIの密結合が発覚した教訓)/ integrationは実データ+残高差分を検証 / dependencies.dartの死んだv2サービス登録5本を削除
- 2026-08-31: PR5詳細化(コード実態調査+ユーザー決定5件)— delete APIは `delete(Record record)`(RecordIdだけではコレクション特定不能のため刷新案§5から変更)/ 残高打ち消しはhasCheckedOut==trueゲートを踏襲(falseの実データ有無が未確認のため安全側。廃止判断はPR9以降)/ 参照先資産消失時はincrementスキップで削除成功(旧実装は削除不能。挙動変更一覧へ追加)/ 削除確認ダイアログなし(忠実移植)/ **「レコード内容」の具象化**: 残高への寄与はレコード内容の関数でありIDや保存状態と無関係、という概念が型に現れていないことがPR4予告 `withoutIdentity()`(意味的転倒)とミラーゲッター案(定義重複)の両方の違和感の正体だったため、`NewRecord`→`RecordContent` 改名+`Record.content` ゲッターで解決(`balanceEffects` の定義は1箇所に。ドメインサービス案は引数型問題が解決せず、原子的適用と資産消失時の除外はD7どおりRepository契約に属するため不採用)。`Period.day` を追加。削除欄を実態調査で具体化(Expense系チェーンはbudget_viewer依存で残置、Income/Transfer系は全削除可)。日次並び順の変更を挙動変更一覧へ追加。日次ルートはシェル外 `/calendar/:date`(settingsの前例踏襲)
- 2026-08-24: PR3詳細化と実装の決定を反映 — watchエラー表現の決定(素の`Stream<T>`+`listen(onError:)`でException/Errorを区分、`Result.guard`の区分と一貫。`Stream<Result<T>>`化・lint新設は見送り) / combineLatest3を自作(`lib/utils/combine_latest.dart`、rxdart不採用) / pairId供給は`SelectedNoteState`の拡張(`updatePairId`) / 検証付き値型のうちAmount・RecordNoteをPR3へ前倒し、RecordDateはシード衝突回避のため無検証を維持 / RecordDtoはIncome/Expense/Transferの3クラスに分割(共用しない) / withConverter採用は見送り(PR4で再評価) / summary_panelは「未配線」ではなく現役表示中だった事実を訂正(budget_graphのみ真に未配線) / ダッシュボード初回ローディングもCommand0で統一(settings準拠)

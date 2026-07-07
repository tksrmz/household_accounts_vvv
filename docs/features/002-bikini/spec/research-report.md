# 調査レポート

対象: [requirements.md](./requirements.md) セクション10の技術的未知（TQ-001, TQ-002）
調査日: 2026-07-06（調査はサブエージェント2体に委譲して並列実施）

> **追記（2026-07-07・人間判断による方針転換）**: 本レポートの「発見された追加制約」3・4を受けて、**期間の共通抽象（`AggregationPeriod`）・期間VO（`CalendarMonthPeriod`/`CustomCyclePeriod`）・v2 `fetchMonthly` の一般化は採用しない**ことが決定された。本機能はレガシー予算タブの拡張で完結し、レガシー経路（`RetrieveBudgetStateUseCase` → `RecordRepository.retrieveRecordsOf(repoId, begin, end)`）が既に begin/end 指定を持つため、期間を多態的に扱うコードが実装経路に存在しないことが理由。これにより TQ-001 の推奨設計（VO・抽象・Repository/Service のシグネチャ変更）は**採用されない**が、以下は引き続き有効な調査結果として設計フェーズで参照する:
>
> - 半開区間（begin 以上・end 未満）による境界表現と、端末ローカル時刻での一貫性（タイムゾーン変換不要）の確認結果
> - `CustomCyclePeriod.containing()` / `shift()` 相当の月度計算ロジック（今日が属する月度の判定、前後移動、うるう年・月日数差の扱い）— VOではなく単体テスト可能な純粋ロジックとして1箇所に集約する形で流用する
> - 既存コードの棚卸し結果（レガシー側の begin/end 先行実装、`assert(begin.isBefore(end))` の誓約パターン）
> - TQ-002 の結論（レガシー拡張＋`SegmentedButton`＋期間ナビゲーションWidget新設）は変更なし。むしろ v2 側の変更が消えたことで選択肢Aの優位性が強まった

## サマリー

- **TQ-001（期間抽象）**: 共通抽象は `abstract interface class AggregationPeriod`（`begin`含む / `end`含まないの半開区間のみを公開）とし、`CalendarMonthPeriod`（暦月）と `CustomCyclePeriod`（月度）を独立した `@freezed` クラスとして `implements` させる設計を推奨。Service層は既に内部で begin/end 半開区間クエリ（`isGreaterThanOrEqualTo`/`isLessThan`）を組み立てており、一般化は外部APIの置き換えに等しい。タイムゾーンはアプリ全体が端末ローカル時刻で一貫しており、特別な変換は不要。
- **TQ-002（予算タブUI）**: レガシー構造のまま最小限の拡張（選択肢A）を推奨。既存の `RetrieveBudgetStateUseCase` は既に begin/end を受け取る設計のため、期間stateの導入は自然な延長。切替UIは Material 3 の `SegmentedButton`（Flutter 3.44・useMaterial3デフォルトtrueで利用可）。カレンダー画面の `_DateLabelWidget` はprivateで直接再利用不可のため、一般化した期間ナビゲーションWidgetを新設する。
- **重要な発見**: 予算タブにはWidgetテスト・Integrationテストが現状ゼロ（`integration_test/budget_feature_test.dart` は空スタブ）であり、テストはゼロからの新設になる。
- **設計フェーズへの申し送り**: 2つの調査結果の間で「期間抽象の責務範囲」（begin/endのみか、ラベル・期間送り・未来判定まで持つか）と「v2 `fetchMonthly` 一般化の適用範囲」（本機能に必須か、規約準拠の併走リファクタか）の整合を取る必要がある（後述「発見された追加制約」参照）。

## 調査結果

### TQ-001: 期間抽象の具体設計

- **問い**: 「暦月期間」VOと「カスタム期間（月度）」VOに共通する抽象の形、一般化されたデータ取得メソッド（Repository / Service）のシグネチャ、半開区間の境界時刻表現とタイムゾーンの扱いを、実装可能なレベルまで具体化する。

- **結論**:
  - 共通抽象は **`abstract interface class AggregationPeriod`**（Dart 3）とし、`begin`（含む）/ `end`（含まない）の2プロパティのみを公開する。
  - `CalendarMonthPeriod`（暦月）と `CustomCyclePeriod`（月度）は、それぞれ独立した `@freezed` クラスとして実装し、`AggregationPeriod` を `implements` する。既存VOの単一プロパティ規約には収まらないため、複数フィールドを持つ小さなEntity的VOとして `assert` で `begin.isBefore(end)` を誓約する。
  - Repository の `fetchMonthly(DateTime date)` は **`fetchByPeriod(AggregationPeriod period)`** に置き換える。Service の `fetchByDate(uid, year, [month, day])` は **`fetchByPeriod(uid, AggregationPeriod period)`** に一般化する。
  - Firestoreクエリは既存パターン（`where('date', isGreaterThanOrEqualTo: begin, isLessThan: end)`）をそのまま流用でき、`period.begin` / `period.end` を渡すだけでよい。
  - タイムゾーンは既存実装同様「端末ローカルの `DateTime` を絶対時刻（epochマイクロ秒）として保存・比較する」方式を踏襲。`DateTime(year, month, 16)` のようなローカル時刻での境界生成は既存データと整合し、UTC変換は不要。

- **根拠**:
  - v2 の全 Service（`PersonalExpenseRecordService.fetchByDate` 等3種、`SharedRecordService.fetchExpensesByDate`/`fetchIncomesByDate`）は既に内部で `firstDay`/`lastDay` を計算して半開区間クエリを発行しており、外部APIを begin/end（Period）に置き換えるのは実装上の一般化にすぎない。
  - レガシー側の `RecordRepository.retrieveRecordsOf({repoId, begin, end})`（doc commentで「begin included / end excluded」と明記）と、その実装（`assert(begin.isBefore(end))` 付き）が今回の一般化のFirestore側の先行実装であり、誓約表現も含めて参考にできる。
  - `pubspec.lock` 実測で `freezed: 3.2.5`、`cloud_firestore: 6.6.0` はいずれも pub.dev の最新安定版と一致（2026-07-06確認）。本ケースは「共通プロパティを持つ2つの独立した値」であり、sealed union のswitch網羅チェックの恩恵が薄いため、`abstract interface class` + 独立 `@freezed` クラスの方が既存のVOパターンおよびRepository interface（`abstract interface class`）の規約と一貫する。

- **選択肢の比較**:

  | 選択肢 | メリット | デメリット |
  |--------|----------|------------|
  | A: `abstract interface class AggregationPeriod` + 独立した2つの `@freezed` クラスが `implements`（**推奨**） | 既存VO記法・Repository interface規約（`abstract interface class`）と一貫。freezedのmixin制約を素直に回避。将来period種別が増えても影響小 | 各クラスに `begin`/`end` の実装を書くボイラープレートが多少増える |
  | B: `@freezed sealed class` 1つに2つのfactory constructor | switch式で網羅的分岐が書ける。1ファイル完結 | 本要件は「begin/endを取り出して渡す」だけで種別分岐がほぼ不要なため恩恵が薄い。「独立した値オブジェクト」という要件文言とも性質が異なる |
  | C: 単純な `abstract class` 継承 | extends/implements双方可能で柔軟 | 既存Repository interfaceは軒並み `abstract interface class` であり規約から逸脱 |
  | D: 抽象を設けずbegin/endを直接引数に取る | 実装が最も簡単 | requirements.md セクション8で「共通する抽象を設ける」ことが決定済みのため不採用 |

- **制約・注意点**:
  - `begin < end` の誓約は、計算済みの begin/end を渡す公開ファクトリ内の通常の `assert` 文で表現する（freezedの `@Assert` はfactory引数の検証にのみ使えるため。`BudgetAmountVo.sum` と同様、privateファクトリ `_create` に生成コードを閉じ込める二段構え）。`build_runner` 生成コード（`copyWith` 等）との整合は設計フェーズで実機確認が必要。
  - `CustomCyclePeriod` のファクトリは2種類必要: ①「N年M月度」を直接指定（前月16日〜当月16日未満）②基準日から所属月度を求める `containing(DateTime date)`（1〜15日なら当月度、16日〜末日なら翌月度。AC-006/007に対応）。前後移動（AC-009, AC-011）には `shift(int delta)` 相当のメソッドが必要。
  - うるう年・月日数差（AC-011）は、境界が「16日固定」のため Dart の `DateTime` コンストラクタの月オーバーフロー自動繰り上げだけで正しく処理される。
  - `fetchMonthly` のシグネチャ変更は、Repository interface 3種・実装5クラス・ダッシュボードViewModel（プロダクションコードの呼び出しはここのみ: `lib/v2/presentation/pages/dashboard/view_model.dart:47,52`）・テスト7ファイル（約48箇所）に波及する。

- **既存コードの棚卸し結果**:
  - Repository インターフェース（`fetchMonthly(DateTime)` を持つもの）:
    - `lib/v2/domain/repositories/expense_repository.dart:16`
    - `lib/v2/domain/repositories/income_repository.dart:16`
    - `lib/v2/domain/repositories/transfer_repository.dart:16`（振替はNon-goalsだがメソッドは存在）
  - Repository 実装（すべて Service の `fetchByDate(uid, date.year, date.month)` 系を呼ぶ）:
    - `lib/v2/data/repositories/firestore/personal_expense_repository.dart:22-26`
    - `lib/v2/data/repositories/firestore/personal_income_repository.dart:22-26`
    - `lib/v2/data/repositories/firestore/transfer_repository.dart:25-29`
    - `lib/v2/data/repositories/firestore/shared_expense_repository.dart:31-36`（`PrivateProfileService` で sharedNoteRef 解決後に呼ぶ）
    - `lib/v2/data/repositories/firestore/shared_income_repository.dart:31-36`
  - Service層: 全4サービス（`personal_expense_record_service.dart:19-59`、`personal_income_record_service.dart:19-59`、`personal_transfer_record_service.dart:19-59`、`shared_record_service.dart:16-51,59-94`）の `fetchByDate(uid, year, [month, day])` が完全に同一パターンで、内部で `firstDay`/`lastDay`（begin/end相当）を計算して半開区間クエリを発行している。
  - レガシー側の先行実装: `lib/feature/repository/record_repository.dart:32-36`（begin/end指定、半開区間をdoc commentで明記）、`lib/data/firebase/firebase_expense_record_repository.dart:224-248`（`assert(begin.isBefore(end))` 付き実装、income/transfer側も同一パターン）、`lib/feature/budget_analyzer/budget_analyzer_interactor.dart:16-21`（カテゴリ別クライアント集計の現行実装）。
  - 日付ユーティリティ: `lib/util/extension/date_time.dart:1-7`（`nextMonth()`, `toFirstDayOfMonth()`）。「16日固定」ロジックは未存在。
  - freezed VOパターン: 全VOが `@freezed abstract class XxxVo with _$XxxVo` の単一プロパティパターン（例: `record_date.dart:6-11`, `budget_amount.dart:6-18`）。誓約テストは `throwsAssertionError` で検証（`test/v2/domain/models/vo/budget_amount_test.dart`）。
  - `fetchMonthly` 呼び出し箇所: プロダクションコードはダッシュボードViewModel（`view_model.dart:47,52`）のみ。テストは7ファイル（`test/v2/data/repositories/firestore/` 配下5ファイル、`test/v2/presentation/pages/dashboard/` 配下2ファイル）。
  - タイムゾーン: レコード書き込みは `toFirestoreJson()`（`lib/v2/data/models/expense_record_model.dart:59-70`）でローカル `DateTime` をそのまま渡し、cloud_firestore が絶対時刻（epochマイクロ秒）に変換。日付入力は `showDatePicker`（時刻00:00のローカルDateTime）。`.toUtc()`/`.toLocal()`/timezoneパッケージの明示使用はゼロ件で、全面的に端末ローカル時刻で一貫。

- **推奨設計の詳細**（コードスケッチ。実装時に `build_runner` で生成コードとの整合を確認すること）:

  ```dart
  // lib/v2/domain/models/vo/aggregation_period.dart

  /// 集計対象期間を表す抽象。
  ///
  /// begin（含む）から end（含まない）までの半開区間 [begin, end) を表現する。
  /// 暦月期間・カスタム期間（月度）はいずれもこのインターフェースを実装する。
  abstract interface class AggregationPeriod {
    /// 期間の開始日時（含む）
    DateTime get begin;

    /// 期間の終了日時（含まない）
    DateTime get end;
  }
  ```

  ```dart
  // lib/v2/domain/models/vo/calendar_month_period.dart
  /// 暦月期間（当月1日 00:00:00 から翌月1日 00:00:00 未満）
  @freezed
  abstract class CalendarMonthPeriod
      with _$CalendarMonthPeriod
      implements AggregationPeriod {
    const factory CalendarMonthPeriod._create({
      required DateTime begin,
      required DateTime end,
    }) = _CalendarMonthPeriod;

    const CalendarMonthPeriod._();

    /// [year]年[month]月の暦月期間を作成する
    factory CalendarMonthPeriod(int year, int month) {
      final begin = DateTime(year, month);
      final end = DateTime(year, month + 1);
      assert(begin.isBefore(end));
      return CalendarMonthPeriod._create(begin: begin, end: end);
    }

    /// [date]が属する暦月の期間を作成する
    factory CalendarMonthPeriod.containing(DateTime date) =>
        CalendarMonthPeriod(date.year, date.month);
  }
  ```

  ```dart
  // lib/v2/domain/models/vo/custom_cycle_period.dart
  /// カスタム期間（月度）: 前月16日 00:00:00 から当月16日 00:00:00 未満まで。
  /// 「N月度」の N は end 側の月（例: 6/16〜7/16未満 = 「7月度」）。
  @freezed
  abstract class CustomCyclePeriod
      with _$CustomCyclePeriod
      implements AggregationPeriod {
    const factory CustomCyclePeriod._create({
      required DateTime begin,
      required DateTime end,
      required int cycleYear,
      required int cycleMonth,
    }) = _CustomCyclePeriod;

    const CustomCyclePeriod._();

    /// [cycleYear]年[cycleMonth]月度（前月16日〜当月16日未満）を作成する
    factory CustomCyclePeriod(int cycleYear, int cycleMonth) {
      final end = DateTime(cycleYear, cycleMonth, 16);
      final begin = DateTime(cycleYear, cycleMonth - 1, 16);
      assert(begin.isBefore(end));
      return CustomCyclePeriod._create(
        begin: begin, end: end, cycleYear: cycleYear, cycleMonth: cycleMonth);
    }

    /// [date]が属する月度を作成する（1〜15日なら当月度、16日〜末日なら翌月度）
    factory CustomCyclePeriod.containing(DateTime date) {
      final belongsToNextMonth = date.day >= 16;
      final cycleDate = belongsToNextMonth
          ? DateTime(date.year, date.month + 1)
          : DateTime(date.year, date.month);
      return CustomCyclePeriod(cycleDate.year, cycleDate.month);
    }

    /// [delta]期間分だけ前後にずらした月度を返す（負値で過去、正値で未来）
    CustomCyclePeriod shift(int delta) =>
        CustomCyclePeriod(cycleYear, cycleMonth + delta);
  }
  ```

  ```dart
  // Repository インターフェースの一般化案（例: expense_repository.dart）
  abstract interface class ExpenseRepository {
    /// 指定された期間の支出データを取得する
    ///
    /// [period.begin]（含む）から[period.end]（含まない）の半開区間で絞り込む。
    Future<Either<Exception, List<ExpenseVo>>> fetchByPeriod(AggregationPeriod period);
    // add / delete は変更なし
  }

  // Service層の一般化案: where('date', isGreaterThanOrEqualTo: period.begin,
  //                             isLessThan: period.end) に置き換えるのみ

  // 既存の暦月呼び出しの移行例（dashboard/view_model.dart:47,52 相当）
  final period = CalendarMonthPeriod.containing(date);
  final incomeResult = await _incomeRepository.fetchByPeriod(period);
  ```

### TQ-002: 予算タブの期間送りUIの実現方法

- **問い**: 予算タブ（BudgetViewerPage）に「暦月⇔カスタム期間（月度）」の切替UIと期間送り（前後移動・未来移動不可）UIをどう実装するか。`_DateLabelWidget` の再利用可否、レガシー拡張 vs v2作り直しの判断を含む。

- **結論**: **レガシー構造のまま最小限の変更で期間送り・期間切替を追加する（選択肢A）を推奨**。`_DateLabelWidget` はprivateクラスで直接再利用不可のため、ラベル・前後コールバック・無効判定を引数化した期間ナビゲーションWidgetを新設する。切替UIは Material 3 の `SegmentedButton<T>`（2択）を採用する。

- **根拠**:
  - requirements.md の制約（新規画面・タブの追加はしない、既存予算タブの拡張）に直接合致し、`BudgetViewerPage` の `_setFuture()`（`budget_viewer_page.dart:56-68`）は既に `_date` から begin/end を計算して `RetrieveBudgetStateUseCase` に渡す構造のため、「期間」をstateとして持たせる改修は自然な延長。
  - カレンダー画面に「未来月に進めない」判定＋年月送りUIの実装例（`isCurrentMonth`/`addMonths`、`lib/presentation/util/date.dart`）が既にあり、意味論を月度に拡張して転用できる。
  - v2作り直しは get_it→Provider の付け替え、UseCase→Repository移行、既存型のVO/Entity置き換えまで波及し、「純粋にUI実装の論点」というTQ-002のスコープを大きく超える。後方互換（AC-008）のリグレッションリスクも増える。

- **選択肢の比較**:

  構造の選択:

  | 選択肢 | メリット | デメリット |
  |--------|----------|------------|
  | A: レガシー拡張（`_PageContentsState` に期間state・切替UIを追加）（**推奨**） | 変更範囲が小さい（既存のbegin/end渡し構造をそのまま利用）。`RetrieveBudgetStateUseCase` との親和性が高い。「既存タブの拡張」制約に直接合致 | レガシーパターン（`FutureBuilder`+`get_it`）に新機能を積み増すことになり、v2規約との不整合がこの画面だけ継続。将来v2化する際の二度手間 |
  | B: v2作り直し（`lib/v2/presentation/pages/budget/` に page/view_model/widgets を新設） | v2規約に完全準拠。`AsyncCommand` による状態管理とテストパターン（mockito+golden）がダッシュボードと統一 | UseCase→Repository移行・DI付け替え・型の置き換えが必要でTQ-002のスコープを大きく超過。画面丸ごと作り直しによるAC-008のリグレッションリスク |

  切替UIの選択:

  | 選択肢 | メリット | デメリット |
  |--------|----------|------------|
  | `SegmentedButton<T>`（2セグメント）（**推奨**） | Material 3ネイティブ、`ToggleButtons` の公式後継。名前付き2択の表現に最適。Flutter 3.7で導入済み・本プロジェクト（Flutter 3.44、useMaterial3デフォルトtrue）で利用可 | 3択以上に増えると横幅が窮屈（今回は2択のみで問題なし） |
  | `TabBar`（サブタブ） | スワイプ操作に馴染みやすい | ボトムナビゲーションのタブと概念が重複しネストタブで分かりにくい。日付送りUIとの共存スペース確保が難しい |
  | `Switch`/`ToggleButtons` | 実装が最軽量 | `ToggleButtons` はM3で `SegmentedButton` への移行が公式推奨。`Switch` はON/OFFの意味合いが強く名前付き選択に不向き |

- **制約・注意点**:
  - AC-006/007により、切替直後は暦月表示中に保持していた年月をそのまま変換するのではなく、常に「今日基準」で今日が属する月度を再計算して位置合わせする。
  - 既存の `isCurrentMonth(year, month)`/`addMonths(year, month, delta)` は暦月専用シグネチャのため月度にはそのまま使えない。月度側の「前後移動」「未来移動不可」判定は新設が必要（期間抽象のファクトリ/メソッドに集約するのが自然）。
  - `RetrieveBudgetStateUseCase` は `String uid` を直接受け取り、個人/共有の切り替えは呼び出し側（`context.read<UserInfo>().repoId(sop)`）で解決済み。期間種別が増えてもこの依存関係は変更不要（AC-012は既存機構で満たせる）。

- **既存コードの棚卸し結果**:
  - `lib/presentation/budget_viewer/budget_viewer_page.dart`: `BudgetViewerPage`（1-24行、StatelessWidget、`SelectedNoteState` をwatch）→ `_PageContentsState`（39-108行）。`_date = DateTime.now()` 固定（42行）で期間ナビゲーションなし。`_setFuture()`（56-68行）で `begin = DateTime(_date.year, _date.month)`, `end = begin.nextMonth()` を計算し `sl<RetrieveBudgetStateUseCase>()`（get_it、61行）を呼ぶ。`_BudgetListItem`（113-152行）はカテゴリごとの消化状況バー表示で今回の変更とは独立。
  - `lib/presentation/monthly_record_viewer/monthly_record_viewer_page.dart`: `_DateLabelWidget`（65-104行）は**privateクラス**のため他ファイルからimport不可。再利用には共通Widget化（public化して `lib/presentation/common_widget/` へ切り出し）または引数化した新規Widgetの書き起こしが必要。未来月移動不可は `disableRightArrow: isCurrentMonth(_year, _month)`（46行）。
  - `lib/presentation/util/date.dart:1-12`: `isCurrentMonth`（`DateUtils.isSameMonth` ラッパー）、`addMonths`（`DateUtils.addMonthsToMonthDate` ラッパー）。いずれもpublicだが暦月専用。
  - `lib/presentation/main_page/page.dart`: 予算タブはボトムナビゲーション6タブの末尾（インデックス5）。予算タブ内部だけの拡張なら main_page への影響なし。
  - 共通Widget置き場: `lib/presentation/common_widget/`（loading, failure等5ファイル）に日付送りWidgetは存在しない。v2側（`lib/v2/presentation/widgets/`）にも同種なし。
  - テストの現状: `test/presentation/budget_viewer/` は**存在しない**（予算タブのテストはゼロ）。`integration_test/budget_feature_test.dart` は空のTODOスタブ。v2ダッシュボードのテスト（`test/v2/presentation/pages/dashboard/page_test.dart`, `view_model_test.dart`, `widgets/budget_graph_test.dart`）が mockito `@GenerateNiceMocks` + golden テスト（`test-util/golden_helper.dart` の `testGoldens`）のパターン参考例になる。

- **推奨設計の詳細**（スケッチ）:

  ```
  BudgetViewerPage (変更なし)
   └ _PageContents (StatefulWidget)
       └ _PageContentsState
           - PeriodMode _mode = PeriodMode.calendar;  // enum { calendar, custom }
           - 期間state（TQ-001の期間抽象を利用）
           - initState: 今日が属する暦月で初期化
           - _setFuture(): 期間の begin/end を UseCase に渡す（現行のbegin/end計算を期間オブジェクトに委譲）
           - build:
               Column(
                 _PeriodModeSwitch(   // 新規: SegmentedButton<PeriodMode>。
                                      // 切替時は常に「今日が属する期間」で再計算（AC-006/007）
                 _PeriodNavigator(    // 新規: ラベル「7月度（6/16〜7/15）」等＋前後矢印。
                                      // 未来側は無効化（AC-010）
                 Expanded(FutureBuilder(...))  // 既存の一覧表示は維持（AC-008）
               )
  ```

  - `_PeriodModeSwitch` / `_PeriodNavigator` は budget_viewer 配下のprivate Widgetで要件を満たせる。カレンダー画面との共通化（`lib/presentation/common_widget/` への切り出し）は本機能のスコープ外の判断でよい。
  - 期間表示ラベルはAC-006/007の「対象期間（開始日・終了日）の明示」要件を満たすため「7月度（6/16〜7/15）」形式とする。

## 発見された追加制約

design / implement フェーズに影響する事項:

1. **予算タブのテストはゼロからの新設**: `test/presentation/budget_viewer/` は存在せず、`integration_test/budget_feature_test.dart` は空のTODOスタブ。style_guide.md の規約（Widgetテスト必須、IntegrationテストはUser Story形式で画面ごとに1件以上）に従い、既存資産の流用なしで新規作成する前提で工数を見積もる必要がある。
2. **`_DateLabelWidget` の直接再利用は不可能**: privateクラスのため、期間ナビゲーションWidgetは新規に書き起こす（または共通Widget化の抽出を行う）前提で設計する。
3. **期間抽象の責務範囲の整合（TQ-001×TQ-002の統合点)**: TQ-001の推奨は `AggregationPeriod` を begin/end のみの最小抽象とし、期間送りは実装クラス側のメソッド（`shift` 等）に持たせる案。一方TQ-002のUIスケッチは期間オブジェクトにラベル生成・前後移動・現在判定を期待している。設計フェーズで「最小抽象＋モードごとにプレゼンテーション層で分岐」か「抽象にナビゲーション責務も持たせる」かを確定する必要がある（ラベル文字列の生成はUI関心事のためプレゼンテーション層に置くのが規約上は自然）。
4. **v2一般化の適用範囲**: 予算タブをレガシー拡張（選択肢A）とする場合、レガシー側の `RecordRepository.retrieveRecordsOf` は既に begin/end を受け取るため、本機能の動作だけなら v2 の `fetchMonthly` 一般化は必須ではない。ただし requirements.md セクション8で「既存メソッドの一般化」が決定済みのため、v2側の一般化（影響: interface 3種・実装5クラス・ダッシュボードViewModel・テスト7ファイル）をどの範囲まで本機能と同時に実施するかを設計フェーズで確定する。
5. **shared側のTransfer Repository実装は存在しない**: 振替はNon-goalsのため実害はないが、`TransferRepository.fetchMonthly` を一般化対象に含めるか（含めない場合はインターフェースに暦月固定メソッドが残る）は設計判断が必要。
6. **Service の `fetchByDate` は年のみ/年月/年月日の3パターンをサポート**: `AggregationPeriod` 化で「年のみ」「日のみ」のユースケースが要件上消えるが、プロダクションコードからの直接呼び出し有無（Repository経由以外）の最終確認grepを設計フェーズで行い、完全置き換えか併存かを決める。
7. **`CustomCyclePeriod` の年またぎ正規化**: 「1月度」の生成で `DateTime(year, month - 1)` の月オーバーフロー自動繰り上げに依存するため実害はないが、`cycleYear`/`cycleMonth` を画面表示に使う場合は正規化したgetterを設けることを推奨。

## 参考資料

- 環境実測値（2026-07-06確認）: Flutter 3.44.4（stable）/ Dart 3.12.2、`freezed 3.2.5`（pub.dev最新安定版と一致）、`freezed_annotation 3.1.0`、`cloud_firestore 6.6.0`（最新と一致）、`dartz 0.10.1`、`build_runner 2.15.0`
- [freezed | pub.dev](https://pub.dev/packages/freezed)（最新版・sealed class記法の確認）
- [cloud_firestore | pub.dev](https://pub.dev/packages/cloud_firestore) / [Query class API](https://pub.dev/documentation/cloud_firestore/latest/cloud_firestore/Query-class.html)（範囲クエリ `isGreaterThanOrEqualTo`/`isLessThan` が現行の推奨方法であることを確認）
- [freezed discussions #939](https://github.com/rrousselGit/freezed/discussions/939)（sealed class / union型の移行ガイダンス）
- [SegmentedButton class - Flutter API](https://api.flutter.dev/flutter/material/SegmentedButton-class.html)（`ToggleButtons` の公式後継、2〜5択向けであることを確認）
- [ThemeData.useMaterial3 - Flutter API](https://api.flutter.dev/flutter/material/ThemeData/useMaterial3.html) / [Material 3 default化のbreaking change告知](https://docs.flutter.dev/release/breaking-changes/material-3-default)（Flutter 3.16以降 useMaterial3 デフォルトtrue。本プロジェクトの `lib/main.dart:162` は未指定のためM3が適用される）
- Timestamp変換の実体確認: `cloud_firestore_platform_interface 6.4.0` の `lib/src/timestamp.dart`（`Timestamp.fromDate` はepochマイクロ秒の絶対時刻を保存、`toDate()` は端末ローカルで復元）

## 変更履歴

- 2026-07-07: 冒頭に方針転換の追記を追加（共通抽象・期間VO・v2一般化を不採用とする人間判断。requirements.md セクション8と同期）
- 2026-07-06: 初版作成（TQ-001/TQ-002の並列調査結果を統合）

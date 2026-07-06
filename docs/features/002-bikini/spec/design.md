# 設計ドキュメント

対象: bikini（仮称）カスタム期間（16日〜翌月15日サイクル）カテゴリ別支出確認
入力: [requirements.md](./requirements.md) / [research-report.md](./research-report.md)

本ドキュメントは詳細設計書ではなく、実装とテストが正しく行われるための**制約と判断の記録**である。

## 1. AC→テスト戦略マッピング

テストレイヤーの定義: unit = 単一モジュールのロジック（`flutter test`）、widget = 予算タブWidgetの振る舞い（`flutter test`、UseCase等はテストダブル）、integration = Firebaseエミュレータを使った画面結合（`integration_test/`）。

| AC-ID  | AC概要 | テストレイヤー | テスト対象のIF | 備考 |
|--------|--------|----------------|----------------|------|
| AC-001 | カスタム期間の支出と予算消化状況の表示（正常系） | unit + widget + integration | 月度計算モジュール（begin/end算出）／予算タブWidget（表示）／画面全体（emulator） | integrationは本ACを代表シナリオとするUser Story形式1本に集約 |
| AC-002 | 期間境界外レコードの除外（6/15・7/16は7月度に含まれない） | unit + integration | 月度計算モジュール（境界の半開区間）／Firestoreクエリ結合（emulatorに境界日レコードをseed） | クエリ自体は既存の `retrieveRecordsOf` （半開区間実装済み）。unitで境界値、integrationで実クエリを保証 |
| AC-003 | 期間内レコード0件で各カテゴリ0円（境界条件） | unit + widget | `RetrieveBudgetStateInteractor`（レコード0件でも全カテゴリを返す）／予算タブWidget（0円表示） | interactorの既存挙動の確認テストを含む（既存テストの有無を実装時に確認し、なければ追加） |
| AC-004 | データ取得失敗時のエラー表示（異常系） | widget | 予算タブWidget（UseCaseがLeftを返すケース） | 既存のエラー表示分岐を踏襲 |
| AC-005 | レコードを持たないカテゴリも0円で一覧表示（境界条件) | unit + widget | AC-003と同じIF（一部カテゴリのみレコードなしのケース） | |
| AC-006 | 今日が月の前半（1〜15日）→切替で当月度を表示 | unit + widget | 月度計算モジュール（今日が属する月度の判定）／予算タブWidget（切替操作、注入した「今日」で検証） | **「今日」の注入が必須**（セクション3参照） |
| AC-007 | 今日が月の後半（16日〜末日）→切替で翌月度を表示 | unit + widget | AC-006と同じIF（後半日付のケース） | 同上 |
| AC-008 | 暦月表示の後方互換（従来と同一の集計・表示） | widget + integration | 予算タブWidget（暦月モードのgolden）／画面全体 | 予算タブの既存テストはゼロのため、goldenベースラインは本機能実装の**前**に現行UIで作成し、実装後に暦月モードが同一であることを確認する |
| AC-009 | 前の期間（月度）へ移動できる | unit + widget | 月度計算モジュール（1つ前の月度の算出）／予算タブWidget（前矢印タップで表示期間・集計入力が変わる） | |
| AC-010 | 未来の期間へは移動できない | unit + widget | 月度計算モジュール（現在月度の判定）／予算タブWidget（次矢印の無効化） | カレンダー画面の `disableRightArrow` と同じUXパターン |
| AC-011 | 月の日数差・うるう年をまたぐ期間移動が正しい | unit | 月度計算モジュール（パラメタライズドテスト: 2月度/3月度、年またぎ（1月度）、うるう年） | 純粋ロジックのためunitのみで十分に保証可能 |
| AC-012 | 共有ノートでも機能する | widget + integration | 予算タブWidget（`SelectedNoteState` に応じたUseCase入力の検証）／画面全体（emulatorの共有ノートseed） | ノート切替は既存機構（`UserInfo.repoId(sop)`）のため変更なし。回帰確認が主目的 |

テスト名は規約に従う: unit/widget は「〈前提〉のとき、〈期待値〉であること」、integration は User Story 形式（例: 「ユーザーは16日〜翌月15日サイクルでカテゴリ別支出と予算を確認できるので、給与サイクルに合わせた家計管理ができる」）。

## 2. 技術選定

### 実装構造: レガシー予算タブの拡張

- **採用**: `lib/presentation/budget_viewer/budget_viewer_page.dart` の `_PageContentsState` に期間モード・期間stateを追加する最小限の拡張 — requirements.md の制約（新規画面・タブなし）に合致し、begin/end を渡す既存構造の自然な延長のため
- **不採用**: v2パターン（page + view_model + AsyncCommand）への作り直し — UseCase→Repository移行・DI付け替えが本機能のスコープを大きく超え、AC-008（後方互換）のリグレッションリスクが増えるため
- **制約**: レガシーパターン（`FutureBuilder` + get_it）が当画面で継続する。将来のv2化は本機能のスコープ外として別途扱う

### データ取得: 既存のbegin/end指定機構をそのまま利用

- **採用**: `RetrieveBudgetStateUseCase`（`RetrieveBudgetStateInput.begin/end`）→ `RecordRepository.retrieveRecordsOf(repoId, begin, end)` の既存経路。データ層・UseCase層の変更なし — 半開区間（begin含む/end含まない）が実装・文書化済みのため
- **不採用**: v2 `fetchMonthly` / Service `fetchByDate` の一般化、期間の共通抽象（`AggregationPeriod`）・期間VO — 期間を多態的に扱うコードが実装経路に存在しないため（2026-07-07 方針転換、requirements.md セクション8）
- **制約**: 本機能でv2のRepository/Service/ダッシュボードには一切手を入れない

### 集計方式: クライアント集計

- **採用**: 既存の `RetrieveBudgetStateInteractor` によるカテゴリ別クライアント集計をそのまま利用 — 変更が不要で、NFR-001（既存と同等の性能）を自明に満たすため
- **不採用**: Firestore集計クエリ（sum aggregation） — 現行実装からの乗り換えメリットがなく、決定済み制約（requirements.md）にも反するため

### 月度計算ロジックの置き場所と形（TQ-001の決着）

- **採用**: `lib/presentation/util/` 配下の新規ファイル（例: `custom_cycle.dart`）に、**イミュータブルな小クラス**（フィールド: 月度の年・月。メソッド/getter: `begin`・`end`・前後の月度・現在月度判定。ファクトリ: 「基準日が属する月度」）として集約する — 既存の暦月ユーティリティ（`lib/presentation/util/date.dart` の `isCurrentMonth`/`addMonths`）と同じ層・同じ利用者（presentation）であり、前後移動や境界計算が値として自然に表現でき、unitテストが書きやすいため
- **不採用**: freezed VO化（`lib/domain/models/vo/`配置） — レガシー画面専用のロジックにv2のドメイン規約を持ち込むと配置が不整合になる。純関数の寄せ集め — 「同じ月度」を表す値の受け渡し（stateとして保持、前後移動）が煩雑になるため
- **制約**:
  - このクラスは **`DateTime.now()` を内部で呼ばない**。「今日」は必ず引数で受け取る（AC-006/007/010のテスト制御のため）
  - 境界は半開区間で表現する: `begin` = 前月16日 00:00:00（含む）、`end` = 当月16日 00:00:00（含まない）。すべて端末ローカル時刻（research-report.md で既存データとの整合を確認済み)
  - 年またぎ・うるう年は `DateTime(year, month + delta, 16)` の自動繰り上げに委ねる。画面表示に使う年月は正規化された値を公開する（内部表現に month=0 や 13 を漏らさない）
  - 誓約: `assert(begin.isBefore(end))` をコンストラクタで保証する
  - ラベル文字列（「7月度（6/16〜7/15）」等）の生成はUI関心事のため、このクラスではなくWidget側（またはFormatter）に置く

### 期間切替UI: SegmentedButton

- **採用**: Material 3 の `SegmentedButton<T>`（「暦月」「月度」の2セグメント） — `ToggleButtons` の公式後継で、名前付き2択の表現に最適。Flutter 3.44・useMaterial3デフォルトtrueで利用可（research-report.md で確認済み）
- **不採用**: `TabBar`（ボトムナビゲーションとネストして分かりにくい）、`Switch`/`ToggleButtons`（名前付き選択に不向き／M3で移行推奨）
- **制約**: 切替時は保持中の表示期間を引き継がず、常に「今日が属する期間」で再計算する（AC-006/007）

### 期間ナビゲーションWidget: 新設

- **採用**: ラベル・前後コールバック・次ボタン無効フラグを引数に取る新規Widget（budget_viewer 配下のprivateで可）を書き起こす — カレンダー画面の `_DateLabelWidget` はprivateで直接再利用不可のため
- **不採用**: `_DateLabelWidget` の共通Widget化（public化して切り出し） — カレンダー画面への変更が後方互換リスクを増やす。共通化は両画面の月度対応が必要になった時点で改めて検討する

## 3. 構造的制約

### テスタビリティのための設計判断

1. **現在時刻の注入**: `_PageContents`（または後継のState）は `DateTime.now()` を直接呼ばず、コンストラクタで注入可能な時刻供給源（例: `DateTime Function() now`、デフォルト `DateTime.now`）を使う。月度計算クラス・暦月計算はすべて「基準日」を引数で受け取る純粋APIとする。AC-006/007/010 のwidgetテストは固定日付を注入して検証する
2. **UseCaseの注入可能化**: 現行の `sl<RetrieveBudgetStateUseCase>()`（get_it直呼び、`budget_viewer_page.dart:61`）を、Widgetのコンストラクタ引数（デフォルトはslから解決）に変更する。widgetテストでget_itのグローバル状態に依存せずテストダブルを渡せるようにするため
3. **月度計算の独立モジュール化**: 月度ロジックをWidget内に書かず、`lib/presentation/util/custom_cycle.dart`（仮）に分離する。AC-002/006/007/009/010/011 の大半をunitテストで担保し、widgetテストを表示・操作の検証に限定するため
4. **UIの状態は期間モード＋表示中期間の2つに限定**: 集計結果はこれまで通り `Future` として保持（既存の `FutureBuilder` 構造を維持）し、モード・期間の変更時に `_setFuture()` を再実行する既存パターンを踏襲する
5. **goldenベースラインの事前作成**: AC-008（後方互換）を検証可能にするため、実装前に現行予算タブのgoldenテスト（暦月表示）を新設してベースラインを確定し、実装後も暦月モードで同一goldenが通ることを確認する

### モック/スタブ境界

| 境界 | テスト時の代替手段 |
|------|--------------------|
| `RetrieveBudgetStateUseCase` | mockito によるテストダブル（widgetテスト。`@GenerateNiceMocks` パターンは `test/v2/presentation/pages/dashboard/` を参考） |
| Firestore / Firebase Auth | Firebaseエミュレータ（integrationテスト。既存の `integration_test/run.sh` の仕組みを利用） |
| 現在時刻（今日） | 注入した固定 `DateTime`（unit/widgetテスト） |
| `SelectedNoteState` / `UserInfo` | Provider 経由で供給するテストダブル（widgetテスト） |
| get_it（`sl`） | 使用しない（構造的制約2により、テストではコンストラクタ注入で代替） |

### テストデータの戦略

- **unit（月度計算）**: パラメタライズに近い形で境界ケースを列挙する — 7月度の begin=6/16 00:00 / end=7/16 00:00、1月度（年またぎ: 前年12/16〜1/16）、3月度（うるう年: 2/16〜3/16、2024年と2025年）、containing判定（15日と16日、1日と末日）
- **widget**: モックUseCaseが返す `RetrieveBudgetStateOutput` を直接組み立てる（カテゴリ3件・0円カテゴリ含む／0件／Left（例外）の3パターンを基本セットとする）
- **integration**: エミュレータに境界日レコードをseedする — 6/15・6/16・7/15・7/16 の支出レコード（各異なるカテゴリ）を投入し、7月度表示で 6/16・7/15 のみが集計されることをUser Storyの中で確認する。共有ノート用にペアユーザーのseedも用意する（AC-012）
- **テスト配置**: unit → `test/presentation/util/`、widget → `test/presentation/budget_viewer/`（新設）、integration → `integration_test/budget_feature_test.dart`（既存の空スタブを実装）

## 変更履歴

- 2026-07-07: 初版作成。TQ-001の残課題（月度計算ロジックの置き場所と形）を「presentation/util 配下のイミュータブル小クラス」として決着

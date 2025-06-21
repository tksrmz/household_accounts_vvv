# 大規模リファクタリング計画: Legacy → V2 アーキテクチャ移行

## 概要

このドキュメントは、`lib/v2/`以外のレガシーアーキテクチャを`lib/v2/`のモダンなClean Architectureパターンに統一するための詳細な実行計画を定義します。

## 現状分析

### レガシーアーキテクチャの問題点

- **過度な抽象化**: Use Case + Interactorパターンで39ファイルが基本的なCRUD操作を実装
- **複雑なDI**: get_itサービスロケーターによる依存関係の複雑化
- **混在する状態管理**: ChangeNotifier、カスタム状態クラス、手動セレクターの混合
- **古いパターン**: Equatableエンティティ vs モダンなfreezed

### V2アーキテクチャの利点

- **Commandパターン**: ViewModel → Repository直接呼び出しと実行状態管理
- **Provider DI**: Flutter標準の依存性注入
- **統一されたfreezedモデル**: 現代的で不変なデータ構造
- **簡潔なエラーハンドリング**: Either → Exception境界変換

## フェーズ別実行計画

### フェーズ1: ドメインモデル統一 (Phase 1)

**目的**: 値オブジェクトとエンティティをV2パターンに移行

**タスクグループ1A: 値オブジェクト移行** (並列実行可能)

- [x] Task 1.1: `lib/vo/budget_amount.dart` → `lib/v2/domain/models/vo/budget_amount.dart`
- [x] Task 1.2: `lib/vo/budget_spent.dart` → `lib/v2/domain/models/vo/budget_spent.dart`
- [x] Task 1.3: レガシーvo削除確認とインポート更新

**タスクグループ1B: エンティティ移行** (1Aに依存)

- [x] Task 1.4: `lib/entity/category.dart` → V2 CategoryVoパターンに変換
- [x] Task 1.5: `lib/entity/property.dart` → V2 PropertyVoパターンに変換  
- [x] Task 1.6: `lib/entity/record.dart` → V2 RecordVoパターンに変換

**依存関係**: なし（独立して実行可能）
**推定工数**: 2-3日
**リスク**: 低（直接的なマッピング）

---

### フェーズ2: データレイヤー統一 (Phase 2)

**目的**: Repository実装をV2パターンに移行

**タスクグループ2A: Repository実装移行** (Phase 1完了後)

- [x] Task 2.1: `lib/data/firebase/*_repository.dart` → `lib/v2/data/repositories/`
  - Either<Exception, T>パターン適用
  - FirestoreServiceレイヤー分離
- [x] Task 2.2: Firebaseモデル → V2 Serviceパターン変換
- [x] Task 2.3: Repository interface調整 (必要に応じて)

**依存関係**: Phase 1完了必須
**推定工数**: 4-5日  
**リスク**: 中（Firebaseインテグレーション）

---

### フェーズ3: ビジネスロジック簡素化 (Phase 3)

**目的**: Use Case/Interactor (39ファイル) → Commandパターン移行

**タスクグループ3A: Commandクラス作成** (Phase 2完了後)

- [ ] Task 3.1: カテゴリ管理用Commands作成
  - AddCategoryCommand, UpdateCategoryCommand, DeleteCategoryCommand
- [ ] Task 3.2: プロパティ管理用Commands作成  
  - AddPropertyCommand, UpdatePropertyCommand, DeletePropertyCommand
- [ ] Task 3.3: レコード管理用Commands作成
  - AddRecordCommand, DeleteRecordCommand
- [ ] Task 3.4: 予算分析用Command作成
  - BudgetAnalysisCommand

**タスクグループ3B: Use Case削除** (3A完了後)

- [ ] Task 3.5: `lib/feature/` 全体削除
- [ ] Task 3.6: `lib/util/service_locator/` 削除

**依存関係**: Phase 2完了必須
**推定工数**: 5-6日
**リスク**: 中（ロジック統合の複雑性）

---

### フェーズ4: プレゼンテーション層移行 (Phase 4)

**目的**: レガシーページをV2パターンに移行

**タスクグループ4A: ViewModel作成** (Phase 3完了後、並列実行可能)

- [ ] Task 4.1: CategoryViewModel + CategoryPage (income/expense)
- [ ] Task 4.2: PropertyViewModel + PropertyPage  
- [ ] Task 4.3: RecordRegisterViewModel + RecordRegisterPage
- [ ] Task 4.4: BudgetViewModel + BudgetPage
- [ ] Task 4.5: RecordViewerViewModel + RecordViewerPages (daily/monthly)

**タスクグループ4B: 共通Widget移行** (4Aと並列実行可能)

- [ ] Task 4.6: `lib/presentation/common_widget/` → `lib/v2/presentation/widgets/`
- [ ] Task 4.7: 日付ユーティリティなど共通機能移行

**依存関係**: Phase 3完了必須
**推定工数**: 8-10日
**リスク**: 高（UI状態管理の複雑性）

---

### フェーズ5: DI・ナビゲーション統合 (Phase 5)

**目的**: メインナビゲーションとProvider DI統合

**タスクグループ5A: Provider設定** (Phase 4完了後)

- [ ] Task 5.1: `main.dart`でのProvider設定統合
- [ ] Task 5.2: RepositorySelector → ProxyProviderパターン変換
- [ ] Task 5.3: AuthGate統合確認

**タスクグループ5B: ナビゲーション更新** (5Aと並列実行可能)

- [ ] Task 5.4: MainPageの drawer/app_bar V2統合
- [ ] Task 5.5: ルーティング確認・修正

**依存関係**: Phase 4完了必須  
**推定工数**: 3-4日
**リスク**: 中（Provider設定の複雑性）

---

### フェーズ6: レガシーコード削除・テスト (Phase 6)

**目的**: 最終クリーンアップとテスト整備

**タスクグループ6A: レガシー削除** (Phase 5完了後)

- [ ] Task 6.1: `lib/presentation/` レガシーページ削除
- [ ] Task 6.2: `lib/util/` 不要ファイル削除  
- [ ] Task 6.3: `lib/entity/`, `lib/data/`, `lib/feature/` 削除
- [ ] Task 6.4: 未使用インポート・依存関係クリーンアップ

**タスクグループ6B: テスト追加** (6Aと並列実行可能)  

- [ ] Task 6.5: 移行したViewModel単体テスト
- [ ] Task 6.6: Repository統合テスト
- [ ] Task 6.7: Widget/Integration テスト追加

**依存関係**: Phase 5完了必須
**推定工数**: 4-5日  
**リスク**: 低（V2パターン踏襲）

## 並列実行マトリックス

| フェーズ | タスクグループ | 並列実行可能 | 依存関係 |
|---------|---------------|-------------|----------|
| Phase 1 | 1A (VO移行) | ✅ | なし |
| Phase 1 | 1B (Entity移行) | ❌ | 1A完了後 |
| Phase 2 | 2A (Repository移行) | ❌ | Phase 1完了後 |
| Phase 3 | 3A (Command作成) | ✅ | Phase 2完了後 |
| Phase 3 | 3B (UseCase削除) | ❌ | 3A完了後 |
| Phase 4 | 4A (ViewModel作成) | ✅ (各機能間) | Phase 3完了後 |
| Phase 4 | 4B (共通Widget) | ✅ | Phase 3完了後 |
| Phase 5 | 5A (Provider設定) | ❌ | Phase 4完了後 |
| Phase 5 | 5B (ナビゲーション) | ✅ | 5Aと並列可能 |
| Phase 6 | 6A (レガシー削除) | ❌ | Phase 5完了後 |
| Phase 6 | 6B (テスト追加) | ✅ | 6Aと並列可能 |

## リスク分析と軽減策

### 高リスク要素

1. **プレゼンテーション層移行** (Phase 4)
   - **リスク**: UI状態管理の複雑性、既存機能の破壊
   - **軽減策**: 段階的移行、既存ページを残したまま新V2ページ作成→テスト→切り替え

2. **Repository統合** (Phase 2)  
   - **リスク**: Firebase連携の破綻、データ不整合
   - **軽減策**: 統合テスト強化、エミュレーター環境での十分な検証

### 中リスク要素

1. **Use Case削除** (Phase 3)
   - **リスク**: ビジネスロジックの欠落
   - **軽減策**: Command実装完了確認後の段階的削除

2. **Provider DI設定** (Phase 5)
   - **リスク**: 依存関係解決の失敗
   - **軽減策**: 小規模テストでのProvider動作確認

## 成功指標

### 技術指標

- [ ] レガシーディレクトリ(`lib/presentation/`, `lib/feature/`, `lib/entity/`, `lib/data/`)の完全削除
- [ ] V2アーキテクチャパターンの100%適用
- [ ] テストカバレッジの向上（最低でも現状維持）
- [ ] ビルド時間・実行時間の性能維持または向上

### 品質指標  

- [ ] 全機能の動作確認完了
- [ ] 新規機能開発での迷いの解消（統一パターン）
- [ ] コードレビュー効率の向上
- [ ] ドキュメント（style_guide.md）の完全準拠

## 推定タイムライン

| フェーズ | 工数 | 並列作業考慮後 | 累積 |
|---------|------|---------------|------|
| Phase 1 | 2-3日 | 2-3日 | 2-3日 |
| Phase 2 | 4-5日 | 4-5日 | 6-8日 |  
| Phase 3 | 5-6日 | 5-6日 | 11-14日 |
| Phase 4 | 8-10日 | 6-8日 (並列化) | 17-22日 |
| Phase 5 | 3-4日 | 3-4日 | 20-26日 |
| Phase 6 | 4-5日 | 3-4日 (並列化) | 23-30日 |

**総合推定期間**: 23-30日 (約1ヶ月)

## 次のステップ

1. **プロジェクト承認**: このプランの技術レビューと承認
2. **環境準備**: ブランチ戦略の確定（`feature/v2-migration`等）
3. **Phase 1開始**: ドメインモデル移行から段階的実行
4. **定期レビュー**: 各フェーズ完了時の進捗確認とリスク評価

---

このプランは、依存関係を重視した段階的なアプローチにより、リスクを最小化しながら確実にV2アーキテクチャへの移行を実現します。

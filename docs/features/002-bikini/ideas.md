# bikini（仮称）: カスタム期間（前月16日〜今月15日）でのカテゴリ別支出確認

## ユーザーからの要望（原文）

> 月単位（1日〜末日）での収支だけでなく、前月16日から今月15日での収支も確認できるようにして欲しい。カテゴリごとに

### ユーザーによる訂正（2026-07-06）

> これ「収支」って言っちゃったんですけれど、実際は「支出」が見れたらOKです

→ 本機能のスコープは**支出のみ**。収入カテゴリ別の集計表示は対象外。

## 補足コンテキスト（現状調査より）

- 現在、収支の集計期間は暦月（1日〜末日）に固定されている。
  - v2アーキテクチャのRepositoryインターフェース（`lib/v2/domain/repositories/expense_repository.dart` 等）は `fetchMonthly(DateTime date)` で暦月固定。
  - レガシー側の予算ビューア（`lib/presentation/budget_viewer/budget_viewer_page.dart`）は内部的に `begin`/`end` の期間指定（`RetrieveBudgetStateUseCase`）でカテゴリ別集計を行っているが、UIからは暦月しか指定できない。
- カテゴリはFirestoreの `incomeCategories` / `expenseCategories` として管理され、個人ノート（personalNotes）と共有ノート（sharedNotes）の両方に存在する。
- 画面としては、ダッシュボード（v2）、カレンダー形式の月次レコードビューア、予算ビューア（カテゴリ別・支出のみ）などが存在する。

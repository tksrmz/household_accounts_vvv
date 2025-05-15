# 画面仕様

## 画面名

このプロジェクトにおいて、この画面は`設定画面`と呼称されます。

## 仕様詳細

### AppBar

- タイトルとして`設定`が表示される

### Body

Bodyの状態遷移図は以下のとおりです。

```mermaid
stateDiagram-v2
    [*] --> Loading
    Loading --> Failed: ローディング失敗
    Loading --> Succeeded: ローディング成功
    Failed --> [*]: 画面を出る
    Succeeded --> [*]: 画面を出る
```

各状態で表示されるものは以下のとおりです。

|状態|表示されるもの|
|-|-|
|Loading|ローディングアイコン|
|Failed|エラーメッセージ|
|Succeeded|下記のBody Contents|

#### Body Contents

##### ユーザー名

編集可能なユーザー名が表示されます。

ユーザー名が取る状態は以下のとおりです。

```mermaid
stateDiagram-v2
    [*] --> Display
    Display --> Editing: ユーザー名にフォーカス
    Editing --> Editing: 有効なユーザー名が入力された
    Editing --> ValidationError: ユーザー名が20文字を超えたか、ユーザー名が0文字になった
    ValidationError --> Editing: ユーザー名が1文字以上、20文字以下になった
    Editing --> Saving: 保存ボタン押下
    Saving --> SavingError: 保存失敗
    SavingError --> Display
    Saving --> Display: 保存完了
```

各状態で表示されるものは以下のとおりです。

|状態|表示されるもの|
|-|-|
|Display|編集可能な状態のユーザー名|
|Editing|編集中のユーザー名と、押下可能な保存ボタン|
|ValidationError|編集中のユーザー名と、押下不可能な保存ボタンと、`ユーザー名は最低1文字、最大20文字にしてください`というエラーメッセージ|
|Saving|編集不可能な状態のユーザー名|
|SavingError|編集可能な状態のユーザー名と、`ユーザー名の保存に失敗しました`というスナックバー|

なお、`Display`のときに表示されるユーザー名は遷移元によって以下のようになります。

|遷移元|表示されるユーザー名|
|-|-|
|初期状態|現在のユーザー名|
|Saving|編集後のユーザー名|
|SavingError|編集前のユーザー名|

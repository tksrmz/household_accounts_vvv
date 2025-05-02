# tests/presentation/pagesテストの方針

このフォルダのテストは、ページが正常に表示されることを確認するものである。
確認はゴールデンテストにより行う。

ページのテストケースは状態遷移テストとして作成する。

各ページで使用しているWidgetがある場合、個別でそれらのWidgetのテストを行う。
確認観点は上記と同じである。
ただし、そのWidgetの状態が十分に少ない場合はページのテストで行うこともある。

このフォルダに配置されているテストはFlutter Docsの[Widget Test](https://docs.flutter.dev/cookbook/testing/widget)である。

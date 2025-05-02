# tests/presentation/pagesテストの方針

このフォルダのテストは、ページが正常に表示されることを確認するものである。
そのために、ページが持つそれぞれの状態に対して以下2つの観点でのテストを行う。

1. 文言が正しく表示されていることを`expect(find.text("hoge"), findsOneWidget)`などで確認する。
    1. 可能な限り、`find.ByType(widget.class)`によるテストは避ける。
2. デザインが正しく表示されていることをゴールデンテストで確認する。
    1. ゴールデンテストは3種類のデバイスサイズで行う。

ページのテストケースは状態遷移テストとして作成する。

各ページで使用しているWidgetがある場合、個別でそれらのWidgetのテストを行う。
確認観点は上記と同じである。
ただし、そのWidgetの状態が十分に少ない場合はページのテストで行うこともある。

このフォルダに配置されているテストはFlutter Docsの[Widget Test](https://docs.flutter.dev/cookbook/testing/widget)である。

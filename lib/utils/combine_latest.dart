import 'dart:async';

/// 3本の[Stream]の最新値を組み合わせて配信する[Stream]を返す。
///
/// RxのcombineLatestオペレーターを、追加パッケージを導入せず必要な形
/// (3本固定)だけ自前実装したもの。Repositoryのwatchメソッドが複数の
/// Firestoreコレクションを結合して1つのドメインモデルへ変換する用途を想定する。
///
/// 契約:
/// - [a] [b] [c] の3本すべてが1回以上emitするまで、出力は何もemitしない
/// - 3本すべてが揃った時点、および以降いずれかがemitするたびに、
///   そのときの最新値の組で[combine]を呼び出した結果を出力する
/// - 単一購読(single-subscription)の[Stream]を返す。ソースの購読は
///   出力の`onListen`まで開始しない
/// - ソースのいずれかがエラーをemitした場合、そのエラーを出力へ転送し、
///   そのソースの最新値を無効化する。エラーを起こしたソースが次に正常な値を
///   emitするまで、他のソースがemitしても出力しない(エラー前の古い値の組で
///   出力すると、失敗中のソースを含む結果が正常であるかのように見えてしまうため)。
///   購読は打ち切らない
/// - [combine]の呼び出しがthrowした場合も、出力のエラーとして扱う
///   (購読は維持する)
/// - [a] [b] [c] のすべてがdoneになった時点で出力をcloseする
/// - 出力側の購読がキャンセルされたら、[a] [b] [c] すべての購読を
///   キャンセルする
Stream<R> combineLatest3<A, B, C, R>(
  Stream<A> a,
  Stream<B> b,
  Stream<C> c,
  R Function(A, B, C) combine,
) {
  late final StreamController<R> controller;
  StreamSubscription<A>? subscriptionA;
  StreamSubscription<B>? subscriptionB;
  StreamSubscription<C>? subscriptionC;

  // 「未emit」の判定にnullではなくフラグを使う理由:
  // A/B/Cの型引数はnullableでも呼び出せる必要があり、`latestA == null`等の
  // 判定では「まだemitしていない」と「emit済みの値がnull」を区別できない。
  late A latestA;
  late B latestB;
  late C latestC;
  var hasA = false;
  var hasB = false;
  var hasC = false;
  var doneCount = 0;

  void emitIfReady() {
    if (!(hasA && hasB && hasC)) {
      return;
    }
    try {
      controller.add(combine(latestA, latestB, latestC));
    } catch (error, stackTrace) {
      controller.addError(error, stackTrace);
    }
  }

  void onSourceDone() {
    doneCount++;
    if (doneCount == 3) {
      controller.close();
    }
  }

  controller = StreamController<R>(
    onListen: () {
      // エラーを起こしたソースの最新値は信頼できないため無効化し、
      // そのソースが次に正常な値をemitするまで出力を止める
      subscriptionA = a.listen(
        (value) {
          latestA = value;
          hasA = true;
          emitIfReady();
        },
        onError: (Object error, StackTrace stackTrace) {
          hasA = false;
          controller.addError(error, stackTrace);
        },
        onDone: onSourceDone,
      );
      subscriptionB = b.listen(
        (value) {
          latestB = value;
          hasB = true;
          emitIfReady();
        },
        onError: (Object error, StackTrace stackTrace) {
          hasB = false;
          controller.addError(error, stackTrace);
        },
        onDone: onSourceDone,
      );
      subscriptionC = c.listen(
        (value) {
          latestC = value;
          hasC = true;
          emitIfReady();
        },
        onError: (Object error, StackTrace stackTrace) {
          hasC = false;
          controller.addError(error, stackTrace);
        },
        onDone: onSourceDone,
      );
    },
    onCancel: () => Future.wait([
      if (subscriptionA case final subscription?) subscription.cancel(),
      if (subscriptionB case final subscription?) subscription.cancel(),
      if (subscriptionC case final subscription?) subscription.cancel(),
    ]),
  );

  return controller.stream;
}

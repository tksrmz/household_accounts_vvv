import 'package:flutter/widgets.dart';

import '../common_widget/loading.dart';

typedef SuccessWidgetBuilder<T> = Widget Function(BuildContext, T);
typedef ErrorWidgetBuilder = Widget Function(BuildContext, Object);
typedef LoadingWidgetBuilder = Widget Function(BuildContext);

class FutureBuilderHelper<T> extends StatelessWidget {
  const FutureBuilderHelper({
    super.key,
    required this.snapshot,
    required this.onSuccess,
    ErrorWidgetBuilder? onError,
    LoadingWidgetBuilder? onLoading,
  }) : onError = onError ?? defaultOnError,
       onLoading = onLoading ?? defaultOnLoading;

  final SuccessWidgetBuilder<T> onSuccess;
  final ErrorWidgetBuilder onError;
  final LoadingWidgetBuilder onLoading;
  final AsyncSnapshot<T> snapshot;

  @override
  Widget build(BuildContext context) {
    final hasConnected = snapshot.connectionState == ConnectionState.done;

    if (hasConnected && snapshot.hasData) {
      return onSuccess(context, snapshot.requireData);
    }

    if (hasConnected && snapshot.hasError) {
      return onError(context, snapshot.error!);
    }

    return onLoading(context);
  }
}

Widget defaultOnError(BuildContext context, Object error) {
  return Center(child: Text(error.toString()));
}

Widget defaultOnLoading(BuildContext context) {
  return Center(child: LoadingWidget());
}

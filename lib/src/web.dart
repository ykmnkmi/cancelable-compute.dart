import 'dart:async';

import 'types.dart';

ComputeOperation<R> compute<Q, R>(ComputeCallback<Q, R> callback, Q message, {String? debugLabel}) {
  return _WebComputeOperation<R>.fromFuture(Future<R>(() => callback(message)));
}

class _WebComputeOperation<R> implements ComputeOperation<R> {
  _WebComputeOperation.fromFuture(Future<R> future)
      : completer = Completer<R>(),
        canceled = false {
    // ignore if canceled
    future.then<void>((value) {
      if (!canceled) {
        completer.complete();
      }
    }).catchError((Object error, [StackTrace? stackTrace]) {
      if (!canceled) {
        completer.completeError(error, stackTrace);
      }
    });
  }

  final Completer<R?> completer;

  bool canceled;

  @override
  bool get isCanceled {
    return canceled;
  }

  @override
  Future<R?> get value {
    return completer.future;
  }

  @override
  void cancel() {
    canceled = true;

    if (!completer.isCompleted) {
      completer.complete();
    }
  }
}

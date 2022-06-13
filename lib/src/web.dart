import 'dart:async' show Completer, FutureOr;

import 'types.dart';

ComputeOperation<R> compute<Q, R>(ComputeCallback<Q, R> callback, Q message) {
  return _Operation<Q, R>(callback, message);
}

class _Operation<Q, R> implements ComputeOperation<R> {
  _Operation(ComputeCallback<Q, R> callback, Q message)
      : completer = Completer<R?>(),
        canceled = false {
    Future<R>(() => callback(message))
        .then<void>(complete)
        .catchError(completeError);
  }

  final Completer<R?> completer;

  bool canceled;

  @override
  bool get isCanceled {
    return canceled;
  }

  bool get isCompleted {
    return completer.isCompleted;
  }

  @override
  Future<R?> get value {
    return completer.future;
  }

  @override
  void cancel([FutureOr<R?>? value]) {
    canceled = true;
    completer.complete(value);
  }

  void complete(FutureOr<R?>? data) {
    if (!canceled) {
      completer.complete(data);
    }
  }

  void completeError(Object error, [StackTrace? stackTrace]) {
    if (!canceled) {
      completer.completeError(error, stackTrace);
    }
  }
}

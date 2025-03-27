import 'dart:async' show Completer, FutureOr;

import 'package:cancelable_compute/src/types.dart';

/// {@macro compute}
ComputeOperation<R> compute<Q, R>(
  ComputeCallback<Q, R> callback,
  Q message, {
  String? debugLabel,
}) {
  return _Operation<Q, R>(callback, message);
}

final class _Operation<Q, R> implements ComputeOperation<R> {
  _Operation(ComputeCallback<Q, R> callback, Q message)
    : completer = Completer<R?>(),
      isCanceled = false {
    Future<R>(
      () => callback(message),
    ).then<void>(complete).catchError(completeError);
  }

  final Completer<R?> completer;

  @override
  bool isCanceled;

  @override
  Future<R?> get value {
    return completer.future;
  }

  @override
  void cancel([FutureOr<R?>? value]) {
    if (!(completer.isCompleted || isCanceled)) {
      isCanceled = true;
      completer.complete(value);
    }
  }

  void complete(FutureOr<R?>? data) {
    if (!(isCanceled || completer.isCompleted)) {
      completer.complete(data);
    }
  }

  void completeError(Object error, [StackTrace? stackTrace]) {
    if (!(isCanceled || completer.isCompleted)) {
      completer.completeError(error, stackTrace);
    }
  }
}

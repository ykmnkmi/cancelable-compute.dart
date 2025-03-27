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
    : _completer = Completer<R?>(),
      _isCanceled = false {
    Future<R>(
      () => callback(message),
    ).then<void>(complete).catchError(completeError);
  }

  final Completer<R?> _completer;

  bool _isCanceled;

  @override
  bool get isCanceled {
    return _isCanceled;
  }

  bool get isCompleted {
    return _completer.isCompleted;
  }

  @override
  Future<R?> get value {
    return _completer.future;
  }

  @override
  void cancel([FutureOr<R?>? value]) {
    if (!(_completer.isCompleted || _isCanceled)) {
      _isCanceled = true;
      _completer.complete(value);
    }
  }

  void complete(FutureOr<R?>? data) {
    if (!(_isCanceled || _completer.isCompleted)) {
      _completer.complete(data);
    }
  }

  void completeError(Object error, [StackTrace? stackTrace]) {
    if (!(_isCanceled || _completer.isCompleted)) {
      _completer.completeError(error, stackTrace);
    }
  }
}

import 'dart:async';

import 'types.dart';

ComputeOperation<R> compute<Q, R>(ComputeCallback<Q, R> callback, Q message) {
  return _WebComputeOperation<R>(Future<R>(() => callback(message)));
}

class _WebComputeOperation<R> implements ComputeOperation<R> {
  _WebComputeOperation(this.future) : canceled = false;

  final Future<R> future;

  bool canceled;

  @override
  bool get isCanceled {
    return canceled;
  }

  @override
  Future<R?> get value {
    return future;
  }

  @override
  void cancel() {
    canceled = true;
  }
}

import 'dart:async';

import 'types.dart';

class ComputeOperationImpl<R> implements ComputeOperation<R> {
  ComputeOperationImpl(this.finish)
      : completer = Completer<R?>(),
        canceled = false;

  final Completer<R?> completer;

  final void Function() finish;

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
  void cancel([R? value]) {
    canceled = true;
    finish();

    if (!completer.isCompleted) {
      completer.complete(value);
    }
  }

  void complete(R? data) {
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

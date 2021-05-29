import 'dart:async';
import 'dart:isolate';

import 'types.dart';

ComputeOperation<R> compute<Q, R>(ComputeCallback<Q, R> callback, Q message) {
  final resultPort = ReceivePort();
  final exitPort = ReceivePort();
  final errorPort = ReceivePort();

  var running = true;
  Isolate? runningIsolate;

  void finish() {
    if (running) {
      running = false;
      errorPort.close();
      exitPort.close();
      resultPort.close();
      runningIsolate?.kill(priority: Isolate.immediate);
    }
  }

  final operation = _IOComputeOperation<R>(finish);
  final configuration = _OperationConfiguration<Q, R>(callback, message, resultPort.sendPort);

  Isolate.spawn<_OperationConfiguration<Q, R>>(_spawn, configuration,
          onExit: exitPort.sendPort, onError: errorPort.sendPort)
      .then<void>((isolate) {
    runningIsolate = isolate;
    errorPort.listen((dynamic data) {
      assert(data is List);
      assert(data.length == 2);

      final exception = Exception(data[0]);
      final stack = StackTrace.fromString(data[1] as String);

      if (operation.isCompleted) {
        Zone.current.handleUncaughtError(exception, stack);
      } else {
        operation.completeError(exception, stack);
      }

      finish();
    });

    exitPort.listen((dynamic data) {
      if (!operation.isCompleted) {
        operation.completeError(Exception('Isolate exited without result or error.'));
      }

      finish();
    });

    resultPort.listen((dynamic data) {
      assert(data == null || data is R);

      if (!operation.isCompleted) {
        operation.complete(data as R);
      }

      finish();
    });
  });

  return operation;
}

class _IOComputeOperation<R> implements ComputeOperation<R> {
  _IOComputeOperation(this.call)
      : completer = Completer<R?>(),
        canceled = false;

  final Completer<R?> completer;

  final void Function() call;

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
  void cancel() {
    canceled = true;
    call();

    if (!completer.isCompleted) {
      completer.complete();
    }
  }

  void complete([R? data]) {
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

class _OperationConfiguration<Q, R> {
  const _OperationConfiguration(this.callback, this.message, this.resultPort);

  final ComputeCallback<Q, R> callback;

  final Q message;

  final SendPort resultPort;

  FutureOr<R> apply() {
    return callback(message);
  }
}

Future<void> _spawn<Q, R>(_OperationConfiguration<Q, R> configuration) {
  return Future<R>.sync(() => configuration.apply()).then<void>(configuration.resultPort.send);
}

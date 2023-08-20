import 'dart:async' show Completer, FutureOr;
import 'dart:isolate' show Isolate, RawReceivePort, RemoteError, SendPort;

import 'package:cancelable_compute/src/types.dart';

/// {@macro compute}
ComputeOperation<R> compute<Q, R>(ComputeCallback<Q, R> callback, Q message) {
  final port = RawReceivePort();
  Isolate? runningIsolate;

  void finish() {
    port.close();
    runningIsolate?.kill(priority: Isolate.immediate);
  }

  final operation = _Operation<R>(finish);
  final configuration = _Configuration<Q, R>(callback, message, port.sendPort);

  port.handler = (Object? message) {
    port.close();

    if (message == null) {
      throw RemoteError('Isolate exited without result or error.', '');
    }

    if (operation.isCompleted) {
      return;
    }

    final list = message as List;

    if (list case [Object remoteError, Object remoteTrace]) {
      if (remoteTrace is StackTrace) {
        operation.completeError(remoteError, remoteTrace);
      } else {
        final error = RemoteError('$remoteError', '$remoteTrace');
        operation.completeError(error, error.stackTrace);
      }
    } else {
      assert(list.length == 1);
      operation.complete(list.first as R);
    }
  };

  void onIsolate(Isolate isolate) {
    runningIsolate = isolate;
  }

  void onError(Object error, [StackTrace? stackTrace]) {
    port.close();
    operation.completeError(error, stackTrace);
  }

  Isolate.spawn<_Configuration<Q, R>>(_spawn, configuration,
          errorsAreFatal: true, onExit: port.sendPort, onError: port.sendPort)
      .then<void>(onIsolate)
      .catchError(onError);

  return operation;
}

final class _Operation<R> implements ComputeOperation<R> {
  _Operation(this._finish)
      : _completer = Completer<R?>(),
        _canceled = false;

  final Completer<R?> _completer;

  final void Function() _finish;

  bool _canceled;

  @override
  bool get isCanceled {
    return _canceled;
  }

  bool get isCompleted {
    return _completer.isCompleted;
  }

  @override
  Future<R?> get value {
    return _completer.future;
  }

  @override
  void cancel([FutureOr<R>? data]) {
    if (_canceled || _completer.isCompleted) {
      return;
    }

    _finish();
    _canceled = true;
    _completer.complete(data);
  }

  void complete(FutureOr<R>? data) {
    if (_canceled || _completer.isCompleted) {
      return;
    }

    _completer.complete(data);
  }

  void completeError(Object error, [StackTrace? stackTrace]) {
    if (_canceled || _completer.isCompleted) {
      return;
    }

    _completer.completeError(error, stackTrace);
  }
}

final class _Configuration<Q, R> {
  const _Configuration(this.callback, this.message, this.port);

  final ComputeCallback<Q, R> callback;

  final Q message;

  final SendPort port;

  FutureOr<R> apply() {
    return callback(message);
  }
}

Future<void> _spawn<Q, R>(_Configuration<Q, R> configuration) {
  void onValue(Object? value) {
    final list = List<Object?>.filled(1, value);
    Isolate.exit(configuration.port, list);
  }

  void onError(Object error, [StackTrace? stackTrace]) {
    final list = List<Object?>.filled(2, null)
      ..[0] = error
      ..[1] = stackTrace;

    Isolate.exit(configuration.port, list);
  }

  return Future<Object?>.sync(configuration.apply)
      .then<void>(onValue)
      .catchError(onError);
}

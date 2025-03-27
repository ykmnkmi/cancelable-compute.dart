import 'dart:async' show Completer, FutureOr;
import 'dart:isolate' show Isolate, ReceivePort, RemoteError, SendPort;

import 'package:cancelable_compute/src/types.dart';

/// {@macro compute}
ComputeOperation<R> compute<Q, R>(
  ComputeCallback<Q, R> callback,
  Q message, {
  String? debugLabel,
}) {
  final port = ReceivePort();
  Isolate? runningIsolate;

  void close() {
    port.close();
    runningIsolate?.kill(priority: Isolate.immediate);
  }

  final operation = _Operation<R>(close);
  final configuration = _Configuration<Q, R>(callback, message, port.sendPort);

  port.listen((Object? message) {
    port.close();

    if (message == null) {
      throw RemoteError('Isolate exited without result or error.', '');
    }

    final list = message as List;

    if (list.length == 1) {
      operation.complete(list.first as R);
    } else {
      assert(list.length == 2);

      final remoteError = list[0] as Object;
      final remoteTrace = list[1] as Object;

      if (remoteTrace is StackTrace) {
        operation.completeError(remoteError, remoteTrace);
      } else {
        final error = RemoteError('$remoteError', '$remoteTrace');
        operation.completeError(error, error.stackTrace);
      }
    }
  });

  void onIsolate(Isolate isolate) {
    runningIsolate = isolate;
  }

  void onError(Object error, [StackTrace? stackTrace]) {
    port.close();
    operation.completeError(error, stackTrace);
  }

  Isolate.spawn<_Configuration<Q, R>>(
    _spawn,
    configuration,
    errorsAreFatal: true,
    onExit: port.sendPort,
    onError: port.sendPort,
    debugName: debugLabel,
  ).then<void>(onIsolate).catchError(onError);

  return operation;
}

final class _Operation<R> implements ComputeOperation<R> {
  _Operation(this.close) : completer = Completer<R?>(), isCanceled = false;

  final Completer<R?> completer;

  final void Function() close;

  @override
  bool isCanceled;

  @override
  Future<R?> get value {
    return completer.future;
  }

  @override
  void cancel([FutureOr<R>? data]) {
    if (!(completer.isCompleted || isCanceled)) {
      close();
      isCanceled = true;
      completer.complete(data);
    }
  }

  void complete(FutureOr<R>? data) {
    if (!(isCanceled || completer.isCompleted)) {
      close();
      completer.complete(data);
    }
  }

  void completeError(Object error, [StackTrace? stackTrace]) {
    if (!(isCanceled || completer.isCompleted)) {
      close();
      completer.completeError(error, stackTrace);
    }
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

void _spawn<Q, R>(_Configuration<Q, R> configuration) {
  void onValue(Object? value) {
    final list = <Object?>[value];
    Isolate.exit(configuration.port, list);
  }

  void onError(Object error, [StackTrace? stackTrace]) {
    final list = <Object?>[error, stackTrace];
    Isolate.exit(configuration.port, list);
  }

  Future<Object?>.sync(
    configuration.apply,
  ).then<void>(onValue).catchError(onError);
}

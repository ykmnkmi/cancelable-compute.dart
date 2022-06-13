import 'dart:async' show Completer, FutureOr;
import 'dart:isolate' show Isolate, RawReceivePort, RemoteError, SendPort;

import 'package:meta/meta.dart';

import 'types.dart';

ComputeOperation<R> compute<Q, R>(ComputeCallback<Q, R> callback, Q message) {
  final completer = Completer<Object?>();
  final port = RawReceivePort();

  port.handler = (Object? message) {
    port.close();
    completer.complete(message);
  };

  Isolate? runningIsolate;

  void finish() {
    port.close();
    runningIsolate?.kill(priority: Isolate.immediate);
  }

  final operation = _Operation<R>(finish);
  final configuration = _Configuration<Q, R>(callback, message, port.sendPort);

  void onIsolate(Isolate isolate) {
    runningIsolate = isolate;

    void onDone(Object? value) {
      if (value == null) {
        throw RemoteError('Isolate exited without result or error.', '');
      }

      if (operation.isCompleted) {
        return;
      }

      assert(value is List<Object?>);
      value as List<Object?>;

      final type = value.length;
      assert(1 <= type && type <= 3);

      switch (type) {
        case 1:
          operation.complete(value[0] as R);
          break;

        case 2:
          final error = RemoteError(value[0] as String, value[1] as String);
          operation.completeError(error);
          break;

        case 3:
        default:
          assert(type == 3 && value[2] == null);
          operation.completeError(value[0] as Object, value[1] as StackTrace?);
      }
    }

    completer.future.then<void>(onDone);
  }

  void onError(Object error, [StackTrace? stackTrace]) {
    port.close();
    operation.completeError(error, stackTrace);
  }

  Isolate.spawn<_Configuration<Q, R>>(_spawn, configuration, //
          errorsAreFatal: true,
          onExit: port.sendPort,
          onError: port.sendPort)
      .then<void>(onIsolate)
      .catchError(onError);

  return operation;
}

class _Operation<R> implements ComputeOperation<R> {
  _Operation(this.finish)
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
  void cancel([FutureOr<R>? data]) {
    if (canceled) {
      return;
    }

    finish();
    canceled = true;

    if (completer.isCompleted) {
      return;
    }

    completer.complete(data);
  }

  void complete(FutureOr<R>? data) {
    if (canceled || completer.isCompleted) {
      return;
    }

    completer.complete(data);
  }

  void completeError(Object error, [StackTrace? stackTrace]) {
    if (canceled || completer.isCompleted) {
      return;
    }

    completer.completeError(error, stackTrace);
  }
}

@immutable
class _Configuration<Q, R> {
  const _Configuration(this.callback, this.message, this.port);

  final ComputeCallback<Q, R> callback;

  final Q message;

  final SendPort port;

  FutureOr<R> apply() {
    return callback(message);
  }
}

Future<void> _spawn<Q, R>(_Configuration<Q, R> configuration) {
  void onValue(R value) {
    final list = List<R>.filled(1, value);
    Isolate.exit(configuration.port, list);
  }

  void onError(Object error, [StackTrace? stackTrace]) {
    final list = List<Object?>.filled(3, null)
      ..[0] = error
      ..[1] = stackTrace;

    Isolate.exit(configuration.port, list);
  }

  return Future<R>.sync(configuration.apply)
      .then<void>(onValue)
      .catchError(onError);
}

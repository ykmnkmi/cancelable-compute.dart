import 'dart:async' show FutureOr;

typedef ComputeCallback<Q, R> = FutureOr<R> Function(Q message);

typedef Compute = ComputeOperation<R> Function<Q, R>(ComputeCallback<Q, R> callback, Q message, {String? debugLabel});

abstract class ComputeOperation<R> {
  bool get isCanceled;

  Future<R?> get value;

  void cancel();
}

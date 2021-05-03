import 'dart:async' show FutureOr;

/// Signature for the callback passed to [compute].
typedef ComputeCallback<Q, R> = FutureOr<R> Function(Q message);

/// [compute] signature.
typedef Compute = ComputeOperation<R> Function<Q, R>(ComputeCallback<Q, R> callback, Q message);

/// [compute] cancellable operation.
abstract class ComputeOperation<R> {
  bool get isCanceled;

  Future<R?> get value;

  void cancel();
}

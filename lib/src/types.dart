import 'dart:async' show FutureOr;

import 'package:cancelable_compute/cancelable_compute.dart';

/// Signature for the callback passed to [compute].
typedef ComputeCallback<Q, R> = FutureOr<R> Function(Q message);

/// [compute] function signature.
typedef Compute = ComputeOperation<R> Function<Q, R>(
    ComputeCallback<Q, R> callback, Q message);

/// [compute] cancellable operation interface.
abstract interface class ComputeOperation<R> {
  bool get isCanceled;

  Future<R?> get value;

  void cancel([FutureOr<R>? data]);
}

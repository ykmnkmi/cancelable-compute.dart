import 'dart:async' show FutureOr;

import 'package:cancelable_compute/cancelable_compute.dart';

/// Callback for [compute].
typedef ComputeCallback<Q, R> = FutureOr<R> Function(Q message);

/// [compute] function signature.
typedef Compute =
    ComputeOperation<R> Function<Q, R>(
      ComputeCallback<Q, R> callback,
      Q message,
    );

/// Cancellable [compute] operation.
abstract interface class ComputeOperation<R> {
  /// Whether the operation has been canceled.
  bool get isCanceled;

  /// The result of the computation.
  ///
  /// Returns `null` or the provided `data` if canceled.
  Future<R?> get value;

  /// Cancels the operation, optionally providing a result.
  ///
  /// If [data] is provided, it will be returned by the `value` future.
  void cancel([FutureOr<R>? data]);
}

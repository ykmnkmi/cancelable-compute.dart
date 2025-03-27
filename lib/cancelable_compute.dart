/// @docImport 'dart:isolate';
library;

import 'package:cancelable_compute/src/io.dart'
    if (dart.library.js_interop) 'package:cancelable_compute/src/js.dart'
    as implementation;
import 'package:cancelable_compute/src/types.dart';

export 'package:cancelable_compute/src/types.dart';

/// {@template compute}
/// Asynchronously runs the given [callback] with the provided [message] in the
/// background and completes with the result.
///
/// ```dart
/// Future<void> main() async {
///   var operation = compute(fib, 255);
///
///   void onTap() {
///     operation.cancel(-1);
///   }
///
///   final result = await operation.value;
///   print(result);
/// }
/// ```
///
/// On web platforms this will run [callback] on the current eventloop.
/// On native platforms this will run [callback] in a separate isolate.
///
/// The `callback`, the `message` given to it as well as the result have to be
/// objects that can be sent across isolates (as they may be transitively copied
/// if needed). The majority of objects can be sent across isolates.
///
/// See [SendPort.send] for more information about exceptions as well as a note
/// of warning about sending closures, which can capture more state than needed.
///
/// The `debugLabel` is used as name for the isolate that executes `callback`.
/// {@endtemplate}
ComputeOperation<R> compute<Q, R>(
  ComputeCallback<Q, R> callback,
  Q message, {
  String? debugLabel,
}) {
  return implementation.compute<Q, R>(
    callback,
    message,
    debugLabel: debugLabel,
  );
}

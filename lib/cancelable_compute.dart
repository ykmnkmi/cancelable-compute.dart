import 'package:cancelable_compute/src/io.dart'
    if (dart.library.js) 'package:cancelable_compute/src/js.dart'
    as implementation;
import 'package:cancelable_compute/src/types.dart';

export 'package:cancelable_compute/src/types.dart';

/// {@template compute}
/// Runs a function with a given argument in an isolate, and returns an
/// operation that can be canceled.
/// {@endtemplate}
const Compute compute = implementation.compute;

library compute;

import 'src/io.dart' if (dart.library.html) 'src/web.dart' as implementation;
import 'src/types.dart';

export 'src/types.dart';

/// Runs a function with a given argument in isolate, and returns an operation that can be canceled.
const Compute compute = implementation.compute;

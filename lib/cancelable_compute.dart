library compute;

import 'src/io.dart' if (dart.library.html) 'src/web.dart' as implementation;
import 'src/types.dart';

/// Run callback in isolate, passing message to it, and return the value returned by callback.
const Compute compute = implementation.compute;

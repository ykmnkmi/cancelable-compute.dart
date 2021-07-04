[![pub package](https://img.shields.io/pub/v/cancelable_compute.svg)](https://pub.dev/packages/cancelable_compute)

## cancelable-compute.dart

Spawn an isolate, run callback on that isolate, passing it message, and return the value returned by callback or canceled by user.

## Usage

A simple usage example:

```dart
import 'package:cancelable_compute/cancelable_compute.dart';

Future<void> main() async {
  final operation = compute(fib, 256);
  
  void onTap() {
    operation.cancel(-1);
  }

  // ...
  
  final result = await operation.value;
  print(result!);
}
```

## Features and bugs

Please file feature requests and bugs at the [issue tracker][tracker].

[tracker]: https://github.com/ykmnkmi/cancelable-compute.dart/issues

## License

MIT

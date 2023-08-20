[![pub package](https://img.shields.io/pub/v/cancelable_compute.svg)](https://pub.dev/packages/cancelable_compute)

## cancelable-compute.dart

Flutter-based compute operation that can be canceled with either null or a specific value.

## Usage

A simple usage example:

```dart
import 'package:cancelable_compute/cancelable_compute.dart';

Future<void> main() async {
  var operation = compute(fib, 256);

  void onTap() {
    operation.cancel(-1);
  }

  final result = await operation.value;
  print(result);
}
```

## Note for Web

Canceling doesn't stop the running future.

## Features and bugs

Please file feature requests and bugs at the [issue tracker][tracker].

[tracker]: https://github.com/ykmnkmi/cancelable-compute.dart/issues

## License

MIT

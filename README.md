[![pub package](https://img.shields.io/pub/v/lints.svg)](https://pub.dev/packages/cancelable_compute)

## cancelable-compute.dart

Allows you to cancel compute operation.

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
  print(result!);
}
```

## Features and bugs

Please file feature requests and bugs at the [issue tracker][tracker].

[tracker]: https://github.com/ykmnkmi/cancelable-compute.dart/issues

## License

MIT

[![pub package](https://img.shields.io/pub/v/cancelable_compute.svg)](https://pub.dev/packages/cancelable_compute)

## cancelable-compute.dart

Flutter-based compute operation that can be canceled with either null or a specific value.

## Usage

A simple usage example:

```dart
import 'package:cancelable_compute/cancelable_compute.dart';

Future<void> main() async {
  var operation = compute(fib, 255);

  void onTap() {
    operation.cancel(-1);
  }

  final result = await operation.value;
  print(result);
}
```

## Note for Web

Canceling doesn't stop the running future. The future will continue to
execute, but the value future will resolve immediately with null (or the
provided data if cancel was called with data) instead of waiting for the
computation to finish.

```dart
import 'package:cancelable_compute/cancelable_compute.dart';

Future<void> main() async {
  var operation = compute((_) async {
    await Future<void>.delayed(Duration(seconds: 5)); // Long running task
    return 'Completed';
  }, 0);

  Future<void>.delayed(Duration(seconds: 1), () {
    operation.cancel('Canceled');
  });

  final result = await operation.value;
  print(result); // Will print "Canceled" after 1 second on web.
}
```

## Features and bugs

Please file feature requests and bugs at the [issue tracker][tracker].

[tracker]: https://github.com/ykmnkmi/cancelable-compute.dart/issues

## License

MIT

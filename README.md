## cancelable_compute.dart

Allows you to cancel compute operation.

## Usage

A simple usage example:

```dart
Future<void> main() async {
  var operation = compute(fib, 256);
  
  void onTap() {
    operation.cancel();
  }
  
  final result = await operation.value;
  print(result ?? -1);
}
```

## Features and bugs

Please file feature requests and bugs at the [issue tracker][tracker].

[tracker]: https://github.com/ykmnkmi/cancelable_compute.dart/issues

## License

MIT

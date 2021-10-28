// import 'package:cancelable_compute/cancelable_compute.dart';

import 'package:cancelable_compute/src/web.dart';

Future<void> main() async {
  final operation = compute(delayed, 5);
  Future<void>.delayed(Duration(seconds: 1), operation.cancel);
  final result = await operation.value;
  print(result ?? -1);
}

int fib(int n) {
  if (n < 2) {
    return n;
  }

  return fib(n - 2) + fib(n - 1);
}

Future<int> delayed(int seconds) {
  return Future.delayed(Duration(seconds: seconds), () => seconds);
}

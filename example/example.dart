import 'package:cancelable_compute/cancelable_compute.dart';

Future<void> main() async {
  final operation = compute(fib, 256);
  Future<void>.delayed(Duration(seconds: 1), operation.cancel);
  final result = await operation.value;
  print(result ?? -1);
}

int fib(int n) {
  print('n: $n');

  if (n < 2) {
    return n;
  }

  return fib(n - 2) + fib(n - 1);
}

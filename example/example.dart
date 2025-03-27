import 'package:cancelable_compute/cancelable_compute.dart';

Future<int> fib(int n) async {
  if (n < 2) {
    return n;
  }

  await Future<void>.delayed(Duration(milliseconds: n));

  final futures = <Future<int>>[fib(n - 2), fib(n - 1)];
  final values = await Future.wait<int>(futures);
  return values.reduce((a, b) => a + b);
}

Future<int> delayedFib(int n) async {
  return fib(n);
}

Future<void> main() async {
  final operation = compute<int, int>(delayedFib, 32);

  Future<void>.delayed(Duration(seconds: 1), () {
    operation.cancel(-1);
  });

  final result = await operation.value;
  print(result); // -1
}

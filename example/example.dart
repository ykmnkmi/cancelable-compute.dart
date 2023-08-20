import 'package:cancelable_compute/cancelable_compute.dart';

int fib(int n) {
  if (n < 2) {
    return n;
  }

  return fib(n - 2) + fib(n - 1);
}

Future<int> delayed(int n) async {
  await Future<void>.delayed(Duration(seconds: n ~/ 2));
  return fib(n);
}

Future<void> main() async {
  final operation = compute(delayed, 4);
  Future<void>.delayed(Duration(seconds: 1), operation.cancel);

  final result = await operation.value;
  print(result ?? -1);
}

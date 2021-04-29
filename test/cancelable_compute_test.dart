import 'package:cancelable_compute/cancelable_compute.dart';
import 'package:test/test.dart';

int fib(int n) {
  if (n < 2) {
    return n;
  }

  return fib(n - 2) + fib(n - 1);
}

void main() {
  test('Compute Test', () {
    expect(fib(5), equals(5));
    final operation = compute(fib, 5);
    expect(operation.value, completion(equals(5)));
  });
}

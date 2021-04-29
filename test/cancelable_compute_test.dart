import 'package:cancelable_compute/cancelable_compute.dart';
import 'package:test/test.dart';

int fib(int n) {
  if (n < 2) {
    return n;
  }

  return fib(n - 2) + fib(n - 1);
}

void main() {
  group('Cancelable Compute', () {
    test('Normal', () {
      final operation = compute(fib, 5);
      expect(operation.value, completion(equals(5)));
    });

    test('Cancel', () {
      final operation = compute(fib, 128);
      Future<void>.delayed(Duration(seconds: 1), operation.cancel);
      expect(operation.value, completion(isNull));
    }, onPlatform: {
      'browser': Skip('no Isolate'),
    });
  });
}

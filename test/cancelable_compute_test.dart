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
    test('normal', () {
      final operation = compute(fib, 5);
      expect(operation.value, completion(equals(5)));
    });

    test('normal with cancel', () {
      final operation = compute(fib, 5);
      Future<void>.delayed(Duration(seconds: 1), operation.cancel);
      expect(operation.value, completion(equals(5)));
    });

    test('cancel with null', () {
      Future<int> delay(int n) async {
        await Future<void>.delayed(Duration(seconds: n));
        return fib(n);
      }

      final operation = compute(delay, 5);
      Future<void>.delayed(Duration(seconds: 1), operation.cancel);
      expect(operation.value, completion(isNull));
    });

    test('cancel with value', () {
      Future<int> delay(int n) async {
        await Future<void>.delayed(Duration(seconds: n));
        return fib(n);
      }

      final operation = compute(delay, 5);
      Future<void>.delayed(Duration(seconds: 1), () => operation.cancel(-1));
      expect(operation.value, completion(equals(-1)));
    });
  });
}

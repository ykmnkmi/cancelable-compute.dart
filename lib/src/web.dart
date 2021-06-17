import 'operation.dart';
import 'types.dart';

ComputeOperation<R> compute<Q, R>(ComputeCallback<Q, R> callback, Q message) {
  final operation = ComputeOperationImpl<R>(() {});
  Future<R>(() => callback(message))
      .then<void>(operation.complete)
      .catchError(operation.completeError);
  return operation;
}

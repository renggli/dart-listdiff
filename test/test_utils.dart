import 'package:checks/checks.dart';
import 'package:listdiff/diff_list.dart';

/// Extension on [Subject] of [Operation] providing domain-specific checks.
extension OperationChecks<T> on Subject<Operation<T>> {
  /// Asserts that the operation is an [Insert].
  Subject<Insert<T>> get isInsert => isA<Insert<T>>();

  /// Asserts that the operation is a [Remove].
  Subject<Remove<T>> get isRemove => isA<Remove<T>>();
}

/// Extension on [Subject] of [Insert] providing domain-specific checks.
extension InsertChecks<T> on Subject<Insert<T>> {
  /// Extracts the index of insertion.
  Subject<int> get index => has((op) => op.index, 'index');

  /// Extracts the inserted value.
  Subject<T> get value => has((op) => op.value, 'value');
}

/// Extension on [Subject] of [Remove] providing domain-specific checks.
extension RemoveChecks<T> on Subject<Remove<T>> {
  /// Extracts the index of removal.
  Subject<int> get index => has((op) => op.index, 'index');
}

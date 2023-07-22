import 'dart:math';

import 'package:listdiff/diff_list.dart';
import 'package:more/collection.dart';
import 'package:test/test.dart';

final values = 'abcdefghijklmnopqrstuvwxyz'.split('');
final maxSize = values.length ~/ 2;

void expectApplication<T>(
    List<T> oldList, List<T> newList, List<Operation<T>> operations) {
  final actualList = oldList.toList();
  for (final operation in operations) {
    operation.apply(actualList);
  }
  expect(actualList, newList);
}

void swapValues<T>(List<T> list, int a, int b) {
  final temp = list[a];
  list[a] = list[b];
  list[b] = temp;
}

void main() {
  group('diff', () {
    group('identical input and output', () {
      for (var size = 0; size < maxSize; size++) {
        test('size = $size', () {
          final oldList = values.take(size).toList();
          final newList = values.take(size).toList();
          final operations = diffList(oldList, newList);
          expectApplication(oldList, newList, operations);
          expect(operations, isEmpty);
        });
      }
    });
    group('remove single element', () {
      for (var size = 1; size < maxSize; size++) {
        for (var index = 0; index < size; index++) {
          test('size = $size, index = $index', () {
            final oldList = values.take(size).toList();
            final newList = oldList.toList()..removeAt(index);
            final operations = diffList(oldList, newList);
            expectApplication(oldList, newList, operations);
            expect(operations, [Remove<String>(index)]);
          });
        }
      }
    });
    group('add single element', () {
      for (var size = 0; size < maxSize; size++) {
        for (var index = 0; index <= size; index++) {
          test('size = $size, index = $index', () {
            final oldList = values.take(size).toList();
            final newList = oldList.toList()..insert(index, '!');
            final operations = diffList(oldList, newList);
            expectApplication(oldList, newList, operations);
            expect(operations, [Insert<String>(index, '!')]);
          });
        }
      }
    });
    group('swap elements', () {
      for (var size = 2; size < maxSize; size++) {
        for (var a = 0; a < size; a++) {
          for (var b = 0; b < size; b++) {
            if (a < b) {
              test('size = $size, a = $a, b = $b', () {
                final oldList = values.take(size).toList();
                final newList = oldList.toList();
                swapValues(newList, a, b);
                final operations = diffList(oldList, newList);
                expectApplication(oldList, newList, operations);
              });
            }
          }
        }
      }
    });
    group('rotate elements', () {
      for (var size = 1; size < maxSize; size++) {
        for (var shift = 1; shift < size; shift++) {
          test('size = $size, shift = $shift or ${shift - size}', () {
            final oldList = values.take(size).toList();
            final newList = oldList.repeat().skip(shift).take(size).toList();
            final operations = diffList(oldList, newList);
            expectApplication(oldList, newList, operations);
          });
        }
      }
    });
    group('random', () {
      final random = Random(461410366);
      for (var sourceSize = 0; sourceSize < maxSize; sourceSize++) {
        for (var targetSize = 0; targetSize < maxSize; targetSize++) {
          test('sourceSize = $sourceSize, targetSize = $targetSize', () {
            final oldList =
                (values.toList()..shuffle(random)).take(sourceSize).toList();
            final newList =
                (values.toList()..shuffle(random)).take(targetSize).toList();
            final operations = diffList(oldList, newList);
            expectApplication(oldList, newList, operations);
          });
        }
      }
    });
  });
}

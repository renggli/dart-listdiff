import 'dart:collection';

import 'package:web/web.dart';

/// Extensions on [Element] to provide a list view of children.
extension ElementChildrenList on Element {
  /// Returns a [List] view of the [children] collection.
  List<Element> get childrenList => HTMLCollectionList(children);
}

/// A [List] view of an [HTMLCollection].
///
/// This list is unmodifiable.
class HTMLCollectionList with ListBase<Element> {
  /// Creates a list view of the provided collection.
  HTMLCollectionList(this._collection);

  final HTMLCollection _collection;

  @override
  int get length => _collection.length;

  @override
  set length(int newLength) => _throw();

  @override
  Element operator [](int index) => _collection.item(index)!;

  @override
  void operator []=(int index, Element value) => _throw();

  static Never _throw() =>
      throw UnsupportedError('Cannot modify an unmodifiable list');
}

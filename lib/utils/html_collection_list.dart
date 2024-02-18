import 'dart:collection';

import 'package:web/web.dart';

extension ElementChildrenList on Element {
  List<Element> get childrenList => HTMLCollectionList(children);
}

class HTMLCollectionList with ListBase<Element> {
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

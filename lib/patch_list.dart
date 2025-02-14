import 'dart:js_interop';

import 'package:web/web.dart';

import 'utils/html_collection_list.dart';

typedef GetKey<T> = String Function(T item);

String defaultGetKey<T>(T item) => item.toString();

typedef Render<T> = Element Function(T element);

Element defaultRender<T>(T item) =>
    document.createElement('div')
      ..appendChild(document.createTextNode(item.toString()));

// Based on https://github.com/livoras/list-diff
void patchList<T>(
  Element parent,
  List<T> items, {
  GetKey<T>? getKey,
  String keyAttr = 'key',
  Render<T>? render,
  bool debug = true,
}) {
  getKey ??= defaultGetKey;
  render ??= defaultRender;

  // Build a map of all the new items.
  final newItems = <String, T>{};
  final newItemKeys = <String>[];
  for (final item in items) {
    final key = getKey(item);
    if (debug) {
      if (key.isEmpty) {
        throw Exception('"$item" is missing a valid key.');
      } else if (newItems.containsKey(key)) {
        throw Exception('"$item" has a duplicated key "$key".');
      }
    }
    newItems[key] = item;
    newItemKeys.add(key);
  }

  // Build a map of all the old children.
  final oldChildren = <String, Element>{};
  for (final element in parent.childrenList.toList()) {
    final key = element.getAttribute(keyAttr) ?? '';
    if (debug) {
      if (key.isEmpty) {
        throw Exception('"$element" is missing attribute "$keyAttr".');
      } else if (oldChildren.containsKey(key)) {
        throw Exception('"$parent" has duplicated key "$key".');
      }
    }
    if (newItems.containsKey(key)) {
      oldChildren[key] = element;
    } else {
      if (debug) {
        console.log('Remove $key.'.toJS);
      }
      element.remove();
    }
  }

  // Patch the list to match the input list.
  var currentIndex = 0;
  final currentChildren = parent.childrenList;
  for (final newKey in newItemKeys) {
    if (currentIndex < currentChildren.length) {
      final currentChild = currentChildren[currentIndex];
      final currentChildKey = currentChild.getAttribute(keyAttr);
      // New key and old key are matching, skip over the element.
      if (newKey == currentChildKey) {
        currentIndex++;
      }
      // New key exist somewhere in the list, move here
      else if (oldChildren.containsKey(newKey)) {
        if (debug) {
          console.log('Move $newKey before $currentChildKey.'.toJS);
        }
        parent.insertBefore(oldChildren[newKey]!, currentChild);
        currentIndex++;
      }
      // New key does not exist yet, create and insert element.
      else {
        if (debug) {
          console.log('Create $newKey before $currentChildKey.'.toJS);
        }
        final element = render(newItems[newKey] as T);
        element.setAttribute(keyAttr, newKey);
        parent.insertBefore(element, currentChild);
        currentIndex++;
      }
    } else {
      // New key does not exist yet, append it to the end.
      if (debug) {
        console.log('Create $newKey at end.'.toJS);
      }
      final element = render(newItems[newKey] as T);
      element.setAttribute(keyAttr, newKey);
      parent.append(element);
      currentIndex++;
    }
  }

  if (debug) {
    final currentChildren = parent.childrenList.toList();
    if (newItemKeys.length != currentChildren.length) {
      throw Exception(
        'Expected ${newItemKeys.length}, but found ${currentChildren.length}.',
      );
    }
    for (var i = 0; i < newItemKeys.length; i++) {
      final childAttribute = currentChildren[i].getAttribute(keyAttr);
      if (newItemKeys[i] != childAttribute) {
        throw Exception(
          'Expected "${newItemKeys[i]}", but found "$childAttribute".',
        );
      }
    }
  }
}

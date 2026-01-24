import 'dart:js_interop';

import 'package:web/web.dart';

import 'utils/html_collection_list.dart';

/// A function that returns the key of an item.
typedef GetKey<T> = String Function(T item);

/// Returns the string representation of [item] as its key.
String defaultGetKey<T>(T item) => item.toString();

/// A function that renders an item into an [Element].
typedef Render<T> = Element Function(T element);

/// Renders [item] as a `div` element with the item's string representation as text.
Element defaultRender<T>(T item) =>
    document.createElement('div')
      ..appendChild(document.createTextNode(item.toString()));

/// Patches the [parent] element's children to match [items].
///
/// This function reconciles the current children of [parent] with the new list
/// of [items]. It uses [getKey] to identify items and [render] to create new
/// elements.
///
/// If [debug] is true, additional checks are performed to ensure keys are unique
/// and valid.
///
/// The [keyAttr] is the attribute name used to store the key on the DOM elements.
///
/// Example:
/// ```dart
/// final parent = document.getElementById('list')!;
/// final items = ['a', 'b', 'c'];
/// patchList(parent, items);
/// ```
///
/// This code is based on <https://github.com/livoras/list-diff>.
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

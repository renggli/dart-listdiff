sealed class Operation<T> {
  void apply(List<T> list);
}

class Insert<T> extends Operation<T> {
  Insert(this.index, this.value);

  final int index;
  final T value;

  @override
  void apply(List<T> list) => list.insert(index, value);

  @override
  String toString() => 'Insert($index, $value)';

  @override
  int get hashCode => Object.hash(Insert, index, value);

  @override
  bool operator ==(Object other) =>
      other is Insert && other.index == index && other.value == value;
}

class Remove<T> extends Operation<T> {
  Remove(this.index);

  final int index;

  @override
  void apply(List<T> list) => list.removeAt(index);

  @override
  String toString() => 'Remove($index)';

  @override
  int get hashCode => Object.hash(Remove, index);

  @override
  bool operator ==(Object other) => other is Remove && other.index == index;
}

// Based on https://github.com/livoras/list-diff
List<Operation<T>> diffList<T>(
  List<T> oldList,
  List<T> newList, {
  String Function(T value)? getKey,
}) {
  getKey ??= (T value) => value.hashCode.toString();

  final oldKeyIndex = getKeyIndex(oldList, getKey);
  final newKeyIndex = getKeyIndex(newList, getKey);

  // first pass to check item in old list: if it's removed or not
  final children = oldKeyIndex.keys.map((oldKey) {
    if (newKeyIndex.containsKey(oldKey)) {
      return newList[newKeyIndex[oldKey]!];
    } else {
      return null;
    }
  }).toList();

  final operations = <Operation<T>>[];
  final simulateList = children.toList();

  // remove items no longer exist
  var k = 0;
  while (k < simulateList.length) {
    if (simulateList[k] == null) {
      operations.add(Remove(k));
      simulateList.removeAt(k);
    } else {
      k++;
    }
  }

  // i is cursor pointing to a item in new list
  // j is cursor pointing to a item in simulateList
  var j = 0, i = 0;
  while (i < newList.length) {
    final item = newList[i];
    final itemKey = getKey(item);
    if (j < simulateList.length) {
      final simulateItem = simulateList[j] as T;
      final simulateItemKey = getKey(simulateItem);

      if (itemKey == simulateItemKey) {
        j++;
      } else {
        // new item, just insert it
        if (!oldKeyIndex.containsKey(itemKey)) {
          operations.add(Insert(i, item));
        } else {
          // if remove current simulateItem make item in right place
          // then just remove it
          var nextItemKey = j + 1 < simulateList.length
              ? getKey(simulateList[j + 1] as T)
              : null;
          if (nextItemKey == itemKey) {
            operations.add(Remove(i));
            simulateList.removeAt(j);
            j++;
          } else {
            // else insert item
            operations.add(Insert(i, item));
          }
        }
      }
    } else {
      operations.add(Insert(i, item));
    }
    i++;
  }

  // if j is not remove to the end, remove all the rest item
  var l = simulateList.length - j;
  while (j++ < simulateList.length) {
    l--;
    operations.add(Remove(l + i));
  }

  return operations;
}

Map<String, int> getKeyIndex<T>(List<T> list, String Function(T value) getKey) {
  final result = <String, int>{};
  for (var i = 0; i < list.length; i++) {
    result[getKey(list[i])] = i;
  }
  return result;
}

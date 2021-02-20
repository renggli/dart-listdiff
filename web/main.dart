import 'dart:html';
import 'dart:math';

import 'package:listdiff/patch_list.dart';

void main() {
  final inputElement = querySelector('#input') as InputElement;
  final randomElement = querySelector('#random') as InputElement;
  final sortElement = querySelector('#sort') as InputElement;
  final shuffleElement = querySelector('#shuffle') as InputElement;
  final listElement = querySelector('#list') as DivElement;

  final random = Random();
  final items = <String>[];

  Element render(String text) {
    final element = document.createElement('div');
    for (var i = 0; i < 10; i++) {
      final group = document.createElement('span');
      group.appendText(' ');
      for (var j = 0; j < text.length; j++) {
        final child = document.createElement('span');
        child.appendText(text[j]);
        group.append(child);
      }
      element.append(group);
    }
    return element;
  }

  void modify(String value) {
    value = value.padLeft(10, '0');
    final index = items.indexOf(value);
    if (index < 0) {
      items.add(value);
    } else {
      items.removeAt(index);
    }
  }

  void update() {
    patchList(listElement, items, render: render, debug: false);
    inputElement.value = '';
    inputElement.focus();
  }

  inputElement.onKeyPress.forEach((event) {
    if (event.keyCode == 13) {
      modify(inputElement.value ?? '');
      update();
    }
  });

  randomElement.onClick.forEach((event) {
    for (var i = 0; i < 100; i++) {
      modify('${random.nextInt(2147483647)}');
    }
    update();
  });

  sortElement.onClick.forEach((event) {
    items.sort();
    update();
  });

  shuffleElement.onClick.forEach((event) {
    items.shuffle();
    update();
  });

  inputElement.focus();
}

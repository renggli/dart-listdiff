import 'dart:html';
import 'dart:math';

import 'package:listdiff/patch_list.dart';

void main() {
  final inputElement = querySelector('#input') as InputElement;
  final randomElement = querySelector('#random') as InputElement;
  final sortElement = querySelector('#sort') as InputElement;
  final shuffleElement = querySelector('#shuffle') as InputElement;
  final debugElement = querySelector('#debug') as CheckboxInputElement;
  final listElement = querySelector('#list') as DivElement;

  final random = Random();
  final items = <String>[];

  Element render(String text) {
    final element = document.createElement('div');
    element.appendText(text);
    return element;
  }

  void modify(String value) {
    value = value.padLeft(10, ' ').substring(0, 10);
    final index = items.indexOf(value);
    if (index < 0) {
      items.add(value);
    } else {
      items.removeAt(index);
    }
  }

  void update() {
    patchList(listElement, items,
        render: render, debug: debugElement.checked ?? false);
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
    for (var i = 0; i < 25; i++) {
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

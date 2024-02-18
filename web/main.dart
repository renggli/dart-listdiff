import 'dart:math';

import 'package:listdiff/patch_list.dart';
import 'package:web/web.dart';

void main() {
  final inputElement = document.querySelector('#input') as HTMLInputElement;
  final randomElement = document.querySelector('#random') as HTMLInputElement;
  final sortElement = document.querySelector('#sort') as HTMLInputElement;
  final shuffleElement = document.querySelector('#shuffle') as HTMLInputElement;
  final debugElement = document.querySelector('#debug') as HTMLInputElement;
  final listElement = document.querySelector('#list') as HTMLDivElement;

  final random = Random();
  final items = <String>[];

  Element render(String text) {
    final element = document.createElement('div');
    element.appendChild(document.createTextNode(text));
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
    patchList(listElement, items, render: render, debug: debugElement.checked);
    inputElement.value = '';
    inputElement.focus();
  }

  inputElement.onKeyPress.forEach((event) {
    if (event.keyCode == 13) {
      modify(inputElement.value);
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
